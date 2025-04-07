-- Attiva l'estensione uuid-ossp
create extension if not exists "uuid-ossp";

-- Assicurati che il ruolo anon abbia accesso al bucket storage
grant usage on schema storage to anon, authenticated;
grant select on storage.buckets to anon, authenticated;
grant select on storage.objects to anon, authenticated;
grant insert, update, delete on storage.objects to authenticated;

-- Crea un bucket di storage per le immagini se non esiste
-- Questo permette di salvare le immagini nel bucket invece che in base64 nel database
insert into storage.buckets (id, name, public)
values ('images', 'images', true)
on conflict (id) do nothing;

-- Verifica che il bucket sia stato creato e sia pubblico
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'images' AND public = true) THEN
    UPDATE storage.buckets SET public = true WHERE id = 'images';
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Il bucket "images" non è stato creato correttamente';
    END IF;
  END IF;
END $$;

-- Crea policy di accesso al bucket images
-- Chiunque può visualizzare le immagini
drop policy if exists "Anyone can view images" on storage.objects;
create policy "Anyone can view images"
on storage.objects for select
using (bucket_id = 'images');

-- Gli utenti autenticati possono caricare immagini
drop policy if exists "Authenticated users can upload images" on storage.objects;
create policy "Authenticated users can upload images"
on storage.objects for insert
with check (bucket_id = 'images' and auth.role() = 'authenticated');

-- Gli utenti possono aggiornare o eliminare solo le loro immagini
drop policy if exists "Users can update own images" on storage.objects;
create policy "Users can update own images"
on storage.objects for update
using (bucket_id = 'images' and auth.uid() = owner);

drop policy if exists "Users can delete own images" on storage.objects;
create policy "Users can delete own images"
on storage.objects for delete
using (bucket_id = 'images' and auth.uid() = owner);

-- Funzione per validare che un campo sia un URL del bucket images
CREATE OR REPLACE FUNCTION validate_storage_url(url TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  -- Permetti NULL e verifica che sia un URL che contiene l'endpoint corretto o il percorso generico
  RETURN url IS NULL OR 
         url ~ 'https://tiylfyyfitqzwstftzpg.supabase.co/storage/v1/.*images/' OR
         url ~ '/storage/v1/.*images/';
END;
$$ LANGUAGE plpgsql;

-- Funzione per generare un percorso sicuro per il caricamento di un'immagine
CREATE OR REPLACE FUNCTION generate_storage_path(bucket_folder text, object_id uuid, filename text)
RETURNS text AS $$
DECLARE
  safe_filename text;
BEGIN
  -- Rimuovi caratteri speciali e spazi dal nome del file
  safe_filename := regexp_replace(filename, '[^a-zA-Z0-9._-]', '_', 'g');
  -- Costruisci e restituisci il percorso completo
  RETURN bucket_folder || '/' || object_id || '/' || safe_filename;
END;
$$ LANGUAGE plpgsql;

-- Funzione per estrarre l'URL di storage da un path
CREATE OR REPLACE FUNCTION get_storage_url(bucket_name text, path text)
RETURNS text AS $$
BEGIN
  -- Usa l'endpoint completo per generare URL assoluti
  RETURN 'https://tiylfyyfitqzwstftzpg.supabase.co/storage/v1/object/public/' || bucket_name || '/' || path;
END;
$$ LANGUAGE plpgsql;

-- Funzione per estrarre il path dall'URL di un'immagine
CREATE OR REPLACE FUNCTION extract_path_from_storage_url(url text)
RETURNS text AS $$
BEGIN
  -- Estrai il percorso dopo 'public/images/' considerando anche l'endpoint completo
  IF url ~ 'https://tiylfyyfitqzwstftzpg.supabase.co/storage/v1/' THEN
    RETURN regexp_replace(url, '.*public/images/', '');
  ELSE
    RETURN regexp_replace(url, '.*/public/images/', '');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL; -- In caso di errore, restituisci NULL
END;
$$ LANGUAGE plpgsql;

-- Modifica tabella profiles per garantire che profile_image sia un URL
create table IF NOT EXISTS profiles (
  id uuid references auth.users on delete cascade primary key,
  first_name text,
  last_name text,
  phone text,
  description text,
  profile_image text CHECK (validate_storage_url(profile_image)), 
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone
);

-- Invece di indicizzare direttamente la colonna, crea un indice sul suo hash MD5
-- questo risolve il problema della dimensione eccessiva dell'indice
DROP INDEX IF EXISTS idx_profiles_profile_image;
CREATE INDEX idx_profiles_profile_image_md5 ON profiles(md5(profile_image)) 
  WHERE profile_image IS NOT NULL;

-- Aggiungi un commento sulla colonna profile_image
COMMENT ON COLUMN profiles.profile_image IS 'URL pubblico dell''immagine nel bucket storage.images (es: https://xxx.supabase.co/storage/v1/object/public/images/users/{user_id}/{filename})';

-- Trigger per eliminare la vecchia immagine dal bucket quando viene aggiornata in profiles
CREATE OR REPLACE FUNCTION cleanup_old_profile_image()
RETURNS TRIGGER AS $$
DECLARE
  old_path text;
BEGIN
  -- Se c'è una nuova immagine e c'era già un'immagine precedente
  IF NEW.profile_image IS DISTINCT FROM OLD.profile_image AND OLD.profile_image IS NOT NULL THEN
    old_path := extract_path_from_storage_url(OLD.profile_image);
    
    -- Se il percorso è valido, aggiungi alla coda di pulizia
    IF old_path IS NOT NULL THEN
      INSERT INTO storage_cleanup_queue(object_path, deleted_at, status)
      VALUES ('images/' || old_path, now(), 'pending');
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Collega il trigger alla tabella profiles
DROP TRIGGER IF EXISTS profile_image_cleanup_trigger ON profiles;
CREATE TRIGGER profile_image_cleanup_trigger
BEFORE UPDATE ON profiles
FOR EACH ROW
WHEN (NEW.profile_image IS DISTINCT FROM OLD.profile_image)
EXECUTE FUNCTION cleanup_old_profile_image();

-- Elimina le policy esistenti per poterle ricreare
DROP POLICY IF EXISTS "Users can view their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;

-- Crea le policy per profiles
create policy "Users can view their own profile" 
  on profiles for select 
  using (auth.uid() = id);

create policy "Users can update their own profile" 
  on profiles for update 
  using (auth.uid() = id);

create policy "Users can insert their own profile" 
  on profiles for insert 
  with check (auth.uid() = id);

-- Modifica tabella products per garantire che image_url sia un URL
DROP TABLE IF EXISTS products CASCADE;  
create table products (
  id uuid default uuid_generate_v4() primary key,
  name text not null,
  description text,
  price decimal not null,
  image_url text CHECK (validate_storage_url(image_url)),
  user_id uuid references auth.users not null,
  metadata jsonb,
  status text default 'active',
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Usa un indice MD5 anche qui per la performance ed evitare errori di dimensione
CREATE INDEX idx_products_image_url_md5 ON products(md5(image_url))
  WHERE image_url IS NOT NULL;

-- Aggiungi un commento sulla colonna image_url
COMMENT ON COLUMN products.image_url IS 'URL pubblico dell''immagine nel bucket storage.images (es: https://xxx.supabase.co/storage/v1/object/public/images/products/{product_id}/{filename})';

-- Trigger per eliminare la vecchia immagine dal bucket quando viene aggiornata in products
CREATE OR REPLACE FUNCTION cleanup_old_product_image()
RETURNS TRIGGER AS $$
DECLARE
  old_path text;
BEGIN
  -- Se c'è una nuova immagine e c'era già un'immagine precedente
  IF NEW.image_url IS DISTINCT FROM OLD.image_url AND OLD.image_url IS NOT NULL THEN
    old_path := extract_path_from_storage_url(OLD.image_url);
    
    -- Se il percorso è valido, elimina l'oggetto
    IF old_path IS NOT NULL THEN
      -- Usa una funzione di supporto esterna o un'estensione come pg_net per chiamare l'API di Storage
      -- In alternativa, l'applicazione client dovrebbe occuparsi di eliminare i file obsoleti
      -- Qui si potrebbe registrare l'eliminazione in una tabella di manutenzione
      INSERT INTO storage_cleanup_queue(object_path, deleted_at, status)
      VALUES ('images/' || old_path, now(), 'pending');
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Collega il trigger alla tabella products
DROP TRIGGER IF EXISTS product_image_cleanup_trigger ON products;
CREATE TRIGGER product_image_cleanup_trigger
BEFORE UPDATE ON products
FOR EACH ROW
WHEN (NEW.image_url IS DISTINCT FROM OLD.image_url)
EXECUTE FUNCTION cleanup_old_product_image();

-- Trigger per aggiornare timestamp updated_at quando si modifica un prodotto
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_products_modtime
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Policies per products
DROP POLICY IF EXISTS "Anyone can view products" ON products;
create policy "Anyone can view products" on products for select using (true);

DROP POLICY IF EXISTS "Users can add their own products" ON products;
create policy "Users can add their own products" 
  on products for insert 
  with check (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own products" ON products;
create policy "Users can update their own products" 
  on products for update 
  using (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own products" ON products;
create policy "Users can delete their own products" 
  on products for delete 
  using (auth.uid() = user_id);

create table IF NOT EXISTS addresses (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users not null,
  name text not null,
  street text not null,
  number text not null,
  city text not null,
  zip_code text not null,
  country text not null,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Policies per indirizzi
DROP POLICY IF EXISTS "Users can view their own addresses" ON addresses;
DROP POLICY IF EXISTS "Users can insert their own addresses" ON addresses;
DROP POLICY IF EXISTS "Users can update their own addresses" ON addresses;
DROP POLICY IF EXISTS "Users can delete their own addresses" ON addresses;

create policy "Users can view their own addresses" on addresses for select using (auth.uid() = user_id);
create policy "Users can insert their own addresses" on addresses for insert with check (auth.uid() = user_id);
create policy "Users can update their own addresses" on addresses for update using (auth.uid() = user_id);
create policy "Users can delete their own addresses" on addresses for delete using (auth.uid() = user_id);

create table IF NOT EXISTS orders (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users not null,
  status text not null default 'processing',
  total_amount decimal not null,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

create table IF NOT EXISTS order_items (
  id uuid default uuid_generate_v4() primary key,
  order_id uuid references orders not null,
  product_id uuid references products not null,
  product_name text not null,
  quantity integer not null,
  unit_price decimal not null,
  created_at timestamp with time zone default now()
);

-- Policies per ordini
DROP POLICY IF EXISTS "Users can view their own orders" ON orders;
DROP POLICY IF EXISTS "Users can view their own order items" ON order_items;

create policy "Users can view their own orders" on orders for select using (auth.uid() = user_id);
create policy "Users can view their own order items" on order_items for select using (
  auth.uid() = (select user_id from orders where id = order_id)
);

create table IF NOT EXISTS favorites (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users not null,
  product_id uuid references products not null,
  created_at timestamp with time zone default now(),
  unique(user_id, product_id)
);

-- Policies per preferiti
DROP POLICY IF EXISTS "Users can view their own favorites" ON favorites;
DROP POLICY IF EXISTS "Users can insert their own favorites" ON favorites;
DROP POLICY IF EXISTS "Users can delete their own favorites" ON favorites;

create policy "Users can view their own favorites" on favorites for select using (auth.uid() = user_id);
create policy "Users can insert their own favorites" on favorites for insert with check (auth.uid() = user_id);
create policy "Users can delete their own favorites" on favorites for delete using (auth.uid() = user_id);

create table IF NOT EXISTS reviews (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users not null,
  product_id uuid references products not null,
  rating integer not null check (rating between 1 and 5),
  comment text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now(),
  unique(user_id, product_id)
);

-- Policies per recensioni
DROP POLICY IF EXISTS "Anyone can view reviews" ON reviews;
DROP POLICY IF EXISTS "Users can insert their own reviews" ON reviews;
DROP POLICY IF EXISTS "Users can update their own reviews" ON reviews;
DROP POLICY IF EXISTS "Users can delete their own reviews" ON reviews;

create policy "Anyone can view reviews" on reviews for select using (true);
create policy "Users can insert their own reviews" on reviews for insert with check (auth.uid() = user_id);
create policy "Users can update their own reviews" on reviews for update using (auth.uid() = user_id);
create policy "Users can delete their own reviews" on reviews for delete using (auth.uid() = user_id);

-- Crea una tabella per tenere traccia delle pulizie di storage necessarie
CREATE TABLE IF NOT EXISTS storage_cleanup_queue (
  id uuid default uuid_generate_v4() primary key,
  object_path text NOT NULL,
  deleted_at timestamp with time zone default now(),
  processed_at timestamp with time zone,
  status text default 'pending',
  error_message text
);

-- Assicurati che solo gli amministratori possano vedere questa tabella
DROP POLICY IF EXISTS "Only admins can access storage cleanup queue" ON storage_cleanup_queue;
CREATE POLICY "Only admins can access storage cleanup queue" ON storage_cleanup_queue USING (auth.role() = 'authenticated' AND EXISTS (
  SELECT 1 FROM auth.users WHERE auth.uid() = id AND raw_user_meta_data->>'is_admin' = 'true'
));
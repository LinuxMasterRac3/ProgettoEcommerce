-- Attiva l'estensione uuid-ossp
create extension if not exists "uuid-ossp";

-- Assicurati che il ruolo anon abbia accesso al bucket storage
grant usage on schema storage to anon, authenticated;
grant select on storage.buckets to anon, authenticated;
grant select on storage.objects to anon, authenticated;
grant insert, update, delete on storage.objects to authenticated;

-- Assicurati che gli utenti autenticati possano gestire i bucket (non solo crearli ma anche modificarli)
grant all privileges on storage.buckets to authenticated;

-- IMPORTANTE: Questo è fondamentale per permettere agli utenti di creare bucket
ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

-- Aggiorna tutte le policy per i bucket
DROP POLICY IF EXISTS "Allow authenticated users to create storage buckets" ON storage.buckets;
DROP POLICY IF EXISTS "Allow authenticated users to manage buckets" ON storage.buckets;

-- Policy più permissiva per la creazione di bucket
CREATE POLICY "Allow authenticated users to create buckets"
ON storage.buckets FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

-- Policy per le altre operazioni
CREATE POLICY "Allow authenticated users to manage existing buckets"
ON storage.buckets FOR ALL
USING (auth.role() = 'authenticated');

-- Crea un bucket di storage per le immagini se non esiste
-- Usa un approccio diretto con una funzione anonima per avere più controllo
DO $$
BEGIN
  -- Tenta di creare il bucket images in modo diretto
  IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'images') THEN
    INSERT INTO storage.buckets (id, name, public)
    VALUES ('images', 'images', true);
  ELSE
    -- Assicurati che il bucket sia pubblico
    UPDATE storage.buckets SET public = true WHERE id = 'images';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Error creating bucket: %', SQLERRM;
    -- Non fare fallire lo script se c'è un errore
END $$;

-- IMPORTANTE: crea una policy specifica per il bucket 'images'
DROP POLICY IF EXISTS "Allow public access to images bucket" ON storage.buckets;
CREATE POLICY "Allow public access to images bucket"
ON storage.buckets FOR SELECT
USING (id = 'images');

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
  -- Permetti solo URL del bucket images
  RETURN url IS NULL OR 
         url ~ '^https://tiylfyyfitqzwstftzpg\.supabase\.co/storage/v1/.*images/' OR
         url ~ '^/storage/v1/.*images/';
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
  -- Usa l'endpoint S3 corretto come specificato nei logs
  RETURN 'https://tiylfyyfitqzwstftzpg.supabase.co/storage/v1/s3/object/public/' || bucket_name || '/' || path;
END;
$$ LANGUAGE plpgsql;

-- Semplifica la funzione di estrazione percorso rimuovendo il base64
CREATE OR REPLACE FUNCTION extract_path_from_storage_url(url text)
RETURNS text AS $$
BEGIN
  RETURN regexp_replace(
    url,
    '^https://tiylfyyfitqzwstftzpg\.supabase\.co/storage/v1/.*/images/',
    ''
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Aggiungi una funzione per generare l'URL pubblico di un'immagine
CREATE OR REPLACE FUNCTION public_image_url(bucket_name text, path text)
RETURNS TEXT AS $$
BEGIN
  RETURN 'https://tiylfyyfitqzwstftzpg.supabase.co/storage/v1/object/public/' || bucket_name || '/' || path;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

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
CREATE INDEX IF NOT EXISTS idx_profiles_profile_image_md5 ON profiles(md5(profile_image)) 
  WHERE profile_image IS NOT NULL;

-- Aggiungi un commento sulla colonna profile_image
COMMENT ON COLUMN profiles.profile_image IS 'URL pubblico dell''immagine nel bucket storage.images (es: https://tiylfyyfitqzwstftzpg.supabase.co/storage/v1/object/public/images/{path})';

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
COMMENT ON COLUMN products.image_url IS 'URL pubblico dell''immagine nel bucket storage.images (es: https://tiylfyyfitqzwstftzpg.supabase.co/storage/v1/object/public/images/{path})';

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

-- Tabella per le chat
CREATE TABLE IF NOT EXISTS chats (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users not null,
  contact_id uuid references auth.users,
  name text not null,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Abilita RLS sulla tabella chats
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;

-- Policies per le chat
DROP POLICY IF EXISTS "Users can view their own chats" ON chats;
DROP POLICY IF EXISTS "Users can insert their own chats" ON chats;
DROP POLICY IF EXISTS "Users can update their own chats" ON chats;
DROP POLICY IF EXISTS "Users can delete their own chats" ON chats;

CREATE POLICY "Users can view their own chats" 
  ON chats FOR SELECT 
  USING (auth.uid() = user_id OR auth.uid() = contact_id);

CREATE POLICY "Users can insert their own chats" 
  ON chats FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own chats" 
  ON chats FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own chats" 
  ON chats FOR DELETE 
  USING (auth.uid() = user_id);

-- Add indexes for chats table for performance
CREATE INDEX IF NOT EXISTS idx_chats_user_id ON chats(user_id);
CREATE INDEX IF NOT EXISTS idx_chats_contact_id ON chats(contact_id);
CREATE INDEX IF NOT EXISTS idx_chats_updated_at ON chats(updated_at DESC);

-- Tabella per i messaggi
CREATE TABLE IF NOT EXISTS messages (
  id uuid default uuid_generate_v4() primary key,
  chat_id uuid references chats not null,
  user_id uuid references auth.users not null,
  text text not null,
  created_at timestamp with time zone default now(),
  read boolean default false
);

-- Abilita RLS sulla tabella messages
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Policies per i messaggi
DROP POLICY IF EXISTS "Users can view messages in their chats" ON messages;
DROP POLICY IF EXISTS "Users can insert messages in their chats" ON messages;
DROP POLICY IF EXISTS "Users can update messages they sent" ON messages;
DROP POLICY IF EXISTS "Users can delete messages they sent" ON messages;

CREATE POLICY "Users can view messages in their chats" 
  ON messages FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM chats 
      WHERE chats.id = messages.chat_id 
      AND (chats.user_id = auth.uid() OR chats.contact_id = auth.uid())
    )
  );

CREATE POLICY "Users can insert messages in their chats" 
  ON messages FOR INSERT 
  WITH CHECK (
    auth.uid() = user_id AND 
    EXISTS (
      SELECT 1 FROM chats 
      WHERE chats.id = messages.chat_id 
      AND (chats.user_id = auth.uid() OR chats.contact_id = auth.uid())
    )
  );

CREATE POLICY "Users can update messages they sent" 
  ON messages FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete messages they sent" 
  ON messages FOR DELETE 
  USING (auth.uid() = user_id);

-- Add index for messages table for performance
CREATE INDEX IF NOT EXISTS idx_messages_chat_id ON messages(chat_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);

-- Trigger per aggiornare il timestamp della chat quando viene inviato un nuovo messaggio
CREATE OR REPLACE FUNCTION update_chat_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE chats 
  SET updated_at = now() 
  WHERE id = NEW.chat_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_chat_timestamp_trigger ON messages;
CREATE TRIGGER update_chat_timestamp_trigger
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION update_chat_timestamp();

-- Tabella per i carrelli degli utenti
CREATE TABLE IF NOT EXISTS user_carts (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  product_id uuid references products on delete cascade not null,
  quantity integer not null default 1 CHECK (quantity > 0),
  added_at timestamp with time zone default now(),
  CONSTRAINT user_product_unique UNIQUE (user_id, product_id)
);

-- Create user_carts table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.user_carts (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users on delete cascade not null,
  product_id uuid references products on delete cascade not null,
  quantity integer not null default 1 CHECK (quantity > 0),
  added_at timestamp with time zone default now(),
  CONSTRAINT user_product_unique UNIQUE (user_id, product_id)
);

-- Enable RLS on the table
ALTER TABLE public.user_carts ENABLE ROW LEVEL SECURITY;

-- Create policies for user_carts
DROP POLICY IF EXISTS "Users can view their own cart items" ON user_carts;
CREATE POLICY "Users can view their own cart items"
  ON user_carts FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert items into their own cart" ON user_carts;
CREATE POLICY "Users can insert items into their own cart"
  ON user_carts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own cart items" ON user_carts;
CREATE POLICY "Users can update their own cart items"
  ON user_carts FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete items from their own cart" ON user_carts;
CREATE POLICY "Users can delete items from their own cart"
  ON user_carts FOR DELETE
  USING (auth.uid() = user_id);

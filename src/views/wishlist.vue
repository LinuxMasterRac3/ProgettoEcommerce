<template>
  <div class="page-wrapper">
    <!-- Navbar -->
    <Navbar />

    <!-- Main Content -->
    <div class="main-content">
      <div class="wishlist-container">
        <h1 class="wishlist-title">Lista dei Desideri</h1>

        <!-- Loading State -->
        <div
          v-if="isLoading"
          class="loading">
          Caricamento in corso...
        </div>

        <!-- Error State -->
        <div
          v-else-if="error"
          class="error">
          {{ error }}
        </div>

        <!-- Wishlist Items -->
        <div v-else>
          <div
            v-if="wishlistItems.length === 0"
            class="empty-wishlist">
            <p>La tua lista dei desideri è vuota.</p>
            <RouterLink
              to="/shop"
              class="continue-shopping-btn">
              Torna allo Shop
            </RouterLink>
          </div>

          <div
            v-else
            class="wishlist-grid">
            <div
              v-for="item in wishlistItems"
              :key="item.id"
              class="wishlist-card">
              <RouterLink
                :to="`/product/${item.id}`"
                class="wishlist-image-link">
                <img
                  :src="getMainImage(item)"
                  :alt="item.title"
                  class="wishlist-image"
                  @error="handleImageError($event)" />
              </RouterLink>
              <div class="wishlist-details">
                <RouterLink
                  :to="`/product/${item.id}`"
                  class="wishlist-title-link">
                  <h2 class="wishlist-item-title">{{ item.title }}</h2>
                </RouterLink>
                <p class="wishlist-item-author">
                  Autore: {{ item.metadata.author || "Sconosciuto" }}
                </p>
                <p class="wishlist-item-category">
                  Categoria: {{ item.metadata.category || "Non specificata" }}
                </p>
                <p class="wishlist-item-price">
                  Prezzo: €{{ item.price.toFixed(2) }}
                </p>
                <button
                  @click="removeFromWishlist(item.id)"
                  class="wishlist-remove-btn">
                  Rimuovi
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Footer -->
    <Footer />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { createClient } from "@supabase/supabase-js";
import { useRouter } from "vue-router";
import Navbar from "@/components/Navbar.vue";
import Footer from "@/components/footer.vue";
import { RouterLink } from "vue-router";

// Define interface for wishlist item type
interface WishlistItem {
  id: string;
  title: string;
  price: number;
  metadata: any;
  image: string;
}

// Supabase configuration
const supabaseUrl = "https://tiylfyyfitqzwstftzpg.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpeWxmeXlmaXRxendzdGZ0enBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNjYyNDcsImV4cCI6MjA1Njc0MjI0N30.CvIx_vI-KGGcFlcZy66-DIC8Itk03Olw3lzEMhnJP_c";
const supabase = createClient(supabaseUrl, supabaseKey);

// State variables
const wishlistItems = ref<WishlistItem[]>([]); // Typed array for wishlist items
const isLoading = ref(true); // Stato di caricamento
const error = ref<string | null>(null); // Messaggio di errore
const wishlist = ref<string[]>([]); // Array per memorizzare gli ID dei libri nella wishlist
const userId = ref<string | null>(null); // ID dell'utente autenticato

// Recupera l'ID dell'utente autenticato
const fetchUserId = async () => {
  const { data, error } = await supabase.auth.getUser();
  if (error) {
    console.error("Errore durante il recupero dell'utente:", error);
    return;
  }
  userId.value = data?.user?.id || null;
};

// Recupera i libri dalla wishlist
const fetchWishlist = async () => {
  isLoading.value = true;
  error.value = null;

  try {
    const savedWishlist = JSON.parse(localStorage.getItem("wishlist") || "[]");

    if (savedWishlist.length === 0) {
      wishlistItems.value = [];
      return;
    }

    const { data, error: fetchError } = await supabase
      .from("products") // Usa il nome corretto della tabella
      .select("*")
      .in("id", savedWishlist);

    if (fetchError) throw fetchError;

    wishlistItems.value = data.map((item) => ({
      id: item.id,
      title: item.title,
      price: item.price,
      metadata: item.metadata || {},
      image: item.image_url || "https://placehold.co/300x400?text=No+Image",
    }));
  } catch (err) {
    console.error("Errore durante il caricamento della wishlist:", err);
    error.value = "Errore durante il caricamento della wishlist.";
  } finally {
    isLoading.value = false;
  }
};

// Rimuovi un libro dalla wishlist
const removeFromWishlist = (id: string) => {
  wishlistItems.value = wishlistItems.value.filter((item) => item.id !== id);

  // Aggiorna la wishlist salvata in localStorage
  const savedWishlist = JSON.parse(localStorage.getItem("wishlist") || "[]");
  const updatedWishlist = savedWishlist.filter(
    (itemId: string) => itemId !== id
  );
  localStorage.setItem("wishlist", JSON.stringify(updatedWishlist));
};

// Gestione immagine di fallback
const handleImageError = (event: Event) => {
  const target = event.target as HTMLImageElement;
  target.src = "https://placehold.co/300x400?text=No+Image";
};

// Funzione per ottenere l'immagine principale
const getMainImage = (item: any) => {
  if (
    item.metadata?.additional_images &&
    item.metadata.additional_images.length > 0
  ) {
    return item.metadata.additional_images[0];
  }
  return item.image || "https://placehold.co/300x400?text=No+Image";
};

// Funzione per aggiungere/rimuovere un prodotto dai preferiti
const toggleFavorite = async (productId: string) => {
  if (!userId.value) {
    console.error("Utente non autenticato.");
    return;
  }

  try {
    // Controlla se il prodotto è già nei preferiti
    const { data: existingFavorite, error: fetchError } = await supabase
      .from("favorites")
      .select("*")
      .eq("user_id", userId.value)
      .eq("product_id", productId)
      .single();

    if (fetchError && fetchError.code !== "PGRST116") {
      // Ignora l'errore "PGRST116" (nessun record trovato)
      throw fetchError;
    }

    if (existingFavorite) {
      // Rimuovi il prodotto dai preferiti
      const { error: deleteError } = await supabase
        .from("favorites")
        .delete()
        .eq("id", existingFavorite.id);

      if (deleteError) throw deleteError;

      console.log(`Prodotto con ID ${productId} rimosso dai preferiti.`);
    } else {
      // Aggiungi il prodotto ai preferiti
      const { error: insertError } = await supabase.from("favorites").insert({
        user_id: userId.value,
        product_id: productId,
      });

      if (insertError) throw insertError;

      console.log(`Prodotto con ID ${productId} aggiunto ai preferiti.`);
    }
  } catch (err) {
    console.error("Errore durante l'aggiornamento dei preferiti:", err);
  }
};

// Recupera i dati al montaggio del componente
onMounted(async () => {
  await fetchUserId();
  const savedWishlist = localStorage.getItem("wishlist");
  if (savedWishlist) {
    wishlist.value = JSON.parse(savedWishlist);
  }
  fetchWishlist();
});
</script>

<style scoped>
.page-wrapper {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background: linear-gradient(to bottom right, #ffffff, #f8f7ff);
}

/* Add this new class */
.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.wishlist-container {
  max-width: 1200px;
  width: 100%;
  margin: 40px auto;
  padding: 20px;
  flex: 1;
}

.wishlist-title {
  font-size: 2.5rem;
  font-weight: 700;
  color: #2d2d2d;
  margin-bottom: 40px;
  text-align: center;
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
}

.wishlist-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 30px;
  padding: 20px;
}

.wishlist-card {
  background: white;
  border: none;
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.wishlist-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 30px rgba(106, 90, 205, 0.15);
}

.wishlist-image-link {
  display: block;
  position: relative;
  overflow: hidden;
  border-radius: 12px;
  margin-bottom: 15px;
}

.wishlist-image {
  width: 100%;
  height: 380px;
  object-fit: cover;
  transition: transform 0.5s ease;
}

.wishlist-card:hover .wishlist-image {
  transform: scale(1.05);
}

.wishlist-details {
  padding: 15px 0;
}

.wishlist-item-title {
  font-size: 1.2rem;
  font-weight: 600;
  color: #2d2d2d;
  margin-bottom: 10px;
  line-height: 1.4;
}

.wishlist-item-author,
.wishlist-item-category {
  color: #666;
  font-size: 0.9rem;
  margin: 8px 0;
}

.wishlist-item-price {
  font-size: 1.1rem;
  font-weight: 600;
  color: #6a5acd;
  margin: 12px 0;
}

.wishlist-remove-btn {
  width: 100%;
  padding: 12px;
  border: none;
  border-radius: 12px;
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  color: white;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-top: 15px;
}

.wishlist-remove-btn:hover {
  background: linear-gradient(45deg, #5a4cba, #4a3ca9);
  box-shadow: 0 4px 15px rgba(106, 90, 205, 0.3);
}

.empty-wishlist {
  text-align: center;
  padding: 60px 20px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
}

.empty-wishlist p {
  font-size: 1.2rem;
  color: #666;
  margin-bottom: 20px;
}

.continue-shopping-btn {
  display: inline-block;
  padding: 15px 30px;
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  color: white;
  text-decoration: none;
  border-radius: 12px;
  font-weight: 500;
  transition: all 0.3s ease;
}

.continue-shopping-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(106, 90, 205, 0.3);
}

.loading {
  text-align: center;
  padding: 40px;
  font-size: 1.2rem;
  color: #666;
}

.error {
  text-align: center;
  padding: 40px;
  color: #dc3545;
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(220, 53, 69, 0.1);
}

@media (max-width: 768px) {
  .wishlist-container {
    padding: 15px;
  }

  .wishlist-title {
    font-size: 2rem;
  }

  .wishlist-grid {
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 20px;
  }

  .wishlist-image {
    height: 320px;
  }
}
</style>

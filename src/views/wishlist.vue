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
                  :alt="item.name"
                  class="wishlist-image"
                  @error="handleImageError($event)" />
              </RouterLink>
              <div class="wishlist-details">
                <RouterLink
                  :to="`/product/${item.id}`"
                  class="wishlist-title-link">
                  <h2 class="wishlist-item-title">{{ item.name }}</h2>
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
  name: string; // Changed from title to name to match Supabase structure
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
// const wishlist = ref<string[]>([]); // This ref seems unused, can be removed if not needed
const userId = ref<string | null>(null); // ID dell'utente autenticato

// Check if user is logged in
const router = useRouter();
const isAuthenticated = ref(false);

const checkAuth = async () => {
  try {
    const { data } = await supabase.auth.getUser();
    if (data?.user) {
      userId.value = data.user.id;
      isAuthenticated.value = true;
    } else {
      isAuthenticated.value = false;
      error.value =
        "Devi effettuare il login per visualizzare la tua wishlist.";
    }
  } catch (err) {
    console.error("Errore durante il recupero dell'utente:", err);
    isAuthenticated.value = false;
    error.value = "Errore durante l'autenticazione.";
  }
};

// Recupera i libri dalla wishlist
const fetchWishlist = async () => {
  isLoading.value = true;
  error.value = null;

  if (!isAuthenticated.value || !userId.value) {
    error.value = "Devi effettuare il login per visualizzare la tua wishlist.";
    wishlistItems.value = [];
    isLoading.value = false;
    // Consider redirecting or showing a more prominent login message
    // setTimeout(() => router.push("/login"), 3000);
    return;
  }

  try {
    // Step 1: Fetch favorite product IDs from Supabase
    const { data: favoriteEntries, error: favError } = await supabase
      .from("favorites")
      .select("product_id")
      .eq("user_id", userId.value);

    if (favError) throw favError;

    const favoriteProductIds = favoriteEntries
      ? favoriteEntries.map((fav) => fav.product_id)
      : [];

    if (favoriteProductIds.length === 0) {
      wishlistItems.value = [];
      isLoading.value = false;
      return;
    }

    // Step 2: Fetch product details for these IDs
    const { data: productsData, error: productsError } = await supabase
      .from("products")
      .select("*") // Select all necessary fields
      .in("id", favoriteProductIds);

    if (productsError) throw productsError;

    if (!productsData || productsData.length === 0) {
      wishlistItems.value = [];
    } else {
      wishlistItems.value = productsData.map((item) => ({
        id: item.id,
        name: item.name || "Prodotto senza nome",
        price: parseFloat(item.price) || 0,
        metadata: item.metadata || {},
        image: getMainImage({
          metadata: item.metadata,
          image_url: item.image_url,
        }), // Use getMainImage logic
      }));
    }
  } catch (err) {
    console.error("Errore durante il caricamento della wishlist:", err);
    error.value = "Errore durante il caricamento della wishlist.";
    wishlistItems.value = [];
  } finally {
    isLoading.value = false;
  }
};

// Rimuovi un libro dalla wishlist (e da Supabase)
const removeFromWishlist = async (productId: string) => {
  // Renamed id to productId for clarity
  if (!isAuthenticated.value || !userId.value) {
    alert("Devi essere loggato per modificare i preferiti.");
    return;
  }
  try {
    // Remove from Supabase
    const { error: deleteError } = await supabase
      .from("favorites")
      .delete()
      .eq("user_id", userId.value)
      .eq("product_id", productId);

    if (deleteError) throw deleteError;

    // Update local list
    wishlistItems.value = wishlistItems.value.filter(
      (item) => item.id !== productId
    );

    // The localStorage part for "wishlist" key can be removed if Supabase is the single source of truth
    // for authenticated users' favorites.
    // console.log(`Product ${productId} removed from favorites via wishlist page.`);
  } catch (err) {
    console.error("Error removing from wishlist:", err);
    alert("Errore durante la rimozione dai preferiti.");
  }
};

// Gestione immagine di fallback
const handleImageError = (event: Event) => {
  const target = event.target as HTMLImageElement;
  target.src = "https://placehold.co/300x400?text=No+Image";
};

// Funzione per ottenere l'immagine principale
const getMainImage = (item: any) => {
  // item can be a product or a wishlist item
  if (
    item.metadata?.additional_images &&
    item.metadata.additional_images.length > 0
  ) {
    return item.metadata.additional_images[0];
  }
  // Fallback to item.image (used by wishlist item structure) or item.image_url (used by product structure)
  return (
    item.image || item.image_url || "https://placehold.co/300x400?text=No+Image"
  );
};

// Funzione per aggiungere/rimuovere un prodotto dai preferiti (used by heart icon on wishlist items)
// This function's name might be confusing if `removeFromWishlist` is also present.
// Let's assume this `toggleFavorite` is for the heart icon on the wishlist page,
// which effectively means removing it from the wishlist.
const toggleFavoriteOnWishlistPage = async (productId: string) => {
  // This function will essentially call removeFromWishlist
  await removeFromWishlist(productId);
};

// Recupera i dati al montaggio del componente
onMounted(async () => {
  await checkAuth();
  if (isAuthenticated.value) {
    await fetchWishlist();
  } else {
    // Optional: redirect to login after a delay if not authenticated
    // setTimeout(() => {
    //   router.push("/login");
    // }, 3000);
  }
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
  background: linear-gradient(
    45deg,
    #7c4dff,
    #6200ea
  ); /* Aggiornato il colore viola */
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  opacity: 0;
  animation: fadeInUp 1s ease forwards;
  transform: translateY(20px);
}

/* Aggiungi questa animazione */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
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
  color: #7c4dff; /* Aggiornato */
  margin: 12px 0;
}

.wishlist-remove-btn {
  width: 100%;
  padding: 12px;
  border: none;
  border-radius: 12px;
  background: linear-gradient(45deg, #7c4dff, #6200ea); /* Aggiornato */
  color: white;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-top: 15px;
}

.wishlist-remove-btn:hover {
  background: linear-gradient(45deg, #6200ea, #5502c7); /* Aggiornato */
  box-shadow: 0 4px 15px rgba(124, 77, 255, 0.3); /* Aggiornato */
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
  background: linear-gradient(45deg, #7c4dff, #6200ea); /* Aggiornato */
  color: white;
  text-decoration: none;
  border-radius: 12px;
  font-weight: 500;
  transition: all 0.3s ease;
}

.continue-shopping-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(124, 77, 255, 0.3); /* Aggiornato */
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

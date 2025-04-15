<template>
  <div>
    <!-- Navbar -->
    <Navbar />

    <!-- Main Content -->
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

// Supabase configuration
const supabaseUrl = "https://tiylfyyfitqzwstftzpg.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpeWxmeXlmaXRxendzdGZ0enBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNjYyNDcsImV4cCI6MjA1Njc0MjI0N30.CvIx_vI-KGGcFlcZy66-DIC8Itk03Olw3lzEMhnJP_c";
const supabase = createClient(supabaseUrl, supabaseKey);

// State variables
const wishlistItems = ref([]); // Array per memorizzare i libri nella wishlist
const isLoading = ref(true); // Stato di caricamento
const error = ref<string | null>(null); // Messaggio di errore
const wishlist = ref<string[]>([]); // Array per memorizzare gli ID dei libri nella wishlist
const userId = ref<string | null>(null); // ID dell'utente autenticato

// Recupera l'ID dell'utente autenticato
const fetchUserId = async () => {
  const { data: user, error } = await supabase.auth.getUser();
  if (error) {
    console.error("Errore durante il recupero dell'utente:", error);
    return;
  }
  userId.value = user?.id || null;
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
.wishlist-container {
  padding: 20px;
  text-align: center;
  font-family: "Roboto", Arial, sans-serif;
}

.wishlist-title {
  font-size: 24px;
  font-weight: bold;
  color: #000; /* Testo nero */
  margin-bottom: 20px;
}

.wishlist-grid {
  display: grid;
  grid-template-columns: repeat(
    auto-fill,
    minmax(220px, 1fr)
  ); /* Riquadro più piccolo */
  gap: 20px;
}

.wishlist-card {
  border: 1px solid #ccc;
  border-radius: 8px;
  padding: 10px; /* Ridotto il padding */
  background-color: #fff;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  text-align: center; /* Centra il contenuto */
  max-width: 220px; /* Riquadro più piccolo */
  margin: auto; /* Centra il riquadro */
}

.wishlist-image-link {
  display: block;
  margin-bottom: 10px;
}

.wishlist-image {
  width: 100%; /* Usa tutta la larghezza disponibile */
  max-width: 200px; /* Limita la larghezza massima */
  height: 250px; /* Altezza proporzionata */
  object-fit: cover; /* Mantiene le proporzioni */
  border-radius: 4px;
  margin: auto; /* Centra l'immagine */
}

.wishlist-details {
  font-size: 14px;
  color: #000; /* Testo nero */
  text-align: center; /* Centra il testo */
}

.wishlist-title-link {
  text-decoration: none;
  color: #000; /* Testo nero */
  font-weight: bold;
  transition: color 0.3s;
}

.wishlist-title-link:hover {
  color: #6a5acd; /* Colore viola su hover */
}

.wishlist-item-author,
.wishlist-item-category,
.wishlist-item-price {
  margin: 5px 0;
}

.wishlist-remove-btn {
  background-color: #d9534f;
  color: white;
  border: none;
  padding: 8px 12px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  margin-top: 10px;
  display: block; /* Centra il bottone */
  margin-left: auto;
  margin-right: auto;
}

.wishlist-remove-btn:hover {
  background-color: #c9302c;
}

.empty-wishlist {
  text-align: center;
  padding: 20px;
  font-size: 16px;
}

.continue-shopping-btn {
  display: inline-block;
  margin-top: 20px;
  padding: 10px 20px;
  background-color: #007bff;
  color: white;
  text-decoration: none;
  border-radius: 4px;
  font-size: 14px;
}

.continue-shopping-btn:hover {
  background-color: #0056b3;
}

.loading {
  font-size: 18px;
  color: #555;
}

.error {
  color: red;
  font-size: 18px;
}
</style>

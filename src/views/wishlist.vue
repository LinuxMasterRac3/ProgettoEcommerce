<template>
  <div>
    <!-- Navbar -->
    <Navbar />

    <!-- Main Content -->
    <div class="wishlist-container">
      <h1>Lista dei Desideri</h1>

      <!-- Loading State -->
      <div
        v-if="loading"
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
      <div
        v-else<template>
  <div>
    <!-- Navbar -->
    <Navbar />

    <!-- Main Content -->
    <div class="wishlist-container">
      <h1>Lista dei Desideri</h1>

      <!-- Loading State -->
      <div v-if="loading" class="loading">Caricamento in corso...</div>

      <!-- Error State -->
      <div v-else-if="error" class="error">{{ error }}</div>

      <!-- Wishlist Items -->
      <div v-else class="wishlist-list">
        <div v-if="wishlistItems.length === 0" class="empty-wishlist">
          <p>La tua lista dei desideri è vuota.</p>
          <RouterLink to="/shop" class="continue-shopping-btn">
            Torna allo Shop
          </RouterLink>
        </div>

        <div v-else>
          <div
            v-for="item in wishlistItems"
            :key="item.id"
            class="wishlist-item"
          >
            <img :src="item.image" :alt="item.title" class="item-image" />
            <div class="item-details">
              <h2>{{ item.title }}</h2>
              <p>Autore: {{ item.metadata.author }}</p>
              <p>Categoria: {{ item.metadata.category }}</p>
              <p>Prezzo: €{{ item.price.toFixed(2) }}</p>
              <button @click="removeFromWishlist(item.id)" class="remove-btn">
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
import Navbar from "@/components/Navbar.vue";
import Footer from "@/components/Footer.vue";
import { RouterLink } from "vue-router";

// Supabase configuration
const supabaseUrl = "https://tiylfyyfitqzwstftzpg.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpeWxmeXlmaXRxendzdGZ0enBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNjYyNDcsImV4cCI6MjA1Njc0MjI0N30.CvIx_vI-KGGcFlcZy66-DIC8Itk03Olw3lzEMhnJP_c";
const supabase = createClient(supabaseUrl, supabaseKey);

// State variables
const wishlistItems = ref([]); // Array per memorizzare i libri nella wishlist
const loading = ref(true); // Stato di caricamento
const error = ref<string | null>(null); // Messaggio di errore

// Recupera i libri dalla wishlist
const fetchWishlist = async () => {
  loading.value = true;
  error.value = null;

  try {
    const savedWishlist = JSON.parse(localStorage.getItem("wishlist") || "[]");
    if (savedWishlist.length === 0) {
      wishlistItems.value = [];
      return;
    }

    const { data, error: fetchError } = await supabase
      .from("books")
      .select("*")
      .in("id", savedWishlist);

    if (fetchError) throw fetchError;

    wishlistItems.value = data.map((item) => ({
      id: item.id,
      title: item.title,
      price: item.price,
      image: item.image_url,
      metadata: item.metadata || {},
    }));
  } catch (err) {
    console.error("Errore durante il caricamento della wishlist:", err);
    error.value = "Errore durante il caricamento della wishlist.";
  } finally {
    loading.value = false;
  }
};

// Rimuovi un libro dalla wishlist
const removeFromWishlist = (id: string) => {
  wishlistItems.value = wishlistItems.value.filter((item) => item.id !== id);

  // Aggiorna la wishlist salvata in localStorage
  const savedWishlist = JSON.parse(localStorage.getItem("wishlist") || "[]");
  const updatedWishlist = savedWishlist.filter((itemId: string) => itemId !== id);
  localStorage.setItem("wishlist", JSON.stringify(updatedWishlist));
};

// Recupera i dati al montaggio del componente
onMounted(() => {
  fetchWishlist();
});
</script>

<style scoped>
.wishlist-container {
  padding: 20px;
  text-align: center;
}

.wishlist-list {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  justify-content: center;
}

.wishlist-item {
  border: 1px solid #ccc;
  border-radius: 8px;
  padding: 15px;
  width: 200px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  text-align: left;
}

.item-image {
  width: 100%;
  height: 150px;
  object-fit: cover;
  border-radius: 4px;
}

.item-details {
  margin-top: 10px;
}

.remove-btn {
  background-color: #d9534f;
  color: white;
  border: none;
  padding: 8px 12px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.remove-btn:hover {
  background-color: #c9302c;
}

.empty-wishlist {
  text-align: center;
  padding: 20px;
}

.continue-shopping-btn {
  display: inline-block;
  margin-top: 20px;
  padding: 10px 20px;
  background-color: #007bff;
  color: white;
  text-decoration: none;
  border-radius: 4px;
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
        class="wishlist-list">
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

        <div v-else>
          <div
            v-for="item in wishlistItems"
            :key="item.id"
            class="wishlist-item">
            <img
              :src="item.image"
              :alt="item.title"
              class="item-image" />
            <div class="item-details">
              <h2>{{ item.title }}</h2>
              <p>Autore: {{ item.metadata.author }}</p>
              <p>Categoria: {{ item.metadata.category }}</p>
              <p>Prezzo: €{{ item.price.toFixed(2) }}</p>
              <button
                @click="removeFromWishlist(item.id)"
                class="remove-btn">
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
import Navbar from "@/components/Navbar.vue";
import Footer from "@/components/Footer.vue";
import { RouterLink } from "vue-router";

// Supabase configuration
const supabaseUrl = "https://tiylfyyfitqzwstftzpg.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpeWxmeXlmaXRxendzdGZ0enBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNjYyNDcsImV4cCI6MjA1Njc0MjI0N30.CvIx_vI-KGGcFlcZy66-DIC8Itk03Olw3lzEMhnJP_c";
const supabase = createClient(supabaseUrl, supabaseKey);

// State variables
const wishlistItems = ref([]); // Array per memorizzare i libri nella wishlist
const loading = ref(true); // Stato di caricamento
const error = ref<string | null>(null); // Messaggio di errore

// Recupera i libri dalla wishlist
const fetchWishlist = async () => {
  loading.value = true;
  error.value = null;

  try {
    const savedWishlist = JSON.parse(localStorage.getItem("wishlist") || "[]");
    if (savedWishlist.length === 0) {
      wishlistItems.value = [];
      return;
    }

    const { data, error: fetchError } = await supabase
      .from("books")
      .select("*")
      .in("id", savedWishlist);

    if (fetchError) throw fetchError;

    wishlistItems.value = data.map((item) => ({
      id: item.id,
      title: item.title,
      price: item.price,
      image: item.image_url,
      metadata: item.metadata || {},
    }));
  } catch (err) {
    console.error("Errore durante il caricamento della wishlist:", err);
    error.value = "Errore durante il caricamento della wishlist.";
  } finally {
    loading.value = false;
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

// Recupera i dati al montaggio del componente
onMounted(() => {
  fetchWishlist();
});
</script>

<style scoped>
.wishlist-container {
  padding: 20px;
  text-align: center;
}

.wishlist-list {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  justify-content: center;
}

.wishlist-item {
  border: 1px solid #ccc;
  border-radius: 8px;
  padding: 15px;
  width: 200px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  text-align: left;
}

.item-image {
  width: 100%;
  height: 150px;
  object-fit: cover;
  border-radius: 4px;
}

.item-details {
  margin-top: 10px;
}

.remove-btn {
  background-color: #d9534f;
  color: white;
  border: none;
  padding: 8px 12px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
}

.remove-btn:hover {
  background-color: #c9302c;
}

.empty-wishlist {
  text-align: center;
  padding: 20px;
}

.continue-shopping-btn {
  display: inline-block;
  margin-top: 20px;
  padding: 10px 20px;
  background-color: #007bff;
  color: white;
  text-decoration: none;
  border-radius: 4px;
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

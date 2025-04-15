<template>
  <div>
    <!-- Navbar -->
    <Navbar />

    <!-- Main Content -->
    <div class="allbooks-container">
      <h1>Tutti i Libri</h1>

      <!-- Loading State -->
      <div v-if="loading" class="loading">Caricamento in corso...</div>

      <!-- Error State -->
      <div v-else-if="error" class="error">{{ error }}</div>

      <!-- Books List -->
      <div v-else class="books-list">
        <div v-for="book in books" :key="book.id" class="book-card">
          <img :src="book.metadata?.additional_images?.[0]" alt="Book Image" class="book-image" />
          <div class="book-details">
            <h2>{{ book.title }}</h2>
            <p>Autore: {{ book.metadata?.author }}</p>
            <p>Categoria: {{ book.metadata?.category }}</p>
            <p>Prezzo: €{{ book.price.toFixed(2) }}</p>
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

// Supabase configuration
const supabaseUrl = "https://tiylfyyfitqzwstftzpg.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpeWxmeXlmaXRxendzdGZ0enBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNjYyNDcsImV4cCI6MjA1Njc0MjI0N30.CvIx_vI-KGGcFlcZy66-DIC8Itk03Olw3lzEMhnJP_c";
const supabase = createClient(supabaseUrl, supabaseKey);

// State variables
const books = ref([]); // Array per memorizzare i libri
const loading = ref(true); // Stato di caricamento
const error = ref<string | null>(null); // Messaggio di errore

// Fetch all books from the database
const fetchBooks = async () => {
  loading.value = true;
  error.value = null;

  try {
    const { data, error: fetchError } = await supabase.from("books").select("*");
    if (fetchError) throw fetchError;

    books.value = data.map((book) => ({
      ...book,
      metadata: book.metadata || {}, // Assicurati che i metadati siano presenti
    }));
  } catch (err) {
    console.error("Errore durante il caricamento dei libri:", err);
    error.value = "Errore durante il caricamento dei libri.";
  } finally {
    loading.value = false;
  }
};

// Fetch books when the component is mounted
onMounted(() => {
  fetchBooks();
});
</script>

<style scoped>
.allbooks-container {
  padding: 20px;
  text-align: center;
}

.books-list {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  justify-content: center;
}

.book-card {
  border: 1px solid #ccc;
  border-radius: 8px;
  padding: 15px;
  width: 200px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  text-align: left;
}

.book-image {
  width: 100%;
  height: 150px;
  object-fit: cover;
  border-radius: 4px;
}

.book-details {
  margin-top: 10px;
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
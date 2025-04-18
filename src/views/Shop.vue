<script setup lang="ts">
import { ref, onMounted } from "vue";
import { RouterLink, useRouter } from "vue-router";
import { createClient } from "@supabase/supabase-js";
import Navbar from "../components/Navbar.vue";
import Footer from "../components/footer.vue";
import { onUnmounted } from "vue";

// Slider data
const slides = ref([
  {
    image: "https://placehold.co/1200x407?text=Slide+1",
    title: "Scopri il Meglio della Lettura",
    description:
      "Esplora una vasta selezione di libri per ogni passione e interesse.",
    link: "https://www.example.com/slide1",
  },
  {
    image: "https://placehold.co/1200x407?text=Slide+2",
    title: "Offerte Esclusive per Te",
    description: "Approfitta di sconti imperdibili sui tuoi libri preferiti.",
    link: "https://www.example.com/slide2",
  },
  {
    image: "https://placehold.co/1200x407?text=Slide+3",
    title: "Nuovi Arrivi Ogni Settimana",
    description: "Rimani aggiornato con le ultime novità editoriali.",
    link: "https://www.example.com/slide3",
  },
]);

const currentSlide = ref(0);
let autoplayInterval: number | undefined;

// Funzione per avviare l'autoplay
const startAutoplay = () => {
  stopAutoplay(); // Ferma eventuali intervalli attivi
  autoplayInterval = setInterval(nextSlide, 3000); // Cambia slide ogni 3 secondi
};

// Funzione per fermare l'autoplay
const stopAutoplay = () => {
  if (autoplayInterval) {
    clearInterval(autoplayInterval);
    autoplayInterval = undefined;
  }
};

// Funzione per passare alla slide successiva
const nextSlide = () => {
  currentSlide.value = (currentSlide.value + 1) % slides.value.length;
  startAutoplay(); // Resetta il timer
};

// Funzione per passare alla slide precedente
const prevSlide = () => {
  currentSlide.value =
    (currentSlide.value - 1 + slides.value.length) % slides.value.length;
  startAutoplay(); // Resetta il timer
};

// Avvia l'autoplay quando il componente è montato
onMounted(() => {
  startAutoplay();
});

// Ferma l'autoplay quando il componente viene distrutto
onUnmounted(() => {
  stopAutoplay();
});

// Type definitions for better type safety
interface Book {
  id: string;
  name: string;
  description: string;
  price: number;
  discountPercentage?: number;
  rating?: number;
  reviewCount?: number;
  metadata?: {
    notes?: string;
    author?: string;
    category?: string;
    location?: string;
    condition?: string;
    publisher?: string;
    additional_images?: string[];
    shipping_available?: boolean;
  };
}

// Supabase configuration
const supabaseUrl = "https://tiylfyyfitqzwstftzpg.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpeWxmeXlmaXRxendzdGZ0enBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNjYyNDcsImV4cCI6MjA1Njc0MjI0N30.CvIx_vI-KGGcFlcZy66-DIC8Itk03Olw3lzEMhnJP_c";
const supabase = createClient(supabaseUrl, supabaseKey);
const router = useRouter();

// Data for the page
const searchData = ref({
  query: "",
  category: "",
  location: "",
});

// Books data
const recentBooks = ref<Book[]>([]);
const isLoading = ref(true);
const error = ref<string | null>(null);

// Search functionality
const searchProducts = () => {
  // Search functionality implementation
  console.log("Searching with:", searchData.value);
};

// Fetch recent books from the database
const fetchRecentBooks = async () => {
  isLoading.value = true;
  error.value = null;

  try {
    // Query to get the most recently added books
    const { data, error: fetchError } = await supabase
      .from("products")
      .select("*")
      .order("created_at", { ascending: false })
      .limit(5);

    if (fetchError) throw fetchError;

    // Properly type cast and handle empty results
    if (data) {
      recentBooks.value = data.map((item) => ({
        id: item.id,
        name: item.name || "Titolo non disponibile",
        description: item.description || "Descrizione non disponibile",
        price: parseFloat(item.price) || 0,
        discountPercentage: item.discount_percentage,
        rating: item.rating,
        reviewCount: item.review_count,
        metadata: item.metadata || {},
      }));
    } else {
      recentBooks.value = [];
    }
  } catch (err) {
    console.error("Error fetching books:", err);
    error.value = "Impossibile caricare i libri recenti. Riprova più tardi.";

    // Provide placeholder data in development
    recentBooks.value = getPlaceholderBooks();
  } finally {
    isLoading.value = false;
  }
};

// Function to get placeholder books for development
const getPlaceholderBooks = (): Book[] => {
  return [
    {
      id: "1",
      name: "Harry Potter e la Pietra Filosofale",
      description: "Il primo libro della saga di Harry Potter",
      price: 15.99,
      metadata: {
        additional_images: ["https://placehold.co/300x400?text=Harry+Potter"],
      },
      discountPercentage: 10,
      rating: 4.8,
      reviewCount: 123,
    },
    {
      id: "2",
      name: "Il Signore degli Anelli",
      description: "La storia epica di Frodo e dell'anello",
      price: 25.99,
      metadata: {
        additional_images: [
          "https://placehold.co/300x200?text=Il+Signore+degli+Anelli",
        ],
      },
      discountPercentage: 0,
      rating: 4.9,
      reviewCount: 256,
    },
    {
      id: "3",
      name: "IT",
      description: "Il terrificante romanzo di Stephen King",
      price: 19.5,
      metadata: {
        additional_images: ["https://placehold.co/300x200?text=IT"],
      },
      discountPercentage: 15,
      rating: 4.6,
      reviewCount: 98,
    },
    {
      id: "4",
      name: "Diario di una Schiappa",
      description: "Le avventure di Greg Heffley",
      price: 12.9,
      metadata: {
        additional_images: [
          "https://placehold.co/300x200?text=Diario+di+una+Schiappa",
        ],
      },
      discountPercentage: 5,
      rating: 4.3,
      reviewCount: 87,
    },
    {
      id: "5",
      name: "Norwegian Wood",
      description: "Un romanzo di Haruki Murakami",
      price: 18.5,
      metadata: {
        additional_images: ["https://placehold.co/300x200?text=Norwegian+Wood"],
      },
      discountPercentage: 0,
      rating: 4.7,
      reviewCount: 64,
    },
  ];
};

// Calculate discounted price safely
const calculateDiscountedPrice = (book: Book): string => {
  try {
    if (!book.price) return "0.00";

    if (book.discountPercentage && book.discountPercentage > 0) {
      const discounted = book.price * (1 - book.discountPercentage / 100);
      return discounted.toFixed(2);
    } else {
      return book.price.toFixed(2);
    }
  } catch (err) {
    console.error("Error calculating price:", err);
    return "0.00";
  }
};

// Favorite/Wishlist functionality
const toggleFavorite = async (bookId: string) => {
  try {
    console.log("Toggle favorite for book ID:", bookId);
    // Add your wishlist toggle functionality here
    // Example:
    // const { data, error } = await supabase.from('favorites').upsert({
    //   user_id: userId,
    //   product_id: bookId,
    //   created_at: new Date()
    // });
  } catch (err) {
    console.error("Error toggling favorite:", err);
  }
};

// Funzione per aggiungere al carrello
const addToCart = async (bookId: string, event: Event) => {
  // Ferma la propagazione dell'evento per evitare navigazione
  event.stopPropagation();

  try {
    console.log("Adding to cart book ID:", bookId);
    // Implementa qui la logica per aggiungere al carrello
    // Esempio:
    // const { data, error } = await supabase.from('cart').insert({
    //   user_id: currentUserId,
    //   product_id: bookId,
    //   quantity: 1,
    //   created_at: new Date()
    // });
  } catch (err) {
    console.error("Error adding to cart:", err);
  }
};

// Navigate to product detail page
const viewProductDetails = (bookId: string) => {
  router.push(`/product/${bookId}`);
};

// Fetch books when component is mounted
onMounted(() => {
  fetchRecentBooks();
});
</script>

<template>
  <div class="page-wrapper">
    <!-- Using imported Navbar component -->
    <Navbar />

    <main>
      <div class="content-container">
        <!-- Hero Banner / Slider -->
        <div class="hero-banner">
          <div class="slider">
            <div
              v-for="(slide, index) in slides"
              :key="index"
              class="slide"
              :class="{ active: index === currentSlide }">
              <a
                :href="slide.link"
                target="_blank"
                rel="noopener noreferrer"
                class="slide-link">
                <img
                  :src="slide.image"
                  :alt="slide.title"
                  class="slide-image" />
              </a>
            </div>
          </div>
          <div class="slider-text">
            <h2 class="slider-title">{{ slides[currentSlide].title }}</h2>
            <p class="slider-description">
              {{ slides[currentSlide].description }}
            </p>
          </div>
          <button
            class="prev-button"
            @click="prevSlide"
            aria-label="Previous slide">
            ❮
          </button>
          <button
            class="next-button"
            @click="nextSlide"
            aria-label="Next slide">
            ❯
          </button>
        </div>

        <!-- Search Section -->
        <div class="search-section">
          <div class="search-container">
            <div class="search-field">
              <label>Cosa cerchi ?</label>
              <input
                v-model="searchData.query"
                type="text"
                placeholder="Nome libro" />
            </div>
            <div class="search-field">
              <label>Categoria</label>
              <input
                v-model="searchData.category"
                type="text"
                placeholder="Categoria" />
            </div>
            <div class="search-field">
              <label>Dove ?</label>
              <input
                v-model="searchData.location"
                type="text"
                placeholder="Località" />
            </div>
            <button
              class="search-button"
              @click="searchProducts">
              <i class="fas fa-search"></i>
            </button>
          </div>
        </div>

        <!-- Recent Books Section -->
        <section class="product-section">
          <div class="section-header">
            <div class="category-indicator">
              <span class="category-icon"></span>
              <span>Libri</span>
            </div>
            <h2 class="section-title">Aggiunti di Recente</h2>
          </div>

          <!-- Loading state -->
          <div
            v-if="isLoading"
            class="loading-container">
            <div class="loading-spinner"></div>
            <p>Caricamento libri...</p>
          </div>

          <!-- Error state -->
          <div
            v-else-if="error"
            class="error-container">
            <p>{{ error }}</p>
            <button
              @click="fetchRecentBooks"
              class="retry-button">
              Riprova
            </button>
          </div>

          <!-- Empty state -->
          <div
            v-else-if="recentBooks.length === 0"
            class="empty-container">
            <p>Non ci sono ancora libri disponibili.</p>
            <RouterLink
              to="/addbook"
              class="add-first-book-button">
              Aggiungi il primo libro!
            </RouterLink>
          </div>

          <!-- Books grid -->
          <div
            v-else
            class="product-grid">
            <div
              v-for="book in recentBooks"
              :key="book.id"
              class="product-card">
              <div
                class="product-image"
                :style="
                  book.metadata?.additional_images &&
                  book.metadata.additional_images.length > 0
                    ? `background-image: url(${book.metadata.additional_images[0]}); background-size: cover;`
                    : ''
                "
                @click="viewProductDetails(book.id)">
                <div
                  v-if="book.discountPercentage && book.discountPercentage > 0"
                  class="discount-tag">
                  -{{ book.discountPercentage }}%
                </div>
                <div class="product-actions">
                  <button
                    class="action-button favorite-button"
                    @click.stop="toggleFavorite(book.id)"
                    title="Aggiungi ai preferiti">
                    <i class="fas fa-heart"></i>
                  </button>
                  <button
                    class="action-button cart-button"
                    @click.stop="addToCart(book.id, $event)"
                    title="Aggiungi al carrello">
                    <i class="fas fa-shopping-cart"></i>
                  </button>
                </div>
              </div>
              <div
                class="product-details"
                @click="viewProductDetails(book.id)">
                <h3 class="product-title">{{ book.name }}</h3>
                <div class="product-price">
                  <span class="current-price"
                    >€{{ calculateDiscountedPrice(book) }}</span
                  >
                  <span
                    v-if="
                      book.discountPercentage && book.discountPercentage > 0
                    "
                    class="original-price">
                    €{{ book.price ? book.price.toFixed(2) : "0.00" }}
                  </span>
                </div>
                <div
                  class="rating"
                  v-if="book.rating">
                  <span class="stars">★★★★★</span>
                  <span class="review-count"
                    >({{ book.reviewCount || 0 }})</span
                  >
                </div>
              </div>
            </div>
          </div>

          <div
            v-if="recentBooks.length > 0"
            class="view-all-container">
            <RouterLink
              to="/shop"
              class="view-all-button">
              Vedi Tutti i Libri
            </RouterLink>
          </div>
        </section>

        <!-- Book Categories Section -->
        <section class="categories-section">
          <div class="section-header">
            <div class="category-indicator">
              <span class="category-icon"></span>
              <span>Categories</span>
            </div>
            <h2 class="section-title">Scegli per tipo di Libro</h2>
            <div class="navigation-arrows">
              <button class="arrow-left">
                <i class="fas fa-arrow-left"></i>
              </button>
              <button class="arrow-right">
                <i class="fas fa-arrow-right"></i>
              </button>
            </div>
          </div>

          <div class="category-grid">
            <div class="category-card">
              <div class="category-icon">
                <i class="fas fa-book"></i>
              </div>
              <span class="category-name">Fantasy</span>
            </div>
            <div class="category-card">
              <div class="category-icon">
                <i class="fas fa-desktop"></i>
              </div>
              <span class="category-name">Saggi</span>
            </div>
            <div class="category-card">
              <div class="category-icon">
                <i class="fas fa-clock"></i>
              </div>
              <span class="category-name">Biografie</span>
            </div>
            <div class="category-card active">
              <div class="category-icon">
                <i class="fas fa-camera"></i>
              </div>
              <span class="category-name">Gialli</span>
            </div>
            <div class="category-card">
              <div class="category-icon">
                <i class="fas fa-headphones"></i>
              </div>
              <span class="category-name">Horror</span>
            </div>
            <div class="category-card">
              <div class="category-icon">
                <i class="fas fa-gamepad"></i>
              </div>
              <span class="category-name">rosa</span>
            </div>
          </div>
        </section>

        <!-- Publishers Section -->
        <section class="publishers-section">
          <div class="section-header">
            <div class="category-indicator">
              <span class="category-icon"></span>
              <span>Categories</span>
            </div>
            <h2 class="section-title">Per Casa Editrice</h2>
            <div class="navigation-arrows">
              <button class="arrow-left">
                <i class="fas fa-arrow-left"></i>
              </button>
              <button class="arrow-right">
                <i class="fas fa-arrow-right"></i>
              </button>
            </div>
          </div>

          <div class="publisher-grid">
            <div class="publisher-card">
              <div class="publisher-icon">
                <i class="fas fa-book"></i>
              </div>
              <span class="publisher-name">Feltrinelli</span>
            </div>
            <div class="publisher-card">
              <div class="publisher-icon">
                <i class="fas fa-desktop"></i>
              </div>
              <span class="publisher-name">Ipperboria</span>
            </div>
            <div class="publisher-card">
              <div class="publisher-icon">
                <i class="fas fa-clock"></i>
              </div>
              <span class="publisher-name">Mondadori</span>
            </div>
            <div class="publisher-card active">
              <div class="publisher-icon">
                <i class="fas fa-camera"></i>
              </div>
              <span class="publisher-name">Giunti</span>
            </div>
            <div class="publisher-card">
              <div class="publisher-icon">
                <i class="fas fa-headphones"></i>
              </div>
              <span class="publisher-name">StarComics</span>
            </div>
            <div class="publisher-card">
              <div class="publisher-icon">
                <i class="fas fa-gamepad"></i>
              </div>
              <span class="publisher-name">Panini</span>
            </div>
          </div>
        </section>
      </div>
    </main>

    <!-- Adding footer component -->
    <Footer />
  </div>
</template>

<style scoped>
/* Base Styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: "Inter", sans-serif;
  color: #333; /* Colore base per tutti i testi */
}

.page-wrapper {
  width: 100%;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background: linear-gradient(to bottom right, #ffffff, #f8f7ff);
}

main {
  padding-top: 80px; /* Aggiunto padding per compensare la navbar fissa */
  flex: 1;
}

.content-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

/* Header Styles */
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 0;
  border-bottom: 1px solid #eaeaea;
}

.logo a {
  text-decoration: none;
}

.logo h2 {
  font-weight: 600;
  color: #222; /* Più scuro per migliorare il contrasto */
  transition: color 0.3s;
}

.logo h2:hover {
  color: #6a5acd;
}

nav.nav-buttons {
  display: flex;
  align-items: center;
  gap: 20px;
}

.nav-item {
  display: flex;
  align-items: center;
  text-decoration: none;
  color: #333;
  gap: 5px;
  padding: 5px;
  border-radius: 5px;
  transition: background-color 0.3s, color 0.3s;
}

.nav-item:hover {
  background-color: rgba(106, 90, 205, 0.1);
  color: #6a5acd;
}

.nav-text {
  font-size: 0.85rem;
  display: none;
}

.cart-button i,
.favorites-button i,
.profile-icon i {
  font-size: 20px;
  vertical-align: middle;
}

.add-book-button {
  display: flex;
  align-items: center;
  gap: 5px;
  background-color: #6a5acd;
  color: black; /* Cambiato da white a black */
  padding: 8px 15px;
  border: none;
  border-radius: 20px;
  cursor: pointer;
  font-weight: 500;
  transition: background-color 0.3s;
}

.add-book-button:hover {
  background-color: #5a4cba;
}

@media (min-width: 768px) {
  .nav-text {
    display: inline;
  }
}

/* Hero Banner Styles */
.hero-banner {
  position: relative;
  width: 1200px;
  height: 407px;
  margin: 0 auto 40px;
  overflow: hidden;
  border-radius: 20px;
  box-shadow: 0 8px 30px rgba(106, 90, 205, 0.15);
}

.slider {
  position: relative;
  width: 100%;
  height: 100%;
}

.slide {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  opacity: 0;
  transition: opacity 0.5s ease-in-out;
}

.slide.active {
  opacity: 1;
}

.slide-link {
  display: block;
  width: 100%;
  height: 100%;
}

.slide-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.slider-text {
  position: absolute;
  bottom: 40px;
  left: 40px;
  z-index: 10;
  max-width: 600px;
  background: rgba(106, 90, 205, 0.9);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  padding: 20px;
  border-radius: 8px;
}

.slider-title {
  font-size: 32px;
  font-weight: 700;
  margin-bottom: 10px;
  color: #ffffff;
}

.slider-description {
  font-size: 18px;
  color: #ffffff;
  line-height: 1.5;
}

.prev-button,
.next-button {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 50px;
  height: 50px;
  background-color: rgba(0, 0, 0, 0.8);
  color: white;
  border: none;
  border-radius: 50%;
  cursor: pointer;
  z-index: 10;
  font-size: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background-color 0.3s;
}

.prev-button:hover,
.next-button:hover {
  background-color: rgba(0, 0, 0, 0.9);
}

.prev-button {
  left: 20px;
}

.next-button {
  right: 20px;
}

@media (max-width: 1200px) {
  .hero-banner {
    width: 100%;
    height: 340px;
  }
}

@media (max-width: 768px) {
  .hero-banner {
    height: 280px;
  }

  .slider-text {
    bottom: 20px;
    left: 20px;
    padding: 15px;
  }

  .slider-title {
    font-size: 24px;
  }

  .slider-description {
    font-size: 16px;
  }
}

/* Search Section Styles */
.search-section {
  margin: 40px 0;
}

.search-container {
  display: grid;
  grid-template-columns: repeat(3, 1fr) auto;
  gap: 20px;
  background: white;
  border: 2px solid #e5e5e5;
  border-radius: 16px;
  padding: 30px;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  background: linear-gradient(to bottom right, #ffffff, #f8f7ff);
}

.search-container:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 25px rgba(106, 90, 205, 0.12);
}

.search-field {
  position: relative;
  padding: 0 15px;
}

/* Fixed selector syntax */
.search-field:not(:last-child)::after {
  content: "";
  position: absolute;
  right: -10px;
  top: 50%;
  transform: translateY(-50%);
  height: 70%;
  width: 1px;
  background: rgba(106, 90, 205, 0.2);
}

.search-field label {
  display: block;
  margin-bottom: 10px;
  font-weight: 600;
  color: #6a5acd;
  font-size: 0.9rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.search-field input {
  width: 100%;
  border: none;
  border-bottom: 2px solid rgba(106, 90, 205, 0.2);
  padding: 12px 0;
  font-size: 1rem;
  color: #333;
  transition: all 0.3s ease;
  background: transparent;
}

.search-field input:focus {
  outline: none;
  border-bottom-color: #6a5acd;
}

.search-field input::placeholder {
  color: #9590d5;
  font-size: 0.9rem;
}

.search-button {
  align-self: flex-end;
  width: 50px;
  height: 50px;
  background-color: #6a5acd;
  color: white;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.search-button i {
  font-size: 1.2rem;
}

.search-button:hover {
  background-color: #5a4cba;
  transform: scale(1.05);
  box-shadow: 0 4px 15px rgba(106, 90, 205, 0.3);
}

@media (max-width: 768px) {
  .search-container {
    grid-template-columns: 1fr;
    gap: 25px;
    padding: 20px;
  }

  .search-field:not(:last-child)::after {
    display: none;
  }

  .search-field {
    padding: 0;
  }

  .search-button {
    width: 100%;
    margin-top: 10px;
  }
}

/* Section Header Styles */
.section-header {
  display: flex;
  align-items: center;
  margin-bottom: 30px;
  position: relative;
  padding: 20px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
}

.category-indicator {
  display: flex;
  align-items: center;
  margin-right: 15px;
}

.category-icon {
  display: inline-block;
  width: 20px;
  height: 20px;
  background-color: #6a5acd;
  padding: 8px;
  border-radius: 8px;
  color: white;
  margin-right: 8px;
}

.category-indicator span {
  color: #333; /* Esplicitamente scuro per il testo dell'indicatore */
}

.section-title {
  font-size: 24px;
  font-weight: 700;
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.navigation-arrows {
  position: absolute;
  right: 0;
  display: flex;
  gap: 10px;
}

.arrow-left,
.arrow-right {
  background: none;
  border: 1px solid #e5e5e5;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Product Grid Styles */
.product-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 20px;
  margin-bottom: 30px;
}

.product-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
  border: none;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
}

.product-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 30px rgba(106, 90, 205, 0.15);
}

.product-image {
  position: relative;
  width: 100%;
  padding-bottom: 141%; /* Rapporto 9:16 (9/16 = 0.5625, 1/0.5625 = 1.7778) */
  background-color: #f5f5f5;
  background-position: center;
  background-repeat: no-repeat;
  background-size: cover;
}

.discount-tag {
  position: absolute;
  top: 10px;
  left: 10px;
  background-color: #6a5acd; /* Changed from #db4444 */
  color: white;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  z-index: 1;
}

/* Posizionamento dei pulsanti in alto a destra */
.product-actions {
  position: absolute;
  top: 10px;
  right: 10px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  z-index: 2;
}

.action-button {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background-color: white;
  color: #333;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  border: none;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
  transition: transform 0.2s, background-color 0.2s;
}

.action-button:hover {
  transform: scale(1.1);
}

.action-button i {
  font-size: 16px;
}

.favorite-button:hover {
  background-color: #e8e6f8; /* Changed from #ffebee */
  color: #6a5acd; /* Changed from #e91e63 */
}

.cart-button:hover {
  background-color: #e3f2fd;
  color: #2196f3;
}

.product-details {
  padding: 20px;
}

.product-title {
  font-size: 16px;
  font-weight: 600;
  color: #2d2d2d;
  margin-bottom: 10px;
}

.product-price {
  margin-bottom: 5px;
}

.current-price {
  font-weight: 500;
  color: #6a5acd; /* Changed from #db4444 */
  margin-right: 5px;
}

.original-price {
  text-decoration: line-through;
  color: #999;
  font-size: 14px;
}

.rating {
  font-size: 14px;
}

.stars {
  color: #ffad33;
}

.review-count {
  color: #777;
  margin-left: 5px;
}

.view-all-container {
  text-align: center;
  margin-bottom: 40px;
}

.view-all-button {
  display: inline-block;
  text-decoration: none;
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  color: white;
  border: none;
  padding: 12px 30px;
  border-radius: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(106, 90, 205, 0.2);
}

/* Category/Publisher Grid Styles */
.category-grid,
.publisher-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 20px;
  margin-bottom: 40px;
}

.category-card,
.publisher-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: white;
  border: none;
  border-radius: 16px;
  padding: 30px;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
  transition: all 0.3s ease;
  color: #333; /* Esplicitamente scuro per il testo delle card */
}

.category-card:hover,
.publisher-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 30px rgba(106, 90, 205, 0.15);
}

.category-card.active,
.publisher-card.active {
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  color: white; /* Mantenuto bianco qui perché lo sfondo è scuro */
}

.category-icon,
.publisher-icon {
  font-size: 24px;
  margin-bottom: 15px;
  color: #333; /* Esplicitamente scuro per le icone */
}

.category-card.active .category-icon,
.publisher-card.active .publisher-icon {
  color: white; /* Mantenuto bianco qui perché lo sfondo è scuro */
}

.category-name,
.publisher-name {
  font-size: 14px;
  font-weight: 500; /* Aggiunto peso del font per migliorare leggibilità */
}

/* Responsive Styles */
@media (max-width: 1024px) {
  .product-grid {
    grid-template-columns: repeat(4, 1fr);
  }

  .category-grid,
  .publisher-grid {
    grid-template-columns: repeat(4, 1fr);
  }
}

@media (max-width: 768px) {
  .product-grid {
    grid-template-columns: repeat(3, 1fr);
  }

  .category-grid,
  .publisher-grid {
    grid-template-columns: repeat(3, 1fr);
  }

  .search-container {
    flex-direction: column;
    gap: 15px;
  }

  .search-field {
    padding: 0;
  }

  .section-header {
    padding: 15px;
  }

  .product-card {
    border-radius: 12px;
  }

  .product-details {
    padding: 15px;
  }

  .category-card,
  .publisher-card {
    padding: 20px;
  }
}

@media (max-width: 576px) {
  .product-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .category-grid,
  .publisher-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

/* Additional styles for new components */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 0;
}

.loading-spinner {
  width: 50px;
  height: 50px;
  border: 4px solid rgba(106, 90, 205, 0.1);
  border-radius: 50%;
  border-top-color: #6a5acd;
  animation: spin 1s infinite ease-in-out;
  margin-bottom: 15px;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.error-container {
  text-align: center;
  padding: 40px 0;
  background-color: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
}

.retry-button {
  margin-top: 15px;
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  color: white;
  padding: 12px 30px;
  border-radius: 12px;
  font-weight: 500;
  transition: all 0.3s ease;
  border: none;
  box-shadow: 0 4px 15px rgba(106, 90, 205, 0.2);
}

.empty-container {
  text-align: center;
  padding: 40px 0;
  background-color: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
}

.add-first-book-button {
  display: inline-block;
  margin-top: 15px;
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  color: white;
  text-decoration: none;
  padding: 12px 30px;
  border-radius: 12px;
  font-weight: 500;
  transition: all 0.3s ease;
  border: none;
  box-shadow: 0 4px 15px rgba(106, 90, 205, 0.2);
}

.view-all-button:hover,
.search-button:hover,
.retry-button:hover,
.add-first-book-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(106, 90, 205, 0.3);
}
</style>

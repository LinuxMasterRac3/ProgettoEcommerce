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
    image: "https://placehold.co/1200x400?text=Slide+1",
    title: "Scopri il Meglio della Lettura",
    description:
      "Esplora una vasta selezione di libri per ogni passione e interesse.",
    link: "https://www.example.com/slide1", // URL di destinazione
  },
  {
    image: "https://placehold.co/1200x400?text=Slide+2",
    title: "Offerte Esclusive per Te",
    description: "Approfitta di sconti imperdibili sui tuoi libri preferiti.",
    link: "https://www.example.com/slide2", // URL di destinazione
  },
  {
    image: "https://placehold.co/1200x400?text=Slide+3",
    title: "Nuovi Arrivi Ogni Settimana",
    description: "Rimani aggiornato con le ultime novità editoriali.",
    link: "https://www.example.com/slide3", // URL di destinazione
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
          <div
            class="slider"
            :style="{ '--current-slide': currentSlide }">
            <div
              v-for="(slide, index) in slides"
              :key="index"
              class="slide">
              <!-- Aggiunto il link cliccabile -->
              <a
                :href="slide.link"
                target="_blank"
                rel="noopener noreferrer"
                class="slide-link">
                <img
                  :src="slide.image"
                  :alt="`Immagine dello slider: ${slide.title}`"
                  class="slide-image"
                  loading="lazy" />
              </a>
            </div>
          </div>
          <!-- Contenuto testuale dello slider -->
          <div class="slider-text">
            <h2 class="slider-title">{{ slides[currentSlide].title }}</h2>
            <p class="slider-description">
              {{ slides[currentSlide].description }}
            </p>
          </div>
          <button
            class="prev-button"
            @click="prevSlide">
            ❮
          </button>
          <button
            class="next-button"
            @click="nextSlide">
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
  overflow: hidden;
  border-radius: 10px;
  height: 330px; /* Altezza dello slider */
  margin-top: -45px; /* Ridotto il margine superiore */
}

.slider-link {
  display: block;
  width: 100%;
  height: 100%;
  text-decoration: none; /* Rimuove la sottolineatura */
}

.slider-link:hover {
  text-decoration: none; /* Rimuove la sottolineatura al passaggio del mouse */
}

.slider {
  display: flex;
  transition: transform 0.5s ease-in-out;
  transform: translateX(calc(-100% * var(--current-slide, 0)));
}

.slide {
  min-width: 100%;
  flex-shrink: 0;
}

.slide-image {
  width: 100%;
  height: 100%; /* L'immagine occupa tutta l'altezza dello slider */
  object-fit: cover; /* Assicura che l'immagine si adatti senza deformarsi */
  border-radius: 10px;
}

.slider-text {
  position: absolute;
  bottom: 20px;
  left: 20px;
  z-index: 10; /* Assicura che le scritte siano sopra gli altri elementi */
  color: white;
  text-shadow: 0 2px 5px rgba(0, 0, 0, 0.7);
  background-color: rgba(
    0,
    0,
    0,
    0.5
  ); /* Sfondo semi-trasparente per migliorare la leggibilità */
  padding: 10px 15px; /* Aggiunge spazio interno */
  border-radius: 8px; /* Arrotonda gli angoli */
}

.slider-content {
  position: absolute;
  bottom: 20px;
  left: 20px;
  color: white;
  text-shadow: 0 2px 5px rgba(0, 0, 0, 0.7);
}

.slider-title {
  font-size: 32px; /* Aumentata la dimensione del titolo */
  font-weight: 700; /* Reso più audace */
  margin-bottom: 15px;
  color: #ffffff; /* Colore bianco per contrasto */
  text-shadow: 0 4px 6px rgba(0, 0, 0, 0.5); /* Migliorato il contrasto */
}

.slider-description {
  font-size: 18px; /* Aumentata la dimensione del testo */
  font-weight: 400; /* Reso più leggibile */
  color: #f0f0f0; /* Colore leggermente più chiaro */
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5); /* Migliorato il contrasto */
  line-height: 1.5; /* Migliorata la leggibilità */
}

.prev-button,
.next-button {
  position: absolute;
  top: 50%;
  transform: translateY(-50%); /* Centra verticalmente */
  background-color: rgba(0, 0, 0, 0.8); /* Colore nero più scuro */
  color: white;
  border: none;
  padding: 0; /* Rimuove padding extra */
  cursor: pointer;
  border-radius: 50%;
  z-index: 10;
  font-size: 24px; /* Aumenta la dimensione della freccia */
  width: 47px; /* Dimensione del pulsante */
  height: 47px; /* Dimensione del pulsante */
  display: flex;
  align-items: center; /* Centra verticalmente il contenuto */
  justify-content: center; /* Centra orizzontalmente il contenuto */
  line-height: 0; /* Rimuove eventuali spazi extra */
}

.prev-button {
  left: 15px; /* Posiziona la freccia a sinistra */
}

.next-button {
  right: 15px; /* Posiziona la freccia a destra */
}

/* Search Section Styles */
.search-section {
  margin-bottom: 40px;
}

.search-container {
  display: flex;
  flex-direction: column;
  border: 1px solid #e5e5e5;
  border-radius: 8px;
  padding: 20px;
}

.search-field {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 0 15px;
}

.search-field label {
  margin-bottom: 8px;
  font-weight: 500;
  color: #222; /* Più scuro per le etichette */
}

.search-field input {
  border: none;
  padding: 5px 0;
  font-size: 14px;
  border-bottom: 1px solid #e5e5e5;
}

.search-button {
  background-color: #7b68ee;
  color: black; /* Cambiato da white a black */
  border: none;
  border-radius: 8px;
  width: 40px;
  height: 40px;
  align-self: flex-end;
  cursor: pointer;
}

/* Section Header Styles */
.section-header {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
  position: relative;
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
  background-color: #333;
  margin-right: 8px;
}

.category-indicator span {
  color: #333; /* Esplicitamente scuro per il testo dell'indicatore */
}

.section-title {
  font-size: 22px;
  font-weight: 600;
  color: #222; /* Più scuro per i titoli delle sezioni */
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
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
  border: 1px solid #eee;
}

.product-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
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
  background-color: #db4444;
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
  background-color: #ffebee;
  color: #e91e63;
}

.cart-button:hover {
  background-color: #e3f2fd;
  color: #2196f3;
}

.product-details {
  padding: 12px;
  background-color: white;
}

.product-title {
  font-size: 14px;
  font-weight: 500;
  margin-bottom: 5px;
  color: #222; /* Più scuro per i titoli dei prodotti */
}

.product-price {
  margin-bottom: 5px;
}

.current-price {
  font-weight: 500;
  color: #db4444;
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
  background-color: #db4444;
  color: black;
  border: none;
  padding: 12px 30px;
  border-radius: 4px;
  font-weight: 500;
  cursor: pointer;
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
  border: 1px solid #e5e5e5;
  border-radius: 4px;
  padding: 25px 0;
  cursor: pointer;
  color: #333; /* Esplicitamente scuro per il testo delle card */
}

.category-card.active,
.publisher-card.active {
  background-color: #2b3238;
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
  width: 40px;
  height: 40px;
  border: 4px solid rgba(0, 0, 0, 0.1);
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
  background-color: #fff3f3;
  border-radius: 8px;
}

.retry-button {
  margin-top: 15px;
  background-color: #6a5acd;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
}

.empty-container {
  text-align: center;
  padding: 40px 0;
  background-color: #f9f9f9;
  border-radius: 8px;
}

.add-first-book-button {
  display: inline-block;
  margin-top: 15px;
  background-color: #6a5acd;
  color: white;
  text-decoration: none;
  padding: 8px 16px;
  border-radius: 4px;
}
</style>

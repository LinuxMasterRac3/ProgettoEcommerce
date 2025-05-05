<template>
  <div class="page-wrapper">
    <!-- Navbar -->
    <Navbar />

    <!-- Main Content -->
    <div class="content-container">
      <div class="allbooks-container">
        <div class="section-header">
          <h1 class="section-title">
            <div class="category-icon"></div>
            Tutti i Libri
          </h1>
          <RouterLink
            to="/"
            class="back-button">
            <i class="fas fa-arrow-left"></i> Torna allo Shop
          </RouterLink>
        </div>

        <!-- Loading State -->
        <div
          v-if="loading"
          class="loading-container">
          <div class="loading-spinner"></div>
          <p>Caricamento in corso...</p>
        </div>

        <!-- Error State -->
        <div
          v-else-if="error"
          class="error-container">
          <p>{{ error }}</p>
          <button
            @click="fetchBooks"
            class="retry-button">
            Riprova
          </button>
        </div>

        <!-- Books List -->
        <div
          v-else
          class="books-list">
          <div
            v-for="book in books"
            :key="book.id"
            class="book-card"
            @click="viewBookDetails(book.id)">
            <div
              class="product-image"
              :style="
                book.metadata?.additional_images &&
                book.metadata.additional_images.length > 0
                  ? `background-image: url(${book.metadata.additional_images[0]}); background-size: cover;`
                  : ''
              ">
              <div
                v-if="book.discountPercentage && book.discountPercentage > 0"
                class="discount-tag">
                -{{ book.discountPercentage }}%
              </div>
              <div class="product-actions">
                <button
                  class="action-button favorite-button"
                  @click.stop="toggleFavorite(book.id, $event)"
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
            <div class="product-details">
              <h3 class="product-title">{{ book.name }}</h3>
              <p class="author">
                Autore: {{ book.metadata?.author || "Non disponibile" }}
              </p>
              <p class="category">
                Categoria: {{ book.metadata?.category || "Non disponibile" }}
              </p>
              <div class="product-price">
                <span class="current-price"
                  >€{{ calculateDiscountedPrice(book) }}</span
                >
                <span
                  v-if="book.discountPercentage && book.discountPercentage > 0"
                  class="original-price">
                  €{{ book.price ? book.price.toFixed(2) : "0.00" }}
                </span>
              </div>
              <div
                class="rating"
                v-if="book.rating">
                <span class="stars">★★★★★</span>
                <span class="review-count">({{ book.reviewCount || 0 }})</span>
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
import { RouterLink, useRouter } from "vue-router";
import { createClient } from "@supabase/supabase-js";
import Navbar from "@/components/Navbar.vue";
import Footer from "@/components/footer.vue";

// Type definition for better type safety
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

// State variables
const books = ref<Book[]>([]);
const loading = ref(true);
const error = ref<string | null>(null);

// Fetch all books from the database
const fetchBooks = async () => {
  loading.value = true;
  error.value = null;

  try {
    // Changed from "books" to "products" to match Shop.vue
    const { data, error: fetchError } = await supabase
      .from("products")
      .select("*");

    if (fetchError) throw fetchError;

    books.value = data.map((book) => ({
      id: book.id,
      name: book.name || "Titolo non disponibile",
      description: book.description || "Descrizione non disponibile",
      price: parseFloat(book.price) || 0,
      discountPercentage: book.discount_percentage,
      rating: book.rating,
      reviewCount: book.review_count,
      metadata: book.metadata || {},
    }));
  } catch (err) {
    console.error("Errore durante il caricamento dei libri:", err);
    error.value = "Errore durante il caricamento dei libri.";
  } finally {
    loading.value = false;
  }
};

// Calculate discounted price safely (same as in Shop.vue)
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

// Function to view book details
const viewBookDetails = (bookId: string) => {
  router.push(`/product/${bookId}`);
};

// Favorite/Wishlist functionality
const toggleFavorite = async (bookId: string, event?: Event) => {
  if (event) event.stopPropagation();
  try {
    console.log("Toggle favorite for book ID:", bookId);
    // Implement wishlist toggle functionality here
  } catch (err) {
    console.error("Error toggling favorite:", err);
  }
};

// Add to cart functionality
const addToCart = async (bookId: string, event: Event) => {
  event.stopPropagation();
  try {
    console.log("Adding to cart book ID:", bookId);
    // Implement add to cart functionality here
  } catch (err) {
    console.error("Error adding to cart:", err);
  }
};

// Fetch books when the component is mounted
onMounted(() => {
  fetchBooks();
});
</script>

<style scoped>
.page-wrapper {
  width: 100%;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background: linear-gradient(to bottom right, #ffffff, #f8f7ff);
}

.content-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 80px 20px 40px;
}

.allbooks-container {
  text-align: center;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding: 20px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
}

.section-title {
  display: flex;
  align-items: center;
  font-size: 24px;
  font-weight: 700;
  background: linear-gradient(45deg, #7c4dff, #6200ea);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  margin: 0;
}

.category-icon {
  width: 12px;
  height: 12px;
  background: linear-gradient(45deg, #7c4dff, #6200ea);
  border-radius: 2px;
  transform: rotate(45deg);
  margin-right: 12px;
  flex-shrink: 0;
}

.back-button {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  text-decoration: none;
  color: #6a5acd;
  font-weight: 500;
  padding: 8px 16px;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.back-button:hover {
  background-color: rgba(106, 90, 205, 0.1);
}

.books-list {
  display: grid;
  grid-template-columns: repeat(
    5,
    1fr
  ); /* Changed to 5 columns like Shop.vue */
  gap: 20px;
  justify-content: center;
  margin-bottom: 30px;
}

.book-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
  border: none;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
}

.book-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 30px rgba(106, 90, 205, 0.15);
}

.product-image {
  position: relative;
  width: 100%;
  padding-bottom: 141%; /* Aspect ratio */
  background-color: #f5f5f5;
  background-position: center;
  background-repeat: no-repeat;
  background-size: cover;
}

.discount-tag {
  position: absolute;
  top: 10px;
  left: 10px;
  background-color: #6a5acd;
  color: white;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  z-index: 1;
}

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
  background-color: #e8e6f8;
  color: #6a5acd;
}

.cart-button:hover {
  background-color: #e3f2fd;
  color: #2196f3;
}

.product-details {
  padding: 20px;
  text-align: left;
}

.product-title {
  font-size: 16px;
  font-weight: 600;
  color: #2d2d2d;
  margin-bottom: 10px;
}

.author,
.category {
  font-size: 14px;
  color: #666;
  margin: 0 0 4px;
}

.product-price {
  margin: 10px 0;
}

.current-price {
  font-weight: 500;
  color: #6a5acd;
  margin-right: 5px;
}

.original-price {
  text-decoration: line-through;
  color: #999;
  font-size: 14px;
}

.rating {
  display: flex;
  align-items: center;
  font-size: 14px;
}

.stars {
  color: #ffad33;
  margin-right: 4px;
}

.review-count {
  color: #777;
  margin-left: 5px;
}

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

.retry-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(106, 90, 205, 0.3);
}

/* Responsive styles */
@media (max-width: 1200px) {
  .books-list {
    grid-template-columns: repeat(4, 1fr);
  }
}

@media (max-width: 1024px) {
  .books-list {
    grid-template-columns: repeat(4, 1fr);
  }
}

@media (max-width: 992px) {
  .books-list {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 768px) {
  .books-list {
    grid-template-columns: repeat(3, 1fr);
    gap: 15px;
  }

  .section-header {
    padding: 15px;
  }
}

@media (max-width: 576px) {
  .books-list {
    grid-template-columns: repeat(2, 1fr);
    gap: 10px;
  }

  .section-header {
    flex-direction: column;
    gap: 15px;
    align-items: flex-start;
  }

  .back-button {
    align-self: flex-start;
  }
}
</style>

<!-- @format -->

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

        <!-- Filters Section -->
        <div class="filters-section">
          <div class="filters-container">
            <div class="filter-group">
              <label for="categoryFilter">Categoria</label>
              <select
                id="categoryFilter"
                v-model="filters.category">
                <option value="">Tutte le categorie</option>
                <option value="fantasy">Fantasy</option>
                <option value="saggi">Saggi</option>
                <option value="biografie">Biografie</option>
                <option value="gialli">Gialli</option>
                <option value="horror">Horror</option>
                <option value="rosa">Romanzi Rosa</option>
                <option value="scifi">Fantascienza</option>
                <option value="manga">Manga</option>
                <option value="bambini">Libri per Bambini</option>
                <option value="narrativa">Narrativa</option>
                <option value="thriller">Thriller</option>
                <option value="storico">Romanzo Storico</option>
                <option value="distopico">Distopico</option>
                <option value="poesia">Poesia</option>
                <option value="fumetti">Fumetti</option>
                <option value="religione">Religione</option>
                <option value="filosofia">Filosofia</option>
                <option value="cucina">Cucina</option>
                <option value="arte">Arte</option>
                <option value="musica">Musica</option>
                <option value="viaggi">Viaggi</option>
                <option value="sport">Sport</option>
                <option value="economia">Economia</option>
                <option value="psicologia">Psicologia</option>
                <option value="storia">Storia</option>
                <option value="scienza">Scienza</option>
                <option value="tecnologia">Tecnologia</option>
              </select>
            </div>

            <div class="filter-group">
              <label for="publisherFilter">Casa Editrice</label>
              <select
                id="publisherFilter"
                v-model="filters.publisher">
                <option value="">Tutte le case editrici</option>
                <option value="feltrinelli">Feltrinelli</option>
                <option value="mondadori">Mondadori</option>
                <option value="einaudi">Einaudi</option>
                <option value="adelphi">Adelphi</option>
                <option value="giunti">Giunti</option>
                <option value="bompiani">Bompiani</option>
                <option value="starcomics">Star Comics</option>
                <option value="panini">Panini Comics</option>
                <option value="ipperboria">Ipperboria</option>
                <option value="rizzoli">Rizzoli</option>
                <option value="laterza">Laterza</option>
                <option value="sperling">Sperling & Kupfer</option>
              </select>
            </div>

            <div class="filter-group">
              <label for="conditionFilter">Condizione</label>
              <select
                id="conditionFilter"
                v-model="filters.condition">
                <option value="">Tutte le condizioni</option>
                <option value="nuovo">Nuovo</option>
                <option value="comeNuovo">Come Nuovo</option>
                <option value="buone">Buone Condizioni</option>
                <option value="usato">Usato</option>
                <option value="dannegiato">Danneggiato</option>
              </select>
            </div>

            <div class="filter-group price-filter">
              <label>Prezzo</label>
              <div class="price-range">
                <input
                  type="number"
                  v-model="filters.minPrice"
                  placeholder="Min €"
                  min="0"
                  step="0.01" />
                <span class="price-separator">-</span>
                <input
                  type="number"
                  v-model="filters.maxPrice"
                  placeholder="Max €"
                  min="0"
                  step="0.01" />
              </div>
            </div>

            <div class="filter-group location-filter">
              <label for="locationFilter">Località</label>
              <div class="location-input-container">
                <input
                  type="text"
                  id="locationFilter"
                  v-model="locationInput"
                  @input="handleLocationInput"
                  @focus="showSuggestions = true"
                  @blur="handleLocationBlur"
                  @keydown.down.prevent="navigateSuggestions('down')"
                  @keydown.up.prevent="navigateSuggestions('up')"
                  @keydown.enter.prevent="
                    selectSuggestion(selectedSuggestionIndex)
                  "
                  @keydown.esc="showSuggestions = false"
                  placeholder="Filtra per località"
                  autocomplete="off" />

                <div
                  v-if="showSuggestions && filteredComuni.length > 0"
                  class="comuni-suggestions">
                  <div
                    v-for="(comune, index) in filteredComuni"
                    :key="comune.codice"
                    @mousedown="selectSuggestion(index)"
                    :class="[
                      'comune-suggestion',
                      { selected: index === selectedSuggestionIndex },
                    ]">
                    <span class="comune-name">{{ comune.nome }}</span>
                    <span
                      class="provincia-sigla"
                      v-if="
                        comune.provincia &&
                        comune.provincia.sigla &&
                        comune.provincia.sigla.length === 2
                      ">
                      ({{ comune.provincia.sigla }})
                    </span>
                  </div>
                </div>

                <div
                  v-if="
                    showSuggestions &&
                    locationInput &&
                    filteredComuni.length === 0
                  "
                  class="no-suggestions">
                  Nessun comune trovato
                </div>
              </div>
            </div>

            <div class="filter-group shipping-filter">
              <div class="checkbox-container">
                <input
                  type="checkbox"
                  id="shippingFilter"
                  v-model="filters.shippingAvailable" />
                <label for="shippingFilter"
                  >Solo con spedizione disponibile</label
                >
              </div>
            </div>
          </div>
          <div class="filter-actions">
            <button
              class="apply-filters-btn"
              @click="applyFilters">
              <i class="fas fa-filter"></i> Applica Filtri
            </button>
            <button
              class="reset-filters-btn"
              @click="resetFilters">
              <i class="fas fa-undo"></i> Reimposta
            </button>
          </div>
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

        <!-- No Results Message -->
        <div
          v-else-if="books.length === 0"
          class="no-results-container">
          <p>Nessun libro trovato con i filtri selezionati.</p>
          <button
            @click="resetFilters"
            class="reset-filters-button">
            Reimposta filtri
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
                <!-- Pulsante Wishlist -->
                <button
                  class="action-button favorite-button"
                  :class="{
                    'is-favorite': favoriteProductIds.includes(book.id),
                  }"
                  @click.stop="toggleFavorite(book.id, $event)"
                  title="Aggiungi ai preferiti">
                  <img
                    src="https://cdn-icons-png.flaticon.com/512/833/833472.png"
                    alt="Aggiungi ai preferiti"
                    class="favorite-icon" />
                </button>
                <!-- Pulsante Carrello -->
                <button
                  class="action-button cart-button"
                  :class="{ 'in-cart': isInCart(book.id) }"
                  @click.stop="addToCart(book.id, $event)"
                  title="Aggiungi al carrello">
                  <img
                    src="https://cdn-icons-png.flaticon.com/512/1170/1170678.png"
                    alt="Aggiungi al carrello"
                    class="cart-icon" />
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

          <!-- Infinite Scroll Trigger -->
          <div
            ref="loadMoreTrigger"
            class="infinite-scroll-trigger">
            <!-- Loading more indicator -->
            <div
              v-if="loadingMore"
              class="loading-more">
              <div class="loading-spinner-small"></div>
              <p>Caricamento altri libri...</p>
            </div>
            <!-- All loaded message -->
            <div
              v-else-if="allBooksLoaded && books.length > 0"
              class="all-loaded-message">
              <p></p>
            </div>
          </div>
        </div>

        <!-- Results Count -->
        <div
          v-if="!loading && !error && books.length > 0"
          class="results-count">
          {{ books.length }} libri trovati
        </div>
      </div>
    </div>

    <!-- Footer -->
    <Footer />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive, computed, watch, onUnmounted } from "vue";
import { RouterLink, useRouter, useRoute } from "vue-router";
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

// Filter state
interface Filters {
  category: string;
  publisher: string;
  condition: string;
  minPrice: number | null;
  maxPrice: number | null;
  location: string;
  shippingAvailable: boolean;
}

// Supabase configuration
const supabaseUrl = "https://tiylfyyfitqzwstftzpg.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpeWxmeXlmaXRxendzdGZ0enBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNjYyNDcsImV4cCI6MjA1Njc0MjI0N30.CvIx_vI-KGGcFlcZy66-DIC8Itk03Olw3lzEMhnJP_c";
const supabase = createClient(supabaseUrl, supabaseKey);
const router = useRouter();
const route = useRoute();

// State variables
const books = ref<Book[]>([]);
const loading = ref(true);
const error = ref<string | null>(null);
const isTransitioning = ref(false);
const loadingMore = ref(false); // New state for infinite scroll loading
const allBooksLoaded = ref(false); // Flag to track if all books have been loaded

// Pagination (modified for infinite scrolling)
const currentPage = ref(0);
const booksPerPage = 10; // Books per batch

// Create a ref for the observer
const loadMoreTrigger = ref(null);
const observer = ref<IntersectionObserver | null>(null);

// Initialize filters
const filters = reactive<Filters>({
  category: "",
  publisher: "",
  condition: "",
  minPrice: null,
  maxPrice: null,
  location: "",
  shippingAvailable: false,
});

// Reset filters to default values
const resetFilters = () => {
  filters.category = "";
  filters.publisher = "";
  filters.condition = "";
  filters.minPrice = null;
  filters.maxPrice = null;
  filters.location = "";
  filters.shippingAvailable = false;
  fetchBooks(); // Fetch all books without filters
};

// Apply current filters and fetch books
const applyFilters = () => {
  fetchBooks();
};

// Fetch books with applied filters and better error handling
const fetchBooks = async (retryCount = 2, loadMore = false) => {
  if (loadMore) {
    if (allBooksLoaded.value) return; // Don't fetch if all books are loaded
    loadingMore.value = true;
  } else {
    loading.value = true;
    error.value = null;
    isTransitioning.value = true;
    currentPage.value = 0; // Reset page when doing a new search
    books.value = []; // Clear books when not loading more
    allBooksLoaded.value = false; // Reset this flag
  }

  // Set a loading timeout
  const loadingTimeout = setTimeout(() => {
    if (loading.value || loadingMore.value) {
      loading.value = false;
      loadingMore.value = false;
      error.value = "Caricamento interrotto per timeout. Riprova più tardi.";
      console.warn("Loading timeout reached for fetchBooks");
    }
  }, 15000); // 15 seconds timeout

  try {
    // Start building the query
    let query = supabase.from("products").select("*", { count: "exact" });

    // Apply category filter
    if (filters.category) {
      query = query.eq("metadata->>category", filters.category);
    }

    // Apply publisher filter
    if (filters.publisher) {
      query = query.eq("metadata->>publisher", filters.publisher);
    }

    // Apply condition filter
    if (filters.condition) {
      query = query.eq("metadata->>condition", filters.condition);
    }

    // Apply price range filters
    if (filters.minPrice !== null) {
      query = query.gte("price", filters.minPrice);
    }
    if (filters.maxPrice !== null) {
      query = query.lte("price", filters.maxPrice);
    }

    // Apply location filter (case insensitive partial match)
    if (filters.location) {
      query = query.ilike("metadata->>location", `%${filters.location}%`);
    }

    // Apply shipping availability filter
    if (filters.shippingAvailable) {
      query = query.eq("metadata->>shipping_available", "true");
    }

    // Handle search query from Shop.vue
    if (route.query.query) {
      // Using ilike for case-insensitive partial matching in the book name or description
      query = query.or(
        `name.ilike.%${route.query.query}%, description.ilike.%${route.query.query}%`
      );
    }

    // Calculate pagination range for current request
    const from = currentPage.value * booksPerPage;
    const to = from + booksPerPage - 1;

    // Execute the query with range
    const {
      data,
      error: fetchError,
      count,
    } = await query.order("created_at", { ascending: false }).range(from, to);

    // Clear timeout as we got a response
    clearTimeout(loadingTimeout);

    if (fetchError) {
      // If we have retries left, try again after a short delay
      if (retryCount > 0) {
        console.log(`Retry attempt ${3 - retryCount} for fetchBooks`);
        setTimeout(() => fetchBooks(retryCount - 1, loadMore), 1500);
        return;
      }
      throw fetchError;
    }

    if (data && data.length > 0) {
      const newBooks = data.map((book) => ({
        id: book.id,
        name: book.name || "Titolo non disponibile",
        description: book.description || "Descrizione non disponibile",
        price: parseFloat(book.price) || 0,
        discountPercentage: book.discount_percentage,
        rating: book.rating,
        reviewCount: book.review_count,
        metadata: book.metadata || {},
      }));

      // If loading more, append to existing books, otherwise replace
      if (loadMore) {
        books.value = [...books.value, ...newBooks];
      } else {
        books.value = newBooks;
      }

      // Check if we've loaded all available books
      if (count !== undefined) {
        allBooksLoaded.value = books.value.length >= count;
      } else {
        // If we got fewer books than requested, we've likely reached the end
        allBooksLoaded.value = data.length < booksPerPage;
      }

      // Increment the page for next load
      currentPage.value++;
    } else {
      if (!loadMore) {
        books.value = []; // Only clear if this isn't "load more"
      }
      allBooksLoaded.value = true; // No more books to load
    }
  } catch (err) {
    // Clear timeout as we caught an error
    clearTimeout(loadingTimeout);

    console.error("Errore durante il caricamento dei libri:", err);
    error.value = "Errore durante il caricamento dei libri. Riprova più tardi.";

    // In development mode, use placeholder data to demonstrate UI
    if (import.meta.env.DEV && !loadMore) {
      books.value = getPlaceholderBooks();
    }
  } finally {
    // Clear timeout and end loading state
    clearTimeout(loadingTimeout);
    loading.value = false;
    loadingMore.value = false;

    // Short delay before removing transition effect
    setTimeout(() => {
      isTransitioning.value = false;
    }, 300);
  }
};

// Load more books when scrolling
const loadMoreBooks = () => {
  if (!loading.value && !loadingMore.value && !allBooksLoaded.value) {
    fetchBooks(2, true);
  }
};

// Setup intersection observer for infinite scrolling
const setupIntersectionObserver = () => {
  // Disconnect previous observer if exists
  if (observer.value) {
    observer.value.disconnect();
  }

  // Create a new intersection observer
  observer.value = new IntersectionObserver(
    (entries) => {
      if (entries[0].isIntersecting && !loadingMore.value) {
        loadMoreBooks();
      }
    },
    {
      rootMargin: "200px", // Start loading before reaching the end
      threshold: 0.1,
    }
  );

  // Start observing the trigger element when available
  if (loadMoreTrigger.value) {
    observer.value.observe(loadMoreTrigger.value);
  }
};

// Function to get placeholder books for development
const getPlaceholderBooks = (): Book[] => {
  return [
    // Example placeholder books
    {
      id: "1",
      name: "Harry Potter e la Pietra Filosofale",
      description: "Il primo libro della saga di Harry Potter",
      price: 15.99,
      metadata: {
        additional_images: ["https://placehold.co/300x400?text=Harry+Potter"],
        author: "J.K. Rowling",
        category: "fantasy",
      },
      discountPercentage: 10,
      rating: 4.8,
      reviewCount: 123,
    },
    // Add more placeholder books as needed
    // ...
  ];
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

// --- Favorites State ---
const favoriteProductIds = ref<string[]>([]);
const currentUserId = ref<string | null>(null);

// Function to check authentication status and fetch user ID
const checkUserAuth = async () => {
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (user) {
    currentUserId.value = user.id;
    await fetchUserFavorites(); // Fetch favorites if user is logged in
  } else {
    currentUserId.value = null;
    favoriteProductIds.value = []; // Clear favorites if not logged in
  }
};

// Function to fetch user's favorites
const fetchUserFavorites = async () => {
  if (!currentUserId.value) return;
  try {
    const { data, error: favError } = await supabase
      .from("favorites")
      .select("product_id")
      .eq("user_id", currentUserId.value);
    if (favError) throw favError;
    favoriteProductIds.value = data ? data.map((fav) => fav.product_id) : [];
  } catch (err) {
    console.error("Error fetching favorites:", err);
  }
};

// Favorite/Wishlist functionality
const toggleFavorite = async (bookId: string, event?: Event) => {
  if (event) event.stopPropagation();
  if (!currentUserId.value) {
    alert("Devi effettuare il login per aggiungere ai preferiti.");
    return;
  }
  try {
    const isCurrentlyFavorite = favoriteProductIds.value.includes(bookId);
    if (isCurrentlyFavorite) {
      // Remove from favorites
      const { error: deleteError } = await supabase
        .from("favorites")
        .delete()
        .eq("user_id", currentUserId.value)
        .eq("product_id", bookId);
      if (deleteError) throw deleteError;
      favoriteProductIds.value = favoriteProductIds.value.filter(
        (id) => id !== bookId
      );
    } else {
      // Add to favorites
      const { error: insertError } = await supabase
        .from("favorites")
        .insert({ user_id: currentUserId.value, product_id: bookId });
      if (insertError) throw insertError;
      favoriteProductIds.value.push(bookId);
    }
  } catch (err) {
    console.error("Error toggling favorite:", err);
    alert("Errore nell'aggiornamento dei preferiti.");
  }
};

// Carrello
const addToCart = async (bookId: string, event: Event) => {
  event.stopPropagation();
  try {
    const cart = JSON.parse(localStorage.getItem("cart") || "[]");
    if (!cart.includes(bookId)) {
      cart.push(bookId);
      localStorage.setItem("cart", JSON.stringify(cart));
      alert("Libro aggiunto al carrello!");
    } else {
      alert("Questo libro è già nel carrello.");
    }
  } catch (err) {
    console.error("Error adding to cart:", err);
    alert("Si è verificato un errore durante l'aggiunta al carrello.");
  }
};

const isInCart = (bookId: string): boolean => {
  const cart = JSON.parse(localStorage.getItem("cart") || "[]");
  return cart.includes(bookId);
};

// Add these at the script setup level
const locationInput = ref("");
const filteredComuni = ref([]);
const comuni = ref([]);
const showSuggestions = ref(false);
const selectedSuggestionIndex = ref(-1);
const isLoadingComuni = ref(false);
const comuniError = ref(null);

// Database of provinces for main Italian cities - copy from AggiungiLibro.vue
const provinceMap = {
  Roma: { nome: "Roma", sigla: "RM" },
  Milano: { nome: "Milano", sigla: "MI" },
  Napoli: { nome: "Napoli", sigla: "NA" },
  Torino: { nome: "Torino", sigla: "TO" },
  Palermo: { nome: "Palermo", sigla: "PA" },
  Genova: { nome: "Genova", sigla: "GE" },
  Bologna: { nome: "Bologna", sigla: "BO" },
  Firenze: { nome: "Firenze", sigla: "FI" },
  Bari: { nome: "Bari", sigla: "BA" },
  Catania: { nome: "Catania", sigla: "CT" },
  // Add more from AggiungiLibro.vue as needed
};

// Fetch Italian communes
const fetchComuni = async () => {
  try {
    isLoadingComuni.value = true;
    comuniError.value = null;

    // Check if we have cached data
    const cachedData = localStorage.getItem("comuni-cache");
    const cacheTimestamp = localStorage.getItem("comuni-cache-timestamp");

    // Use cache if valid (less than 24 hours old)
    if (
      cachedData &&
      cacheTimestamp &&
      Date.now() - parseInt(cacheTimestamp) < 24 * 60 * 60 * 1000
    ) {
      comuni.value = JSON.parse(cachedData);
      return;
    }

    // Fetch from API if no valid cache
    const response = await fetch(
      "https://raw.githubusercontent.com/matteocontrini/comuni-json/master/comuni.json"
    );

    if (!response.ok) {
      throw new Error(`Error loading communes: ${response.status}`);
    }

    const data = await response.json();

    // Clean and normalize data - matching AggiungiLibro's approach
    const normalizedData = data
      .filter((comune) => comune && comune.nome)
      .map((comune) => {
        // Check if the city is in our province database
        const comuneName = comune.nome.trim();
        if (provinceMap[comuneName]) {
          comune.provincia = {
            nome: provinceMap[comuneName].nome,
            sigla: provinceMap[comuneName].sigla,
          };
          return comune;
        }

        // Handle cases where province is not correctly defined
        if (
          !comune.provincia ||
          !comune.provincia.sigla ||
          comune.provincia.sigla === "??" ||
          comune.provincia.sigla.length !== 2
        ) {
          // Try to extract province from name
          const provinceMatch = comune.nome.match(/\s*\(([A-Z]{2})\)\s*$/);
          if (provinceMatch && provinceMatch[1]) {
            comune.provincia = {
              nome: "Provincia di " + provinceMatch[1],
              sigla: provinceMatch[1],
            };
            return comune;
          }

          // Try to deduce province from city name
          for (const [city, province] of Object.entries(provinceMap)) {
            if (
              comune.nome.includes(city) ||
              comune.nome.startsWith(city + " ")
            ) {
              comune.provincia = {
                nome: province.nome,
                sigla: province.sigla,
              };
              return comune;
            }
          }

          // Set generic value if we can't determine the province
          comune.provincia = {
            nome: "Provincia non specificata",
            sigla: "",
          };
        }

        return comune;
      });

    // Additional check to remove question marks
    for (const comune of normalizedData) {
      if (comune.provincia && comune.provincia.sigla === "??") {
        comune.provincia.sigla = "";
      }
    }

    comuni.value = normalizedData;

    // Save to cache
    try {
      localStorage.setItem("comuni-cache", JSON.stringify(normalizedData));
      localStorage.setItem("comuni-cache-timestamp", Date.now().toString());
    } catch (e) {
      console.warn("Unable to save communes to cache:", e);
    }
  } catch (error) {
    console.error("Error loading communes:", error);
    comuniError.value = error.message;
  } finally {
    isLoadingComuni.value = false;
  }
};

// Filter communes based on input
const handleLocationInput = () => {
  if (locationInput.value.length < 2) {
    filteredComuni.value = [];
    filters.location = locationInput.value; // Update filter as typing
    return;
  }

  const input = locationInput.value.toLowerCase().trim();

  filteredComuni.value = comuni.value
    .filter((comune) => {
      // Search in both city name and province
      const matchesName = comune.nome.toLowerCase().includes(input);
      const matchesProvincia =
        comune.provincia &&
        (comune.provincia.nome.toLowerCase().includes(input) ||
          comune.provincia.sigla.toLowerCase() === input);

      return matchesName || matchesProvincia;
    })
    .sort((a, b) => {
      // Sort results, prioritizing matches that start with the query
      const aStartsWithQuery = a.nome.toLowerCase().startsWith(input);
      const bStartsWithQuery = b.nome.toLowerCase().startsWith(input);

      if (aStartsWithQuery && !bStartsWithQuery) return -1;
      if (!aStartsWithQuery && bStartsWithQuery) return 1;

      return a.nome.localeCompare(b.nome);
    })
    .slice(0, 10); // Limit to 10 results

  selectedSuggestionIndex.value = -1;
  showSuggestions.value = true;

  // Update the filter with the current input
  filters.location = locationInput.value;
};

// Handle selecting a commune from suggestions
const selectSuggestion = (index) => {
  if (index >= 0 && index < filteredComuni.value.length) {
    const selectedComune = filteredComuni.value[index];

    // Check if city is in the main database
    if (provinceMap[selectedComune.nome]) {
      const provinciaCorretta = provinceMap[selectedComune.nome];
      locationInput.value = `${selectedComune.nome} (${provinciaCorretta.sigla})`;
    }
    // Otherwise use the existing data if valid
    else if (
      selectedComune.provincia &&
      selectedComune.provincia.sigla &&
      selectedComune.provincia.sigla.length === 2 &&
      selectedComune.provincia.sigla !== "??"
    ) {
      locationInput.value = `${selectedComune.nome} (${selectedComune.provincia.sigla})`;
    }
    // Fallback: use only city name
    else {
      locationInput.value = selectedComune.nome;
    }

    filters.location = locationInput.value;
    showSuggestions.value = false;
  }
};

// Navigate suggestions with up/down keys
const navigateSuggestions = (direction) => {
  if (filteredComuni.value.length === 0) return;

  if (direction === "down") {
    selectedSuggestionIndex.value =
      selectedSuggestionIndex.value < filteredComuni.value.length - 1
        ? selectedSuggestionIndex.value + 1
        : 0;
  } else {
    selectedSuggestionIndex.value =
      selectedSuggestionIndex.value > 0
        ? selectedSuggestionIndex.value - 1
        : filteredComuni.value.length - 1;
  }
};

// Handle input blur
const handleLocationBlur = () => {
  // Delay closing to allow clicking on suggestions
  setTimeout(() => {
    showSuggestions.value = false;
  }, 200);

  // Update filter with current input
  filters.location = locationInput.value;
};

// Fetch books when the component is mounted
onMounted(() => {
  // Check for query parameters from the search form
  const query = route.query;

  // Apply any query parameters to the filters
  if (query.category) {
    // Try to match the category with available options
    filters.category = String(query.category);
  }

  if (query.location) {
    locationInput.value = String(query.location);
    filters.location = locationInput.value;
  }

  // For search query, we'll handle it directly in fetchBooks

  // Fetch communes
  fetchComuni();

  // Fetch books with the applied filters
  fetchBooks();

  // Setup the intersection observer after component is mounted
  setupIntersectionObserver();

  checkUserAuth();
});

// Update observer when DOM changes
watch(loadMoreTrigger, () => {
  if (loadMoreTrigger.value) {
    setupIntersectionObserver();
  }
});

// Cleanup observer when component is unmounted
onUnmounted(() => {
  if (observer.value) {
    observer.value.disconnect();
  }
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

/* Filter styles */
.filters-section {
  background: white;
  border-radius: 16px;
  padding: 20px;
  margin-bottom: 30px;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
}

.filters-container {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}

.filter-group {
  display: flex;
  flex-direction: column;
  text-align: left;
}

.filter-group label {
  margin-bottom: 8px;
  font-weight: 500;
  color: #333;
}

.filter-group select,
.filter-group input[type="text"],
.filter-group input[type="number"] {
  padding: 10px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  background-color: #f8f9fa;
  transition: border-color 0.3s, box-shadow 0.3s;
}

.filter-group select:focus,
.filter-group input:focus {
  border-color: #6a5acd;
  outline: none;
  box-shadow: 0 0 0 2px rgba(106, 90, 205, 0.2);
}

.price-range {
  display: flex;
  align-items: center;
  gap: 10px;
}

.price-range input {
  width: 100%;
  padding: 10px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
}

.price-separator {
  color: #6a5acd;
  font-weight: bold;
}

.checkbox-container {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-top: 10px;
}

.filter-actions {
  margin-top: 20px;
  display: flex;
  justify-content: center;
  gap: 15px;
}

.apply-filters-btn,
.reset-filters-btn {
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 8px;
}

.apply-filters-btn {
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  color: white;
}

.reset-filters-btn {
  background-color: #f5f5f5;
  color: #333;
}

.apply-filters-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(106, 90, 205, 0.3);
}

.reset-filters-btn:hover {
  background-color: #e5e5e5;
}

.books-list {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
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
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px; /* Spazio tra icona e testo */
  width: auto; /* Adatta la larghezza al contenuto */
  padding: 8px 12px;
  border-radius: 8px;
  background-color: white;
  color: #333;
  border: 1px solid #ddd;
  cursor: pointer;
  transition: transform 0.2s, background-color 0.2s;
}

.action-button:hover {
  background-color: #f5f5f5;
  transform: scale(1.05);
}

/* Pulsante Wishlist (rosso quando è nei preferiti) */
.favorite-button.is-favorite {
  background-color: #ff6b6b; /* Rosso */
  color: white;
  border-color: transparent;
}

.favorite-button.is-favorite:hover {
  background-color: #e63946; /* Rosso più scuro */
}

/* Pulsante Carrello (blu quando è nel carrello) */
.cart-button.in-cart {
  background-color: #4dabf7; /* Blu */
  color: white;
  border-color: transparent;
}

.cart-button.in-cart:hover {
  background-color: #1e90ff; /* Blu più scuro */
}

.favorite-icon,
.cart-icon {
  width: 20px;
  height: 20px;
  object-fit: contain;
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

.no-results-container {
  text-align: center;
  padding: 40px 0;
  background-color: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
}

.reset-filters-button {
  margin-top: 15px;
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.reset-filters-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(106, 90, 205, 0.3);
}

.retry-button {
  margin-top: 15px;
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  color: white;
  font-style: italic;
}

/* Responsive styles */
@media (max-width: 1200px) {
  .books-list {
    grid-template-columns: repeat(4, 1fr);
  }

  .filters-container {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 992px) {
  .books-list {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 768px) {
  .books-list {
    grid-template-columns: repeat(2, 1fr);
    gap: 15px;
  }

  .filters-container {
    grid-template-columns: 1fr;
  }

  .section-header {
    padding: 15px;
  }
}

@media (max-width: 576px) {
  .books-list {
    grid-template-columns: repeat(1, 1fr);
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

  .filter-actions {
    flex-direction: column;
  }

  .apply-filters-btn,
  .reset-filters-btn {
    width: 100%;
  }
}

/* Add these styles for the location search */
.location-input-container {
  position: relative;
  width: 100%;
}

.comuni-suggestions {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  max-height: 300px;
  overflow-y: auto;
  background-color: white;
  border: 1px solid #ddd;
  border-top: none;
  border-radius: 0 0 8px 8px;
  z-index: 10;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.comune-suggestion {
  padding: 10px 15px;
  cursor: pointer;
  transition: background-color 0.2s;
  display: flex;
  justify-content: space-between;
  text-align: left;
}

.comune-suggestion:hover {
  background-color: #f5f5f5;
}

.comune-suggestion.selected {
  background-color: #e8e8fd;
}

.comune-name {
  font-weight: 500;
}

.provincia-sigla {
  color: #666;
  font-size: 0.9em;
}

.no-suggestions {
  padding: 10px 15px;
  color: #666;
  font-style: italic;
  background-color: white;
  border: 1px solid #ddd;
  border-top: none;
  border-radius: 0 0 8px 8px;
}

/* Add these styles for infinite scrolling */
.infinite-scroll-trigger {
  width: 100%;
  height: 100px;
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 20px;
}

.loading-more {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
}

.loading-spinner-small {
  width: 30px;
  height: 30px;
  border: 3px solid rgba(106, 90, 205, 0.1);
  border-radius: 50%;
  border-top-color: #6a5acd;
  animation: spin 1s infinite ease-in-out;
}

.all-loaded-message {
  padding: 15px;
  color: #777;
  font-style: italic;
}
</style>

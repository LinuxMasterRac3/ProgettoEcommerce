<script setup lang="ts">
import { ref, onMounted, computed } from "vue";
import { RouterLink, useRouter } from "vue-router";
import { createClient } from "@supabase/supabase-js";
import Navbar from "../components/Navbar.vue";
import Footer from "../components/footer.vue";
import { onUnmounted, watch } from "vue";

const slides = ref([
  {
    image:
      "https://images.unsplash.com/photo-1532012197267-da84d127e765?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&h=407&q=80",
    title: "Scopri il Meglio della Lettura",
    description:
      "Esplora una vasta selezione di libri per ogni passione e interesse.",
    link: "/allbooks",
  },

  {
    image:
      "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&h=407&q=80",
    title: "Offerte Esclusive per Te",
    description: "Approfitta di sconti imperdibili sui tuoi libri preferiti.",
    link: "/allbooks",
  },
  {
    image:
      "https://images.unsplash.com/photo-1464925257126-6450e871c667?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&h=407&q=80",
    title: "Nuovi Arrivi Ogni Settimana",
    description: "Rimani aggiornato con le ultime novità editoriali.",
    link: "/allbooks",
  },
]);

const currentSlide = ref(0);
let autoplayInterval: number | undefined;

const startAutoplay = () => {
  stopAutoplay();
  autoplayInterval = setInterval(nextSlide, 3000);
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
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
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

// Search functionality
const searchProducts = () => {
  const queryParams = {};

  // Add any non-empty search parameters to the query
  if (searchData.value.query) queryParams.query = searchData.value.query;
  if (searchData.value.category)
    queryParams.category = searchData.value.category;
  if (locationInput.value) queryParams.location = locationInput.value;

  // Navigate to Allbooks with the query parameters
  router.push({
    path: "/allbooks",
    query: queryParams,
  });
};

// Fetch recent books from the database
const fetchRecentBooks = async (retryCount = 2) => {
  isLoading.value = true;
  error.value = null;

  // Set a loading timeout to prevent infinite loading state
  const loadingTimeout = setTimeout(() => {
    if (isLoading.value) {
      isLoading.value = false;
      error.value = "Caricamento interrotto per timeout. Riprova più tardi.";
      console.warn("Loading timeout reached for fetchRecentBooks");
    }
  }, 15000); // 15 seconds timeout

  try {
    // Fetch books from Supabase
    const { data, error: fetchError } = await supabase
      .from("products")
      .select("*")
      .order("created_at", { ascending: false })
      .limit(12);

    // Clear timeout as we got a response
    clearTimeout(loadingTimeout);

    if (fetchError) {
      console.error("Error fetching books:", fetchError);

      // If we have retries left, try again after a short delay
      if (retryCount > 0) {
        console.log(`Retry attempt ${3 - retryCount} for fetchRecentBooks`);
        setTimeout(() => fetchRecentBooks(retryCount - 1), 1500);
        return;
      }

      throw fetchError;
    }

    if (data && data.length > 0) {
      recentBooks.value = data.map((book) => ({
        id: book.id,
        name: book.name || "Titolo non disponibile",
        description: book.description || "Descrizione non disponibile",
        price: parseFloat(book.price) || 0,
        discountPercentage: book.discount_percentage,
        rating: book.rating,
        reviewCount: book.review_count,
        metadata: book.metadata || {},
      }));
    } else {
      recentBooks.value = [];
      console.log("No books found in the database");
    }
  } catch (err) {
    // Clear timeout as we got an error
    clearTimeout(loadingTimeout);

    console.error("Error during book fetch:", err);
    error.value = "Errore durante il caricamento dei libri. Riprova più tardi.";

    // For development purposes, you might want to add sample data
    if (import.meta.env.DEV) {
      recentBooks.value = getSampleBooks();
    }
  } finally {
    // Clear timeout and set loading to false
    clearTimeout(loadingTimeout);
    isLoading.value = false;
  }
};

// Helper function to get sample books for development
const getSampleBooks = () => {
  return [
    {
      id: "sample1",
      name: "Il Nome della Rosa",
      description: "Un'avvincente storia ambientata in un monastero medievale",
      price: 14.99,
      metadata: {
        author: "Umberto Eco",
        category: "narrativa",
        additional_images: [
          "https://placehold.co/300x400?text=Il+Nome+della+Rosa",
        ],
      },
    },
    {
      id: "sample2",
      name: "Harry Potter e la Pietra Filosofale",
      description: "Il primo libro della saga di Harry Potter",
      price: 12.5,
      metadata: {
        author: "J.K. Rowling",
        category: "fantasy",
        additional_images: ["https://placehold.co/300x400?text=Harry+Potter"],
      },
    },
    // Add a few more sample books for development
  ];
};

// Add function to manually retry loading
const retryLoading = () => {
  fetchRecentBooks(2); // Start with full retry count
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
const toggleFavorite = async (bookId: string, event: Event) => {
  event.stopPropagation(); // Prevent card click
  if (!currentUserId.value) {
    alert("Devi effettuare il login per aggiungere ai preferiti.");
    // Optionally redirect to login: router.push('/login');
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
      // console.log(`Book ${bookId} removed from favorites.`);
    } else {
      // Add to favorites
      const { error: insertError } = await supabase
        .from("favorites")
        .insert({ user_id: currentUserId.value, product_id: bookId });
      if (insertError) throw insertError;
      favoriteProductIds.value.push(bookId);
      // console.log(`Book ${bookId} added to favorites.`);
    }
  } catch (err) {
    console.error("Error toggling favorite:", err);
    alert("Errore nell'aggiornamento dei preferiti.");
  }
};

// Funzione per aggiungere al carrello
const addToCart = async (bookId: string, event: Event) => {
  // Ferma la propagazione dell'evento per evitare navigazione
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

// Check if a book is in the cart
const isInCart = (bookId: string): boolean => {
  const cart = JSON.parse(localStorage.getItem("cart") || "[]");
  return cart.includes(bookId);
};

// Navigate to product detail page
const viewProductDetails = (bookId: string) => {
  router.push(`/product/${bookId}`);
};

// Fetch books when component is mounted
onMounted(async () => {
  try {
    // Initialize data loading with Promise.allSettled to continue even if some fail
    const results = await Promise.allSettled([
      fetchRecentBooks(),
      fetchComuni(),
      checkUserAuth(),
    ]);

    // Log any rejections for debugging
    results.forEach((result, index) => {
      if (result.status === "rejected") {
        console.warn(`Task ${index} failed:`, result.reason);

        // Retry failed operations once
        if (index === 0) fetchRecentBooks(); // Retry books
        if (index === 1) fetchComuni(); // Retry comuni
      }
    });

    // Start autoplay for slider
    startAutoplay();
  } catch (err) {
    console.error("Error during page initialization:", err);
    // Make sure we have placeholder data if everything fails
    if (recentBooks.value.length === 0) {
      recentBooks.value = getPlaceholderBooks();
    }
  }

  // Setup auth listeners
  const { data: authListener } = supabase.auth.onAuthStateChange(
    async (event, session) => {
      if (event === "SIGNED_IN" && session?.user) {
        currentUserId.value = session.user.id;
        await fetchUserFavorites();
      } else if (event === "SIGNED_OUT") {
        currentUserId.value = null;
        favoriteProductIds.value = [];
      }
    }
  );

  // Cleanup listener on unmount
  onUnmounted(() => {
    if (
      authListener &&
      typeof authListener.subscription?.unsubscribe === "function"
    ) {
      authListener.subscription.unsubscribe();
    }

    // Also clean up the autoplay interval
    stopAutoplay();
  });
});

// Add these with your existing refs
const locationInput = ref("");
const filteredComuni = ref([]);
const comuni = ref([]);
const showSuggestions = ref(false);
const selectedSuggestionIndex = ref(-1);
const isLoadingComuni = ref(false);
const comuniError = ref(null);

// Database of provinces for main Italian cities
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
      try {
        comuni.value = JSON.parse(cachedData);
        return;
      } catch (parseError) {
        console.warn(
          "Cache data parsing error, fetching fresh data",
          parseError
        );
        // Continue with fetch if parse fails
      }
    }

    // Fetch with retry mechanism
    const data = await fetchWithRetry(async () => {
      const response = await fetch(
        "https://raw.githubusercontent.com/matteocontrini/comuni-json/master/comuni.json"
      );

      if (!response.ok) {
        throw new Error(`Error loading communes: ${response.status}`);
      }

      return response.json();
    });

    // Process data as before
    // ...existing data normalization code...
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

    comuni.value = normalizedData;

    // Save to cache - with error handling
    try {
      localStorage.setItem("comuni-cache", JSON.stringify(normalizedData));
      localStorage.setItem("comuni-cache-timestamp", Date.now().toString());
    } catch (e) {
      console.warn("Unable to save communes to cache:", e);
    }
  } catch (error) {
    console.error("Error loading communes:", error);
    comuniError.value = error.message;

    // Provide fallback for location search using provinceMap
    comuni.value = Object.entries(provinceMap).map(([nome, provincia]) => ({
      nome,
      provincia,
      codice: nome.toLowerCase().replace(/\s/g, "-"),
    }));
  } finally {
    isLoadingComuni.value = false;
  }
};

// Function to fetch data with retries
const fetchWithRetry = async (fetcher, maxRetries = 3, delay = 1000) => {
  let retries = 0;
  let lastError = null;

  while (retries < maxRetries) {
    try {
      return await fetcher();
    } catch (err) {
      lastError = err;
      console.warn(`Fetch attempt ${retries + 1} failed, retrying...`, err);
      retries++;
      if (retries < maxRetries) {
        await new Promise((resolve) => setTimeout(resolve, delay));
        // Increase delay for each retry (exponential backoff)
        delay = delay * 1.5;
      }
    }
  }

  // If we've exhausted retries, throw the last error
  throw lastError;
};

// Filter communes based on input
const handleLocationInput = () => {
  if (locationInput.value.length < 2) {
    filteredComuni.value = [];
    searchData.value.location = locationInput.value;
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

  // Update the search data with the current input
  searchData.value.location = locationInput.value;
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

    searchData.value.location = locationInput.value;
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

  // Update search data with current input
  searchData.value.location = locationInput.value;
};

// Update onMounted to also load communes
onMounted(() => {
  fetchRecentBooks();

  // Add this line to load communes
  fetchComuni();
});

// Variabili per la paginazione
const currentPage = ref(0); // Pagina corrente
const booksPerPage = 5; // Numero di libri per pagina

// Funzione per ottenere i libri della pagina corrente
const paginatedBooks = computed(() => {
  const start = currentPage.value * booksPerPage;
  const end = start + booksPerPage;
  return recentBooks.value.slice(start, end);
});

// Funzione per andare alla pagina precedente
const prevPage = () => {
  if (currentPage.value > 0) {
    currentPage.value--;
  }
};

// Funzione per andare alla pagina successiva
const nextPage = () => {
  const maxPage = Math.ceil(recentBooks.value.length / booksPerPage) - 1;
  if (currentPage.value < maxPage) {
    currentPage.value++;
  }
};

// Improved book loading mechanism with timeout and retry functionality
const fetchBooks = async (retryCount = 2) => {
  loading.value = true;
  error.value = null;

  // Set a loading timeout to prevent infinite loading
  const loadingTimeout = setTimeout(() => {
    if (loading.value) {
      loading.value = false;
      error.value = "Caricamento interrotto per timeout. Riprova più tardi.";
      console.warn("Loading timeout reached for fetchBooks");

      // Try to use cached data as fallback if available
      const cachedData = localStorage.getItem("cached-books");
      if (cachedData) {
        try {
          const parsed = JSON.parse(cachedData);
          books.value = parsed;
          error.value = "Mostrati dati in cache. Riprova per aggiornare.";
          console.log("Using cached book data as fallback");
        } catch (e) {
          console.error("Failed to parse cached data", e);
        }
      }
    }
  }, 10000); // 10 seconds timeout

  try {
    // Start building the query
    let query = supabase.from("products").select("*");

    // Apply category filter if provided
    if (selectedCategory) {
      query = query.eq("metadata->>category", selectedCategory);
    }

    // Apply search filter if provided
    if (searchQuery.value) {
      query = query.or(
        `name.ilike.%${searchQuery.value}%,description.ilike.%${searchQuery.value}%`
      );
    }

    // Execute the query
    const { data, error: fetchError } = await query
      .order("created_at", { ascending: false })
      .limit(12); // Limit for better performance

    // Clear timeout as we got a response
    clearTimeout(loadingTimeout);

    if (fetchError) {
      // If we have retries left, try again after a short delay
      if (retryCount > 0) {
        console.log(`Retry attempt ${3 - retryCount} for fetchBooks`);
        setTimeout(() => fetchBooks(retryCount - 1), 1500);
        return;
      }
      throw fetchError;
    }

    if (data && data.length > 0) {
      const processedData = data.map((book) => ({
        id: book.id,
        name: book.name || "Titolo non disponibile",
        description: book.description || "Descrizione non disponibile",
        price: parseFloat(book.price) || 0,
        discountPercentage: book.discount_percentage,
        rating: book.rating,
        reviewCount: book.review_count,
        metadata: book.metadata || {},
      }));

      books.value = processedData;

      // Cache the data for fallback use
      try {
        localStorage.setItem("cached-books", JSON.stringify(processedData));
        localStorage.setItem("cached-books-timestamp", Date.now().toString());
      } catch (e) {
        console.warn("Failed to cache book data", e);
      }
    } else {
      books.value = [];
      error.value =
        "Nessun libro trovato. Prova a cambiare i filtri di ricerca.";
    }
  } catch (err) {
    // Clear timeout as we caught an error
    clearTimeout(loadingTimeout);

    console.error("Errore durante il caricamento dei libri:", err);
    error.value = "Errore durante il caricamento dei libri. Riprova più tardi.";

    // Try to use cached data if available
    const cachedData = localStorage.getItem("cached-books");
    const cacheTimestamp = localStorage.getItem("cached-books-timestamp");

    if (cachedData && cacheTimestamp) {
      const cacheAge = Date.now() - parseInt(cacheTimestamp);
      if (cacheAge < 24 * 60 * 60 * 1000) {
        // Cache valid for 24 hours
        try {
          books.value = JSON.parse(cachedData);
          error.value =
            "Impossibile aggiornare i dati. Mostrati dati in cache.";
          console.log("Using cached book data due to fetch error");
        } catch (e) {
          console.error("Failed to parse cached data", e);
        }
      }
    }
  } finally {
    // Clear timeout and end loading state
    clearTimeout(loadingTimeout);
    loading.value = false;
  }
};
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
              <RouterLink
                :to="slide.link"
                class="slide-link">
                <img
                  :src="slide.image"
                  :alt="slide.title"
                  class="slide-image" />
              </RouterLink>
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
            <!-- Replace the existing category input with this dropdown -->
            <div class="search-field">
              <label>Categoria</label>
              <select
                v-model="searchData.category"
                class="category-dropdown">
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
            <!-- Replace the existing location input with this: -->
            <div class="search-field">
              <label>Dove ?</label>
              <div class="location-input-container">
                <input
                  type="text"
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
                  placeholder="Località"
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
            <button
              class="search-button"
              @click="searchProducts">
              <img
                src="https://cdn-icons-png.flaticon.com/512/151/151773.png"
                alt="Icona di ricerca"
                class="search-icon" />
              <span class="button-text">Search</span>
            </button>
          </div>
        </div>

        <!-- Recent Books Section -->
        <section class="product-section">
          <div class="section-header">
            <h2 class="section-title">
              <div class="category-icon"></div>
              Aggiunti di Recente
            </h2>
            <div class="navigation-arrows">
              <button
                class="arrow-left"
                @click="prevPage">
                <img
                  src="https://cdn-icons-png.flaticon.com/512/271/271220.png"
                  alt="Freccia Sinistra"
                  class="arrow-icon" />
              </button>
              <button
                class="arrow-right"
                @click="nextPage">
                <img
                  src="https://cdn-icons-png.flaticon.com/512/271/271228.png"
                  alt="Freccia Destra"
                  class="arrow-icon" />
              </button>
            </div>
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
              @click="retryLoading"
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
              v-for="book in paginatedBooks"
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
                  <!-- Pulsante Wishlist -->
                  <button
                    class="action-button favorite-button"
                    :class="{
                      'is-favorite': favoriteProductIds.includes(book.id),
                    }"
                    @click="toggleFavorite(book.id, $event)"
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
              to="/allbooks"
              class="view-all-button">
              Vedi Tutti i Libri
            </RouterLink>
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
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px; /* Spazio tra icona e testo */
  width: auto;
  padding: 10px 15px;
  background-color: #6a5acd;
  color: white;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(106, 90, 205, 0.2);
}

.search-button:hover {
  background-color: #5a4cba;
  transform: scale(1.05);
}

.search-icon {
  width: 20px; /* Larghezza dell'immagine */
  height: 20px; /* Altezza dell'immagine */
  object-fit: contain; /* Mantiene le proporzioni */
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

.category-indicator {
  display: none;
}

.navigation-arrows {
  display: flex;
  gap: 10px;
  margin-left: auto;
}

/* Aggiusta spaziatura delle frecce di navigazione */
.navigation-arrows {
  display: flex;
  gap: 10px;
  margin-left: auto; /* Spinge le frecce a destra */
}

.arrow-left,
.arrow-right {
  background: white;
  border: 1px solid #e5e5e5;
  width: 35px;
  height: 35px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
}

.arrow-left:hover,
.arrow-right:hover {
  background: linear-gradient(45deg, #7c4dff, #6200ea);
  border-color: transparent;
  color: white;
}

.arrow-icon {
  width: 16px; /* Imposta la larghezza desiderata */
  height: 16px; /* Imposta l'altezza desiderata */
  object-fit: contain; /* Mantiene le proporzioni */
}

/* Aggiusta lo stile delle card delle categorie e degli editori */
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
  padding: 25px 20px;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
  transition: all 0.3s ease;
  cursor: pointer;
}

.category-card:hover,
.publisher-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 30px rgba(106, 90, 205, 0.15);
}

.category-card.active,
.publisher-card.active {
  background: linear-gradient(45deg, #6a5acd, #6200ea);
}

/* Aggiusta gli spazi delle sezioni */
.product-section,
.categories-section,
.publishers-section {
  margin-bottom: 60px;
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

.favorite-icon,
.cart-icon {
  width: 20px;
  height: 20px;
  object-fit: contain;
}

.button-text {
  font-size: 14px;
  font-weight: 500;
  color: #333;
}

.favorite-button:hover {
  background-color: #ffe6e6;
  color: #e74c3c;
}

.cart-button:hover {
  background-color: #e6f7ff;
  color: #3498db;
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
  padding: 20px;
  background-color: #fff0f0;
  border-radius: 8px;
  margin: 20px 0;
}

.retry-button {
  margin-top: 15px;
  padding: 10px 20px;
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.retry-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(106, 90, 205, 0.3);
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

.shop-title {
  background: linear-gradient(45deg, #7c4dff, #6200ea);
}

.add-to-cart-btn {
  background: linear-gradient(45deg, #7c4dff, #6200ea);
}

.add-to-cart-btn:hover {
  background: linear-gradient(45deg, #6200ea, #5502c7);
  box-shadow: 0 4px 15px rgba(124, 77, 255, 0.3);
}

.price {
  color: #7c4dff;
}

/* Add this to your existing CSS section */
.category-dropdown {
  width: 100%;
  border: none;
  border-bottom: 2px solid rgba(106, 90, 205, 0.2);
  padding: 12px 0;
  font-size: 1rem;
  color: #333;
  transition: all 0.3s ease;
  background: transparent;
  appearance: none;
  cursor: pointer;
  background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='%236a5acd' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e");
  background-repeat: no-repeat;
  background-position: right 0px center;
  background-size: 16px;
}

.category-dropdown:focus {
  outline: none;
  border-bottom-color: #6a5acd;
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
  border-radius: 0 0 8px 8px;
}
</style>

<script setup lang="ts">
import { ref, onMounted, computed, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import { createClient } from "@supabase/supabase-js";
import Navbar from "../../components/Navbar.vue";
import Footer from "../../components/footer.vue";

// Type definitions for better type safety
interface Book {
  id: string;
  name: string;
  description: string;
  price: number;
  discountPercentage?: number;
  rating?: number;
  reviewCount?: number;
  created_at?: string;
  user_id?: string;
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

interface User {
  id: string;
  username?: string;
  email?: string;
  full_name?: string;
  avatar_url?: string;
  location?: string;
  phone?: string;
  rating?: number;
  memberSince?: string;
}

// Funzione per aggiungere il libro al carrello
const addToCart = async () => {
  if (!product.value) return;

  try {
    // Recupera il carrello dal localStorage
    const cart = JSON.parse(localStorage.getItem("cart") || "[]");

    // Controlla se il libro è già nel carrello
    if (cart.includes(product.value.id)) {
      alert("Questo libro è già nel carrello.");
      return;
    }

    // Aggiungi l'ID del libro al carrello
    cart.push(product.value.id);
    localStorage.setItem("cart", JSON.stringify(cart));

    alert("Libro aggiunto al carrello!");
  } catch (error) {
    console.error("Errore durante l'aggiunta al carrello:", error);
    alert("Si è verificato un errore. Riprova più tardi.");
  }
};

// Supabase configuration
const supabaseUrl = "https://tiylfyyfitqzwstftzpg.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpeWxmeXlmaXRxendzdGZ0enBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNjYyNDcsImV4cCI6MjA1Njc0MjI0N30.CvIx_vI-KGGcFlcZy66-DIC8Itk03Olw3lzEMhnJP_c";
const supabase = createClient(supabaseUrl, supabaseKey);

// Component state
const route = useRoute();
const router = useRouter(); // Aggiunta istanza del router
const productId = route.params.id as string;
const product = ref<Book | null>(null);
const seller = ref<User | null>(null);
const isLoading = ref(true);
const error = ref<string | null>(null);
const selectedImageIndex = ref(0); // Track the currently selected image index
const relatedBooks = ref<Book[]>([]); // Add state for related books

// Funzione per cambiare l'immagine principale quando si clicca su una thumbnail
const setMainImage = (index: number) => {
  selectedImageIndex.value = index;
};

// Computed property per ottenere l'immagine principale
const mainImage = computed(() => {
  if (
    product.value?.metadata?.additional_images &&
    product.value.metadata.additional_images.length > 0 &&
    selectedImageIndex.value < product.value.metadata.additional_images.length
  ) {
    return product.value.metadata.additional_images[selectedImageIndex.value];
  }
  return "https://placehold.co/300x400?text=No+Image";
});

// Computed property per ottenere le immagini aggiuntive
const additionalImages = computed(() => {
  if (
    product.value?.metadata?.additional_images &&
    product.value.metadata.additional_images.length > 0
  ) {
    return product.value.metadata.additional_images;
  }
  return [];
});

// Funzione per navigare a un prodotto correlato
const navigateToRelatedProduct = (bookId: string) => {
  // Utilizza window.location.href per forzare un refresh completo della pagina
  window.location.href = `/product/${bookId}`;
};

// Add this method under the existing methods in the script section
const contactSeller = () => {
  if (!product.value) {
    alert("Informazioni sul prodotto non disponibili");
    return;
  }

  // If seller info is not available, we'll still try to use the user_id from the product
  const sellerId = seller.value?.id || product.value.user_id;

  if (!sellerId) {
    alert("Informazioni sul venditore non disponibili");
    return;
  }

  // Navigate to the contact page with seller information as query parameters
  router.push({
    path: "/contact",
    query: {
      seller_id: sellerId,
      seller_name:
        seller.value?.full_name || seller.value?.username || "Venditore",
      product_id: product.value.id,
      product_name: product.value.name,
    },
  });
};

// Fetch product details
const fetchProductDetails = async () => {
  isLoading.value = true;
  error.value = null;

  try {
    const { data: productData, error: productError } = await supabase
      .from("products")
      .select("*")
      .eq("id", productId)
      .single();

    if (productError) throw productError;

    if (productData) {
      product.value = {
        id: productData.id,
        name: productData.name || "Titolo non disponibile",
        description: productData.description || "Descrizione non disponibile",
        price: parseFloat(productData.price) || 0,
        discountPercentage: productData.discount_percentage,
        rating: productData.rating,
        reviewCount: productData.review_count,
        created_at: productData.created_at,
        user_id: productData.user_id,
        metadata: productData.metadata || {},
      };

      if (productData.user_id) {
        try {
          // Get the user directly from auth.users first to ensure we have an email and basic user info
          const { data: authUserData, error: authUserError } =
            await supabase.auth.admin.getUserById(productData.user_id);

          if (authUserError) {
            console.error("Error fetching auth user data:", authUserError);
          }

          // Then get the profile data which might have additional fields
          const { data: userData, error: userError } = await supabase
            .from("profiles")
            .select(
              "first_name, last_name, phone, description, profile_image, created_at"
            )
            .eq("id", productData.user_id)
            .maybeSingle(); // Use maybeSingle instead of single to handle missing profile gracefully

          if (userError && userError.code !== "PGRST116") {
            console.error("Error fetching seller profile:", userError);
          }

          // Merge the data from auth.users and profiles
          seller.value = {
            id: productData.user_id,
            username: authUserData?.user?.user_metadata?.username || "Utente",
            email: authUserData?.user?.email,
            full_name: userData
              ? `${userData.first_name || ""} ${
                  userData.last_name || ""
                }`.trim()
              : authUserData?.user?.user_metadata?.name || "Utente Supabase",
            avatar_url: userData?.profile_image,
            location: userData?.location,
            phone: userData?.phone,
            rating: 5, // Default rating or from another source
            memberSince: userData?.created_at || authUserData?.user?.created_at,
          };
        } catch (profileError) {
          console.error("Failed to fetch seller profile:", profileError);
          // Fallback to a basic seller object
          seller.value = {
            id: productData.user_id,
            username: "Utente",
            full_name: "Venditore",
          };
        }
      }

      // Fetch related books with smarter query
      let query = supabase.from("products").select("*").neq("id", productId);

      // If we have a category, try to find books in the same category
      if (productData.metadata?.category) {
        query = query.eq("metadata->>category", productData.metadata.category);
      }
      // If we have a publisher, try to find books from the same publisher
      else if (productData.metadata?.publisher) {
        query = query.eq(
          "metadata->>publisher",
          productData.metadata.publisher
        );
      }

      // Fetch related books
      let { data: relatedBooksData, error: relatedBooksError } =
        await query.limit(4);

      // If no related books found by category or publisher, fetch any books
      if (
        (!relatedBooksData || relatedBooksData.length === 0) &&
        !relatedBooksError
      ) {
        const { data: anyBooks, error: anyBooksError } = await supabase
          .from("products")
          .select("*")
          .neq("id", productId)
          .limit(4);

        if (!anyBooksError) {
          relatedBooksData = anyBooks;
        }
      }

      if (relatedBooksError) throw relatedBooksError;

      if (relatedBooksData) {
        relatedBooks.value = relatedBooksData.map((book: any) => ({
          id: book.id,
          name: book.name || "Titolo non disponibile",
          description: book.description || "Descrizione non disponibile",
          price: parseFloat(book.price) || 0,
          discountPercentage: book.discount_percentage,
          rating: book.rating,
          reviewCount: book.review_count,
          created_at: book.created_at,
          user_id: book.user_id,
          metadata: book.metadata || {},
        }));
      }
    } else {
      throw new Error("Prodotto non trovato");
    }
  } catch (err) {
    console.error("Error fetching product details:", err);
    error.value =
      "Impossibile caricare i dettagli del prodotto. Riprova più tardi.";
  } finally {
    isLoading.value = false;
  }
};

// Fetch product details on component mount
onMounted(() => {
  fetchProductDetails();
});
</script>

<template>
  <div class="page-container">
    <!-- Navbar -->
    <Navbar />

    <!-- Main content -->
    <div class="content-container">
      <!-- Loading state -->
      <div
        v-if="isLoading"
        class="loading-container">
        <p>Caricamento dettagli prodotto...</p>
      </div>

      <!-- Error state -->
      <div
        v-else-if="error"
        class="error-container">
        <p>{{ error }}</p>
        <button
          @click="fetchProductDetails"
          class="retry-button">
          Riprova
        </button>
      </div>

      <!-- Product details -->
      <div
        v-else-if="product"
        class="product-detail-container">
        <div class="product-main">
          <!-- Product images -->
          <div class="product-images">
            <div class="product-thumbnails">
              <img
                v-for="(image, index) in additionalImages"
                :key="index"
                :src="image"
                :class="[
                  'product-thumbnail',
                  { active: selectedImageIndex === index },
                ]"
                @click="setMainImage(index)"
                alt="Thumbnail" />
            </div>
            <img
              :src="mainImage"
              alt="Immagine prodotto"
              class="product-main-image" />
          </div>

          <!-- Product info -->
          <div class="product-info">
            <h1 class="product-title">{{ product.name }}</h1>
            <p class="product-author">
              di {{ product.metadata?.author || "Autore sconosciuto" }}
            </p>
            <p class="product-price">Prezzo: €{{ product.price.toFixed(2) }}</p>
            <div class="product-buttons">
              <button
                class="contact-button"
                @click="contactSeller">
                Contatta il venditore
              </button>
              <button class="buy-button">Acquista ora</button>
              <button
                class="add-to-cart-button"
                @click="addToCart">
                Aggiungi al carrello
              </button>
            </div>
            <div class="shipping-info">
              <i class="shipping-icon">🚚</i>
              <p>Consegna a solo €1,99</p>
              <input
                type="text"
                placeholder="Inserisci il tuo CAP"
                class="cap-input" />
            </div>

            <!-- Migliorata visualizzazione info venditore -->
            <div
              class="seller-info-card"
              v-if="seller">
              <div class="seller-header">Venditore</div>
              <div class="seller-details">
                <div class="seller-avatar">
                  <img
                    v-if="seller.avatar_url"
                    :src="seller.avatar_url"
                    alt="Immagine profilo" />
                  <div
                    v-else
                    class="avatar-placeholder">
                    {{
                      seller.full_name
                        ? seller.full_name.charAt(0).toUpperCase()
                        : "U"
                    }}
                  </div>
                </div>
                <div class="seller-text">
                  <p class="seller-name">
                    {{
                      seller.full_name || seller.username || "Utente Supabase"
                    }}
                  </p>
                  <p
                    class="seller-location"
                    v-if="seller.location">
                    {{ seller.location }}
                  </p>
                  <p
                    class="seller-member-since"
                    v-if="seller.memberSince">
                    Membro dal
                    {{ new Date(seller.memberSince).toLocaleDateString() }}
                  </p>
                  <div
                    class="seller-rating"
                    v-if="seller.rating">
                    <span
                      v-for="i in 5"
                      :key="i"
                      class="star">
                      {{ i <= seller.rating ? "★" : "☆" }}
                    </span>
                  </div>
                </div>
              </div>
            </div>
            <p
              class="seller-info"
              v-else>
              Venditore: <strong>Sconosciuto</strong>
            </p>
          </div>
        </div>

        <!-- Product description -->
        <div class="product-description-section">
          <h2>Trama</h2>
          <p>{{ product.description || "Descrizione non disponibile" }}</p>
        </div>

        <!-- Metadata section -->
        <div
          class="product-metadata"
          v-if="product.metadata">
          <h2>Informazioni aggiuntive</h2>
          <ul>
            <li v-if="product.metadata.notes">
              <strong>Note:</strong> {{ product.metadata.notes }}
            </li>
            <li v-if="product.metadata.category">
              <strong>Categoria:</strong> {{ product.metadata.category }}
            </li>
            <li v-if="product.metadata.condition">
              <strong>Condizione:</strong> {{ product.metadata.condition }}
            </li>
            <li v-if="product.metadata.publisher">
              <strong>Casa Editrice:</strong> {{ product.metadata.publisher }}
            </li>
            <li v-if="product.metadata.location">
              <strong>Posizione:</strong> {{ product.metadata.location }}
            </li>
            <li v-if="product.metadata.shipping_available !== undefined">
              <strong>Spedizione Disponibile:</strong>
              {{ product.metadata.shipping_available ? "Sì" : "No" }}
            </li>
          </ul>
        </div>

        <!-- Related products -->
        <div
          class="related-products"
          v-if="relatedBooks.length > 0">
          <h2>Prodotti correlati</h2>
          <div class="related-products-list">
            <div
              v-for="relatedBook in relatedBooks"
              :key="relatedBook.id"
              class="related-product-card"
              @click="navigateToRelatedProduct(relatedBook.id)">
              <img
                :src="
                  relatedBook.metadata?.additional_images?.[0] ||
                  'https://placehold.co/150x150?text=No+Image'
                "
                alt="Prodotto correlato"
                class="related-product-image" />
              <p class="related-product-name">{{ relatedBook.name }}</p>
              <p class="related-product-price">
                €{{ relatedBook.price.toFixed(2) }}
              </p>
              <p
                class="related-product-author"
                v-if="relatedBook.metadata?.author">
                {{ relatedBook.metadata.author }}
              </p>
            </div>
          </div>
        </div>
        <div
          v-else-if="!isLoading"
          class="no-related-products">
          <p>Non ci sono prodotti correlati disponibili al momento.</p>
        </div>
      </div>
    </div>

    <!-- Footer -->
    <Footer />
  </div>
</template>

<style scoped>
/* Layout styles */
.page-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.content-container {
  flex: 1;
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

/* Product details */
.product-detail-container {
  display: flex;
  flex-direction: column;
  gap: 40px;
}

.product-main {
  display: flex;
  gap: 20px;
}

.product-images {
  display: flex;
  flex-direction: row;
  gap: 20px;
}

.product-thumbnails {
  display: flex;
  flex-direction: column;
  gap: 10px;
  height: 400px;
  justify-content: flex-start;
  overflow-y: auto;
}

.product-main-image {
  width: 400px;
  height: 400px;
  border-radius: 10px;
  object-fit: contain;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.product-thumbnail {
  width: 60px;
  height: 60px;
  border-radius: 5px;
  object-fit: cover;
  cursor: pointer;
  border: 1px solid #ddd;
  transition: border-color 0.3s;
}

.product-thumbnail:hover {
  border-color: #6a5acd;
}

.product-thumbnail.active {
  border-color: #6a5acd;
  border-width: 2px;
  box-shadow: 0 0 6px rgba(106, 90, 205, 0.5);
}

.product-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.product-title {
  font-size: 28px;
  font-weight: bold;
  color: #333;
}

.product-author {
  font-size: 16px;
  color: #000000;
}

.product-price {
  font-size: 24px;
  font-weight: bold;
  color: #222;
}

.product-buttons {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.contact-button {
  padding: 12px 24px;
  background-color: #000;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.3s;
}

.contact-button:hover {
  background-color: #000000;
}

.buy-button {
  padding: 12px 24px;
  background-color: #6a5acd;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.3s;
}

.buy-button:hover {
  background-color: #5a4cbf;
}

.shipping-info {
  margin-top: 10px;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 5px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
}

.shipping-icon {
  font-size: 20px;
}

.shipping-info p {
  font-size: 16px;
  color: #000;
}

.cap-input {
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 5px;
  width: 100%;
}

/* Nuovo stile per la card del venditore */
.seller-info-card {
  margin-top: 10px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  overflow: hidden;
  background-color: #fff;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.seller-header {
  background-color: #f5f5f5;
  padding: 10px 15px;
  font-weight: 600;
  color: #444;
  border-bottom: 1px solid #e0e0e0;
}

.seller-details {
  padding: 15px;
  display: flex;
  align-items: center;
  gap: 15px;
}

.seller-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  overflow: hidden;
  background-color: #e0e0e0;
  border: 1px solid #ddd;
  flex-shrink: 0;
}

.seller-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  font-weight: bold;
  color: #000;
  background-color: #e9e9e9;
}

.seller-text {
  flex: 1;
}

.seller-name {
  font-weight: 600;
  color: #333;
  margin: 0 0 5px 0;
  font-size: 16px;
}

.seller-location {
  color: #000;
  margin: 0 0 5px 0;
  font-size: 14px;
}

.seller-member-since {
  color: #000;
  margin: 0 0 5px 0;
  font-size: 12px;
}

.seller-rating {
  display: flex;
  gap: 2px;
}

.star {
  color: #ffb74d;
  font-size: 16px;
}

.seller-info {
  margin-top: 10px;
  font-size: 16px;
  color: #000;
}

/* Product description */
.product-description-section {
  margin-top: 20px;
}

.product-description-section h2 {
  font-size: 20px;
  margin-bottom: 10px;
  color: #333;
}

.product-description-section p {
  font-size: 16px;
  color: #000;
  line-height: 1.6;
}

/* Related products */
.related-products {
  margin-top: 40px;
}

.related-products h2 {
  font-size: 20px;
  margin-bottom: 20px;
  color: #333;
}

.related-products-list {
  display: flex;
  gap: 20px;
  overflow-x: auto;
  padding-bottom: 10px;
}

.related-product-card {
  width: 150px;
  flex-shrink: 0;
  text-align: center;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
  padding: 10px;
  border-radius: 8px;
}

.related-product-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 15px rgba(106, 90, 205, 0.2);
  background-color: #f8f7ff;
}

.related-product-image {
  width: 100%;
  height: 150px;
  border-radius: 10px;
  object-fit: cover;
  margin-bottom: 10px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.related-product-name {
  font-size: 14px;
  font-weight: bold;
  margin-bottom: 5px;
  color: #000;
}

.related-product-price {
  font-size: 14px;
  color: #000;
}

.add-to-cart-button {
  padding: 12px 24px;
  background-color: #28a745;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.3s;
}

.add-to-cart-button:hover {
  background-color: #218838;
}

.no-related-products {
  margin-top: 20px;
  font-size: 16px;
  color: #000;
}

/* Responsive fixes */
@media (max-width: 768px) {
  .product-main {
    flex-direction: column;
  }

  .product-images {
    flex-direction: column;
  }

  .product-thumbnails {
    flex-direction: row;
    height: auto;
    width: 100%;
    overflow-x: auto;
    overflow-y: hidden;
  }

  .product-main-image {
    width: 100%;
    height: auto;
    max-height: 400px;
  }

  .product-buttons {
    flex-direction: column;
  }
}
</style>
<style scoped>
/* Layout styles */
.page-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.content-container {
  flex: 1;
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

/* Product details */
.product-detail-container {
  display: flex;
  flex-direction: column;
  gap: 40px;
}

.product-main {
  display: flex;
  gap: 20px;
}

.product-images {
  display: flex;
  flex-direction: row;
  gap: 20px;
}

.product-thumbnails {
  display: flex;
  flex-direction: column;
  gap: 10px;
  height: 400px;
  justify-content: flex-start;
  overflow-y: auto;
}

.product-main-image {
  width: 400px;
  height: 400px;
  border-radius: 10px;
  object-fit: contain;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.product-thumbnail {
  width: 60px;
  height: 60px;
  border-radius: 5px;
  object-fit: cover;
  cursor: pointer;
  border: 1px solid #ddd;
  transition: border-color 0.3s;
}

.product-thumbnail:hover {
  border-color: #6a5acd;
}

.product-thumbnail.active {
  border-color: #6a5acd;
  border-width: 2px;
  box-shadow: 0 0 6px rgba(106, 90, 205, 0.5);
}

.product-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.product-title {
  font-size: 28px;
  font-weight: bold;
  color: #333;
  background: linear-gradient(45deg, #7c4dff, #6200ea);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
}

.product-author {
  font-size: 16px;
  color: #000000;
}

.product-price {
  font-size: 24px;
  font-weight: bold;
  color: #7c4dff;
}

.product-buttons {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.contact-button {
  padding: 12px 24px;
  background-color: #000;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.3s;
}

.contact-button:hover {
  background-color: #000000;
}

.buy-button {
  padding: 12px 24px;
  background-color: #6a5acd;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.3s;
}

.buy-button:hover {
  background-color: #5a4cbf;
}

.shipping-info {
  margin-top: 10px;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 5px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
}

.shipping-icon {
  font-size: 20px;
}

.shipping-info p {
  font-size: 16px;
  color: #000;
}

.cap-input {
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 5px;
  width: 100%;
}

/* Nuovo stile per la card del venditore */
.seller-info-card {
  margin-top: 10px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  overflow: hidden;
  background-color: #fff;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.seller-header {
  background-color: #f5f5f5;
  padding: 10px 15px;
  font-weight: 600;
  color: #444;
  border-bottom: 1px solid #e0e0e0;
}

.seller-details {
  padding: 15px;
  display: flex;
  align-items: center;
  gap: 15px;
}

.seller-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  overflow: hidden;
  background-color: #e0e0e0;
  border: 1px solid #ddd;
  flex-shrink: 0;
}

.seller-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  font-weight: bold;
  color: #000;
  background-color: #e9e9e9;
}

.seller-text {
  flex: 1;
}

.seller-name {
  font-weight: 600;
  color: #333;
  margin: 0 0 5px 0;
  font-size: 16px;
}

.seller-location {
  color: #000;
  margin: 0 0 5px 0;
  font-size: 14px;
}

.seller-member-since {
  color: #000;
  margin: 0 0 5px 0;
  font-size: 12px;
}

.seller-rating {
  display: flex;
  gap: 2px;
}

.star {
  color: #ffb74d;
  font-size: 16px;
}

.seller-info {
  margin-top: 10px;
  font-size: 16px;
  color: #000;
}

/* Product description */
.product-description-section {
  margin-top: 20px;
}

.product-description-section h2 {
  font-size: 20px;
  margin-bottom: 10px;
  color: #333;
}

.product-description-section p {
  font-size: 16px;
  color: #000;
  line-height: 1.6;
}

/* Related products */
.related-products {
  margin-top: 40px;
}

.related-products h2 {
  font-size: 20px;
  margin-bottom: 20px;
  color: #333;
}

.related-products-list {
  display: flex;
  gap: 20px;
  overflow-x: auto;
  padding-bottom: 10px;
}

.related-product-card {
  width: 150px;
  flex-shrink: 0;
  text-align: center;
}

.related-product-image {
  width: 100%;
  height: 150px;
  border-radius: 10px;
  object-fit: cover;
  margin-bottom: 10px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.related-product-name {
  font-size: 14px;
  font-weight: bold;
  margin-bottom: 5px;
  color: #000;
}

.related-product-price {
  font-size: 14px;
  color: #000;
}

.add-to-cart-button {
  padding: 12px 24px;
  background-color: #28a745;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.3s;
}

.add-to-cart-button:hover {
  background-color: #218838;
}

.add-to-cart-btn {
  background: linear-gradient(45deg, #7c4dff, #6200ea);
}

.add-to-cart-btn:hover {
  background: linear-gradient(45deg, #6200ea, #5502c7);
  box-shadow: 0 4px 15px rgba(124, 77, 255, 0.3);
}

.wishlist-btn {
  border: 2px solid #7c4dff;
  color: #7c4dff;
}

.wishlist-btn:hover {
  background: linear-gradient(45deg, #7c4dff, #6200ea);
  color: white;
}

/* Responsive fixes */
@media (max-width: 768px) {
  .product-main {
    flex-direction: column;
  }

  .product-images {
    flex-direction: column;
  }

  .product-thumbnails {
    flex-direction: row;
    height: auto;
    width: 100%;
    overflow-x: auto;
    overflow-y: hidden;
  }

  .product-main-image {
    width: 100%;
    height: auto;
    max-height: 400px;
  }

  .product-buttons {
    flex-direction: column;
  }
}
</style>

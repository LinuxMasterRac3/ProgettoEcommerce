<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRoute } from "vue-router";
import { createClient } from "@supabase/supabase-js";
import Navbar from "../../components/Navbar.vue";
import Footer from "../../components/footer.vue";

// Type definitions for better type safety
interface Book {
  id: string;
  name: string;
  description: string;
  price: number;
  image_url?: string;
  discountPercentage?: number;
  rating?: number;
  reviewCount?: number;
  created_at?: string;
  author?: string;
  publisher?: string;
  condition?: string;
  pages?: number;
  language?: string;
  isbn?: string;
  category?: string;
  user_id?: string;
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

// Supabase configuration
const supabaseUrl = "https://tiylfyyfitqzwstftzpg.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpeWxmeXlmaXRxendzdGZ0enBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNjYyNDcsImV4cCI6MjA1Njc0MjI0N30.CvIx_vI-KGGcFlcZy66-DIC8Itk03Olw3lzEMhnJP_c";
const supabase = createClient(supabaseUrl, supabaseKey);

// Component state
const route = useRoute();
const productId = route.params.id as string;
const product = ref<Book | null>(null);
const seller = ref<User | null>(null);
const isLoading = ref(true);
const error = ref<string | null>(null);
const relatedProducts = ref<Book[]>([]);

// Fetch product details
const fetchProductDetails = async () => {
  isLoading.value = true;
  error.value = null;

  try {
    // Get product details
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
        image_url: productData.image_url,
        discountPercentage: productData.discount_percentage,
        rating: productData.rating,
        reviewCount: productData.review_count,
        created_at: productData.created_at,
        author: productData.author,
        publisher: productData.publisher,
        condition: productData.condition,
        pages: productData.pages,
        language: productData.language,
        isbn: productData.isbn,
        category: productData.category,
        user_id: productData.user_id,
      };

      // Fetch seller information if user_id exists
      if (productData.user_id) {
        const { data: userData, error: userError } = await supabase
          .from("profiles")
          .select("*")
          .eq("id", productData.user_id)
          .single();

        if (!userError && userData) {
          seller.value = {
            id: userData.id,
            username: userData.username,
            email: userData.email,
            full_name: userData.full_name,
            avatar_url: userData.avatar_url,
            location: userData.location,
            phone: userData.phone,
            rating: userData.rating,
            memberSince: userData.created_at,
          };
        }
      }

      // Fetch related products (same category)
      if (productData.category) {
        const { data: relatedData, error: relatedError } = await supabase
          .from("products")
          .select("*")
          .eq("category", productData.category)
          .neq("id", productId)
          .limit(4);

        if (!relatedError && relatedData) {
          relatedProducts.value = relatedData.map((item) => ({
            id: item.id,
            name: item.name || "Titolo non disponibile",
            description: item.description || "Descrizione non disponibile",
            price: parseFloat(item.price) || 0,
            image_url: item.image_url,
            discountPercentage: item.discount_percentage,
            rating: item.rating,
            reviewCount: item.review_count,
          }));
        }
      }
    } else {
      throw new Error("Prodotto non trovato");
    }
  } catch (err) {
    console.error("Error fetching product details:", err);
    error.value =
      "Impossibile caricare i dettagli del prodotto. Riprova più tardi.";

    // Use placeholder data for development
    product.value = getPlaceholderProduct();
    seller.value = getPlaceholderSeller();
    relatedProducts.value = getPlaceholderRelatedProducts();
  } finally {
    isLoading.value = false;
  }
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

// Format date
const formatDate = (dateString?: string): string => {
  if (!dateString) return "Data non disponibile";
  return new Date(dateString).toLocaleDateString("it-IT", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
};

// Development placeholder data
const getPlaceholderProduct = (): Book => {
  return {
    id: "1",
    name: "Harry Potter e la Pietra Filosofale",
    description:
      "Il primo libro della saga di Harry Potter racconta le avventure del giovane mago Harry Potter, di Hermione Granger e di Ron Weasley, suoi amici e compagni di studi alla Scuola di Magia e Stregoneria di Hogwarts. Il libro narra la storia dalla scoperta da parte di Harry dei suoi poteri magici, fino alla pietra filosofale.",
    price: 15.99,
    image_url: "https://placehold.co/600x400?text=Harry+Potter",
    discountPercentage: 10,
    rating: 4.8,
    reviewCount: 123,
    created_at: "2023-05-15T10:30:00Z",
    author: "J.K. Rowling",
    publisher: "Salani Editore",
    condition: "Nuovo",
    pages: 324,
    language: "Italiano",
    isbn: "9788831003384",
    category: "Fantasy",
  };
};

const getPlaceholderSeller = (): User => {
  return {
    id: "u1",
    username: "librofilo",
    email: "librofilo@example.com",
    full_name: "Mario Rossi",
    avatar_url: "https://placehold.co/150x150?text=MR",
    location: "Roma, Italia",
    phone: "+39123456789",
    rating: 4.9,
    memberSince: "2022-01-10T00:00:00Z",
  };
};

const getPlaceholderRelatedProducts = (): Book[] => {
  return [
    {
      id: "2",
      name: "Harry Potter e la Camera dei Segreti",
      description: "Il secondo libro della saga di Harry Potter",
      price: 16.99,
      image_url: "https://placehold.co/300x200?text=HP+Camera+dei+Segreti",
      discountPercentage: 5,
      rating: 4.7,
      reviewCount: 112,
    },
    {
      id: "3",
      name: "Harry Potter e il Prigioniero di Azkaban",
      description: "Il terzo libro della saga di Harry Potter",
      price: 17.99,
      image_url: "https://placehold.co/300x200?text=HP+Prigioniero",
      discountPercentage: 0,
      rating: 4.9,
      reviewCount: 134,
    },
    {
      id: "4",
      name: "Il Signore degli Anelli",
      description: "La storia epica di Frodo e dell'anello",
      price: 25.99,
      image_url: "https://placehold.co/300x200?text=Il+Signore+degli+Anelli",
      discountPercentage: 0,
      rating: 4.9,
      reviewCount: 256,
    },
  ];
};

// Add to favorites functionality
const addToFavorites = async () => {
  if (!product.value) return;

  try {
    console.log(`Adding product ${product.value.id} to favorites`);
    // Placeholder for actual favorites implementation
    // const { data, error } = await supabase.from('favorites').insert({
    //   user_id: currentUser.id,
    //   product_id: product.value.id,
    //   created_at: new Date()
    // });
  } catch (err) {
    console.error("Error adding to favorites:", err);
  }
};

// Contact seller functionality
const contactSeller = () => {
  if (!seller.value) return;
  console.log(`Contacting seller: ${seller.value.email}`);
  // Implementation would depend on your app's messaging system
};

// Fetch product details when component is mounted
onMounted(() => {
  fetchProductDetails();
});
</script>

<template>
  <div class="app-container">
    <Navbar />

    <!-- Loading state -->
    <div
      v-if="isLoading"
      class="loading-container">
      <div class="loading-spinner"></div>
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

    <!-- Product details content -->
    <div
      v-else-if="product"
      class="product-detail-container">
      <div class="breadcrumb">
        <RouterLink to="/">Home</RouterLink> /
        <RouterLink to="/shop">Shop</RouterLink> /
        <span>{{ product.name }}</span>
      </div>

      <div class="product-main">
        <div class="product-image-container">
          <img
            :src="
              product.image_url || 'https://placehold.co/600x400?text=No+Image'
            "
            :alt="product.name"
            class="product-image" />
        </div>

        <div class="product-info">
          <h1 class="product-title">{{ product.name }}</h1>

          <div class="product-meta">
            <div
              v-if="product.author"
              class="meta-item">
              <span class="meta-label">Autore:</span>
              <span class="meta-value">{{ product.author }}</span>
            </div>
            <div
              v-if="product.publisher"
              class="meta-item">
              <span class="meta-label">Editore:</span>
              <span class="meta-value">{{ product.publisher }}</span>
            </div>
            <div
              v-if="product.isbn"
              class="meta-item">
              <span class="meta-label">ISBN:</span>
              <span class="meta-value">{{ product.isbn }}</span>
            </div>
          </div>

          <div
            class="product-rating"
            v-if="product.rating">
            <div class="stars">★★★★★</div>
            <span class="rating-value">{{ product.rating }}</span>
            <span class="review-count"
              >({{ product.reviewCount || 0 }} recensioni)</span
            >
          </div>

          <div class="product-price-container">
            <span class="current-price"
              >€{{ calculateDiscountedPrice(product) }}</span
            >
            <span
              v-if="
                product.discountPercentage && product.discountPercentage > 0
              "
              class="original-price">
              €{{ product.price ? product.price.toFixed(2) : "0.00" }}
            </span>
            <span
              v-if="
                product.discountPercentage && product.discountPercentage > 0
              "
              class="discount-tag">
              -{{ product.discountPercentage }}%
            </span>
          </div>

          <div class="product-details-list">
            <div
              v-if="product.condition"
              class="detail-item">
              <span class="detail-label">Condizioni:</span>
              <span class="detail-value">{{ product.condition }}</span>
            </div>
            <div
              v-if="product.pages"
              class="detail-item">
              <span class="detail-label">Pagine:</span>
              <span class="detail-value">{{ product.pages }}</span>
            </div>
            <div
              v-if="product.language"
              class="detail-item">
              <span class="detail-label">Lingua:</span>
              <span class="detail-value">{{ product.language }}</span>
            </div>
            <div
              v-if="product.category"
              class="detail-item">
              <span class="detail-label">Categoria:</span>
              <span class="detail-value">{{ product.category }}</span>
            </div>
            <div class="detail-item">
              <span class="detail-label">Data pubblicazione annuncio:</span>
              <span class="detail-value">{{
                formatDate(product.created_at)
              }}</span>
            </div>
          </div>

          <div class="product-actions">
            <button
              class="action-button favorite-button"
              @click="addToFavorites">
              <i class="far fa-heart"></i> Aggiungi ai preferiti
            </button>
            <button
              class="action-button contact-button"
              @click="contactSeller">
              <i class="far fa-envelope"></i> Contatta il venditore
            </button>
          </div>
        </div>
      </div>

      <div class="product-description">
        <h2 class="section-title">Descrizione</h2>
        <p class="description-text">{{ product.description }}</p>
      </div>

      <div
        class="seller-info"
        v-if="seller">
        <h2 class="section-title">Informazioni sul Venditore</h2>
        <div class="seller-card">
          <div class="seller-avatar">
            <img
              :src="
                seller.avatar_url || 'https://placehold.co/150x150?text=User'
              "
              :alt="seller.username || 'Venditore'" />
          </div>
          <div class="seller-details">
            <h3 class="seller-name">
              {{ seller.full_name || seller.username || "Venditore" }}
            </h3>
            <div
              v-if="seller.rating"
              class="seller-rating">
              <span class="stars">★★★★★</span>
              <span class="rating-value">{{ seller.rating }}</span>
            </div>
            <div
              class="seller-location"
              v-if="seller.location">
              <i class="fas fa-map-marker-alt"></i> {{ seller.location }}
            </div>
            <div class="seller-since">
              <span>Membro dal {{ formatDate(seller.memberSince) }}</span>
            </div>
          </div>
          <div class="seller-contact">
            <button
              class="contact-seller-button"
              @click="contactSeller">
              Contatta
            </button>
          </div>
        </div>
      </div>

      <div
        v-if="relatedProducts.length > 0"
        class="related-products">
        <h2 class="section-title">Libri Correlati</h2>
        <div class="related-products-grid">
          <div
            v-for="relatedProduct in relatedProducts"
            :key="relatedProduct.id"
            class="related-product-card">
            <RouterLink
              :to="`/product/${relatedProduct.id}`"
              class="related-product-link">
              <div
                class="related-product-image"
                :style="
                  relatedProduct.image_url
                    ? `background-image: url(${relatedProduct.image_url})`
                    : ''
                ">
                <div
                  v-if="
                    relatedProduct.discountPercentage &&
                    relatedProduct.discountPercentage > 0
                  "
                  class="discount-tag">
                  -{{ relatedProduct.discountPercentage }}%
                </div>
              </div>
              <div class="related-product-details">
                <h3 class="related-product-title">{{ relatedProduct.name }}</h3>
                <div class="related-product-price">
                  <span class="current-price"
                    >€{{ calculateDiscountedPrice(relatedProduct) }}</span
                  >
                  <span
                    v-if="
                      relatedProduct.discountPercentage &&
                      relatedProduct.discountPercentage > 0
                    "
                    class="original-price">
                    €{{
                      relatedProduct.price
                        ? relatedProduct.price.toFixed(2)
                        : "0.00"
                    }}
                  </span>
                </div>
              </div>
            </RouterLink>
          </div>
        </div>
      </div>
    </div>

    <Footer />
  </div>
</template>

<style scoped>
/* Base styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: "Inter", sans-serif;
  color: #333;
}

.app-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

/* Loading and error states */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 0;
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
  margin: 30px 0;
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

/* Breadcrumb styles */
.breadcrumb {
  padding: 20px 0;
  font-size: 14px;
  color: #666;
}

.breadcrumb a {
  color: #666;
  text-decoration: none;
}

.breadcrumb a:hover {
  color: #6a5acd;
}

/* Product main section styles */
.product-detail-container {
  margin-bottom: 50px;
}

.product-main {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 30px;
  margin-bottom: 40px;
}

.product-image-container {
  border-radius: 8px;
  overflow: hidden;
}

.product-image {
  width: 100%;
  height: auto;
  object-fit: cover;
}

.product-info {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.product-title {
  font-size: 28px;
  font-weight: 600;
  color: #222;
}

.product-meta {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.meta-item,
.detail-item {
  display: flex;
  gap: 5px;
}

.meta-label,
.detail-label {
  font-weight: 500;
  color: #555;
}

.product-rating {
  display: flex;
  align-items: center;
  gap: 5px;
}

.stars {
  color: #ffad33;
}

.rating-value {
  font-weight: 500;
}

.review-count {
  color: #777;
}

.product-price-container {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}

.current-price {
  font-size: 24px;
  font-weight: 600;
  color: #db4444;
}

.original-price {
  text-decoration: line-through;
  color: #999;
}

.discount-tag {
  background-color: #db4444;
  color: white;
  padding: 3px 8px;
  border-radius: 4px;
  font-size: 14px;
}

.product-details-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: 10px;
  padding-top: 15px;
  border-top: 1px solid #eee;
}

.product-actions {
  display: flex;
  gap: 15px;
  margin-top: 20px;
}

.action-button {
  padding: 12px 20px;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 5px;
}

.favorite-button {
  background-color: #f5f5f5;
  border: 1px solid #e0e0e0;
  color: #333;
}

.contact-button {
  background-color: #6a5acd;
  border: none;
  color: white;
}

/* Product description styles */
.product-description {
  margin-bottom: 40px;
  padding: 20px 0;
  border-top: 1px solid #eee;
}

.section-title {
  font-size: 20px;
  font-weight: 600;
  margin-bottom: 15px;
  color: #222;
}

.description-text {
  line-height: 1.6;
  color: #444;
}

/* Seller info styles */
.seller-info {
  margin-bottom: 40px;
  padding: 20px 0;
  border-top: 1px solid #eee;
}

.seller-card {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 20px;
  border: 1px solid #eee;
  border-radius: 8px;
  background-color: #f9f9f9;
}

.seller-avatar img {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  object-fit: cover;
}

.seller-details {
  flex: 1;
}

.seller-name {
  font-size: 18px;
  font-weight: 500;
  margin-bottom: 5px;
  color: #222;
}

.seller-rating {
  display: flex;
  align-items: center;
  gap: 5px;
  margin-bottom: 5px;
}

.seller-location,
.seller-since {
  font-size: 14px;
  color: #666;
  margin-bottom: 3px;
}

.contact-seller-button {
  padding: 10px 20px;
  background-color: #6a5acd;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

/* Related products styles */
.related-products {
  padding: 20px 0;
  border-top: 1px solid #eee;
}

.related-products-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

.related-product-card {
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid #eee;
}

.related-product-link {
  text-decoration: none;
  display: block;
}

.related-product-image {
  height: 180px;
  background-color: #f5f5f5;
  position: relative;
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
}

.related-product-details {
  padding: 12px;
}

.related-product-title {
  font-size: 14px;
  font-weight: 500;
  margin-bottom: 5px;
  color: #222;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.related-product-price {
  display: flex;
  align-items: center;
  gap: 5px;
}

/* Responsive styles */
@media (max-width: 992px) {
  .product-main {
    grid-template-columns: 1fr;
  }

  .related-products-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 768px) {
  .product-actions {
    flex-direction: column;
  }

  .related-products-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .seller-card {
    flex-direction: column;
    text-align: center;
  }

  .seller-contact {
    margin-top: 15px;
  }
}

@media (max-width: 576px) {
  .related-products-grid {
    grid-template-columns: 1fr;
  }
}
</style>

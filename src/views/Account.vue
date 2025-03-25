<template>
  <div
    class="account-container"
    v-if="user">
    <h1>Il Mio Account</h1>

    <div
      v-if="loading"
      class="loading">
      Caricamento informazioni dell'account...
    </div>

    <div
      v-if="errorMessage"
      class="error-message">
      {{ errorMessage }}
    </div>

    <div
      v-if="successMessage"
      class="success-message">
      {{ successMessage }}
    </div>

    <div
      class="account-sections"
      v-if="!loading">
      <!-- Personal Information Section -->
      <div class="account-section">
        <h2>Informazioni Personali</h2>
        <form @submit.prevent="updateProfile">
          <div class="form-group">
            <label for="firstName">Nome</label>
            <input
              id="firstName"
              v-model="profileData.first_name"
              type="text"
              placeholder="Il tuo nome" />
          </div>

          <div class="form-group">
            <label for="lastName">Cognome</label>
            <input
              id="lastName"
              v-model="profileData.last_name"
              type="text"
              placeholder="Il tuo cognome" />
          </div>

          <div class="form-group">
            <label for="phone">Numero di Telefono</label>
            <input
              id="phone"
              v-model="profileData.phone"
              type="tel"
              placeholder="Il tuo numero di telefono" />
          </div>

          <div class="form-group">
            <label for="description">Descrizione</label>
            <textarea
              id="description"
              v-model="profileData.description"
              placeholder="Descrizione del profilo"
              rows="3"></textarea>
          </div>

          <button
            type="submit"
            class="submit-btn">
            Aggiorna Profilo
          </button>
        </form>
      </div>

      <!-- Addresses Section -->
      <div class="account-section">
        <h2>Indirizzi di Spedizione</h2>
        <div
          v-if="addresses.length === 0"
          class="empty-list">
          Non hai ancora salvato nessun indirizzo.
        </div>

        <div
          v-else
          class="address-list">
          <div
            v-for="(address, index) in addresses"
            :key="index"
            class="address-card">
            <div class="address-details">
              <p>
                <strong>{{ address.name }}</strong>
              </p>
              <p>{{ address.street }}, {{ address.number }}</p>
              <p>{{ address.city }}, {{ address.zip_code }}</p>
              <p>{{ address.country }}</p>
            </div>
            <div class="address-actions">
              <button
                @click="editAddress(index)"
                class="action-btn">
                Modifica
              </button>
              <button
                @click="deleteAddress(address.id)"
                class="action-btn delete">
                Elimina
              </button>
            </div>
          </div>
        </div>

        <button
          @click="showAddressForm = true"
          class="submit-btn"
          v-if="!showAddressForm">
          Aggiungi Nuovo Indirizzo
        </button>

        <form
          v-if="showAddressForm"
          @submit.prevent="saveAddress"
          class="address-form">
          <div class="form-group">
            <label for="addressName">Nome Indirizzo</label>
            <input
              id="addressName"
              v-model="newAddress.name"
              type="text"
              placeholder="Es. Casa, Ufficio"
              required />
          </div>

          <div class="form-group">
            <label for="street">Via</label>
            <input
              id="street"
              v-model="newAddress.street"
              type="text"
              placeholder="Nome della via"
              required />
          </div>

          <div class="form-group">
            <label for="number">Numero Civico</label>
            <input
              id="number"
              v-model="newAddress.number"
              type="text"
              placeholder="Numero civico"
              required />
          </div>

          <div class="form-group">
            <label for="city">Città</label>
            <input
              id="city"
              v-model="newAddress.city"
              type="text"
              placeholder="Città"
              required />
          </div>

          <div class="form-group">
            <label for="zipCode">CAP</label>
            <input
              id="zipCode"
              v-model="newAddress.zip_code"
              type="text"
              placeholder="Codice postale"
              required />
          </div>

          <div class="form-group">
            <label for="country">Paese</label>
            <input
              id="country"
              v-model="newAddress.country"
              type="text"
              placeholder="Paese"
              required />
          </div>

          <div class="form-buttons">
            <button
              type="submit"
              class="submit-btn">
              Salva Indirizzo
            </button>
            <button
              type="button"
              @click="cancelAddressForm"
              class="cancel-btn">
              Annulla
            </button>
          </div>
        </form>
      </div>

      <!-- Orders History Section -->
      <div class="account-section">
        <h2>Storico Ordini</h2>
        <div
          v-if="orders.length === 0"
          class="empty-list">
          Non hai ancora effettuato ordini.
        </div>

        <div
          v-else
          class="orders-list">
          <div
            v-for="order in orders"
            :key="order.id"
            class="order-card">
            <div class="order-header">
              <h3>Ordine #{{ order.id }}</h3>
              <p>Data: {{ new Date(order.created_at).toLocaleDateString() }}</p>
              <p>
                Stato:
                <span :class="'status-' + order.status">{{
                  order.status
                }}</span>
              </p>
            </div>

            <div class="order-details">
              <p>Importo totale: €{{ order.total_amount.toFixed(2) }}</p>
              <button
                @click="toggleOrderDetails(order.id)"
                class="action-btn">
                {{
                  expandedOrders.includes(order.id)
                    ? "Nascondi Dettagli"
                    : "Mostra Dettagli"
                }}
              </button>
            </div>

            <div
              v-if="expandedOrders.includes(order.id)"
              class="order-items">
              <h4>Articoli:</h4>
              <div
                v-for="item in order.items"
                :key="item.id"
                class="order-item">
                <p>{{ item.product_name }} - Quantità: {{ item.quantity }}</p>
                <p>Prezzo unitario: €{{ item.unit_price.toFixed(2) }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Favorites Section -->
      <div class="account-section">
        <h2>Preferiti</h2>
        <div
          v-if="favorites.length === 0"
          class="empty-list">
          Non hai ancora prodotti nei preferiti.
        </div>

        <div
          v-else
          class="favorites-grid">
          <div
            v-for="favorite in favorites"
            :key="favorite.id"
            class="favorite-card">
            <img
              :src="favorite.product.image_url"
              :alt="favorite.product.name" />
            <div class="favorite-details">
              <h3>{{ favorite.product.name }}</h3>
              <p>€{{ favorite.product.price.toFixed(2) }}</p>
            </div>
            <div class="favorite-actions">
              <button
                @click="removeFavorite(favorite.id)"
                class="action-btn delete">
                Rimuovi
              </button>
              <button
                @click="addToCart(favorite.product_id)"
                class="action-btn">
                Aggiungi al Carrello
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Reviews Section -->
      <div class="account-section">
        <h2>Le Mie Recensioni</h2>
        <div
          v-if="reviews.length === 0"
          class="empty-list">
          Non hai ancora scritto recensioni.
        </div>

        <div
          v-else
          class="reviews-list">
          <div
            v-for="review in reviews"
            :key="review.id"
            class="review-card">
            <div class="review-header">
              <h3>{{ review.product.name }}</h3>
              <div class="rating">
                <span
                  v-for="i in 5"
                  :key="i"
                  class="star">
                  {{ i <= review.rating ? "★" : "☆" }}
                </span>
              </div>
              <p>
                Data: {{ new Date(review.created_at).toLocaleDateString() }}
              </p>
            </div>

            <div class="review-content">
              <p>{{ review.comment }}</p>
            </div>

            <div class="review-actions">
              <button
                @click="editReview(review)"
                class="action-btn">
                Modifica
              </button>
              <button
                @click="deleteReview(review.id)"
                class="action-btn delete">
                Elimina
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div
    v-else
    class="account-container">
    <h1>Accedi per visualizzare il tuo account</h1>
    <button
      @click="goToLogin"
      class="submit-btn">
      Vai al Login
    </button>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { useRouter } from "vue-router";
import { createClient } from "@supabase/supabase-js";

// Supabase configuration
const supabaseUrl = "https://tiylfyyfitqzwstftzpg.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpeWxmeXlmaXRxendzdGZ0enBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNjYyNDcsImV4cCI6MjA1Njc0MjI0N30.CvIx_vI-KGGcFlcZy66-DIC8Itk03Olw3lzEMhnJP_c";
const supabase = createClient(supabaseUrl, supabaseKey);

const router = useRouter();
const user = ref(null);
const loading = ref(true);
const errorMessage = ref("");
const successMessage = ref("");

// Profile data
const profileData = ref({
  first_name: "",
  last_name: "",
  phone: "",
  description: "",
});

// Addresses
const addresses = ref([]);
const showAddressForm = ref(false);
const newAddress = ref({
  name: "",
  street: "",
  number: "",
  city: "",
  zip_code: "",
  country: "",
  id: null, // Used when editing an existing address
});

// Orders
const orders = ref([]);
const expandedOrders = ref([]);

// Favorites
const favorites = ref([]);

// Reviews
const reviews = ref([]);

// Check if user is logged in and fetch user data
onMounted(async () => {
  const {
    data: { session },
  } = await supabase.auth.getSession();

  if (!session) {
    loading.value = false;
    return;
  }

  user.value = session.user;
  await fetchUserData();
});

// Fetch all user data
const fetchUserData = async () => {
  loading.value = true;
  errorMessage.value = "";

  try {
    await Promise.all([
      fetchProfile(),
      fetchAddresses(),
      fetchOrders(),
      fetchFavorites(),
      fetchReviews(),
    ]);
  } catch (error) {
    errorMessage.value =
      "Errore nel caricamento dei dati dell'account: " + error.message;
    console.error("Error fetching user data:", error);
  } finally {
    loading.value = false;
  }
};

// Fetch user profile
const fetchProfile = async () => {
  const { data, error } = await supabase
    .from("profiles")
    .select("*")
    .eq("user_id", user.value.id)
    .single();

  if (error) {
    if (error.code === "PGRST116") {
      // Profile doesn't exist yet, we'll create it on first save
      return;
    }
    throw error;
  }

  if (data) {
    profileData.value = data;
  }
};

// Update user profile
const updateProfile = async () => {
  try {
    const { data, error } = await supabase
      .from("profiles")
      .upsert({
        user_id: user.value.id,
        first_name: profileData.value.first_name,
        last_name: profileData.value.last_name,
        phone: profileData.value.phone,
        description: profileData.value.description,
        updated_at: new Date(),
      })
      .select();

    if (error) throw error;

    successMessage.value = "Profilo aggiornato con successo!";
    setTimeout(() => {
      successMessage.value = "";
    }, 3000);
  } catch (error) {
    errorMessage.value =
      "Errore durante l'aggiornamento del profilo: " + error.message;
    console.error("Error updating profile:", error);
  }
};

// Fetch addresses
const fetchAddresses = async () => {
  const { data, error } = await supabase
    .from("addresses")
    .select("*")
    .eq("user_id", user.value.id)
    .order("created_at", { ascending: false });

  if (error) throw error;

  addresses.value = data || [];
};

// Save address (new or edit)
const saveAddress = async () => {
  try {
    const addressData = {
      ...newAddress.value,
      user_id: user.value.id,
    };

    let operation;
    if (addressData.id) {
      // Update existing address
      operation = supabase
        .from("addresses")
        .update(addressData)
        .eq("id", addressData.id)
        .select();
    } else {
      // Create new address
      delete addressData.id;
      operation = supabase.from("addresses").insert(addressData).select();
    }

    const { data, error } = await operation;
    if (error) throw error;

    await fetchAddresses();
    resetAddressForm();
    successMessage.value = addressData.id
      ? "Indirizzo aggiornato!"
      : "Nuovo indirizzo aggiunto!";
    setTimeout(() => {
      successMessage.value = "";
    }, 3000);
  } catch (error) {
    errorMessage.value =
      "Errore nel salvataggio dell'indirizzo: " + error.message;
    console.error("Error saving address:", error);
  }
};

// Edit address
const editAddress = (index) => {
  const address = addresses.value[index];
  newAddress.value = { ...address };
  showAddressForm.value = true;
};

// Delete address
const deleteAddress = async (addressId) => {
  if (!confirm("Sei sicuro di voler eliminare questo indirizzo?")) return;

  try {
    const { error } = await supabase
      .from("addresses")
      .delete()
      .eq("id", addressId);

    if (error) throw error;

    await fetchAddresses();
    successMessage.value = "Indirizzo eliminato con successo";
    setTimeout(() => {
      successMessage.value = "";
    }, 3000);
  } catch (error) {
    errorMessage.value =
      "Errore durante l'eliminazione dell'indirizzo: " + error.message;
    console.error("Error deleting address:", error);
  }
};

// Reset address form
const resetAddressForm = () => {
  newAddress.value = {
    name: "",
    street: "",
    number: "",
    city: "",
    zip_code: "",
    country: "",
    id: null,
  };
  showAddressForm.value = false;
};

// Cancel address form
const cancelAddressForm = () => {
  resetAddressForm();
};

// Fetch orders
const fetchOrders = async () => {
  const { data, error } = await supabase
    .from("orders")
    .select(
      `
      *,
      items:order_items(*)
    `
    )
    .eq("user_id", user.value.id)
    .order("created_at", { ascending: false });

  if (error) throw error;

  orders.value = data || [];
};

// Toggle order details visibility
const toggleOrderDetails = (orderId) => {
  if (expandedOrders.value.includes(orderId)) {
    expandedOrders.value = expandedOrders.value.filter((id) => id !== orderId);
  } else {
    expandedOrders.value.push(orderId);
  }
};

// Fetch favorites
const fetchFavorites = async () => {
  const { data, error } = await supabase
    .from("favorites")
    .select(
      `
      *,
      product:products(*)
    `
    )
    .eq("user_id", user.value.id);

  if (error) throw error;

  favorites.value = data || [];
};

// Remove favorite
const removeFavorite = async (favoriteId) => {
  try {
    const { error } = await supabase
      .from("favorites")
      .delete()
      .eq("id", favoriteId);

    if (error) throw error;

    await fetchFavorites();
    successMessage.value = "Prodotto rimosso dai preferiti";
    setTimeout(() => {
      successMessage.value = "";
    }, 3000);
  } catch (error) {
    errorMessage.value =
      "Errore durante la rimozione del preferito: " + error.message;
    console.error("Error removing favorite:", error);
  }
};

// Add product to cart
const addToCart = (productId) => {
  // Implement cart functionality
  successMessage.value = "Prodotto aggiunto al carrello";
  setTimeout(() => {
    successMessage.value = "";
  }, 3000);
};

// Fetch reviews
const fetchReviews = async () => {
  const { data, error } = await supabase
    .from("reviews")
    .select(
      `
      *,
      product:products(*)
    `
    )
    .eq("user_id", user.value.id)
    .order("created_at", { ascending: false });

  if (error) throw error;

  reviews.value = data || [];
};

// Edit review
const editReview = (review) => {
  // Implement review editing functionality
  // This would typically show a form to edit the review
  console.log("Edit review:", review);
};

// Delete review
const deleteReview = async (reviewId) => {
  if (!confirm("Sei sicuro di voler eliminare questa recensione?")) return;

  try {
    const { error } = await supabase
      .from("reviews")
      .delete()
      .eq("id", reviewId);

    if (error) throw error;

    await fetchReviews();
    successMessage.value = "Recensione eliminata con successo";
    setTimeout(() => {
      successMessage.value = "";
    }, 3000);
  } catch (error) {
    errorMessage.value =
      "Errore durante l'eliminazione della recensione: " + error.message;
    console.error("Error deleting review:", error);
  }
};

// Navigate to login page
const goToLogin = () => {
  router.push("/login");
};
</script>

<style scoped>
.account-container {
  max-width: 1200px;
  margin: 2rem auto;
  padding: 0 1rem;
}

h1 {
  text-align: center;
  margin-bottom: 2rem;
  color: #333;
}

.loading {
  text-align: center;
  padding: 2rem;
  font-style: italic;
  color: #666;
}

.error-message {
  background-color: #ffebee;
  color: #d32f2f;
  padding: 0.75rem;
  border-radius: 4px;
  margin-bottom: 1rem;
  font-size: 0.875rem;
}

.success-message {
  background-color: #e8f5e9;
  color: #2e7d32;
  padding: 0.75rem;
  border-radius: 4px;
  margin-bottom: 1rem;
  font-size: 0.875rem;
}

.account-sections {
  display: grid;
  grid-template-columns: 1fr;
  gap: 2rem;
}

.account-section {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  padding: 1.5rem;
}

h2 {
  margin-top: 0;
  margin-bottom: 1.5rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid #eee;
  color: #444;
}

.form-group {
  margin-bottom: 1rem;
}

label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
}

input,
textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

textarea {
  resize: vertical;
}

.submit-btn {
  width: 100%;
  background-color: #4361ee;
  color: white;
  padding: 0.75rem;
  border: none;
  border-radius: 4px;
  font-size: 1rem;
  cursor: pointer;
  transition: background-color 0.2s;
}

.submit-btn:hover {
  background-color: #3a56d4;
}

.cancel-btn {
  width: 100%;
  background-color: #f5f5f5;
  color: #333;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
  cursor: pointer;
  margin-top: 0.5rem;
  transition: background-color 0.2s;
}

.cancel-btn:hover {
  background-color: #e5e5e5;
}

.empty-list {
  text-align: center;
  padding: 2rem;
  background-color: #f9f9f9;
  border-radius: 4px;
  color: #666;
  font-style: italic;
}

/* Addresses styling */
.address-list {
  display: grid;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.address-card {
  display: flex;
  justify-content: space-between;
  padding: 1rem;
  border: 1px solid #eee;
  border-radius: 4px;
  background-color: #f9f9f9;
}

.address-details p {
  margin: 0.25rem 0;
}

.address-actions {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.action-btn {
  background-color: #f0f0f0;
  color: #333;
  border: none;
  border-radius: 4px;
  padding: 0.5rem 0.75rem;
  cursor: pointer;
  font-size: 0.875rem;
  transition: background-color 0.2s;
}

.action-btn:hover {
  background-color: #e0e0e0;
}

.action-btn.delete {
  background-color: #ffebee;
  color: #d32f2f;
}

.action-btn.delete:hover {
  background-color: #ffcdd2;
}

.form-buttons {
  display: grid;
  gap: 0.5rem;
}

/* Orders styling */
.order-card {
  margin-bottom: 1rem;
  border: 1px solid #eee;
  border-radius: 4px;
  overflow: hidden;
}

.order-header {
  padding: 1rem;
  background-color: #f9f9f9;
  border-bottom: 1px solid #eee;
}

.order-header h3 {
  margin: 0 0 0.5rem 0;
}

.order-header p {
  margin: 0.25rem 0;
}

.status-completed {
  color: #2e7d32;
}

.status-processing {
  color: #1976d2;
}

.status-cancelled {
  color: #d32f2f;
}

.order-details {
  padding: 1rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.order-items {
  padding: 1rem;
  background-color: #f9f9f9;
  border-top: 1px solid #eee;
}

.order-item {
  margin-bottom: 0.5rem;
  padding: 0.5rem;
  background-color: white;
  border-radius: 4px;
}

/* Favorites styling */
.favorites-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 1rem;
}

.favorite-card {
  border: 1px solid #eee;
  border-radius: 4px;
  overflow: hidden;
}

.favorite-card img {
  width: 100%;
  height: 150px;
  object-fit: cover;
}

.favorite-details {
  padding: 0.75rem;
}

.favorite-details h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1rem;
}

.favorite-details p {
  margin: 0;
  font-weight: bold;
}

.favorite-actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.5rem;
  padding: 0.75rem;
}

/* Reviews styling */
.reviews-list {
  display: grid;
  gap: 1rem;
}

.review-card {
  border: 1px solid #eee;
  border-radius: 4px;
  overflow: hidden;
}

.review-header {
  padding: 1rem;
  background-color: #f9f9f9;
  border-bottom: 1px solid #eee;
}

.review-header h3 {
  margin: 0 0 0.5rem 0;
}

.rating {
  margin-bottom: 0.5rem;
}

.star {
  color: #ffc107;
  font-size: 1.25rem;
}

.review-content {
  padding: 1rem;
}

.review-actions {
  display: flex;
  gap: 0.5rem;
  padding: 0 1rem 1rem 1rem;
}

@media (min-width: 768px) {
  .account-section {
    padding: 2rem;
  }

  .address-list {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 992px) {
  .favorites-grid {
    grid-template-columns: repeat(3, 1fr);
  }

  .address-list {
    grid-template-columns: repeat(3, 1fr);
  }
}
</style>

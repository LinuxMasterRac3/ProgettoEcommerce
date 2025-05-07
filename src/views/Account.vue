<template>
  <div class="page-wrapper">
    <Navbar />

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
            <div class="profile-image-container">
              <div class="profile-image">
                <img
                  v-if="imagePreview"
                  :src="imagePreview"
                  alt="Immagine profilo" />
                <div
                  v-else
                  class="no-image">
                  <span>Nessuna immagine</span>
                </div>
              </div>
              <div class="image-upload">
                <label
                  v-if="!profileData.profile_image"
                  for="profileImage"
                  >Carica immagine profilo</label
                >

                <input
                  id="profileImage"
                  type="file"
                  accept="image/*"
                  @change="handleImageUpload" />
                <button
                  v-if="profileData.profile_image"
                  type="button"
                  @click="removeProfileImage"
                  class="remove-image-btn">
                  Rimuovi immagine
                </button>
              </div>
              <button
                @click="logout"
                class="logout-btn">
                Esci
              </button>
            </div>

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
                <p>
                  Data: {{ new Date(order.created_at).toLocaleDateString() }}
                </p>
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
                <p class="favorite-price">
                  €{{ favorite.product.price.toFixed(2) }}
                </p>
                <p
                  v-if="favorite.product.metadata?.author"
                  class="favorite-author">
                  di {{ favorite.product.metadata.author }}
                </p>
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
                <div class="review-product-info">
                  <img
                    :src="review.product.image_url"
                    :alt="review.product.name"
                    class="review-product-image" />
                  <div>
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
                      Data:
                      {{ new Date(review.created_at).toLocaleDateString() }}
                    </p>
                  </div>
                </div>
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
    <div class="login-message">
      Se non hai un account, puoi registrarti
      <router-link to="/register">qui</router-link>.
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { createClient } from "@supabase/supabase-js";
import Navbar from "../components/Navbar.vue";

// Supabase configuration
const supabaseUrl = "https://tiylfyyfitqzwstftzpg.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpeWxmeXlmaXRxendzdGZ0enBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNjYyNDcsImV4cCI6MjA1Njc0MjI0N30.CvIx_vI-KGGcFlcZy66-DIC8Itk03Olw3lzEMhnJP_c";
const supabase = createClient(supabaseUrl, supabaseKey);

// Configurazione per la gestione delle immagini
const maxImageSize = 1 * 1024 * 1024; // 1MB
const maxImageDimension = 1200; // Dimensione max per larghezza/altezza
const imageQuality = 0.7; // Qualità compressione JPEG

const router = useRouter();
const user = ref(null);
const loading = ref(true);
const successMessage = ref("");
const imagePreview = ref("");

// Profile data
const profileData = ref({
  first_name: "",
  last_name: "",
  phone: "",
  description: "",
  profile_image: "",
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
  id: null,
});

// Orders
const orders = ref([]);
const expandedOrders = ref([]);

// Favorites
const favorites = ref([]);

// Reviews
const reviews = ref([]);

// --- Lifecycle & Fetching ---

onMounted(async () => {
  try {
    const {
      data: { session },
    } = await supabase.auth.getSession();

    if (!session?.user) {
      loading.value = false;
      return;
    }

    user.value = session.user;
    await fetchUserData();
  } catch (error) {
    console.error("Errore durante l'inizializzazione:", error);
  } finally {
    loading.value = false;
  }
});

const logout = async () => {
  try {
    await supabase.auth.signOut();
    user.value = null;
    router.push("/login");
  } catch (err) {
    console.error("Errore durante il logout:", err.message);
  }
};

const fetchUserData = async () => {
  loading.value = true;
  successMessage.value = "";

  try {
    // Esegui le query in parallelo per migliorare le prestazioni
    await Promise.allSettled([
      fetchProfile(),
      fetchAddresses(),
      fetchOrders(),
      fetchFavorites(),
      fetchReviews(),
    ]);
  } catch (error) {
    console.error("Error fetching user data:", error);
  } finally {
    loading.value = false;
  }
};

// --- Profile & Image Handling ---

const fetchProfile = async () => {
  if (!user.value?.id) return;

  try {
    const { data, error } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", user.value.id)
      .single();

    if (error && error.code !== "PGRST116") {
      throw error;
    }

    if (data) {
      profileData.value = { ...profileData.value, ...data };

      if (data.profile_image) {
        imagePreview.value = data.profile_image;
      } else {
        imagePreview.value = "";
      }
    } else {
      profileData.value = {
        first_name: "",
        last_name: "",
        phone: "",
        description: "",
        profile_image: "",
      };
      imagePreview.value = "";
    }
  } catch (error) {
    console.error("Errore caricamento profilo:", error);
  }
};

const updateProfile = async () => {
  if (!user.value?.id) return;

  loading.value = true;
  successMessage.value = "";

  try {
    const profileUpdates = {
      id: user.value.id,
      user_id: user.value.id,
      first_name: profileData.value.first_name || null,
      last_name: profileData.value.last_name || null,
      phone: profileData.value.phone || null,
      description: profileData.value.description || null,
      profile_image: profileData.value.profile_image || null,
      updated_at: new Date().toISOString(),
    };

    const { error } = await supabase
      .from("profiles")
      .upsert(profileUpdates, { onConflict: "id" });

    if (error) throw error;

    successMessage.value = "Profilo aggiornato con successo!";
    setTimeout(() => {
      successMessage.value = "";
    }, 3000);
  } catch (error) {
    console.error("Errore aggiornamento profilo:", error);
  } finally {
    loading.value = false;
  }
};

const handleImageUpload = async (event) => {
  const file = event.target.files[0];
  if (!file) return;

  loading.value = true;
  successMessage.value = "";

  try {
    // Validazione
    if (!file.type.startsWith("image/")) {
      console.error("Formato immagine non valido");
      return;
    }
    if (file.size > maxImageSize) {
      console.error("Immagine troppo grande");
      return;
    }

    // Ottimizza immagine
    const optimizedBase64 = await processAndOptimizeImage(file);
    imagePreview.value = optimizedBase64;
    profileData.value.profile_image = optimizedBase64;
  } catch (error) {
    console.error("Errore caricamento immagine:", error);
  } finally {
    loading.value = false;
    event.target.value = null; // Resetta input file
  }
};

const removeProfileImage = async () => {
  const currentImage = profileData.value.profile_image;
  if (!currentImage) return;

  loading.value = true;

  // Rimuovi solo l'immagine dai dati del profilo e dall'anteprima
  profileData.value.profile_image = null;
  imagePreview.value = "";

  loading.value = false;
  successMessage.value = "Immagine rimossa.";
  setTimeout(() => {
    successMessage.value = "";
  }, 3000);
};

// Funzione helper per ottimizzare l'immagine
const processAndOptimizeImage = (file, returnBlob = false) => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      const img = new Image();
      img.onload = () => {
        try {
          let { width, height } = img;
          if (width > maxImageDimension || height > maxImageDimension) {
            if (width > height) {
              height *= maxImageDimension / width;
              width = maxImageDimension;
            } else {
              width *= maxImageDimension / height;
              height = maxImageDimension;
            }
          }
          const canvas = document.createElement("canvas");
          canvas.width = width;
          canvas.height = height;
          const ctx = canvas.getContext("2d");
          ctx.drawImage(img, 0, 0, width, height);

          if (returnBlob) {
            canvas.toBlob(
              (blob) => {
                if (blob) resolve(blob);
                else reject(new Error("Creazione Blob fallita"));
              },
              "image/jpeg",
              imageQuality
            );
          } else {
            const optimizedBase64 = canvas.toDataURL(
              "image/jpeg",
              imageQuality
            );
            resolve(optimizedBase64);
          }
        } catch (err) {
          reject(new Error("Errore ottimizzazione immagine"));
        }
      };
      img.onerror = () => reject(new Error("Impossibile caricare immagine"));
      img.src = e.target.result;
    };
    reader.onerror = () => reject(new Error("Errore lettura file"));
    reader.readAsDataURL(file);
  });
};

// --- Addresses ---

const fetchAddresses = async () => {
  if (!user.value?.id) return;

  try {
    const { data, error } = await supabase
      .from("addresses")
      .select("*")
      .eq("user_id", user.value.id)
      .order("created_at", { ascending: false });

    if (error) throw error;
    addresses.value = data || [];
  } catch (error) {
    console.error("Errore caricamento indirizzi:", error);
    addresses.value = [];
  }
};

const saveAddress = async () => {
  if (!user.value?.id) return;

  // Validazione dei campi obbligatori
  if (!validateAddress()) {
    return;
  }

  try {
    loading.value = true;

    // Clona l'oggetto per evitare modifiche dirette e aggiungi `user_id`
    const addressData = { ...newAddress.value, user_id: user.value.id };

    let operation;
    if (addressData.id) {
      operation = supabase
        .from("addresses")
        .update(addressData)
        .eq("id", addressData.id)
        .select();
    } else {
      delete addressData.id;
      operation = supabase.from("addresses").insert(addressData).select();
    }

    const { error } = await operation;
    if (error) throw error;

    // Aggiorna la lista degli indirizzi
    await fetchAddresses();

    // Resetta il form e mostra un messaggio di successo
    resetAddressForm();
    successMessage.value = addressData.id
      ? "Indirizzo aggiornato con successo!"
      : "Nuovo indirizzo salvato con successo!";
    setTimeout(() => {
      successMessage.value = "";
    }, 3000);
  } catch (error) {
    console.error("Error saving address:", error);
  } finally {
    loading.value = false;
  }
};

const editAddress = (index) => {
  newAddress.value = { ...addresses.value[index] };
  showAddressForm.value = true;
  document
    .querySelector(".address-form")
    ?.scrollIntoView({ behavior: "smooth" });
};

const deleteAddress = async (addressId) => {
  if (!user.value?.id) return;
  if (!confirm("Confermi l'eliminazione di questo indirizzo?")) return;

  try {
    const { error } = await supabase
      .from("addresses")
      .delete()
      .eq("id", addressId)
      .eq("user_id", user.value.id);

    if (error) throw error;

    await fetchAddresses();
    successMessage.value = "Indirizzo eliminato.";
    setTimeout(() => {
      successMessage.value = "";
    }, 3000);
  } catch (error) {
    console.error("Error deleting address:", error);
  }
};

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

const cancelAddressForm = () => {
  resetAddressForm();
};

// --- Orders ---

const fetchOrders = async () => {
  if (!user.value?.id) return;

  try {
    const { data, error } = await supabase
      .from("orders")
      .select(
        `
        id,
        created_at,
        status,
        total_amount,
        items:order_items ( id, product_name, quantity, unit_price )
      `
      )
      .eq("user_id", user.value.id)
      .order("created_at", { ascending: false });

    if (error) throw error;
    orders.value = data || [];
  } catch (error) {
    console.error("Errore caricamento ordini:", error);
    orders.value = [];
  }
};

const toggleOrderDetails = (orderId) => {
  const index = expandedOrders.value.indexOf(orderId);
  if (index > -1) {
    expandedOrders.value.splice(index, 1);
  } else {
    expandedOrders.value.push(orderId);
  }
};

// --- Favorites --- (Versione corretta senza relazione)
const fetchFavorites = async () => {
  if (!user.value?.id) return;

  try {
    // Step 1: Recupera prima i preferiti dell'utente
    const { data: favoritesData, error: favoritesError } = await supabase
      .from("favorites")
      .select("id, product_id, created_at")
      .eq("user_id", user.value.id);

    if (favoritesError) throw favoritesError;

    if (!favoritesData || favoritesData.length === 0) {
      favorites.value = [];
      return;
    }

    // Step 2: Ottieni i dettagli dei prodotti associati ai preferiti
    const productIds = favoritesData.map((fav) => fav.product_id);

    const { data: productsData, error: productsError } = await supabase
      .from("products")
      .select(
        "id, name, price, description, discount_percentage, rating, review_count, metadata"
      )
      .in("id", productIds);

    if (productsError) throw productsError;

    // Step 3: Combina i dati dei preferiti con i prodotti corrispondenti
    const processed = favoritesData
      .map((favorite) => {
        const product = productsData.find((p) => p.id === favorite.product_id);

        if (!product) return null;

        // Estrai l'URL immagine dal metadata o usa un placeholder
        let imageUrl = "https://placehold.co/300x400?text=No+Image";
        if (
          product.metadata?.additional_images &&
          product.metadata.additional_images.length > 0
        ) {
          imageUrl = product.metadata.additional_images[0];
        }

        return {
          id: favorite.id,
          product_id: favorite.product_id,
          created_at: favorite.created_at,
          product: {
            ...product,
            image_url: imageUrl,
            price:
              typeof product.price === "string"
                ? parseFloat(product.price)
                : product.price,
          },
        };
      })
      .filter((item) => item !== null);

    favorites.value = processed;
  } catch (error) {
    console.error("Errore caricamento preferiti:", error);
    favorites.value = [];
  }
};

const removeFavorite = async (favoriteId) => {
  if (!user.value?.id) return;

  try {
    const { error } = await supabase
      .from("favorites")
      .delete()
      .eq("id", favoriteId)
      .eq("user_id", user.value.id);

    if (error) throw error;

    await fetchFavorites();
    successMessage.value = "Rimosso dai preferiti.";
    setTimeout(() => {
      successMessage.value = "";
    }, 3000);
  } catch (error) {
    console.error("Error removing favorite:", error);
  }
};

// --- Reviews --- (Versione corretta senza relazione)
const fetchReviews = async () => {
  if (!user.value?.id) return;

  try {
    // Step 1: Recupera le recensioni dell'utente
    const { data: reviewsData, error: reviewsError } = await supabase
      .from("reviews")
      .select("id, rating, comment, created_at, product_id")
      .eq("user_id", user.value.id)
      .order("created_at", { ascending: false });

    if (reviewsError) throw reviewsError;

    if (!reviewsData || reviewsData.length === 0) {
      reviews.value = [];
      return;
    }

    // Step 2: Ottieni i dettagli dei prodotti associati alle recensioni
    const productIds = reviewsData.map((rev) => rev.product_id);

    const { data: productsData, error: productsError } = await supabase
      .from("products")
      .select(
        "id, name, price, description, discount_percentage, rating, review_count, metadata"
      )
      .in("id", productIds);

    if (productsError) throw productsError;

    // Step 3: Combina i dati delle recensioni con i prodotti corrispondenti
    const processed = reviewsData
      .map((review) => {
        const product = productsData.find((p) => p.id === review.product_id);

        if (!product) return null;

        // Estrai l'URL immagine dal metadata o usa un placeholder
        let imageUrl = "https://placehold.co/300x400?text=No+Image";
        if (
          product.metadata?.additional_images &&
          product.metadata.additional_images.length > 0
        ) {
          imageUrl = product.metadata.additional_images[0];
        }

        return {
          id: review.id,
          rating: review.rating,
          comment: review.comment,
          created_at: review.created_at,
          product_id: review.product_id,
          product: {
            ...product,
            image_url: imageUrl,
            price:
              typeof product.price === "string"
                ? parseFloat(product.price)
                : product.price,
          },
        };
      })
      .filter((item) => item !== null);

    reviews.value = processed;
  } catch (error) {
    console.error("Errore caricamento recensioni:", error);
    reviews.value = [];
  }
};

const editReview = (review) => {
  console.log("Modifica recensione (da implementare):", review);
  alert("Funzionalità modifica recensione da implementare.");
};

const deleteReview = async (reviewId) => {
  if (!user.value?.id) return;
  if (!confirm("Confermi l'eliminazione di questa recensione?")) return;

  try {
    const { error } = await supabase
      .from("reviews")
      .delete()
      .eq("id", reviewId)
      .eq("user_id", user.value.id);

    if (error) throw error;

    await fetchReviews();
    successMessage.value = "Recensione eliminata.";
    setTimeout(() => {
      successMessage.value = "";
    }, 3000);
  } catch (error) {
    console.error("Error deleting review:", error);
  }
};

// --- Cart ---
const addToCart = (productId) => {
  console.log(`Prodotto ID ${productId} aggiunto al carrello`);
  successMessage.value = "Prodotto aggiunto al carrello.";
  setTimeout(() => {
    successMessage.value = "";
  }, 2000);
};

// --- Navigation ---
const goToLogin = () => {
  router.push("/login");
};

const validateAddress = () => {
  if (
    !newAddress.value.name ||
    !newAddress.value.street ||
    !newAddress.value.city ||
    !newAddress.value.zip_code ||
    !newAddress.value.country
  ) {
    return false;
  }
  return true;
};
</script>

<style scoped>
/* Assicurati che .page-wrapper esista se lo usi per layout generale */
.page-wrapper {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.account-container {
  max-width: 1200px;
  margin: 2rem auto;
  padding: 0 1rem;
  flex-grow: 1; /* Fa sì che il container occupi lo spazio disponibile */
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
  background-color: #ffebee; /* Rosso chiaro */
  color: #c62828; /* Rosso scuro */
  padding: 0.8rem 1rem;
  border-radius: 4px;
  margin-bottom: 1.5rem;
  font-size: 0.9rem;
  border: 1px solid #ef9a9a; /* Bordo rosso chiaro */
}

.success-message {
  background-color: #e8f5e9; /* Verde chiaro */
  color: #2e7d32; /* Verde scuro */
  padding: 0.8rem 1rem;
  border-radius: 4px;
  margin-bottom: 1.5rem;
  font-size: 0.9rem;
  border: 1px solid #a5d6a7; /* Bordo verde chiaro */
}

.account-sections {
  display: grid;
  grid-template-columns: 1fr;
  gap: 2rem;
}

.account-section {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08); /* Ombra più leggera */
  padding: 1.5rem;
  border: 1px solid #e0e0e0; /* Bordo sottile */
}

h2 {
  margin-top: 0;
  margin-bottom: 1.5rem;
  padding-bottom: 0.75rem;
  border-bottom: 1px solid #eee;
  color: #444;
  font-size: 1.4em; /* Dimensione leggermente maggiore */
}

.form-group {
  margin-bottom: 1.2rem; /* Maggiore spazio */
}

label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #555;
}

input[type="text"],
input[type="tel"],
input[type="email"], /* Aggiunto per coerenza */
textarea {
  width: 100%;
  padding: 0.8rem 1rem; /* Padding leggermente maggiore */
  border: 1px solid #ccc; /* Bordo più scuro */
  border-radius: 4px;
  font-size: 1rem;
  box-sizing: border-box; /* Include padding/border nella larghezza */
  transition: border-color 0.2s, box-shadow 0.2s;
}
input:focus,
textarea:focus {
  border-color: #4361ee; /* Colore primario al focus */
  box-shadow: 0 0 0 2px rgba(67, 97, 238, 0.2); /* Glow al focus */
  outline: none;
}

textarea {
  resize: vertical;
  min-height: 80px; /* Altezza minima */
}

.submit-btn {
  display: inline-block; /* Permette width: auto se necessario */
  width: auto; /* Non sempre full-width */
  min-width: 150px; /* Larghezza minima */
  background-color: #4361ee; /* Blu primario */
  color: white;
  padding: 0.8rem 1.5rem; /* Padding orizzontale maggiore */
  border: none;
  border-radius: 4px;
  font-size: 1rem;
  font-weight: 500; /* Leggermente bold */
  cursor: pointer;
  text-align: center;
  transition: background-color 0.2s, transform 0.1s;
}
.submit-btn:hover {
  background-color: #3a56d4; /* Blu più scuro */
}
.submit-btn:active {
  transform: scale(0.98); /* Effetto pressione */
}
/* Stile specifico per il bottone di login quando l'utente non è loggato */
.account-container > .submit-btn {
  display: block;
  margin: 2rem auto 0; /* Centrato con margine sopra */
}

.cancel-btn {
  display: inline-block;
  width: auto;
  min-width: 120px;
  background-color: #f1f1f1; /* Grigio chiaro */
  color: #555;
  padding: 0.75rem 1.2rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 0.95rem;
  cursor: pointer;
  margin-top: 0; /* Rimuovi margine se nel form buttons */
  transition: background-color 0.2s, border-color 0.2s;
}

.cancel-btn:hover {
  background-color: #e5e5e5;
  border-color: #ccc;
}

.empty-list {
  text-align: center;
  padding: 2rem;
  background-color: #f9f9f9;
  border-radius: 4px;
  color: #777; /* Grigio più scuro */
  font-style: italic;
  border: 1px dashed #ddd; /* Bordo tratteggiato */
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
  align-items: flex-start; /* Allinea in alto */
  padding: 1rem 1.2rem;
  border: 1px solid #eee;
  border-radius: 6px; /* Angoli più arrotondati */
  background-color: #fff; /* Sfondo bianco */
  transition: box-shadow 0.2s;
}
.address-card:hover {
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.06);
}

.address-details p {
  margin: 0.25rem 0;
  font-size: 0.95rem;
  color: #555;
}
.address-details strong {
  color: #333;
  font-weight: 600; /* Nome indirizzo più marcato */
}

.address-actions {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-left: 1rem; /* Spazio dai dettagli */
  flex-shrink: 0; /* Evita che i bottoni si restringano */
}

.action-btn {
  background-color: #f0f0f0;
  color: #444;
  border: 1px solid #ddd;
  border-radius: 4px;
  padding: 0.4rem 0.8rem; /* Leggermente più piccolo */
  cursor: pointer;
  font-size: 0.85rem; /* Testo più piccolo */
  transition: background-color 0.2s, border-color 0.2s;
}

.action-btn:hover {
  background-color: #e5e5e5;
  border-color: #ccc;
}

.action-btn.delete {
  background-color: #fff0f0; /* Rosso molto chiaro */
  color: #d32f2f; /* Rosso scuro */
  border-color: #ffcdd2; /* Bordo rosso chiaro */
}

.action-btn.delete:hover {
  background-color: #ffebee; /* Rosso più intenso su hover */
}

.address-form {
  margin-top: 1.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid #eee;
}

.form-buttons {
  display: flex; /* Bottoni affiancati */
  gap: 0.8rem;
  margin-top: 1.5rem; /* Spazio sopra i bottoni */
  flex-wrap: wrap; /* Permette ai bottoni di andare a capo */
}
.form-buttons .submit-btn,
.form-buttons .cancel-btn {
  width: auto; /* Larghezza automatica */
}

/* Orders styling */
.order-card {
  margin-bottom: 1.5rem; /* Aumenta spazio */
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  background-color: #fff;
  overflow: hidden;
}

.order-header {
  padding: 1rem 1.2rem;
  background-color: #f8f8f8; /* Grigio molto chiaro */
  border-bottom: 1px solid #eee;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap; /* Permette wrap su mobile */
  gap: 0.5rem;
}

.order-header h3 {
  margin: 0;
  font-size: 1.1em;
}

.order-header p {
  margin: 0;
  font-size: 0.9em;
  color: #666;
}
.order-header span[class^="status-"] {
  font-weight: 500;
  padding: 0.2em 0.5em;
  border-radius: 4px;
  font-size: 0.85em;
}

.status-completed {
  color: #2e7d32;
  background-color: #e8f5e9;
}
.status-processing {
  color: #1976d2;
  background-color: #e3f2fd;
}
.status-shipped {
  color: #ef6c00;
  background-color: #fff3e0;
} /* Aggiunto status spedito */
.status-cancelled {
  color: #d32f2f;
  background-color: #ffebee;
}
.status-pending {
  color: #546e7a;
  background-color: #eceff1;
} /* Aggiunto status pendente */

.order-details {
  padding: 1rem 1.2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.order-details p {
  margin: 0;
  font-weight: 500;
}

.order-items {
  padding: 1rem 1.2rem;
  background-color: #fafafa; /* Sfondo leggermente diverso */
  border-top: 1px solid #eee;
}
.order-items h4 {
  margin-top: 0;
  margin-bottom: 0.8rem;
  font-size: 1em;
  color: #555;
}

.order-item {
  margin-bottom: 0.8rem;
  padding: 0.8rem;
  background-color: white;
  border-radius: 4px;
  border: 1px solid #eee;
  font-size: 0.9rem;
}
.order-item p {
  margin: 0.2rem 0;
}
.order-item:last-child {
  margin-bottom: 0;
}

/* Favorites styling */
.favorites-grid {
  display: grid;
  grid-template-columns: repeat(
    auto-fill,
    minmax(180px, 1fr)
  ); /* Minimo più piccolo */
  gap: 1rem;
}

.favorite-card {
  border: 1px solid #eee;
  border-radius: 6px;
  overflow: hidden;
  background-color: #fff;
  display: flex;
  flex-direction: column; /* Contenuto verticale */
  transition: box-shadow 0.2s;
}
.favorite-card:hover {
  box-shadow: 0 3px 8px rgba(0, 0, 0, 0.08);
}

.favorite-card img {
  width: 100%;
  height: 180px; /* Altezza fissa immagine */
  object-fit: cover;
  border-bottom: 1px solid #eee;
}

.favorite-details {
  padding: 0.8rem;
  flex-grow: 1; /* Occupa spazio disponibile */
}

.favorite-details h3 {
  margin: 0 0 0.4rem 0;
  font-size: 0.95rem;
  font-weight: 600;
  line-height: 1.3; /* Per nomi lunghi */
  /* Tronca testo lungo se necessario */
  /* display: -webkit-box;
   -webkit-line-clamp: 2;
   -webkit-box-orient: vertical;
   overflow: hidden; */
}

.favorite-details p {
  margin: 0;
  font-weight: 600; /* Prezzo bold */
  color: #4361ee; /* Colore primario */
}

.favorite-actions {
  display: grid;
  grid-template-columns: 1fr; /* Bottoni uno sotto l'altro */
  gap: 0.5rem;
  padding: 0.8rem;
  border-top: 1px solid #eee;
}
.favorite-actions .action-btn {
  width: 100%; /* Bottoni a larghezza piena */
  text-align: center;
}

.favorite-author {
  margin: 0.2rem 0 0 0;
  font-size: 0.85rem;
  color: #666;
  font-style: italic;
}

.favorite-price {
  margin: 0.4rem 0;
  font-weight: 600;
  color: #4361ee;
}

/* Reviews styling */
.reviews-list {
  display: grid;
  gap: 1.5rem;
}

.review-card {
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  background-color: #fff;
  overflow: hidden;
}

.review-header {
  padding: 1rem 1.2rem;
  background-color: #f8f8f8;
  border-bottom: 1px solid #eee;
}

.review-header h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.1em;
}
.review-header p {
  font-size: 0.85em;
  color: #777;
  margin-top: 0.5rem;
  margin-bottom: 0;
}

.rating {
  margin-bottom: 0.5rem;
}

.star {
  color: #ffb74d; /* Arancione più chiaro */
  font-size: 1.3rem;
  margin-right: 1px;
}

.review-content {
  padding: 1rem 1.2rem;
  font-size: 0.95rem;
  line-height: 1.5;
  color: #444;
}
.review-content p {
  margin: 0;
}

.review-actions {
  display: flex;
  gap: 0.8rem;
  padding: 0 1.2rem 1rem 1.2rem;
  border-top: 1px solid #eee;
  margin-top: 1rem;
  padding-top: 1rem;
}

/* Profile Image styling */
.profile-image-container {
  display: flex;
  gap: 1.5rem;
  margin-bottom: 2rem; /* Maggiore spazio sotto */
  align-items: center;
  flex-wrap: wrap; /* Wrap su mobile */
}

.profile-image {
  width: 120px; /* Leggermente più piccolo */
  height: 120px;
  border-radius: 50%;
  overflow: hidden;
  background-color: #e0e0e0; /* Grigio più scuro per placeholder */
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid #ccc; /* Bordo più spesso */
  flex-shrink: 0; /* Non restringere */
}

.profile-image img {
  width: 100%;
  height: 100%;
  object-fit: cover; /* Copre mantenendo proporzioni */
}

.no-image {
  color: #888;
  font-size: 0.9em;
  text-align: center;
  padding: 10px;
}

.image-upload input[type="file"] {
  display: none;
}

.image-upload label {
  cursor: pointer;
  color: #4361ee;
  text-decoration: underline;
}

.image-upload input[type="file"] + label {
  display: inline-block;
  background-color: #f0f0f0;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.remove-image-btn {
  background-color: #ffebee;
  color: #d32f2f;
  border: none;
  border-radius: 4px;
  padding: 0.5rem 0.8rem;
  cursor: pointer;
  transition: background-color 0.2s;
  font-size: 0.875rem;
  align-self: flex-start; /* Allinea a sinistra */
}

.remove-image-btn:hover {
  background-color: #ffcdd2;
}

.image-info {
  font-size: 0.8rem;
  color: #666;
  margin-top: 0.2rem; /* Meno spazio */
}

/* Debug Container */
.debug-container {
  margin-top: 2rem;
  padding: 1rem;
  background-color: #f1f1f1;
  border: 1px dashed #ccc;
  border-radius: 4px;
  font-size: 0.85rem;
}
.debug-container h2 {
  font-size: 1.1em;
  margin-bottom: 0.8rem;
  border-bottom: none;
}
.storage-info {
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
  color: #555;
}
.storage-info strong {
  color: #333;
}

/* Responsive adjustments */
@media (min-width: 768px) {
  .account-sections {
    /* Due colonne su schermi medi e grandi */
    /* grid-template-columns: repeat(2, 1fr); */
    /* Manteniamo una colonna per leggibilità, ma puoi cambiare se preferisci */
  }
  .account-section {
    padding: 2rem;
  }
  .address-list {
    grid-template-columns: repeat(2, 1fr); /* 2 colonne indirizzi */
  }
  .form-buttons {
    justify-content: flex-start; /* Allinea bottoni a sinistra */
  }
}

@media (min-width: 992px) {
  .favorites-grid {
    grid-template-columns: repeat(3, 1fr); /* 3 colonne preferiti */
  }
  /* Puoi decidere se vuoi 3 colonne per gli indirizzi su schermi grandi */
  /* .address-list {
     grid-template-columns: repeat(3, 1fr);
   } */
  .favorite-actions {
    grid-template-columns: 1fr 1fr; /* Bottoni preferiti affiancati */
  }
}

@media (min-width: 1200px) {
  .favorites-grid {
    grid-template-columns: repeat(4, 1fr); /* 4 colonne preferiti */
  }
}

.review-product-info {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
}

.review-product-image {
  width: 80px;
  height: 80px;
  border-radius: 4px;
  object-fit: cover;
  border: 1px solid #eee;
}
.logout-btn {
  background-color: #d32f2f;
  color: white;
  padding: 0.8rem 1.5rem;
  border: none;
  border-radius: 4px;
  font-size: 1rem;
  cursor: pointer;
  transition: background-color 0.2s;
}
.logout-btn:hover {
  background-color: #b71c1c;
}
</style>

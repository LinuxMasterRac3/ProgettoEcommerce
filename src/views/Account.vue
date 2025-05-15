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
                <label for="profileImage" class="upload-label">
                  <i class="fas fa-camera"></i>
                  {{ profileData.profile_image ? 'Cambia foto' : 'Carica foto' }}
                </label>
                <input
                  id="profileImage"
                  type="file"
                  accept="image/*"
                  @change="handleImageUpload"
                  class="hidden-input" />
                <button
                  v-if="profileData.profile_image"
                  type="button"
                  @click="removeProfileImage"
                  class="remove-image-btn">
                  <i class="fas fa-trash"></i>
                  Rimuovi
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

        <!-- My Listings Section -->
        <div class="account-section">
          <h2>I Miei Annunci</h2>
          <div v-if="listings.length === 0" class="empty-list">
            <p>Non hai ancora pubblicato nessun annuncio.</p>
            <router-link to="/addbook" class="add-listing-link">
              Crea il tuo primo annuncio
            </router-link>
          </div>

          <div
            v-else
            class="listings-list">
            <div
              v-for="listing in listings"
              :key="listing.id"
              class="listing-card">
              <div class="listing-image">
                <img
                  :src="getListingImage(listing)"
                  :alt="listing.name"
                  class="listing-thumbnail" />
              </div>
              <div class="listing-details">
                <h3>{{ listing.name }}</h3>
                <p class="listing-price">
                  €{{ (listing.price || 0).toFixed(2) }}
                </p>
                <p
                  class="listing-status"
                  :class="'status-' + listing.status">
                  {{ translateStatus(listing.status) }}
                </p>
                <p class="listing-date">
                  Pubblicato il: {{ formatDate(listing.created_at) }}
                </p>
              </div>
              <div class="listing-actions">
                <router-link
                  :to="`/product/${listing.id}`"
                  class="action-btn view">
                  Visualizza
                </router-link>
                <button
                  @click="editListing(listing)"
                  class="action-btn">
                  Modifica
                </button>
                <button
                  @click="deleteListing(listing.id)"
                  class="action-btn delete">
                  Elimina
                </button>
              </div>
            </div>
          </div>

          <router-link
            to="/addbook"
            class="submit-btn create-listing-btn">
            Pubblica un nuovo annuncio
          </router-link>
        </div>

        <!-- Account Settings Section -->
        <div class="account-section logout-section">
          <h2>Impostazioni Account</h2>
          <div class="logout-container">
            <p class="logout-text">Vuoi uscire dal tuo account?</p>
            <button @click="logout" class="logout-btn">
              <i class="fas fa-sign-out-alt"></i>
              Esci dall'account
            </button>
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
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { createClient } from "@supabase/supabase-js";
import Navbar from "../components/Navbar.vue";

// Supabase configuration
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
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

// Reviews
const reviews = ref([]);

// Listings
const listings = ref([]);
const editMode = ref(false);
const currentListing = ref(null);

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
      fetchReviews(),
      fetchListings(), // Add listings fetch
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
    // Verifica se esiste già un profilo
    const { data: existingProfile } = await supabase
      .from('profiles')
      .select('id')
      .eq('id', user.value.id)
      .single();

    const profileUpdates = {
      id: user.value.id,
      first_name: profileData.value.first_name || null,
      last_name: profileData.value.last_name || null,
      phone: profileData.value.phone || null,
      description: profileData.value.description || null,
      profile_image: profileData.value.profile_image || null,
      updated_at: new Date().toISOString(),
    };

    // Aggiungi user_id solo per una nuova creazione
    if (!existingProfile) {
      profileUpdates.user_id = user.value.id;
    }

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
    alert("Si è verificato un errore durante l'aggiornamento del profilo");
  } finally {
    loading.value = false;
  }
};

const handleImageUpload = async (event) => {
  const file = event.target.files[0];
  if (!file) return;

  // Check if user is authenticated
  if (!user.value?.id) {
    alert("Devi effettuare il login per aggiornare l'immagine del profilo");
    return;
  }

  loading.value = true;
  successMessage.value = "";

  try {
    // Validazione del file
    if (!file.type.startsWith("image/")) {
      alert("Per favore seleziona un'immagine valida");
      return;
    }
    
    if (file.size > maxImageSize) {
      alert("L'immagine è troppo grande. Dimensione massima: 1MB");
      return;
    }

    // Converti l'immagine in Base64
    const reader = new FileReader();
    reader.onload = async (e) => {
      try {
        // Ottimizza e converti l'immagine
        const optimizedImage = await processAndOptimizeImage(file);
        
        // Aggiorna l'anteprima
        imagePreview.value = optimizedImage;
        
        // Aggiorna i dati del profilo
        profileData.value.profile_image = optimizedImage;
        
        // Verifica se esiste già un profilo per questo utente
        const { data: existingProfile } = await supabase
          .from('profiles')
          .select('id')
          .eq('id', user.value.id)
          .single();

        let operation;
        if (existingProfile) {
          // Aggiorna il profilo esistente
          operation = supabase
            .from('profiles')
            .update({
              profile_image: optimizedImage,
              updated_at: new Date().toISOString()
            })
            .eq('id', user.value.id);
        } else {
          // Crea un nuovo profilo
          operation = supabase
            .from('profiles')
            .insert({
              id: user.value.id,
              user_id: user.value.id, // Importante: imposta sia id che user_id
              profile_image: optimizedImage,
              updated_at: new Date().toISOString()
            });
        }

        const { error } = await operation;
        if (error) throw error;

        successMessage.value = "Immagine del profilo aggiornata con successo!";
        setTimeout(() => {
          successMessage.value = "";
        }, 3000);

      } catch (error) {
        console.error("Errore durante il salvataggio dell'immagine:", error);
        alert("Si è verificato un errore durante il salvataggio dell'immagine");
      } finally {
        loading.value = false;
      }
    };

    reader.onerror = () => {
      loading.value = false;
      alert("Errore durante la lettura del file");
    };

    reader.readAsDataURL(file);
  } catch (error) {
    console.error("Errore durante il caricamento dell'immagine:", error);
    alert("Si è verificato un errore durante il caricamento dell'immagine");
    loading.value = false;
  }
};

const removeProfileImage = async () => {
  if (!profileData.value.profile_image) return;
  
  // Check if user is authenticated
  if (!user.value?.id) {
    alert("Devi effettuare il login per rimuovere l'immagine del profilo");
    return;
  }

  loading.value = true;
  try {
    const { error } = await supabase
      .from('profiles')
      .update({ 
        profile_image: null,
        updated_at: new Date().toISOString()
      })
      .eq('id', user.value.id);

    if (error) throw error;

    profileData.value.profile_image = null;
    imagePreview.value = "";
    
    successMessage.value = "Immagine del profilo rimossa con successo";
    setTimeout(() => {
      successMessage.value = "";
    }, 3000);
  } catch (error) {
    console.error("Errore durante la rimozione dell'immagine:", error);
    alert("Si è verificato un errore durante la rimozione dell'immagine");
  } finally {
    loading.value = false;
  }
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

// --- Listings ---

const fetchListings = async () => {
  if (!user.value?.id) return;

  try {
    const { data, error } = await supabase
      .from("products")
      .select("*")
      .eq("user_id", user.value.id)
      .order("created_at", { ascending: false });

    if (error) throw error;
    listings.value = data || [];
  } catch (error) {
    console.error("Errore caricamento annunci:", error);
    listings.value = [];
  }
};

const getListingImage = (listing) => {
  // First check metadata for additional_images
  if (
    listing.metadata?.additional_images &&
    listing.metadata.additional_images.length > 0
  ) {
    return listing.metadata.additional_images[0];
  }

  // Then check image_url
  if (listing.image_url) {
    return listing.image_url;
  }

  // Default placeholder
  return "https://placehold.co/300x400?text=No+Image";
};

const formatDate = (dateString) => {
  if (!dateString) return "";

  const options = { year: "numeric", month: "long", day: "numeric" };
  return new Date(dateString).toLocaleDateString("it-IT", options);
};

const translateStatus = (status) => {
  const statusMap = {
    active: "Attivo",
    sold: "Venduto",
    pending: "In attesa",
    draft: "Bozza",
    inactive: "Non attivo",
  };

  return statusMap[status] || status;
};

const editListing = (listing) => {
  // Navigate to edit page with listing ID
  router.push(`/editbook/${listing.id}`);
};

const deleteListing = async (listingId) => {
  if (
    !confirm(
      "Sei sicuro di voler eliminare questo annuncio? Questa azione non può essere annullata."
    )
  ) {
    return;
  }

  loading.value = true;

  try {
    // Delete from Supabase
    const { error } = await supabase
      .from("products")
      .delete()
      .eq("id", listingId)
      .eq("user_id", user.value.id);

    if (error) throw error;

    // If listing had Stripe product, delete it
    // This is just placeholder logic - implement based on your Stripe integration
    try {
      const { data: product } = await supabase
        .from("products")
        .select("stripe_product_id")
        .eq("id", listingId)
        .single();

      if (product?.stripe_product_id) {
        // Call your API to delete from Stripe
        fetch("http://localhost:3000/api/delete-stripe-products", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ productIds: [product.stripe_product_id] }),
        });
      }
    } catch (stripeError) {
      console.error("Error deleting from Stripe:", stripeError);
      // Continue anyway
    }

    // Update UI
    await fetchListings();
    successMessage.value = "Annuncio eliminato con successo";
    setTimeout(() => {
      successMessage.value = "";
    }, 3000);
  } catch (error) {
    console.error("Error deleting listing:", error);
    alert("Si è verificato un errore durante l'eliminazione dell'annuncio.");
  } finally {
    loading.value = false;
  }
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
/* Main Layout */
.page-wrapper {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background-color: #f8f9fa;
}

/* Main Layout Improvements */
.account-container {
  max-width: 2000px; /* Increased from 1800px */
  margin: 3rem auto;
  padding: 2rem 10rem; /* Increased padding */
  flex-grow: 1;
  width: 95%; /* Added to ensure consistent width */
}

.account-container {
  max-width: 1600px; /* Increased from 1400px */
  margin: 3rem auto;
  padding: 2rem 6rem; /* Increased horizontal padding */
  flex-grow: 1;
}

/* Header Styling */
h1 {
  font-size: 2.8rem;
  text-align: center;
  margin-bottom: 3.5rem;
  color: #2C3E50;
  font-weight: 800;
  position: relative;
  padding-bottom: 1.5rem;
}

h1::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 100px;
  height: 4px;
  background: #6B46C1;
  border-radius: 4px;
}

/* Section Styling */
.account-section {
  background: white;
  border-radius: 30px; /* Increased from 24px */
  box-shadow: 0 8px 30px rgba(107, 70, 193, 0.08);
  padding: 6rem 10rem; /* Increased padding */
  margin-bottom: 6rem; /* Increased margin */
  border: 1px solid rgba(107, 70, 193, 0.1);
  transition: all 0.3s ease;
}

.account-section {
  background: white;
  border-radius: 24px; /* Increased from 20px */
  box-shadow: 0 8px 30px rgba(107, 70, 193, 0.08);
  padding: 4rem 6rem; /* Increased horizontal padding */
  margin-bottom: 4rem; /* Increased from 3rem */
  border: 1px solid rgba(107, 70, 193, 0.1);
  transition: all 0.3s ease;
}

.account-section:hover {
  transform: translateY(-3px);
  box-shadow: 0 12px 40px rgba(107, 70, 193, 0.12);
}

h2 {
  font-size: 2rem;
  color: #2C3E50;
  margin-bottom: 2.5rem;
  padding-bottom: 1rem;
  border-bottom: 2px solid #f0f0f0;
  font-weight: 700;
  position: relative;
}

h2::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 60px;
  height: 3px;
  background: #6B46C1;
}

/* Form Styling */
.form-group {
  max-width: 1400px; /* Increased width */
  margin: 0 auto 2.5rem; /* Center the form groups */
}

.form-group {
  max-width: 1000px; /* Increased from 800px */
  margin: 0 auto 2.5rem; /* Center the form groups */
}

label {
  display: block;
  margin-bottom: 1rem;
  font-weight: 600;
  color: #2C3E50;
  font-size: 1rem;
}

input[type="text"],
input[type="tel"],
input[type="email"],
textarea {
  width: 100%;
  padding: 1.2rem;
  border: 2px solid #e6e6e6;
  border-radius: 12px;
  font-size: 1rem;
  transition: all 0.3s ease;
  background: #ffffff;
  margin-bottom: 0.5rem;
}

input:focus,
textarea:focus {
  border-color: #6B46C1;
  box-shadow: 0 0 0 4px rgba(107, 70, 193, 0.1);
  outline: none;
}

/* Button Styling */
.submit-btn, .action-btn {
  background: #6B46C1;
  color: white;
  padding: 1.2rem 2.5rem;
  border-radius: 12px;
  font-weight: 600;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  font-size: 0.95rem;
  margin: 0.5rem;
}

.submit-btn:hover, .action-btn:hover {
  background: #553C9A;
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(107, 70, 193, 0.25);
}

/* Profile Image Section */
.profile-image-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 2rem;
  background: linear-gradient(to right bottom, #ffffff, #f8f9fa);
  border-radius: 20px;
  padding: 6rem 10rem;
  max-width: 1400px; /* Increased width */
  margin: 0 auto; /* Center the container */
}

.profile-image-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 2rem;
  background: linear-gradient(to right bottom, #ffffff, #f8f9fa);
  border-radius: 20px;
  padding: 4rem 6rem; /* Increased padding */
  max-width: 1000px; /* Increased from 800px */
  margin: 0 auto; /* Center the container */
}

.profile-image {
  width: 240px; /* Increased from 200px */
  height: 240px; /* Increased from 200px */
  border: 6px solid white;
  box-shadow: 0 12px 30px rgba(107, 70, 193, 0.15);
}

.profile-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 50%;
}

.no-image {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f1f5f9;
  border-radius: 50%;
  color: #64748b;
  font-weight: 500;
}

/* Image Upload Improvements */
.image-upload {
  display: flex;
  flex-direction: row; /* Changed from column to row */
  align-items: center;
  justify-content: center;
  gap: 1rem;
  margin: 2rem 0;
  width: 100%;
}

.upload-label {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  background: #6B46C1;
  color: white;
  padding: 1.2rem 2rem;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 600;
  min-width: 200px; /* Added fixed minimum width */
  margin: 0; /* Removed margin */
}

.remove-image-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  background: #FEE2E2;
  color: #DC2626;
  padding: 1.2rem 2rem;
  border-radius: 12px;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 600;
  min-width: 200px; /* Added fixed minimum width */
  margin: 0; /* Removed margin */
}

/* Update responsive styles */
@media (max-width: 768px) {
  .image-upload {
    flex-direction: column;
    width: 100%;
  }

  .upload-label,
  .remove-image-btn {
    width: 100%;
    min-width: unset;
  }
}

/* Logout Button */
.logout-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  background: #DC2626;
  color: white;
  padding: 1.2rem 3rem;
  border-radius: 12px;
  font-weight: 600;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
  font-size: 1.1rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  width: auto;
  min-width: 250px;
}

.logout-btn i {
  font-size: 1.2rem;
}

.logout-btn:hover {
  background: #B91C1C;
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(220, 38, 38, 0.25);
}

/* Status Badges */
[class^="status-"] {
  padding: 0.8rem 1.5rem;
  border-radius: 25px;
  font-weight: 600;
  font-size: 0.9rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin: 0.5rem 0;
  display: inline-block;
}

.status-active {
  background: #C6F6D5;
  color: #22543D;
}

.status-pending {
  background: #FEEBC8;
  color: #8B5C14;
}

.status-sold {
  background: #E2E8F0;
  color: #2D3748;
}

/* Success Message */
.success-message {
  background: #C6F6D5;
  color: #22543D;
  padding: 1.2rem 2rem;
  border-radius: 12px;
  margin: 2rem 0;
  font-weight: 600;
  text-align: center;
}

/* Action Buttons Container */
.action-buttons {
  display: flex;
  gap: 1rem;
  margin-top: 1.5rem;
  flex-wrap: wrap;
}

.action-btn.delete {
  background: #FEE2E2;
  color: #DC2626;
}

.action-btn.delete:hover {
  background: #DC2626;
  color: white;
}

/* Card Layouts */
.address-card, .review-card, .order-card {
  background: white;
  border-radius: 12px;
  padding: 2.5rem; /* Increased padding */
  margin-bottom: 1.5rem;
  border: 1px solid rgba(107, 70, 193, 0.1);
  transition: all 0.3s ease;
}

.address-card:hover, .review-card:hover, .order-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(107, 70, 193, 0.08);
}

/* Form Buttons Group */
.form-buttons {
  display: flex;
  gap: 1rem;
  margin-top: 2rem;
}

.cancel-btn {
  background: #E2E8F0;
  color: #2D3748;
  padding: 1.2rem 2.5rem;
  border-radius: 12px;
  font-weight: 600;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
}

.cancel-btn:hover {
  background: #CBD5E0;
  transform: translateY(-2px);
}

/* Responsive Design */
@media (max-width: 768px) {
  .account-container {
    padding: 1rem;
    margin: 1rem;
  }

  .account-section {
    padding: 2rem;
    margin-bottom: 2rem;
  }

  .profile-image-container {
    flex-direction: column;
    align-items: center;
    text-align: center;
    padding: 2rem;
  }

  .form-buttons {
    flex-direction: column;
  }

  .submit-btn, .action-btn {
    width: 100%;
    padding: 1rem;
    margin: 0.5rem 0;
  }

  h1 {
    font-size: 2rem;
    margin-bottom: 2rem;
  }

  h2 {
    font-size: 1.6rem;
  }
}

/* Image Upload Improvements */
.hidden-input {
  display: none;
}

.upload-label {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  background: #6B46C1;
  color: white;
  padding: 1rem 2rem;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 600;
}

.upload-label i {
  font-size: 1.2rem;
}

.upload-label:hover {
  background: #553C9A;
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(107, 70, 193, 0.2);
}

.remove-image-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  background: #FEE2E2;
  color: #DC2626;
  padding: 1rem 2rem;
  border-radius: 10px;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 600;
  margin-left: 1rem;
}

.remove-image-btn:hover {
  background: #DC2626;
  color: white;
  transform: translateY(-2px);
}

/* Listings Section Improvements */
.listings-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(600px, 1fr)); /* Increased card width */
  gap: 4rem; /* Increased from 3rem */
  margin-top: 2.5rem;
}

.listings-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr)); /* Increased from 320px */
  gap: 3rem; /* Increased from 2.5rem */
  margin-top: 2.5rem;
}

.listing-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  border: 1px solid rgba(107, 70, 193, 0.1);
  transition: all 0.3s ease;
  display: flex;
  flex-direction: column;
}

.listing-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 30px rgba(107, 70, 193, 0.1);
}

.listing-image {
  width: 100%;
  height: 200px;
  overflow: hidden;
  position: relative;
}

.listing-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.listing-card:hover .listing-image img {
  transform: scale(1.05);
}

.listing-details {
  padding: 1.5rem;
  flex-grow: 1;
}

.listing-details h3 {
  font-size: 1.2rem;
  color: #2C3E50;
  margin-bottom: 1rem;
  font-weight: 600;
}

.listing-price {
  font-size: 1.25rem;
  color: #6B46C1;
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.listing-status {
  display: inline-block;
  margin: 0.5rem 0;
}

.listing-date {
  font-size: 0.9rem;
  color: #64748B;
  margin-top: 0.5rem;
}

.listing-actions {
  padding: 1.5rem;
  background: #F8FAFC;
  border-top: 1px solid rgba(107, 70, 193, 0.1);
  display: flex;
  gap: 0.75rem;
  justify-content: flex-end;
  flex-wrap: wrap;
}

.listing-actions .action-btn {
  padding: 0.75rem 1.5rem;
  font-size: 0.9rem;
  margin: 0;
}

.create-listing-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  margin-top: 2rem;
  width: auto;
  text-decoration: none;
}

.create-listing-btn:hover {
  text-decoration: none;
}

.add-listing-link {
  color: #6B46C1;
  text-decoration: none;
  font-weight: 600;
  margin-top: 1rem;
  display: inline-block;
  transition: all 0.3s ease;
}

.add-listing-link:hover {
  color: #553C9A;
  text-decoration: underline;
}

/* Empty State Improvement */
.empty-list {
  text-align: center;
  padding: 4rem 2rem;
  background: linear-gradient(to right bottom, #ffffff, #f8f9fa);
  border-radius: 20px;
  margin: 2rem 0;
  border: 2px dashed rgba(107, 70, 193, 0.2);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.5rem;
}

.empty-list p {
  color: #4A5568;
  font-size: 1.1rem;
  margin-bottom: 1rem;
}

.add-listing-link {
  display: inline-flex;
  align-items: center;
  gap: 0.75rem;
  background: #6B46C1;
  color: white;
  padding: 1.2rem 2.5rem;
  border-radius: 12px;
  font-weight: 600;
  text-decoration: none;
  transition: all 0.3s ease;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  font-size: 0.95rem;
  box-shadow: 0 4px 15px rgba(107, 70, 193, 0.2);
}

.add-listing-link:before {
  content: '+';
  font-size: 1.2rem;
  font-weight: 600;
}

.add-listing-link:hover {
  background: #553C9A;
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(107, 70, 193, 0.25);
  text-decoration: none;
}

.create-listing-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  margin-top: 2rem;
  width: auto;
  text-decoration: none;
  background: #6B46C1;
  color: white;
  padding: 1.2rem 2.5rem;
  border-radius: 12px;
  font-weight: 600;
  transition: all 0.3s ease;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  font-size: 0.95rem;
}

.create-listing-btn:hover {
  background: #553C9A;
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(107, 70, 193, 0.25);
  text-decoration: none;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .empty-list {
    padding: 2rem 1rem;
  }

  .add-listing-link,
  .create-listing-btn {
    width: 100%;
    justify-content: center;
    padding: 1rem 1.5rem;
  }
}

@media (max-width: 768px) {
  .listings-list {
    grid-template-columns: 1fr;
  }
  
  .listing-actions {
    flex-direction: column;
  }
  
  .listing-actions .action-btn {
    width: 100%;
  }
}

/* Address Cards */
.address-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(700px, 1fr)); /* Increased card width */
  gap: 4rem;
}

.address-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(500px, 1fr)); /* Increased from 400px */
  gap: 3rem;
}

/* Orders and Reviews */
.orders-list,
.reviews-list {
  max-width: 1800px; /* Increased width */
  margin: 0 auto; /* Center the lists */
}

.orders-list,
.reviews-list {
  max-width: 1400px; /* Increased from 1200px */
  margin: 0 auto; /* Center the lists */
}

/* Logout Section Styling */
.logout-section {
  margin-top: 4rem;
  background: linear-gradient(to right bottom, #ffffff, #f8f9fa);
  border: 2px solid #e9ecef;
}

.logout-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 2rem;
  text-align: center;
}

.logout-text {
  font-size: 1.2rem;
  color: #4A5568;
  margin-bottom: 2rem;
}

/* Responsive Improvements */
@media (max-width: 768px) {
  .logout-btn, 
  .upload-label,
  .remove-image-btn {
    width: 100%;
    min-width: unset;
    padding: 1rem 2rem;
  }

  .profile-image {
    width: 150px;
    height: 150px;
  }

  .profile-image-container {
    padding: 1.5rem;
  }

  .logout-section {
    margin-top: 2rem;
  }

  .logout-container {
    padding: 1rem;
  }
}

/* Responsive breakpoints adjusted */
@media (max-width: 2000px) {
  .account-container {
    padding: 2rem 8rem;
  }
  
  .account-section {
    padding: 5rem 8rem;
  }
}

@media (max-width: 1800px) {
  .account-container {
    padding: 2rem 6rem;
  }
  
  .account-section {
    padding: 4rem 6rem;
  }
  
  .listings-list {
    grid-template-columns: repeat(auto-fill, minmax(500px, 1fr));
  }
}

@media (max-width: 1600px) {
  .account-container {
    max-width: 90%;
    padding: 2rem 4rem;
  }
}

@media (max-width: 1400px) {
  .account-container {
    padding: 2rem 4rem;
  }
  
  .account-section {
    padding: 3rem 4rem;
  }
  
  .listings-list {
    grid-template-columns: repeat(auto-fill, minmax(450px, 1fr));
  }
  
  .address-list {
    grid-template-columns: repeat(auto-fill, minmax(500px, 1fr));
  }
}

@media (max-width: 1200px) {
  .account-container {
    padding: 2rem;
  }
  
  .account-section {
    padding: 3rem;
  }
  
  .listings-list {
    grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  }
  
  .address-list {
    grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  }
}

/* Only apply mobile styles at a smaller breakpoint */
@media (max-width: 640px) {
  .account-container {
    padding: 1rem;
    margin: 1rem;
  }

  .account-section {
    padding: 2rem;
  }

  .listings-list {
    grid-template-columns: 1fr;
  }

  .address-list {
    grid-template-columns: 1fr;
  }
}
</style>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"></link>
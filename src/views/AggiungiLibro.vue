<template>
  <div class="add-book-container">
    <header>
      <Navbar />
    </header>

    <div class="page-title">
      <h2>Aggiungi Libro</h2>
      <p>Inserisci i dettagli del libro che vuoi vendere</p>
    </div>

    <!-- Authentication Message -->
    <div
      v-if="!isAuthenticated && !isLoading"
      class="auth-required">
      <div class="auth-message">
        <h3>Accesso Richiesto</h3>
        <p>Per aggiungere un libro è necessario accedere al tuo account.</p>
        <div class="auth-buttons">
          <RouterLink
            to="/login"
            class="login-button"
            >Accedi</RouterLink
          >
          <RouterLink
            to="/register"
            class="register-button"
            >Registrati</RouterLink
          >
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div
      v-else-if="isLoading"
      class="loading-container">
      <div class="loading-spinner"></div>
      <p>Caricamento...</p>
    </div>

    <!-- Authenticated Content -->
    <div v-else>
      <div
        v-if="successMessage"
        class="success-message">
        {{ successMessage }}
      </div>

      <div
        v-if="errorMessage"
        class="error-message">
        <div v-html="errorMessage"></div>
      </div>

      <div class="form-container">
        <form @submit.prevent="submitBook">
          <div class="form-section">
            <h3>Informazioni Generali</h3>

            <div class="form-group">
              <label for="title">Titolo del Libro*</label>
              <input
                type="text"
                id="title"
                v-model="bookData.title"
                required
                placeholder="Inserisci il titolo del libro" />
            </div>

            <div class="form-group">
              <label for="author">Autore*</label>
              <input
                type="text"
                id="author"
                v-model="bookData.author"
                required
                placeholder="Nome dell'autore" />
            </div>

            <div class="form-group">
              <label for="category">Categoria*</label>
              <select
                id="category"
                v-model="bookData.category"
                required>
                <option
                  value=""
                  disabled>
                  Seleziona una categoria
                </option>
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
                <option value="altro">Altro</option>
              </select>
            </div>

            <div class="form-group">
              <label for="publisher">Casa Editrice*</label>
              <select
                id="publisher"
                v-model="bookData.publisher"
                required>
                <option
                  value=""
                  disabled>
                  Seleziona una casa editrice
                </option>
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
                <option value="newton">Newton Compton</option>
                <option value="longanesi">Longanesi</option>
                <option value="piemme">Piemme</option>
                <option value="sellerio">Sellerio</option>
                <option value="hoepli">Hoepli</option>
                <option value="zanichelli">Zanichelli</option>
                <option value="corbaccio">Corbaccio</option>
                <option value="fazi">Fazi Editore</option>
                <option value="marsilio">Marsilio</option>
                <option value="salani">Salani</option>
                <option value="bollati">Bollati Boringhieri</option>
                <option value="marcos">Marcos y Marcos</option>
                <option value="minimum">minimum fax</option>
                <option value="neri">Neri Pozza</option>
                <option value="sei">SEI Editore</option>
                <option value="mursia">Mursia</option>
                <option value="utet">UTET</option>
                <option value="nottetempo">nottetempo</option>
                <option value="edagricole">Edagricole</option>
                <option value="bao">BAO Publishing</option>
                <option value="coconino">Coconino Press</option>
                <option value="jPop">J-POP Manga</option>
                <option value="tunue">Tunué</option>
                <option value="altro">Altro</option>
              </select>
            </div>

            <div
              class="form-group"
              v-if="bookData.publisher === 'altro'">
              <label for="customPublisher">Specifica Casa Editrice*</label>
              <input
                type="text"
                id="customPublisher"
                v-model="bookData.customPublisher"
                required
                placeholder="Inserisci il nome della casa editrice" />
            </div>
          </div>

          <div class="form-section">
            <h3>Descrizione e Condizioni</h3>

            <div class="form-group">
              <label for="description">Descrizione del Libro*</label>
              <textarea
                id="description"
                v-model="bookData.description"
                required
                rows="5"
                placeholder="Descrivi il libro, includi dettagli come trama, anno di pubblicazione, edizione, etc."></textarea>
            </div>

            <div class="form-group">
              <label for="condition">Condizioni del Libro*</label>
              <select
                id="condition"
                v-model="bookData.condition"
                required>
                <option
                  value=""
                  disabled>
                  Seleziona le condizioni
                </option>
                <option value="nuovo">Nuovo</option>
                <option value="comeNuovo">Come Nuovo</option>
                <option value="buone">Buone Condizioni</option>
                <option value="usato">Usato</option>
                <option value="dannegiato">Danneggiato</option>
              </select>
            </div>

            <div class="form-group">
              <label for="notes">Note Aggiuntive (opzionale)</label>
              <textarea
                id="notes"
                v-model="bookData.notes"
                rows="3"
                placeholder="Eventuali note aggiuntive sulle condizioni, presenza di sottolineature, etc."></textarea>
            </div>
          </div>

          <div class="form-section">
            <h3>Prezzo e Posizione</h3>

            <div class="form-group">
              <label for="price">Prezzo (€)*</label>
              <input
                type="number"
                id="price"
                v-model.number="bookData.price"
                required
                min="0.01"
                step="0.01" />
            </div>

            <div class="form-group">
              <label for="location">Posizione*</label>
              <input
                type="text"
                id="location"
                v-model="bookData.location"
                required
                placeholder="Città/Zona dove il libro è disponibile" />
            </div>

            <div class="form-group">
              <div class="checkbox-group">
                <input
                  type="checkbox"
                  id="shippingAvailable"
                  v-model="bookData.shippingAvailable" />
                <label for="shippingAvailable"
                  >Disponibile per spedizione</label
                >
              </div>
            </div>
          </div>

          <div class="form-section">
            <h3>Foto del Libro</h3>
            <p class="photo-instruction">
              Carica delle foto chiare del libro (copertina, dorso, eventuali
              difetti)
            </p>

            <div class="photo-upload-container">
              <div
                class="photo-upload-box"
                @click="triggerFileInput">
                <input
                  type="file"
                  ref="fileInput"
                  accept="image/*"
                  multiple
                  @change="handleFileUpload"
                  class="hidden-file-input" />
                <div class="upload-icon">+</div>
                <p>Clicca per aggiungere foto</p>
              </div>

              <div
                v-for="(photo, index) in photoPreview"
                :key="index"
                class="photo-preview">
                <img
                  :src="photo"
                  alt="Anteprima foto" />
                <button
                  type="button"
                  class="remove-photo"
                  @click="removePhoto(index)">
                  ×
                </button>
              </div>
            </div>

            <p class="photo-limit">{{ photoPreview.length }}/5 foto caricate</p>
            <p
              class="error-text"
              v-if="errors.photos">
              {{ errors.photos }}
            </p>
          </div>

          <div class="form-actions">
            <button
              type="button"
              class="cancel-button"
              @click="cancelForm">
              Annulla
            </button>
            <button
              type="submit"
              class="submit-button"
              :disabled="isSubmitting">
              {{
                isSubmitting ? "Pubblicazione in corso..." : "Pubblica Annuncio"
              }}
            </button>
          </div>
        </form>
      </div>

      <!-- Simplified storage status indicator -->
      <div
        class="debug-container"
        v-if="isAuthenticated">
        <div class="endpoint-info">
          <small><strong>Bucket di storage:</strong> images</small>
        </div>
        <button
          type="button"
          class="debug-button"
          @click="verifyStorageAccess"
          title="Verifica la connessione ai bucket di storage">
          <i class="fas fa-database"></i> Verifica connessione
        </button>
      </div>
    </div>
    <Footer />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from "vue";
import { useRouter } from "vue-router";
import { RouterLink } from "vue-router";
import { createClient } from "@supabase/supabase-js";
import Navbar from "../components/Navbar.vue";
import Footer from "../components/footer.vue";

// Supabase configuration
const supabaseUrl = "https://tiylfyyfitqzwstftzpg.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpeWxmeXlmaXRxendzdGZ0enBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNjYyNDcsImV4cCI6MjA1Njc0MjI0N30.CvIx_vI-KGGcFlcZy66-DIC8Itk03Olw3lzEMhnJP_c";
const supabase = createClient(supabaseUrl, supabaseKey);

// Storage configuration semplificata
const storageBucket = "images";

const router = useRouter();

// Authentication state
const user = ref(null);
const isLoading = ref(true);
const isAuthenticated = computed(() => !!user.value);

// State for form data
const bookData = reactive({
  title: "",
  author: "",
  description: "",
  price: null,
  location: "",
  category: "",
  publisher: "",
  customPublisher: "",
  condition: "",
  notes: "",
  shippingAvailable: false,
});

// State for photos
const fileInput = ref(null);
const photoFiles = ref([]);
const photoPreview = ref([]);
const errors = reactive({
  photos: "",
});

// State for form submission
const isSubmitting = ref(false);
const successMessage = ref("");
const errorMessage = ref("");

// Funzione semplificata per caricare le immagini direttamente
const uploadImages = async (files) => {
  if (!user.value?.id) {
    throw new Error("Utente non autenticato");
  }

  console.log(`📤 Caricamento diretto nel bucket "${storageBucket}"`);
  const imageUrls = [];

  for (const file of files) {
    try {
      const fileExt = file.name.split(".").pop().toLowerCase();
      const timestamp = Date.now();
      const randomId = Math.random().toString(36).substring(2, 10);
      const fileName = `${timestamp}_${randomId}.${fileExt}`;
      const userId = user.value.id;
      const filePath = `users/${userId}/${fileName}`;

      console.log(`🔄 Caricamento file: ${filePath}, tipo: ${file.type}`);

      // Carica il file tramite l'API Supabase Storage
      const { data, error } = await supabase.storage
        .from(storageBucket)
        .upload(filePath, file, {
          cacheControl: "3600",
          upsert: true,
          contentType: file.type,
        });

      if (error) throw error;

      // Costruisci l'URL pubblico direttamente
      const publicUrl = `https://tiylfyyfitqzwstftzpg.supabase.co/storage/v1/object/public/${storageBucket}/${filePath}`;

      console.log("✅ URL generato:", publicUrl);
      imageUrls.push(publicUrl);
    } catch (err) {
      console.error("❌ Errore durante il caricamento:", err);
      throw err;
    }
  }

  return imageUrls;
};

// Improved submitBook function
const submitBook = async () => {
  if (!isAuthenticated.value) {
    errorMessage.value = "Sessione scaduta. Effettua nuovamente il login.";
    setTimeout(() => {
      router.push("/login");
    }, 2000);
    return;
  }

  try {
    isSubmitting.value = true;
    errorMessage.value = "";
    successMessage.value = "";

    if (photoFiles.value.length === 0) {
      errors.photos = "Carica almeno una foto del libro.";
      isSubmitting.value = false;
      return;
    }

    const validationErrors = validateForm();
    if (validationErrors.length > 0) {
      errorMessage.value = validationErrors.join(". ");
      isSubmitting.value = false;
      return;
    }

    // Carica le immagini direttamente senza verifiche sui bucket
    let imageUrls;
    try {
      imageUrls = await uploadImages(photoFiles.value);
      console.log("Caricamento immagini riuscito:", imageUrls);
    } catch (uploadError) {
      console.error("Errore nel caricamento delle immagini:", uploadError);
      errorMessage.value =
        "Errore nel caricamento delle immagini: " + uploadError.message;
      isSubmitting.value = false;
      return;
    }

    if (!imageUrls || imageUrls.length === 0) {
      errorMessage.value = "Nessuna immagine è stata caricata. Riprova.";
      isSubmitting.value = false;
      return;
    }

    const finalImageUrl = imageUrls[0];
    console.log("URL immagine finale:", finalImageUrl);

    // Prepara i dati del libro
    const bookDetails = {
      author: bookData.author,
      publisher:
        bookData.publisher === "altro"
          ? bookData.customPublisher
          : bookData.publisher,
      category: bookData.category,
      condition: bookData.condition,
      notes: bookData.notes || null,
      shipping_available: bookData.shippingAvailable,
      location: bookData.location,
    };

    const bookToInsert = {
      name: bookData.title,
      description: bookData.description,
      price: bookData.price,
      image_url: finalImageUrl,
      user_id: user.value.id,
      metadata: bookDetails,
      status: "active",
    };

    console.log("Inserimento libro con dati:", bookToInsert);

    try {
      const { data, error } = await supabase
        .from("products")
        .insert([bookToInsert])
        .select();

      if (error) throw error;

      successMessage.value =
        "Libro aggiunto con successo! Verrai reindirizzato allo shop.";
      resetForm();
      setTimeout(() => {
        router.push("/shop");
      }, 2000);
    } catch (insertError) {
      console.error("Error with insert attempt:", insertError);
      errorMessage.value =
        "Errore durante l'inserimento del libro: " + insertError.message;
    }
  } catch (error) {
    console.error("Error submitting book:", error);
    errorMessage.value =
      "Si è verificato un errore: " + (error.message || "Riprova più tardi");
  } finally {
    isSubmitting.value = false;
  }
};

// Metodo di verifica semplificato
const verifyStorageAccess = async () => {
  errorMessage.value = "";
  successMessage.value = "";

  try {
    const { data, error } = await supabase.storage
      .from(storageBucket)
      .list("", { limit: 1 });

    if (error) {
      console.error("❌ Errore accesso storage:", error);
      errorMessage.value = `Errore nell'accesso al bucket "${storageBucket}": ${error.message}`;
      return false;
    }

    console.log("✅ Accesso al bucket verificato");
    successMessage.value = `Connessione al bucket "${storageBucket}" verificata con successo.`;
    return true;
  } catch (error) {
    console.error("❌ Errore verifica storage:", error);
    errorMessage.value =
      "Errore nella verifica dello storage: " + error.message;
    return false;
  }
};

// Methods
const triggerFileInput = () => {
  if (photoPreview.value.length >= 5) {
    errors.photos = "Hai raggiunto il limite massimo di 5 foto.";
    return;
  }
  fileInput.value.click();
};

const handleFileUpload = (event) => {
  const files = event.target.files;

  if (!files || !files.length) return;

  errors.photos = "";

  if (photoPreview.value.length + files.length > 5) {
    errors.photos = `Puoi caricare al massimo 5 foto. Seleziona ${
      5 - photoPreview.value.length
    } o meno file.`;
    return;
  }

  Array.from(files).forEach((file) => {
    if (!file.type.match("image.*")) {
      errors.photos = "Puoi caricare solo file immagine.";
      return;
    }

    photoFiles.value.push(file);

    const reader = new FileReader();
    reader.onload = (e) => {
      photoPreview.value.push(e.target.result);
    };
    reader.readAsDataURL(file);
  });

  event.target.value = "";
};

const removePhoto = (index) => {
  photoPreview.value.splice(index, 1);
  photoFiles.value.splice(index, 1);
  errors.photos = "";
};

// Form validation function
const validateForm = () => {
  const errors = [];

  if (!bookData.title.trim()) errors.push("Titolo richiesto");
  if (!bookData.author.trim()) errors.push("Autore richiesto");
  if (!bookData.description.trim()) errors.push("Descrizione richiesta");
  if (!bookData.price || bookData.price <= 0)
    errors.push("Prezzo valido richiesto");
  if (!bookData.location.trim()) errors.push("Posizione richiesta");
  if (!bookData.category) errors.push("Categoria richiesta");
  if (!bookData.publisher) errors.push("Casa editrice richiesta");
  if (bookData.publisher === "altro" && !bookData.customPublisher.trim())
    errors.push("Specificare la casa editrice");
  if (!bookData.condition) errors.push("Condizione del libro richiesta");

  return errors;
};

// Reset form function
const resetForm = () => {
  Object.keys(bookData).forEach((key) => {
    if (typeof bookData[key] === "boolean") {
      bookData[key] = false;
    } else if (typeof bookData[key] === "number") {
      bookData[key] = null;
    } else {
      bookData[key] = "";
    }
  });

  photoFiles.value = [];
  photoPreview.value = [];
  errors.photos = "";
};

const cancelForm = () => {
  if (
    confirm("Sei sicuro di voler annullare? I dati inseriti andranno persi.")
  ) {
    router.push("/shop");
  }
};

// Verifica la sessione utente all'avvio della pagina
onMounted(async () => {
  try {
    isLoading.value = true;

    const {
      data: { session },
      error: authError,
    } = await supabase.auth.getSession();
    if (authError) {
      console.error("Authentication error:", authError);
      errorMessage.value = "Errore durante la verifica dell'autenticazione";
      return;
    }

    if (session) {
      user.value = session.user;
      // Verifica l'accesso allo storage ma non blocca il componente
      await verifyStorageAccess();
    } else {
      console.log("Utente non autenticato");
    }
  } catch (error) {
    console.error("Error during initialization:", error);
    errorMessage.value = "Si è verificato un errore: " + error.message;
  } finally {
    isLoading.value = false;
  }
});
</script>

<style scoped>
.add-book-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 20px;
}

header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
  margin-bottom: 30px;
}

nav {
  display: flex;
  gap: 20px;
  align-items: center;
}

.nav-link {
  text-decoration: none;
  color: #6a5acd;
  font-weight: 500;
}

.icon {
  font-size: 20px;
  cursor: pointer;
}

.page-title {
  margin-bottom: 30px;
  text-align: center;
}

.page-title h2 {
  font-size: 28px;
  margin-bottom: 10px;
}

.page-title p {
  color: #666;
}

.form-container {
  background-color: white;
  border-radius: 10px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  padding: 30px;
}

.form-section {
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 1px solid #eee;
}

.form-section:last-child {
  border-bottom: none;
}

.form-section h3 {
  margin-bottom: 20px;
  color: #444;
  font-weight: 600;
}

.form-group {
  margin-bottom: 20px;
}

label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
}

input[type="text"],
input[type="number"],
select,
textarea {
  width: 100%;
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 16px;
}

input:focus,
select:focus,
textarea:focus {
  border-color: #6a5acd;
  outline: none;
}

.checkbox-group {
  display: flex;
  align-items: center;
  gap: 10px;
}

.checkbox-group input {
  width: auto;
}

.photo-upload-container {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
  margin-bottom: 15px;
}

.photo-upload-box {
  width: 150px;
  height: 150px;
  border: 2px dashed #ccc;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  cursor: pointer;
  transition: border-color 0.3s;
}

.photo-upload-box:hover {
  border-color: #6a5acd;
}

.upload-icon {
  font-size: 32px;
  color: #999;
  margin-bottom: 10px;
}

.hidden-file-input {
  display: none;
}

.photo-preview {
  width: 150px;
  height: 150px;
  position: relative;
  overflow: hidden;
  border-radius: 8px;
}

.photo-preview img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.remove-photo {
  position: absolute;
  top: 5px;
  right: 5px;
  width: 25px;
  height: 25px;
  border-radius: 50%;
  background-color: rgba(0, 0, 0, 0.6);
  color: white;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  font-size: 18px;
}

.photo-limit {
  font-size: 14px;
  color: #666;
  margin-bottom: 10px;
}

.photo-instruction {
  margin-bottom: 15px;
  font-size: 14px;
  color: #666;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 15px;
  margin-top: 20px;
}

.cancel-button {
  padding: 12px 24px;
  background-color: #f5f5f5;
  border: 1px solid #ddd;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.3s;
}

.cancel-button:hover {
  background-color: #e5e5e5;
}

.submit-button {
  padding: 12px 24px;
  background-color: #6a5acd;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.3s;
}

.submit-button:hover {
  background-color: #5a4cba;
}

.submit-button:disabled {
  background-color: #b2aae0;
  cursor: not-allowed;
}

.success-message {
  background-color: #e8f5e9;
  color: #2e7d32;
  padding: 15px;
  border-radius: 4px;
  margin-bottom: 20px;
  text-align: center;
}

.error-message {
  background-color: #ffebee;
  color: #d32f2f;
  padding: 15px;
  border-radius: 4px;
  margin-bottom: 20px;
  text-align: center;
}

.error-text {
  color: #d32f2f;
  font-size: 14px;
  margin-top: 5px;
}

/* New styles for authentication prompt */
.auth-required {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 40px 0;
}

.auth-message {
  background-color: #f9f9f9;
  border-radius: 10px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  padding: 30px;
  text-align: center;
  max-width: 500px;
  width: 100%;
}

.auth-message h3 {
  font-size: 22px;
  margin-bottom: 15px;
  color: #333;
}

.auth-message p {
  color: #666;
  margin-bottom: 20px;
}

.auth-buttons {
  display: flex;
  gap: 15px;
  justify-content: center;
}

.login-button,
.register-button {
  padding: 12px 20px;
  border-radius: 5px;
  font-weight: 500;
  text-decoration: none;
  transition: all 0.3s ease;
}

.login-button {
  background-color: #6a5acd;
  color: white;
}

.register-button {
  background-color: white;
  border: 1px solid #6a5acd;
  color: #6a5acd;
}

.login-button:hover {
  background-color: #5a4cba;
}

.register-button:hover {
  background-color: #f0f0f0;
}

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

.storage-info {
  margin-top: 10px;
  font-size: 0.9rem;
  padding: 8px;
  background-color: rgba(255, 255, 255, 0.2);
  border-radius: 4px;
}

.storage-info a {
  color: #ff6b6b;
  text-decoration: underline;
}

.debug-container {
  margin: 10px 0;
  text-align: right;
}

.endpoint-info {
  font-size: 12px;
  color: #666;
  margin-bottom: 8px;
  text-align: right;
}

.endpoint-info small {
  display: block;
  line-height: 1.4;
}

.debug-button {
  background-color: #f0f0f0;
  border: 1px solid #ddd;
  padding: 6px 12px;
  border-radius: 4px;
  font-size: 14px;
  color: #555;
  cursor: pointer;
  transition: all 0.2s;
}

.debug-button:hover {
  background-color: #e5e5e5;
}

@media (max-width: 768px) {
  .form-container {
    padding: 20px;
  }

  .photo-upload-container {
    justify-content: center;
  }

  .form-actions {
    flex-direction: column;
  }

  .cancel-button,
  .submit-button {
    width: 100%;
  }
}

/* Styles to ensure all text is black for better visibility */
.add-book-container,
.add-book-container input,
.add-book-container textarea,
.add-book-container select,
.add-book-container button,
.add-book-container label,
.add-book-container p,
.add-book-container h2,
.add-book-container h3,
.add-book-container option {
  color: #000000;
}

.add-book-container select option {
  color: #000000;
  background-color: #ffffff;
}

.submit-button,
.login-button {
  color: white !important;
}
</style>

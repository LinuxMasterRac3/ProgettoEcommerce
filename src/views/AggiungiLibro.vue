<template>
  <div class="add-book-container">
    <header>
      <h1>PiegaLibro</h1>
      <nav>
        <RouterLink
          to="/shop"
          class="nav-link"
          >Torna allo Shop</RouterLink
        >
        <span class="icon">❤️</span>
        <span class="icon">🛒</span>
        <span class="icon">👤</span>
      </nav>
    </header>

    <div class="page-title">
      <h2>Aggiungi Libro</h2>
      <p>Inserisci i dettagli del libro che vuoi vendere</p>
    </div>

    <div
      v-if="successMessage"
      class="success-message">
      {{ successMessage }}
    </div>

    <div
      v-if="errorMessage"
      class="error-message">
      {{ errorMessage }}
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
              <label for="shippingAvailable">Disponibile per spedizione</label>
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
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import { useRouter } from "vue-router";
import { RouterLink } from "vue-router";
import { createClient } from "@supabase/supabase-js";

// Supabase configuration
const supabaseUrl = "https://tiylfyyfitqzwstftzpg.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpeWxmeXlmaXRxendzdGZ0enBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNjYyNDcsImV4cCI6MjA1Njc0MjI0N30.CvIx_vI-KGGcFlcZy66-DIC8Itk03Olw3lzEMhnJP_c";
const supabase = createClient(supabaseUrl, supabaseKey);
const router = useRouter();
const user = ref(null);

// Variables to track Supabase configuration
const storageBucketName = ref("book-images"); // Nome fisso del bucket esistente
const bucketExists = ref(true); // Assumiamo che esista dato che conosciamo l'endpoint

// Check if user is authenticated and verify bucket availability
onMounted(async () => {
  try {
    const {
      data: { session },
    } = await supabase.auth.getSession();
    if (session) {
      user.value = session.user;
      await checkAndSetBucket();
    } else {
      errorMessage.value = "Devi effettuare l'accesso per aggiungere un libro";
      setTimeout(() => {
        router.push("/login");
      }, 2000);
    }
  } catch (error) {
    console.error("Error during initialization:", error);
  }
});

// Function to check for available buckets
const checkAndSetBucket = async () => {
  try {
    console.log(
      "Tentativo di utilizzare il bucket specifico:",
      storageBucketName.value
    );

    // Prova ad accedere alle informazioni del bucket specifico
    const { data, error } = await supabase.storage.getBucket(
      storageBucketName.value
    );

    if (error) {
      if (
        error.message &&
        error.message.includes("The resource was not found")
      ) {
        console.error(`Il bucket "${storageBucketName.value}" non esiste.`);
        // Prova a ottenere un elenco di tutti i bucket disponibili
        const { data: buckets, error: listError } =
          await supabase.storage.listBuckets();

        if (listError) {
          console.error("Errore nell'elencare i bucket:", listError);
          bucketExists.value = false;
          errorMessage.value = `Non è possibile accedere ai bucket di storage: ${listError.message}`;
          return;
        }

        if (buckets && buckets.length > 0) {
          console.log(
            "Bucket disponibili:",
            buckets.map((b) => b.name).join(", ")
          );
          storageBucketName.value = buckets[0].name;
          bucketExists.value = true;
          console.log(
            `Utilizzo bucket alternativo: ${storageBucketName.value}`
          );
        } else {
          bucketExists.value = false;
          errorMessage.value =
            "Nessun bucket disponibile nel tuo progetto Supabase.";
        }
      } else {
        console.error("Errore nell'accesso al bucket:", error);
        bucketExists.value = false;
        errorMessage.value = `Errore nell'accesso al bucket: ${error.message}`;
      }
    } else {
      console.log(`Bucket "${storageBucketName.value}" trovato e accessibile.`);
      bucketExists.value = true;
    }
  } catch (err) {
    console.error("Errore nella verifica del bucket:", err);
    bucketExists.value = false;
    errorMessage.value = `Errore nella verifica del bucket: ${err.message}`;
  }
};

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

// Function to upload images to Supabase Storage
const uploadImages = async (files) => {
  // Se non abbiamo accesso al bucket, usiamo Base64
  if (!bucketExists.value) {
    console.log("Fallback a Base64: nessun bucket accessibile");
    return photoPreview.value;
  }

  const imageUrls = [];

  for (const file of files) {
    try {
      // Nome file univoco
      const fileName = `${Date.now()}_${Math.random()
        .toString(36)
        .substring(2, 15)}_${file.name.replace(/\s+/g, "_")}`;

      // Percorso nel bucket (ora usa direttamente il bucket book-images)
      const filePath = user.value
        ? `users/${user.value.id}/${fileName}`
        : `public/${fileName}`;

      console.log(
        `Caricamento su ${storageBucketName.value}, percorso: ${filePath}`
      );

      // Upload a Supabase Storage
      const { data, error } = await supabase.storage
        .from(storageBucketName.value)
        .upload(filePath, file, {
          cacheControl: "3600",
          upsert: true, // Sovrascrive il file se esiste già
        });

      if (error) throw error;

      // Ottieni URL pubblico dell'immagine
      const { data: urlData } = supabase.storage
        .from(storageBucketName.value)
        .getPublicUrl(filePath);

      if (!urlData || !urlData.publicUrl) {
        throw new Error("URL pubblico non disponibile");
      }

      console.log("Caricamento completato, URL:", urlData.publicUrl);
      imageUrls.push(urlData.publicUrl);
    } catch (err) {
      console.error("Errore nel caricamento dell'immagine:", err);
      throw new Error(
        `Errore durante il caricamento dell'immagine: ${err.message}`
      );
    }
  }

  return imageUrls;
};

// Modified submitBook function to save to Supabase
const submitBook = async () => {
  try {
    if (!user.value) {
      errorMessage.value = "Devi effettuare l'accesso per aggiungere un libro";
      setTimeout(() => {
        router.push("/login");
      }, 2000);
      return;
    }

    isSubmitting.value = true;
    errorMessage.value = "";

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

    // Verifica il bucket prima del caricamento
    await checkAndSetBucket();

    let imageUrls;

    try {
      // Prova a caricare le immagini
      imageUrls = await uploadImages(photoFiles.value);
      console.log("Immagini caricate con successo:", imageUrls.length);
    } catch (uploadError) {
      console.error("Errore nel caricamento delle immagini:", uploadError);

      // In caso di errore, mostra un messaggio ma continua con Base64
      errorMessage.value = `Attenzione: le immagini verranno salvate in formato Base64 a causa di un errore di caricamento: ${uploadError.message}`;

      // Usa le anteprime Base64 come fallback
      imageUrls = photoPreview.value;
      console.log("Utilizzando immagini Base64 come fallback");
    }

    const bookToInsert = {
      name: bookData.title,
      description: bookData.description,
      price: bookData.price,
      image_url: imageUrls[0],
      additional_images: imageUrls.slice(1),
      user_id: user.value.id,
      author: bookData.author,
      category: bookData.category,
      publisher:
        bookData.publisher === "altro"
          ? bookData.customPublisher
          : bookData.publisher,
      condition: bookData.condition,
      notes: bookData.notes || null,
      location: bookData.location,
      shipping_available: bookData.shippingAvailable,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };

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
  } catch (error) {
    console.error("Error submitting book:", error);
    errorMessage.value =
      "Si è verificato un errore durante l'invio del libro: " +
      (error.message || "Riprova più tardi.");
  } finally {
    isSubmitting.value = false;
  }
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
</style>

<template>
  <div class="page-wrapper">
    <Navbar />

    <div class="edit-book-container">
      <h1>Modifica Annuncio</h1>

      <div
        v-if="loading"
        class="loading">
        <p>Caricamento dati...</p>
      </div>

      <div
        v-else-if="error"
        class="error-message">
        <p>{{ error }}</p>
        <button
          @click="goBack"
          class="submit-btn">
          Torna indietro
        </button>
      </div>

      <form
        v-else
        @submit.prevent="updateListing"
        class="edit-form">
        <section class="form-section">
          <h2>Informazioni Generali</h2>

          <div class="form-group">
            <label for="title">Titolo del Libro*</label>
            <input
              id="title"
              v-model="listing.name"
              type="text"
              placeholder="Inserisci il titolo del libro"
              required />
          </div>

          <div class="form-group">
            <label for="author">Autore*</label>
            <input
              id="author"
              v-model="author"
              type="text"
              placeholder="Nome dell'autore"
              required />
          </div>

          <div class="form-group">
            <label for="category">Categoria*</label>
            <select
              id="category"
              v-model="category"
              required>
              <option value="">Seleziona una categoria</option>
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

          <div class="form-group">
            <label for="publisher">Casa Editrice*</label>
            <select
              id="publisher"
              v-model="publisher"
              required>
              <option value="">Seleziona una casa editrice</option>
              <option value="mondadori">Mondadori</option>
              <option value="einaudi">Einaudi</option>
              <option value="feltrinelli">Feltrinelli</option>
              <option value="rizzoli">Rizzoli</option>
              <option value="bompiani">Bompiani</option>
              <option value="garzanti">Garzanti</option>
              <option value="adelphi">Adelphi</option>
              <option value="sellerio">Sellerio</option>
              <option value="laterza">Laterza</option>
              <option value="holden">Holden</option>
              <option value="piemme">Piemme</option>
              <option value="newton_compton">Newton Compton</option>
              <option value="fazi">Fazi</option>
              <option value="guanda">Guanda</option>
              <option value="longanesi">Longanesi</option>
              <option value="neri_pozza">Neri Pozza</option>
              <option value="marcos_y_marcos">Marcos y Marcos</option>
              <option value="other">Altra...</option>
            </select>
          </div>
        </section>

        <section class="form-section">
          <h2>Descrizione e Condizioni</h2>

          <div class="form-group">
            <label for="description">Descrizione del Libro*</label>
            <textarea
              id="description"
              v-model="listing.description"
              placeholder="Descrivi il libro, includi dettagli come trama, anno di pubblicazione, edizione, etc."
              rows="4"
              required></textarea>
          </div>

          <div class="form-group">
            <label for="condition">Condizioni del Libro*</label>
            <select
              id="condition"
              v-model="condition"
              required>
              <option value="">Seleziona le condizioni</option>
              <option value="come_nuovo">Come nuovo</option>
              <option value="ottime">Ottime condizioni</option>
              <option value="buone">Buone condizioni</option>
              <option value="accettabili">Condizioni accettabili</option>
              <option value="usato">Usato con segni di usura</option>
            </select>
          </div>

          <div class="form-group">
            <label for="notes">Note Aggiuntive (opzionale)</label>
            <textarea
              id="notes"
              v-model="notes"
              placeholder="Eventuali note aggiuntive sulle condizioni, presenza di sottolineature, etc."
              rows="3"></textarea>
          </div>
        </section>

        <section class="form-section">
          <h2>Prezzo e Posizione</h2>

          <div class="form-group">
            <label for="price">Prezzo (€)*</label>
            <input
              id="price"
              v-model="listing.price"
              type="number"
              step="0.01"
              min="0"
              placeholder="Prezzo in euro"
              required />
          </div>

          <div class="form-group">
            <label for="location">Posizione*</label>
            <div class="location-input-container">
              <input
                id="location"
                v-model="location"
                type="text"
                placeholder="Inizia a digitare il nome del comune..."
                @input="handleLocationInput"
                @focus="showLocationSuggestions = true"
                @blur="handleLocationBlur"
                required />

              <div
                v-if="showLocationSuggestions && filteredLocations.length > 0"
                class="location-suggestions">
                <div
                  v-for="loc in filteredLocations"
                  :key="loc.codice"
                  class="location-suggestion"
                  @mousedown="selectLocation(loc)">
                  <span>{{ loc.nome }}</span>
                  <span v-if="loc.provincia && loc.provincia.sigla"
                    >({{ loc.provincia.sigla }})</span
                  >
                </div>
              </div>
            </div>
          </div>

          <div class="form-group checkbox-group">
            <input
              id="shipping"
              type="checkbox"
              v-model="shippingAvailable" />
            <label for="shipping">Disponibile per spedizione</label>
          </div>

          <div class="form-group">
            <label for="status">Stato Annuncio</label>
            <select
              id="status"
              v-model="listing.status">
              <option value="active">Attivo</option>
              <option value="inactive">Non attivo</option>
              <option value="draft">Bozza</option>
            </select>
          </div>
        </section>

        <section class="form-section">
          <h2>Foto del Libro</h2>
          <div class="image-section-header">
            <p class="section-info">
              Carica delle foto chiare del libro (copertina, dorso, eventuali
              difetti)
            </p>
          </div>

          <div class="images-section">
            <!-- Changed position -->
            <div class="current-images">
              <div
                v-for="(image, index) in images"
                :key="index"
                class="image-preview">
                <img
                  :src="image"
                  :alt="listing.name" />
                <button
                  type="button"
                  @click="removeImage(index)"
                  class="remove-image">
                  ×
                </button>
              </div>

              <div
                class="add-image-container"
                v-if="images.length < 5">
                <input
                  type="file"
                  id="imageUpload"
                  @change="handleImageUpload"
                  accept="image/*"
                  hidden />
                <label
                  for="imageUpload"
                  class="add-image-btn">
                  <span>+</span>
                  <span>Aggiungi foto</span>
                </label>
              </div>
            </div>
            <p class="image-info">{{ images.length }}/5 foto caricate</p>
          </div>
        </section>

        <div class="form-actions">
          <button
            type="submit"
            class="submit-btn"
            :disabled="isSubmitting">
            {{ isSubmitting ? "Salvataggio..." : "Salva Modifiche" }}
          </button>
          <button
            type="button"
            @click="goBack"
            class="cancel-btn">
            Annulla
          </button>
        </div>
      </form>
    </div>

    <Footer />
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import { createClient } from "@supabase/supabase-js";
import Navbar from "../components/Navbar.vue";
import Footer from "../components/footer.vue";

// Supabase configuration
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

const route = useRoute();
const router = useRouter();
const listingId = route.params.id;

// State
const loading = ref(true);
const error = ref(null);
const isSubmitting = ref(false);
const user = ref(null);
const listing = ref({
  name: "",
  description: "",
  price: 0,
  status: "active",
  metadata: {},
});

// Additional fields
const author = ref("");
const category = ref("");
const publisher = ref("");
const condition = ref("");
const notes = ref("");
const location = ref("");
const shippingAvailable = ref(false);
const images = ref([]);

// Location autocomplete
const comuni = ref([]);
const filteredLocations = ref([]);
const showLocationSuggestions = ref(false);
const locationTimeout = ref(null);

// Image processing configuration
const maxImageSize = 2 * 1024 * 1024; // 2MB
const maxImageCount = 5;

// Watch for metadata changes and update the form
watch(
  () => listing.value.metadata,
  (newMetadata) => {
    if (newMetadata) {
      // Update form fields from metadata
      author.value = newMetadata.author || "";
      category.value = newMetadata.category || "";
      publisher.value = newMetadata.publisher || "";
      condition.value = newMetadata.condition || "";
      notes.value = newMetadata.notes || "";
      location.value = newMetadata.location || "";
      shippingAvailable.value = newMetadata.shipping_available || false;
    }
  },
  { deep: true }
);

onMounted(async () => {
  try {
    // Check authentication
    const {
      data: { session },
    } = await supabase.auth.getSession();

    if (!session?.user) {
      error.value = "Devi effettuare il login per modificare un annuncio";
      loading.value = false;
      return;
    }

    user.value = session.user;

    // Load comuni for location autocomplete
    await fetchComuni();

    // Fetch listing
    const { data, error: fetchError } = await supabase
      .from("products")
      .select("*")
      .eq("id", listingId)
      .eq("user_id", user.value.id)
      .single();

    if (fetchError) {
      throw new Error(fetchError.message);
    }

    if (!data) {
      throw new Error(
        "Annuncio non trovato o non hai i permessi per modificarlo"
      );
    }

    // Initialize listing data
    listing.value = data;

    // Load fields from metadata
    if (data.metadata) {
      author.value = data.metadata.author || "";
      category.value = data.metadata.category || "";
      publisher.value = data.metadata.publisher || "";
      condition.value = data.metadata.condition || "";
      notes.value = data.metadata.notes || "";
      location.value = data.metadata.location || "";
      shippingAvailable.value = data.metadata.shipping_available || false;
    }

    // Load current images
    if (
      data.metadata?.additional_images &&
      Array.isArray(data.metadata.additional_images)
    ) {
      images.value = [...data.metadata.additional_images];
    } else if (data.image_url) {
      images.value = [data.image_url];
    }
  } catch (err) {
    console.error("Error fetching listing:", err);
    error.value = `Errore: ${
      err.message || "Impossibile caricare i dati dell'annuncio"
    }`;
  } finally {
    loading.value = false;
  }
});

// Location autocomplete functions
const fetchComuni = async () => {
  try {
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

    const response = await fetch(
      "https://raw.githubusercontent.com/matteocontrini/comuni-json/master/comuni.json"
    );

    if (!response.ok) {
      throw new Error(`Error loading communes: ${response.status}`);
    }

    const data = await response.json();
    comuni.value = data;

    // Cache the data
    localStorage.setItem("comuni-cache", JSON.stringify(data));
    localStorage.setItem("comuni-cache-timestamp", Date.now().toString());
  } catch (error) {
    console.error("Error fetching comuni:", error);
  }
};

const handleLocationInput = () => {
  clearTimeout(locationTimeout.value);

  if (location.value.length < 2) {
    filteredLocations.value = [];
    return;
  }

  locationTimeout.value = setTimeout(() => {
    const input = location.value.toLowerCase().trim();

    filteredLocations.value = comuni.value
      .filter((comune) => {
        const matchesName = comune.nome.toLowerCase().includes(input);
        const matchesProvincia =
          comune.provincia &&
          (comune.provincia.nome.toLowerCase().includes(input) ||
            comune.provincia.sigla.toLowerCase() === input);

        return matchesName || matchesProvincia;
      })
      .sort((a, b) => {
        const aStartsWithQuery = a.nome.toLowerCase().startsWith(input);
        const bStartsWithQuery = b.nome.toLowerCase().startsWith(input);

        if (aStartsWithQuery && !bStartsWithQuery) return -1;
        if (!aStartsWithQuery && bStartsWithQuery) return 1;

        return a.nome.localeCompare(b.nome);
      })
      .slice(0, 10); // Limit to 10 results
  }, 300);
};

const selectLocation = (comune) => {
  if (comune.provincia && comune.provincia.sigla) {
    location.value = `${comune.nome} (${comune.provincia.sigla})`;
  } else {
    location.value = comune.nome;
  }

  showLocationSuggestions.value = false;
};

const handleLocationBlur = () => {
  setTimeout(() => {
    showLocationSuggestions.value = false;
  }, 200);
};

// Image handling functions
const handleImageUpload = async (event) => {
  const file = event.target.files[0];
  if (!file) return;

  // Validate file
  if (!file.type.startsWith("image/")) {
    alert("Per favore seleziona un file immagine valido");
    return;
  }

  if (file.size > maxImageSize) {
    alert(
      `L'immagine è troppo grande. La dimensione massima è ${
        maxImageSize / (1024 * 1024)
      }MB`
    );
    return;
  }

  if (images.value.length >= maxImageCount) {
    alert(`Puoi caricare al massimo ${maxImageCount} immagini`);
    return;
  }

  try {
    // Process image
    const optimizedImage = await processAndOptimizeImage(file);

    // Add to images array
    images.value.push(optimizedImage);

    // Reset file input
    event.target.value = "";
  } catch (err) {
    console.error("Error processing image:", err);
    alert("Si è verificato un errore durante il caricamento dell'immagine");
  }
};

// Function to convert image to base64
const processAndOptimizeImage = (file) => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      const img = new Image();
      img.onload = () => {
        try {
          // Resize if needed
          let { width, height } = img;
          const maxDimension = 1200;

          if (width > maxDimension || height > maxDimension) {
            if (width > height) {
              height *= maxDimension / width;
              width = maxDimension;
            } else {
              width *= maxDimension / height;
              height = maxDimension;
            }
          }

          const canvas = document.createElement("canvas");
          canvas.width = width;
          canvas.height = height;
          const ctx = canvas.getContext("2d");
          ctx.drawImage(img, 0, 0, width, height);

          // Convert to base64
          const base64 = canvas.toDataURL("image/jpeg", 0.8);
          resolve(base64);
        } catch (err) {
          reject(new Error("Errore durante l'ottimizzazione dell'immagine"));
        }
      };
      img.onerror = () => reject(new Error("Impossibile caricare l'immagine"));
      img.src = e.target.result;
    };
    reader.onerror = () =>
      reject(new Error("Errore durante la lettura del file"));
    reader.readAsDataURL(file);
  });
};

const removeImage = (index) => {
  images.value.splice(index, 1);
};

const updateListing = async () => {
  if (!user.value?.id) {
    error.value = "Devi effettuare il login per modificare un annuncio";
    return;
  }

  isSubmitting.value = true;

  try {
    // Prepare metadata with all fields
    const metadata = {
      ...listing.value.metadata,
      author: author.value,
      category: category.value,
      publisher: publisher.value,
      condition: condition.value,
      notes: notes.value,
      location: location.value,
      shipping_available: shippingAvailable.value,
      additional_images: images.value,
    };

    // Update listing in database
    const { error: updateError } = await supabase
      .from("products")
      .update({
        name: listing.value.name,
        description: listing.value.description,
        price: parseFloat(listing.value.price),
        status: listing.value.status,
        metadata: metadata,
        updated_at: new Date().toISOString(),
      })
      .eq("id", listingId)
      .eq("user_id", user.value.id);

    if (updateError) throw updateError;

    alert("Annuncio aggiornato con successo!");
    router.push("/account");
  } catch (err) {
    console.error("Error updating listing:", err);
    alert(
      `Si è verificato un errore: ${
        err.message || "Impossibile aggiornare l'annuncio"
      }`
    );
  } finally {
    isSubmitting.value = false;
  }
};

const goBack = () => {
  router.back();
};
</script>

<style scoped>
.page-wrapper {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background-color: #f8fafc;
}

.edit-book-container {
  max-width: 95%; /* Increased from 90% */
  margin: 2rem auto;
  padding: 0 2rem;
}

h1 {
  text-align: center;
  margin-bottom: 2rem;
  color: #553c9a; /* Changed to purple */
  font-size: 2rem;
  font-weight: 700; /* Made bolder */
}

.loading,
.error-message {
  text-align: center;
  padding: 2rem;
  background-color: white;
  border-radius: 1rem; /* Increased border radius */
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); /* Enhanced shadow */
}

.error-message {
  color: #e53e3e;
  background-color: #fff5f5;
  border: 2px solid #feb2b2; /* Made border thicker */
}

.edit-form {
  background-color: white;
  padding: 3rem 4rem;
  border-radius: 1rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.form-section {
  display: grid;
  grid-template-columns: repeat(3, 1fr); /* Changed from 2 to 3 columns */
  gap: 2.5rem; /* Increased gap */
  margin-bottom: 3rem; /* Increased margin */
  padding-bottom: 2.5rem;
  border-bottom: 2px solid #e2e8f0; /* Made border thicker */
}

.form-section h2 {
  grid-column: 1 / -1; /* Span full width */
  font-size: 1.75rem; /* Increased font size */
  margin-bottom: 2rem;
  color: #553c9a; /* Changed to purple */
  font-weight: 600;
}

.section-info {
  font-size: 1rem;
  color: #4a5568;
  margin-bottom: 0;
  font-weight: 500;
}

.form-group {
  margin-bottom: 1.5rem;
  min-width: 0; /* Prevents overflow */
}

label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #2d3748;
}

input,
textarea,
select {
  width: 100%;
  padding: 0.75rem;
  border: 2px solid #e2e8f0; /* Made border thicker */
  border-radius: 0.75rem; /* Increased border radius */
  font-size: 1rem;
  color: #2d3748;
  transition: all 0.2s;
  background-color: #f8fafc; /* Added light background */
}

input:focus,
textarea:focus,
select:focus {
  border-color: #553c9a; /* Changed to purple */
  box-shadow: 0 0 0 3px rgba(85, 60, 154, 0.2); /* Changed to purple */
  outline: none;
}

textarea {
  resize: vertical;
  min-height: 120px;
}

/* Full width for description and notes textareas */
.form-group:has(textarea) {
  grid-column: 1 / -1;
}

.checkbox-group {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.checkbox-group input[type="checkbox"] {
  width: 1.25rem;
  height: 1.25rem;
}

.location-input-container {
  position: relative;
}

.location-suggestions {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  max-height: 200px;
  overflow-y: auto;
  background-color: white;
  border: 1px solid #e2e8f0;
  border-top: none;
  border-radius: 0 0 0.5rem 0.5rem;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  z-index: 50;
}

.location-suggestion {
  padding: 0.75rem 1rem;
  cursor: pointer;
  transition: background-color 0.2s;
}

.location-suggestion:hover {
  background-color: #edf2f7;
}

/* Improved Image Section */
.images-section {
  grid-column: 1 / -1;
  background-color: #f8fafc;
  padding: 3rem; /* Increased padding */
  border-radius: 1rem;
  border: 2px dashed #e2e8f0;
  margin-top: 1.5rem;
}

.current-images {
  display: flex; /* Changed from grid to flex */
  flex-wrap: wrap; /* Allow wrapping for multiple images */
  gap: 2.5rem; /* Increased gap */
  margin-bottom: 2rem;
  align-items: center; /* Center items vertically */
}

.image-preview {
  flex: 0 0 250px; /* Increased size from 200px */
  height: 250px; /* Increased height */
  position: relative;
  border: 3px solid #e2e8f0;
  border-radius: 1rem;
  overflow: hidden;
  transition: all 0.3s ease;
  background-color: white;
  box-shadow: 0 4px 6px rgba(85, 60, 154, 0.1);
}

.image-preview:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 15px rgba(85, 60, 154, 0.2);
  border-color: #553c9a;
}

.image-preview img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.5s ease;
}

.image-preview:hover img {
  transform: scale(1.08);
}

.remove-image {
  position: absolute;
  top: 1rem;
  right: 1rem;
  width: 3rem;
  height: 3rem;
  border-radius: 1rem;
  background-color: rgba(255, 255, 255, 0.95);
  border: none;
  font-size: 1.75rem;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #553c9a;
  transition: all 0.3s ease;
  backdrop-filter: blur(8px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.remove-image:hover {
  background-color: #553c9a;
  color: white;
  transform: rotate(90deg) scale(1.1);
}

.add-image-container {
  flex: 0 0 250px; /* Increased size from 200px */
  height: 250px; /* Increased height */
}

.add-image-btn {
  width: 100%;
  height: 100%;
  border: 3px dashed #553c9a;
  border-radius: 1.5rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: #553c9a;
  transition: all 0.3s ease;
  background-color: white;
  gap: 1rem;
  font-size: 1.2rem;
  font-weight: 600;
  box-shadow: 0 4px 6px rgba(85, 60, 154, 0.1);
}

.add-image-btn:hover {
  background-color: #553c9a;
  color: white;
  transform: translateY(-4px);
  box-shadow: 0 8px 15px rgba(85, 60, 154, 0.2);
}

.add-image-btn span:first-child {
  font-size: 2.5rem;
  font-weight: 400;
}

/* Button Styling */
.form-actions {
  display: flex;
  gap: 1.5rem;
  margin-top: 3rem;
  grid-column: 1 / -1;
}

.submit-btn {
  flex: 1;
  background-color: #553c9a;
  color: white;
  padding: 1rem 2rem;
  border: none;
  border-radius: 1rem;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 6px rgba(85, 60, 154, 0.2);
}

.submit-btn:hover {
  background-color: #6b46c1;
  transform: translateY(-2px);
  box-shadow: 0 8px 15px rgba(85, 60, 154, 0.3);
}

.submit-btn:disabled {
  background-color: #cbd5e0;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

.cancel-btn {
  padding: 1rem 2rem;
  background-color: white;
  color: #553c9a;
  border: 2px solid #553c9a;
  border-radius: 1rem;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.cancel-btn:hover {
  background-color: #553c9a;
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 4px 6px rgba(85, 60, 154, 0.2);
}

/* Enhanced Select Dropdowns */
select {
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%23553C9A'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 1rem center;
  background-size: 1.5rem;
  padding-right: 2.5rem;
  cursor: pointer;
}

select:hover {
  border-color: #553c9a;
  background-color: #f8fafc;
}

select option {
  padding: 0.75rem;
  font-size: 1rem;
}

/* Add visual feedback for form controls */
input:hover,
textarea:hover,
select:hover {
  border-color: #553c9a;
}

/* Image count indicator */
.image-info {
  text-align: center;
  color: #553c9a;
  font-size: 0.9rem;
  margin-top: 1rem;
  font-weight: 500;
}

/* Responsive adjustments */
@media (max-width: 1024px) {
  .current-images {
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  }
}

@media (max-width: 640px) {
  .edit-book-container {
    max-width: 100%;
    margin: 1rem auto;
    padding: 0 1rem;
  }

  .edit-form {
    padding: 1.5rem;
  }

  .current-images {
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
    gap: 1rem;
  }

  .remove-image {
    width: 2rem;
    height: 2rem;
    font-size: 1.25rem;
  }

  h1 {
    font-size: 1.75rem;
  }
}

/* Responsive adjustments */
@media (max-width: 1200px) {
  .form-section {
    grid-template-columns: repeat(2, 1fr); /* 2 columns on smaller screens */
  }
}

@media (max-width: 768px) {
  .form-section {
    grid-template-columns: 1fr; /* Single column on mobile */
  }

  .image-preview,
  .add-image-container {
    flex: 0 0 200px;
    height: 200px;
  }
}

@media (max-width: 480px) {
  .image-preview,
  .add-image-container {
    flex: 0 0 120px;
    height: 120px;
  }
}

.image-section-header {
  grid-column: 1 / -1;
  margin-bottom: 1.5rem;
}
</style>

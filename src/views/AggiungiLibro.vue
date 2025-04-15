<template>
  <div class="add-book-page">
    <Navbar />

    <div class="page-content">
      <h2 class="page-title">Aggiungi Libro</h2>
      <p class="page-subtitle">
        Inserisci i dettagli del libro che vuoi vendere
      </p>

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

        <form
          @submit.prevent="submitBook"
          class="book-form">
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
              <div class="location-input-container">
                <input
                  type="text"
                  id="location"
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
                  required
                  autocomplete="off"
                  placeholder="Inizia a digitare il nome del comune..." />

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
              <small
                class="location-help-text"
                v-if="comuniError">
                Errore nel caricamento dei comuni. Puoi inserire manualmente la
                tua città.
              </small>
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

// Comuni italiani
const comuni = ref([]);
const locationInput = ref("");
const filteredComuni = ref([]);
const showSuggestions = ref(false);
const selectedSuggestionIndex = ref(-1);
const isLoadingComuni = ref(false);
const comuniError = ref(null);

// Database di province per comuni principali italiani
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
  Venezia: { nome: "Venezia", sigla: "VE" },
  Verona: { nome: "Verona", sigla: "VR" },
  Messina: { nome: "Messina", sigla: "ME" },
  Padova: { nome: "Padova", sigla: "PD" },
  Trieste: { nome: "Trieste", sigla: "TS" },
  Taranto: { nome: "Taranto", sigla: "TA" },
  Brescia: { nome: "Brescia", sigla: "BS" },
  Parma: { nome: "Parma", sigla: "PR" },
  Prato: { nome: "Prato", sigla: "PO" },
  Modena: { nome: "Modena", sigla: "MO" },
  "Reggio Calabria": { nome: "Reggio Calabria", sigla: "RC" },
  "Reggio Emilia": { nome: "Reggio Emilia", sigla: "RE" },
  Perugia: { nome: "Perugia", sigla: "PG" },
  Livorno: { nome: "Livorno", sigla: "LI" },
  Ravenna: { nome: "Ravenna", sigla: "RA" },
  Cagliari: { nome: "Cagliari", sigla: "CA" },
  Foggia: { nome: "Foggia", sigla: "FG" },
  Salerno: { nome: "Salerno", sigla: "SA" },
  Rimini: { nome: "Rimini", sigla: "RN" },
  Ferrara: { nome: "Ferrara", sigla: "FE" },
  Sassari: { nome: "Sassari", sigla: "SS" },
  Latina: { nome: "Latina", sigla: "LT" },
  "Giugliano in Campania": { nome: "Napoli", sigla: "NA" },
  Monza: { nome: "Monza e della Brianza", sigla: "MB" },
  Siracusa: { nome: "Siracusa", sigla: "SR" },
  Pescara: { nome: "Pescara", sigla: "PE" },
  Bergamo: { nome: "Bergamo", sigla: "BG" },
  Forlì: { nome: "Forlì-Cesena", sigla: "FC" },
  Vicenza: { nome: "Vicenza", sigla: "VI" },
  Trento: { nome: "Trento", sigla: "TN" },
  Terni: { nome: "Terni", sigla: "TR" },
  Bolzano: { nome: "Bolzano/Bozen", sigla: "BZ" },
  Novara: { nome: "Novara", sigla: "NO" },
  Ancona: { nome: "Ancona", sigla: "AN" },
  Andria: { nome: "Barletta-Andria-Trani", sigla: "BT" },
  Piacenza: { nome: "Piacenza", sigla: "PC" },
  Udine: { nome: "Udine", sigla: "UD" },
  Arezzo: { nome: "Arezzo", sigla: "AR" },
  Cesena: { nome: "Forlì-Cesena", sigla: "FC" },
  Lecce: { nome: "Lecce", sigla: "LE" },
  Pesaro: { nome: "Pesaro e Urbino", sigla: "PU" },
  Alessandria: { nome: "Alessandria", sigla: "AL" },
  Barletta: { nome: "Barletta-Andria-Trani", sigla: "BT" },
  "La Spezia": { nome: "La Spezia", sigla: "SP" },
  Catanzaro: { nome: "Catanzaro", sigla: "CZ" },
  Pistoia: { nome: "Pistoia", sigla: "PT" },
  Caserta: { nome: "Caserta", sigla: "CE" },
  Como: { nome: "Como", sigla: "CO" },
  Lucca: { nome: "Lucca", sigla: "LU" },
  Treviso: { nome: "Treviso", sigla: "TV" },
  Monza: { nome: "Monza e della Brianza", sigla: "MB" },
  Varese: { nome: "Varese", sigla: "VA" },
};

// Carica i comuni italiani
const fetchComuni = async () => {
  try {
    isLoadingComuni.value = true;
    comuniError.value = null;

    // Forziamo il ricaricamento dei dati per risolvere il problema dei punti interrogativi
    localStorage.removeItem("comuni-cache");
    localStorage.removeItem("comuni-cache-timestamp");

    // Tentativo di ottenere i dati da API
    console.log("Caricamento comuni da API...");
    const response = await fetch(
      "https://raw.githubusercontent.com/matteocontrini/comuni-json/master/comuni.json"
    );
    if (!response.ok) {
      throw new Error(`Errore nel caricamento dei comuni: ${response.status}`);
    }

    const data = await response.json();
    console.log(`Ricevuti ${data.length} comuni dall'API`);

    // Pulizia e normalizzazione più aggressiva dei dati
    const normalizedData = data
      .filter((comune) => comune && comune.nome) // Filtra solo comuni validi con un nome
      .map((comune) => {
        // Controllo se il comune è nel nostro database di province
        const comuneName = comune.nome.trim();
        if (provinceMap[comuneName]) {
          // Sostituisci con la provincia corretta dal nostro database
          comune.provincia = {
            nome: provinceMap[comuneName].nome,
            sigla: provinceMap[comuneName].sigla,
          };
          return comune;
        }

        // Gestisci i casi in cui la provincia non è definita correttamente
        if (
          !comune.provincia ||
          !comune.provincia.sigla ||
          comune.provincia.sigla === "??" ||
          comune.provincia.sigla.length !== 2
        ) {
          // Prova a estrarre la provincia dal nome (es. "Comune (PR)")
          const provinceMatch = comune.nome.match(/\s*\(([A-Z]{2})\)\s*$/);
          if (provinceMatch && provinceMatch[1]) {
            comune.provincia = {
              nome: "Provincia di " + provinceMatch[1],
              sigla: provinceMatch[1],
            };
            return comune;
          }

          // Cerca di dedurre la provincia dal nome del comune
          for (const [city, province] of Object.entries(provinceMap)) {
            // Se il nome del comune contiene la città chiave
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

          // Se non riusciamo a determinare la provincia, imposta un valore generico
          comune.provincia = {
            nome: "Provincia non specificata",
            sigla: "", // Stringa vuota invece di "??"
          };
        }

        return comune;
      });

    // Ulteriore verifica per assicurarci che non rimangano punti interrogativi
    for (const comune of normalizedData) {
      if (comune.provincia && comune.provincia.sigla === "??") {
        console.warn(`Rimozione sigla ?? per ${comune.nome}`);
        comune.provincia.sigla = "";
      }
    }

    comuni.value = normalizedData;

    // Salva i dati puliti in cache
    try {
      localStorage.setItem("comuni-cache", JSON.stringify(normalizedData));
      localStorage.setItem("comuni-cache-timestamp", Date.now().toString());
      console.log("Comuni salvati in cache");
    } catch (e) {
      console.warn("Impossibile salvare i comuni in cache:", e);
    }

    console.log(`Caricati ${comuni.value.length} comuni italiani`);
  } catch (error) {
    console.error("Errore durante il caricamento dei comuni:", error);
    comuniError.value = error.message;
  } finally {
    isLoadingComuni.value = false;
  }
};

// Filtra i comuni in base all'input
const handleLocationInput = () => {
  if (locationInput.value.length < 2) {
    filteredComuni.value = [];
    return;
  }

  const input = locationInput.value.toLowerCase().trim();

  filteredComuni.value = comuni.value
    .filter((comune) => {
      // Cerca sia nel nome del comune che nella provincia
      const matchesName = comune.nome.toLowerCase().includes(input);
      const matchesProvincia =
        comune.provincia &&
        (comune.provincia.nome.toLowerCase().includes(input) ||
          comune.provincia.sigla.toLowerCase() === input);

      // Dai priorità ai comuni che iniziano con la stringa di ricerca
      return matchesName || matchesProvincia;
    })
    .sort((a, b) => {
      // Ordina mettendo prima i risultati che iniziano con la stringa di ricerca
      const aStartsWithQuery = a.nome.toLowerCase().startsWith(input);
      const bStartsWithQuery = b.nome.toLowerCase().startsWith(input);

      if (aStartsWithQuery && !bStartsWithQuery) return -1;
      if (!aStartsWithQuery && bStartsWithQuery) return 1;

      // Se entrambi iniziano o non iniziano con la query, ordina alfabeticamente
      return a.nome.localeCompare(b.nome);
    })
    .slice(0, 15); // Aumentiamo il limite a 15 risultati per includere più opzioni

  selectedSuggestionIndex.value = -1;
  showSuggestions.value = true;
};

// Gestisce la selezione di un comune dai suggerimenti con sigla corretta
const selectSuggestion = (index) => {
  if (index >= 0 && index < filteredComuni.value.length) {
    const selectedComune = filteredComuni.value[index];

    // Verifico se il comune è nel database principale
    if (provinceMap[selectedComune.nome]) {
      const provinciaCorretta = provinceMap[selectedComune.nome];
      locationInput.value = `${selectedComune.nome} (${provinciaCorretta.sigla})`;
    }
    // Altrimenti usa i dati presenti se validi
    else if (
      selectedComune.provincia &&
      selectedComune.provincia.sigla &&
      selectedComune.provincia.sigla.length === 2 &&
      selectedComune.provincia.sigla !== "??"
    ) {
      locationInput.value = `${selectedComune.nome} (${selectedComune.provincia.sigla})`;
    }
    // Fallback: usa solo il nome del comune
    else {
      locationInput.value = selectedComune.nome;
    }

    bookData.location = locationInput.value;
    showSuggestions.value = false;
  }
};

// Gestisce la navigazione con le frecce su/giù
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

// Gestisce il blur del campo input
const handleLocationBlur = () => {
  // Ritarda la chiusura per permettere il click sui suggerimenti
  setTimeout(() => {
    showSuggestions.value = false;
  }, 200);

  // Aggiorna bookData.location con l'input corrente
  bookData.location = locationInput.value;
};

// Funzione per forzare il ricaricamento dei comuni (utile per debug)
const forceReloadComuni = () => {
  localStorage.removeItem("comuni-cache");
  localStorage.removeItem("comuni-cache-timestamp");
  comuni.value = [];
  fetchComuni();
};

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

    // Carica le immagini direttamente
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
      additional_images: imageUrls,
    };

    const bookToInsert = {
      name: bookData.title,
      description: bookData.description,
      price: bookData.price,
      user_id: user.value.id,
      metadata: bookDetails,
      status: "active",
    };

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

  locationInput.value = ""; // Resetta anche l'input di ricerca comuni
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
    } else {
      console.log("Utente non autenticato");
    }

    // Forza il ricaricamento per pulire i dati problematici
    forceReloadComuni();

    // Carica i comuni italiani
    await fetchComuni();
  } catch (error) {
    console.error("Error during initialization:", error);
    errorMessage.value = "Si è verificato un errore: " + error.message;
  } finally {
    isLoading.value = false;
  }
});
</script>

<style scoped>
.add-book-page {
  width: 100%;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.page-content {
  flex: 1;
  width: 100%;
  max-width: 100%;
  padding: 0 20px 40px;
  box-sizing: border-box;
}

.page-title {
  font-size: 28px;
  margin: 20px 0 5px;
  text-align: center;
}

.page-subtitle {
  color: #666;
  text-align: center;
  margin-bottom: 30px;
}

.book-form {
  max-width: 1200px;
  margin: 0 auto;
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

@media (max-width: 768px) {
  .page-content {
    padding: 0 10px 20px;
  }

  .book-form {
    padding: 15px;
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

/* Assicura che tutti i testi siano ben visibili */
.add-book-page,
.add-book-page input,
.add-book-page textarea,
.add-book-page select,
.add-book-page button,
.add-book-page label,
.add-book-page p,
.add-book-page h2,
.add-book-page h3,
.add-book-page option {
  color: #000000;
}

.add-book-page select option {
  color: #000000;
  background-color: #ffffff;
}

.submit-button,
.login-button {
  color: white !important;
}

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
  border-radius: 0 0 4px 4px;
  z-index: 10;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.comune-suggestion {
  padding: 10px 15px;
  cursor: pointer;
  transition: background-color 0.2s;
  display: flex;
  justify-content: space-between;
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

.location-help-text {
  color: #666;
  font-size: 12px;
  margin-top: 5px;
}
</style>

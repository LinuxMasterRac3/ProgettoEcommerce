<!-- filepath: c:\Users\HP1342\Desktop\Progetto_e-commerce\ProgettoEcommerce\src\views\Cart.vue -->
<template>
  <div class="page-wrapper">
    <!-- Navbar -->
    <Navbar />

    <div class="cart-container">
      <!-- Stato di caricamento -->
      <div
        v-if="isLoading"
        class="loading-container">
        <p>Caricamento carrello...</p>
      </div>

      <!-- Stato di errore -->
      <div
        v-else-if="error"
        class="error-container">
        <p>{{ error }}</p>
        <button
          @click="fetchCartItems"
          class="retry-button">
          Riprova
        </button>
      </div>

      <!-- Contenuto del carrello -->
      <div v-else>
        <!-- Intestazioni Tabella Carrello -->
        <div
          class="cart-table-header"
          v-if="cartItems.length > 0">
          <div class="header-product">Prodotto</div>
          <div class="header-price">Prezzo</div>
          <div class="header-subtotal">Subtotale</div>
          <div class="header-remove"></div>
        </div>

        <!-- Lista Articoli Carrello -->
        <div class="cart-items-list">
          <div
            v-if="cartItems.length === 0"
            class="empty-cart">
            <p>Il tuo carrello è vuoto.</p>
            <RouterLink
              to="/shop"
              class="continue-shopping-btn empty-cart-btn">
              Torna allo Shop
            </RouterLink>
          </div>

          <!-- Riga Articolo -->
          <div
            v-if="cartItems.length > 0"
            class="cart-items-list">
            <div
              class="cart-item-row"
              v-for="(item, index) in cartItems"
              :key="item.id">
              <div class="item-product">
                <img
                  :src="item.image"
                  :alt="item.name"
                  class="item-image" />
                <span class="item-name">{{ item.name }}</span>
              </div>
              <div class="item-price">€{{ item.price.toFixed(2) }}</div>
              <div class="item-subtotal">
                €{{ (item.price * item.quantity).toFixed(2) }}
              </div>
              <div class="item-remove">
                <button @click="removeItem(index)">×</button>
              </div>
            </div>
          </div>
        </div>

        <!-- Azioni Sotto la Tabella (se carrello non vuoto) -->
        <div
          class="cart-actions-bar"
          v-if="cartItems.length > 0">
          <RouterLink
            to="/shop"
            class="continue-shopping-btn">
            Torna allo Shop
          </RouterLink>
          <!-- L'Update Cart non è strettamente necessario con Vue reattivo
               <button class="update-cart-btn">Update Cart</button>
          -->
        </div>

        <!-- Sezione Inferiore: Promo Code e Riepilogo (se carrello non vuoto) -->
        <div
          v-if="cartItems.length > 0"
          class="cart-details-bottom">
          <!-- Colonna Sinistra: Codice Promozionale -->
          <div class="promo-code-section">
            <!-- <label for="promoCodeInput" class="promo-label">Coupon Code</label> -->
            <input
              id="promoCodeInput"
              type="text"
              v-model="promoCode"
              placeholder="Codice Sconto"
              class="promo-input" />
            <button
              @click="applyPromoCode"
              class="apply-promo-button">
              Applica Codice
            </button>
            <p
              v-if="promoMessage"
              class="promo-message"
              :class="{ error: isPromoError }">
              {{ promoMessage }}
            </p>
          </div>

          <!-- Colonna Destra: Riepilogo Carrello -->
          <div class="cart-summary-section">
            <h3 class="summary-title">Carrello</h3>
            <div class="summary-details">
              <p>
                <span>Subtotale</span> <span>€{{ cartTotal.toFixed(2) }}</span>
              </p>
              <p
                v-if="discount > 0"
                class="summary-discount">
                <span>Sconto ({{ discount }}%)</span>
                <span>- €{{ (cartTotal - discountedTotal).toFixed(2) }}</span>
              </p>
              <p>
                <span>Spedizione</span> <span>{{ shippingDisplay }}</span>
              </p>
              <hr class="summary-divider" />
              <p class="summary-total">
                <strong>
                  <span>Totale</span>
                  <span
                    >€{{
                      totalWithShipping ? totalWithShipping.toFixed(2) : "0.00"
                    }}</span
                  >
                </strong>
              </p>
            </div>
            <button
              class="checkout-button"
              @click="checkout">
              Procedi al checkout
            </button>
          </div>
        </div>
      </div>
      <!-- <Footer /> -->
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { createClient } from "@supabase/supabase-js";
import { RouterLink } from "vue-router";
import Navbar from "../components/Navbar.vue";

// Configurazione Supabase
const supabaseUrl = "https://tiylfyyfitqzwstftzpg.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpeWxmeXlmaXRxendzdGZ0enBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNjYyNDcsImV4cCI6MjA1Njc0MjI0N30.CvIx_vI-KGGcFlcZy66-DIC8Itk03Olw3lzEMhnJP_c";
const supabase = createClient(supabaseUrl, supabaseKey);

// Stato del carrello
const cartItems = ref([]); // Array vuoto per i libri nel carrello
const isLoading = ref(true);
const error = ref<string | null>(null);

// Funzione per recuperare i dettagli dei libri dal database
const fetchCartItems = async () => {
  isLoading.value = true;
  error.value = null;

  try {
    const savedCart = JSON.parse(localStorage.getItem("cart") || "[]");
    console.log("Saved cart:", savedCart); // Log per verificare gli ID salvati

    if (savedCart.length === 0) {
      cartItems.value = [];
      return;
    }

    const { data, error: fetchError } = await supabase
      .from("products")
      .select("*")
      .in("id", savedCart);

    if (fetchError) throw fetchError;

    console.log("Fetched data:", data); // Log per verificare i dati recuperati

    cartItems.value = data.map((item) => ({
      id: item.id,
      name: item.name,
      price: item.price,
      quantity: 1,
      image: item.image_url,
    }));
  } catch (err) {
    console.error("Errore durante il recupero dei dati del carrello:", err);
    error.value =
      "Impossibile caricare i dati del carrello. Riprova più tardi.";
  } finally {
    isLoading.value = false;
  }
};

const cartTotal = computed(() =>
  cartItems.value.reduce((total, item) => total + item.price * item.quantity, 0)
);

const shippingCost = ref(5); // Costo di spedizione predefinito
const totalWithShipping = computed(() => cartTotal.value + shippingCost.value);

// Rimuovi un libro dal carrello
const removeItem = (index: number) => {
  const removedItem = cartItems.value.splice(index, 1);

  // Aggiorna il carrello salvato in localStorage
  const savedCart = JSON.parse(localStorage.getItem("cart") || "[]");
  const updatedCart = savedCart.filter(
    (id: string) => id !== removedItem[0].id
  );
  localStorage.setItem("cart", JSON.stringify(updatedCart));
};

// Recupera i dati al montaggio del componente
onMounted(() => {
  fetchCartItems();
});

const applyPromoCode = () => {
  const code = promoCode.value.trim().toUpperCase(); // Pulisci e metti in maiuscolo
  if (code === "SCONTO10") {
    discount.value = 10;
    promoMessage.value = "Sconto 10% applicato!";
  } else if (code === "SCONTO20") {
    discount.value = 20;
    promoMessage.value = "Sconto 20% applicato!";
  } else {
    discount.value = 0;
    if (code === "") {
      promoMessage.value = ""; // Nessun messaggio se vuoto
    } else {
      promoMessage.value = "Codice sconto non valido.";
    }
  }
};

const resetPromo = () => {
  promoCode.value = "";
  promoMessage.value = "";
  discount.value = 0;
};

const checkout = () => {
  console.log("Procedendo al checkout con:", {
    items: cartItems.value.map((item) => ({
      id: item.id,
      name: item.name,
      quantity: item.quantity,
      price: item.price,
    })),
    subtotal: cartTotal.value,
    discountApplied: discount.value,
    shipping: shippingCost.value,
    total: totalWithShipping.value,
    promoCode: promoCode.value,
  });
  alert("Procedi al pagamento (simulazione)");
};
</script>

<style scoped>
/* Stili Generali */
.page-wrapper {
  background-color: #fff; /* Sfondo bianco pulito */
  color: #333;
}

.cart-container {
  max-width: 1100px; /* Larghezza leggermente ridotta per il design */
  margin: 30px auto;
  padding: 20px;
}

/* Intestazioni Tabella Carrello */
.cart-table-header {
  display: flex;
  padding: 10px 0;
  border-bottom: 2px solid #eee;
  margin-bottom: 10px;
  font-weight: 600;
  font-size: 0.9em;
  color: #555;
}

.header-product {
  flex: 3;
  padding-left: 10px;
}
.header-price {
  flex: 1;
  text-align: center;
}
.header-quantity {
  flex: 1;
  text-align: center;
}
.header-subtotal {
  flex: 1;
  text-align: right;
}
.header-remove {
  flex: 0 0 50px;
} /* Larghezza fissa per icona rimozione */

/* Lista Articoli */
.cart-items-list {
  margin-bottom: 30px;
}

/* Riga Articolo */
.cart-item-row {
  display: flex;
  align-items: center;
  padding: 15px 0;
  border-bottom: 1px solid #f0f0f0; /* Bordo sottile tra gli articoli */
}
.cart-item-row:last-child {
  border-bottom: none;
}

/* Colonne Articolo */
.item-product {
  flex: 3;
  display: flex;
  align-items: center;
  gap: 15px;
  padding-left: 10px;
}
.item-image {
  width: 60px;
  height: 80px;
  object-fit: cover;
  border: 1px solid #eee;
  border-radius: 4px;
}
.item-name {
  font-weight: 500;
  color: #444;
}

.item-price,
.item-quantity,
.item-subtotal {
  flex: 1;
  text-align: center;
  color: #666;
}
.item-subtotal {
  text-align: right;
  font-weight: 500;
  color: #333;
}

.item-remove {
  flex: 0 0 50px; /* Larghezza fissa */
  text-align: center;
}

/* Controlli Quantità */
.quantity-controls {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}
.quantity-controls button {
  width: 28px;
  height: 28px;
  border: 1px solid #ccc;
  background-color: #f8f8f8;
  color: #555;
  border-radius: 50%; /* Bottoni tondi */
  cursor: pointer;
  font-weight: bold;
  line-height: 26px; /* Centra il testo verticalmente */
  transition: background-color 0.2s;
}
.quantity-controls button:hover {
  background-color: #eee;
}
.quantity-controls span {
  font-weight: 500;
  min-width: 20px;
  text-align: center;
}

/* Pulsante Rimuovi */
.remove-button {
  background: none;
  border: none;
  color: #aaa;
  font-size: 1.6em; /* Icona 'x' più grande */
  cursor: pointer;
  padding: 0 5px;
  line-height: 1;
  transition: color 0.2s;
}
.remove-button:hover {
  color: #d9534f; /* Rosso su hover */
}

/* Barra Azioni (Torna allo Shop) */
.cart-actions-bar {
  display: flex;
  justify-content: space-between; /* Pulsanti ai lati */
  padding: 20px 0;
  border-top: 1px solid #eee;
  margin-bottom: 30px;
}
.continue-shopping-btn {
  padding: 10px 20px;
  border: 1px solid #ccc;
  background-color: #fff;
  color: #555;
  border-radius: 4px;
  text-decoration: none;
  font-weight: 500;
  transition: all 0.2s;
}
.continue-shopping-btn:hover {
  background-color: #f8f8f8;
  border-color: #bbb;
}
.continue-shopping-btn.empty-cart-btn {
  display: inline-block; /* Rende il link un blocco per margini */
  margin-top: 20px;
  background-color: #555; /* Stile diverso per carrello vuoto */
  color: white;
  border: none;
}
.continue-shopping-btn.empty-cart-btn:hover {
  background-color: #333;
}

/* Sezione Inferiore (Promo + Riepilogo) */
.cart-details-bottom {
  display: flex;
  gap: 40px; /* Aumenta lo spazio tra le colonne */
  flex-wrap: wrap;
  background-color: #f9f9f9; /* Sfondo leggermente grigio per la sezione inferiore */
  padding: 30px;
  border-radius: 8px;
  border: 1px solid #eee;
}

/* Colonna Codice Sconto */
.promo-code-section {
  flex: 1;
  min-width: 280px;
  display: flex; /* Per allineare input e bottone */
  align-items: flex-start; /* Allinea in alto se il messaggio appare */
  flex-wrap: wrap; /* Permette al messaggio di andare sotto */
  gap: 10px;
}
.promo-label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  width: 100%;
}
.promo-input {
  flex-grow: 1; /* Occupa spazio */
  padding: 12px; /* Padding maggiore */
  border: 1px solid #ccc;
  border-radius: 4px;
  font-size: 1em;
  height: 44px; /* Altezza fissa */
  box-sizing: border-box;
}
.apply-promo-button {
  padding: 0 25px; /* Padding orizzontale */
  border: none;
  background-color: #333a40; /* Colore scuro come immagine */
  color: white;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
  height: 44px; /* Stessa altezza dell'input */
  line-height: 44px; /* Centra verticalmente */
  white-space: nowrap;
  transition: background-color 0.2s;
}
.apply-promo-button:hover {
  background-color: #4a535a;
}
.promo-message {
  width: 100%; /* Occupa tutta la larghezza */
  margin-top: 5px; /* Spazio sopra il messaggio */
  font-size: 0.9em;
  color: #28a745; /* Verde successo */
}
.promo-message.error {
  color: #dc3545; /* Rosso errore */
}

/* Colonna Riepilogo Carrello */
.cart-summary-section {
  flex: 1;
  min-width: 280px;
  border: 1px solid #ddd;
  padding: 25px;
  border-radius: 6px;
  background-color: #ffffff; /* Sfondo bianco per il box */
}
.summary-title {
  text-align: left; /* Titolo a sinistra */
  margin-top: 0;
  margin-bottom: 25px;
  font-size: 1.3em;
  color: #333;
}
.summary-details p {
  display: flex;
  justify-content: space-between;
  margin-bottom: 12px;
  color: #555;
  font-size: 0.95em;
}
.summary-details span:last-child {
  font-weight: 500;
  color: #333;
}
.summary-discount span:last-child {
  color: #28a745; /* Verde per lo sconto */
}

.summary-divider {
  border: none;
  border-top: 1px solid #eee;
  margin: 20px 0;
}
.summary-total {
  font-size: 1.1em; /* Totale leggermente più grande */
  font-weight: bold;
  color: #333;
}
.summary-total span:last-child {
  font-size: 1.2em; /* Prezzo totale ancora più grande */
}

.checkout-button {
  margin-top: 25px;
  padding: 14px 25px;
  width: 100%;
  border: none;
  background-color: #333a40; /* Colore scuro come immagine */
  color: white;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1.1em;
  font-weight: 600;
  transition: background-color 0.2s;
}
.checkout-button:hover {
  background-color: #4a535a;
}

/* Stili Carrello Vuoto */
.empty-cart {
  text-align: center;
  padding: 60px 20px;
  border: 1px dashed #ddd;
  border-radius: 8px;
  background-color: #f9f9f9;
}
.empty-cart p {
  font-size: 1.2em;
  color: #666;
  margin-bottom: 25px;
}

/* Responsive */
@media (max-width: 992px) {
  .cart-table-header {
    /* Potrebbe essere necessario nascondere/modificare header su mobile */
    font-size: 0.85em;
  }
  .item-product {
    flex: 2.5;
  } /* Riduce spazio prodotto */
  .header-product {
    flex: 2.5;
  }
}

@media (max-width: 768px) {
  .cart-table-header {
    display: none; /* Nasconde header su schermi piccoli */
  }
  .cart-item-row {
    flex-direction: column; /* Stack verticale */
    align-items: flex-start; /* Allinea a sinistra */
    padding: 20px;
    border: 1px solid #eee; /* Bordo per ogni item */
    border-radius: 6px;
    margin-bottom: 15px;
    position: relative; /* Per posizionare il tasto rimuovi */
  }
  .item-product,
  .item-price,
  .item-quantity,
  .item-subtotal,
  .item-remove {
    flex: auto; /* Reset flex */
    width: 100%; /* Larghezza piena */
    text-align: left; /* Allinea a sinistra */
    margin-bottom: 10px; /* Spazio tra elementi */
    padding: 0;
  }
  .item-product {
    gap: 10px;
    margin-bottom: 15px;
  }
  .item-price::before,
  .item-quantity::before,
  .item-subtotal::before {
    /* Aggiunge etichette su mobile */
    content: attr(data-label);
    font-weight: bold;
    display: inline-block;
    width: 80px; /* Larghezza fissa etichetta */
    color: #555;
    margin-right: 10px;
  }
  /* Riassegna i data-label (anche se non usati sopra, utile come riferimento) */
  .item-price::before {
    content: "Prezzo:";
  }
  .item-quantity::before {
    content: "Quantità:";
  }
  .item-subtotal::before {
    content: "Subtotale:";
  }

  .item-price,
  .item-subtotal {
    display: flex; /* Per allineare etichetta e valore */
    justify-content: space-between;
  }
  .item-quantity {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  .quantity-controls {
    justify-content: flex-end;
  } /* Sposta controlli a destra */

  .item-remove {
    position: absolute; /* Posiziona tasto rimuovi */
    top: 10px;
    right: 10px;
    width: auto;
    margin-bottom: 0;
  }
  .remove-button {
    font-size: 1.4em;
    padding: 0;
  }

  .cart-details-bottom {
    flex-direction: column; /* Stack verticale anche per promo/summary */
    padding: 20px;
  }
  .promo-code-section {
    margin-bottom: 20px; /* Spazio tra promo e summary */
  }
  .cart-actions-bar {
    flex-direction: column;
    gap: 15px;
    align-items: center;
  }
}
</style>

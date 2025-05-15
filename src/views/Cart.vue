<!-- @format -->

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

      <!-- Utente non autenticato -->
      <div
        v-else-if="!isAuthenticated"
        class="not-logged-in">
        <p>Per visualizzare il carrello, devi effettuare il login.</p>
        <RouterLink
          to="/login"
          class="login-button">
          Accedi
        </RouterLink>
        <RouterLink
          to="/"
          class="home-button">
          Torna alla Home
        </RouterLink>
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
                <!-- Aggiunto RouterLink per l'immagine -->
                <RouterLink :to="`/product/${item.id}`">
                  <img
                    :src="getMainImage(item)"
                    :alt="item.name"
                    class="item-image" />
                </RouterLink>
                <!-- Aggiunto RouterLink per il nome -->
                <RouterLink
                  :to="`/product/${item.id}`"
                  class="item-name-link">
                  <span class="item-name">{{ item.name }}</span>
                </RouterLink>
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
                <span>Spedizione</span>
                <span>€{{ shippingCost.toFixed(2) }}</span>
              </p>
              <hr class="summary-divider" />
              <p class="summary-total">
                <strong>
                  <span>Totale</span>
                  <span>€{{ totalWithShipping.toFixed(2) }}</span>
                </strong>
              </p>
            </div>
            <button
              class="checkout-button"
              @click="checkout"
              :disabled="isProcessingCheckout || cartItems.length === 0">
              {{
                isProcessingCheckout ? 'Processando...' : 'Procedi al checkout'
              }}
            </button>
            <p
              v-if="checkoutError"
              class="error-message"
              style="color: red; text-align: center; margin-top: 10px">
              {{ checkoutError }}
            </p>
          </div>
        </div>
      </div>
    </div>

    <!-- Footer -->
    <Footer />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { createClient } from '@supabase/supabase-js';
import { RouterLink, useRouter } from 'vue-router';
import Navbar from '../components/Navbar.vue';
import Footer from '../components/footer.vue';

const BACKEND_API_URL = 'http://localhost:3000';
const router = useRouter();

interface CartItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
  metadata: any;
}

const supabaseUrl = 'https://tiylfyyfitqzwstftzpg.supabase.co';
const supabaseKey =
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpeWxmeXlmaXRxendzdGZ0enBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNjYyNDcsImV4cCI6MjA1Njc0MjI0N30.CvIx_vI-KGGcFlcZy66-DIC8Itk03Olw3lzEMhnJP_c';
const supabase = createClient(supabaseUrl, supabaseKey);

const cartItems = ref<CartItem[]>([]);
const isLoading = ref(true);
const error = ref<string | null>(null);
const isAuthenticated = ref(false);

const discount = ref<number>(0);
const isPromoError = ref<boolean>(false);
const isProcessingCheckout = ref(false); // Added missing variable
const promoCode = ref(''); // Added missing variable
const promoMessage = ref(''); // Added missing variable
const checkoutError = ref<string | null>(null); // Added missing variable

const checkAuth = async () => {
  try {
    const {
      data: { session },
    } = await supabase.auth.getSession();
    isAuthenticated.value = !!session;
  } catch (err) {
    console.error('Error checking authentication:', err);
    isAuthenticated.value = false;
  }
};

const discountedTotal = computed(() => {
  if (discount.value > 0) {
    return cartTotal.value * (1 - discount.value / 100);
  }
  return cartTotal.value;
});

const fetchCartItems = async () => {
  isLoading.value = true;
  error.value = null;

  try {
    const savedCart = JSON.parse(localStorage.getItem('cart') || '[]');

    if (savedCart.length === 0) {
      cartItems.value = [];
      isLoading.value = false;
      return;
    }

    const { data, error: fetchError } = await supabase
      .from('products')
      .select('*')
      .in('id', savedCart);

    if (fetchError) throw fetchError;

    if (!data || data.length === 0) {
      cartItems.value = [];
      isLoading.value = false;
      return;
    }

    cartItems.value = data.map((item) => ({
      id: item.id,
      name: item.name,
      price: parseFloat(item.price) || 0,
      quantity: 1,
      metadata: item.metadata || {},
    }));
  } catch (err) {
    console.error('Error loading cart items:', err);
    error.value =
      'Impossibile caricare i dati del carrello. Riprova più tardi.';
  } finally {
    isLoading.value = false;
  }
};

const shippingCost = computed(() => {
  const totalBooks = cartItems.value.reduce(
    (total, item) => total + item.quantity,
    0
  );
  return totalBooks * 1.99; // €1,99 per ogni libro
});

const totalWithShipping = computed(() => cartTotal.value + shippingCost.value);

const getMainImage = (item: any) => {
  if (
    item.metadata?.additional_images &&
    item.metadata.additional_images.length > 0
  ) {
    return item.metadata.additional_images[0];
  }
  return 'https://placehold.co/300x400?text=No+Image';
};

const cartTotal = computed(() =>
  cartItems.value.reduce((total, item) => total + item.price * item.quantity, 0)
);

// Rimuovi un libro dal carrello
const removeItem = (index: number) => {
  const removedItem = cartItems.value.splice(index, 1);

  // Aggiorna il carrello salvato in localStorage
  const savedCart = JSON.parse(localStorage.getItem('cart') || '[]');
  const updatedCart = savedCart.filter(
    (id: string) => id !== removedItem[0].id
  );
  localStorage.setItem('cart', JSON.stringify(updatedCart));
};

// Recupera i dati al montaggio del componente
onMounted(async () => {
  await checkAuth();
  await fetchCartItems();
});

const applyPromoCode = () => {
  const code = promoCode.value.trim().toUpperCase();
  isPromoError.value = false;
  promoMessage.value = ''; // Ensure promoMessage is reset

  if (!code) {
    discount.value = 0;
    return;
  }

  if (code === 'SCONTO10') {
    discount.value = 10;
    promoMessage.value = 'Sconto 10% applicato!';
  } else if (code === 'SCONTO20') {
    discount.value = 20;
    promoMessage.value = 'Sconto 20% applicato!';
  } else {
    discount.value = 0;
    promoMessage.value = 'Codice sconto non valido.';
    isPromoError.value = true;
  }
};

const checkout = async () => {
  if (!isAuthenticated.value) {
    router.push('/login');
    return;
  }

  if (cartItems.value.length === 0) {
    checkoutError.value = 'Il carrello è vuoto.';
    return;
  }

  isProcessingCheckout.value = true; // Ensure the variable is used correctly
  checkoutError.value = null; // Reset error before processing

  const itemsToCheckout = cartItems.value.map((item) => ({
    id: item.id,
    priceId: item.metadata?.stripe_price_id, // Assicurati che sia presente!
    quantity: item.quantity,
  }));

  try {
    const {
      data: { session },
    } = await supabase.auth.getSession();

    const response = await fetch(
      `${BACKEND_API_URL}/api/create-checkout-session`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          items: itemsToCheckout,
          customerEmail: session?.user?.email,
        }),
      }
    );

    const stripeSessionData = await response.json();

    if (!response.ok) {
      throw new Error(
        stripeSessionData.error || `Errore dal server: ${response.statusText}`
      );
    }

    if (stripeSessionData.url) {
      window.location.href = stripeSessionData.url; // Reindirizza alla pagina di pagamento Stripe
    } else {
      checkoutError.value = 'Impossibile avviare il pagamento. Riprova.';
    }
  } catch (err: any) {
    checkoutError.value =
      err.message ||
      'Si è verificato un errore durante il checkout. Riprova più tardi.';
  } finally {
    isProcessingCheckout.value = false; // Ensure the variable is reset
  }
};
</script>

<style scoped>
.page-wrapper {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background: linear-gradient(to bottom right, #ffffff, #f8f7ff);
}

.cart-container {
  flex: 1;
  max-width: 1200px;
  margin: 40px auto;
  padding: 20px;
}

/* Cart Header Styling */
.cart-title {
  font-size: 2.5rem;
  font-weight: 700;
  color: #2d2d2d;
  margin-bottom: 40px;
  text-align: center;
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
}

/* Cart Items Styling */
.cart-table-header {
  display: grid;
  grid-template-columns: 3fr 1fr 1fr 50px;
  padding: 20px;
  background: white;
  border-radius: 12px;
  margin-bottom: 20px;
  font-weight: 600;
  color: #6a5acd;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
}

.cart-item-row {
  display: grid;
  grid-template-columns: 3fr 1fr 1fr 50px;
  align-items: center;
  background: white;
  padding: 20px;
  border-radius: 12px;
  margin-bottom: 15px;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
}

.cart-item-row:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 25px rgba(106, 90, 205, 0.12);
}

.item-product {
  display: flex;
  align-items: center;
  gap: 20px;
}

.item-image {
  width: 80px;
  height: 100px;
  object-fit: cover;
  border-radius: 8px;
  box-shadow: 0 4px 10px rgba(106, 90, 205, 0.1);
}

.item-name-link {
  text-decoration: none;
  color: #2d2d2d;
  font-weight: 600;
  transition: color 0.3s ease;
}

.item-name-link:hover {
  color: #6a5acd;
}

/* Summary Section Styling */
.cart-details-bottom {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 30px;
  margin-top: 40px;
}

.promo-code-section {
  background: white;
  padding: 30px;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
}

.promo-input {
  width: 100%;
  padding: 15px;
  border: 2px solid rgba(106, 90, 205, 0.2);
  border-radius: 12px;
  margin-bottom: 15px;
  transition: border-color 0.3s ease;
}

.promo-input:focus {
  outline: none;
  border-color: #6a5acd;
}

.apply-promo-button {
  width: 100%;
  padding: 15px;
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  color: white;
  border: none;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.apply-promo-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(106, 90, 205, 0.3);
}

.cart-summary-section {
  background: white;
  padding: 30px;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
}

.summary-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: #2d2d2d;
  margin-bottom: 25px;
}

.summary-details p {
  display: flex;
  justify-content: space-between;
  margin-bottom: 15px;
  color: #666;
}

.summary-total {
  font-size: 1.2rem;
  color: #6a5acd;
  font-weight: 700;
}

.checkout-button {
  width: 100%;
  padding: 15px;
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  color: white;
  border: none;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  margin-top: 20px;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.checkout-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(106, 90, 205, 0.3);
}

/* Empty Cart Styling */
.empty-cart {
  text-align: center;
  padding: 60px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
}

.empty-cart p {
  font-size: 1.2rem;
  color: #666;
  margin-bottom: 30px;
}

.continue-shopping-btn {
  display: inline-block;
  padding: 15px 30px;
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  color: white;
  text-decoration: none;
  border-radius: 12px;
  font-weight: 600;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.continue-shopping-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(106, 90, 205, 0.3);
}

/* Loading and Error States */
.loading-container,
.error-container,
.not-logged-in {
  text-align: center;
  padding: 60px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(106, 90, 205, 0.08);
}

.retry-button,
.login-button {
  display: inline-block;
  padding: 15px 30px;
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  color: white;
  text-decoration: none;
  border-radius: 12px;
  font-weight: 600;
  border: none;
  cursor: pointer;
  margin: 10px;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.retry-button:hover,
.login-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(106, 90, 205, 0.3);
}

@media (max-width: 768px) {
  .cart-details-bottom {
    grid-template-columns: 1fr;
  }

  .cart-table-header {
    display: none;
  }

  .cart-item-row {
    grid-template-columns: 1fr;
    gap: 15px;
  }

  .item-product {
    flex-direction: column;
    text-align: center;
  }

  .item-image {
    width: 120px;
    height: 150px;
  }
}

/* Add these new styles and modifications to your existing CSS */
.page-wrapper {
  background: linear-gradient(135deg, #ffffff, #f8f7ff, #f0f0ff);
}

/* Enhanced Cart Header */
.cart-container::before {
  content: 'Il Tuo Carrello';
  display: block;
  font-size: 2.8rem;
  font-weight: 800;
  text-align: center;
  margin-bottom: 40px;
  background: linear-gradient(45deg, #6a5acd, #9370db, #5a4cba);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  letter-spacing: -0.5px;
  animation: fadeIn 0.8s ease-out;
}

/* Animated Items */
.cart-item-row {
  position: relative;
  overflow: hidden;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(106, 90, 205, 0.1);
  animation: slideIn 0.5s ease-out;
}

.cart-item-row::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #6a5acd, #9370db);
  transform: scaleX(0);
  transition: transform 0.3s ease;
  border-radius: 4px 4px 0 0;
}

.cart-item-row:hover::before {
  transform: scaleX(1);
}

/* Enhanced Item Image */
.item-image {
  transition: transform 0.5s ease, box-shadow 0.3s ease;
  border: 4px solid white;
}

.item-image:hover {
  transform: scale(1.05) rotate(-2deg);
  box-shadow: 0 8px 25px rgba(106, 90, 205, 0.2);
}

/* Remove Button Enhancement */
.item-remove button {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border: none;
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  color: white;
  font-size: 1.2rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.item-remove button:hover {
  transform: rotate(90deg) scale(1.1);
  background: linear-gradient(45deg, #ff6b6b, #ff4757);
}

/* Summary Section Enhancements */
.cart-summary-section {
  position: relative;
  overflow: hidden;
}

.cart-summary-section::after {
  content: '';
  position: absolute;
  bottom: 0;
  right: 0;
  width: 100px;
  height: 100px;
  background: linear-gradient(135deg, transparent 50%, rgba(106, 90, 205, 0.1));
  border-radius: 0 0 16px 0;
}

.summary-details {
  position: relative;
}

.summary-divider {
  border: none;
  height: 2px;
  background: linear-gradient(
    90deg,
    transparent,
    rgba(106, 90, 205, 0.2),
    transparent
  );
  margin: 20px 0;
}

/* Price Animations */
.item-price,
.item-subtotal {
  position: relative;
  font-weight: 600;
  color: #6a5acd;
  transition: color 0.3s ease;
}

/* Promo Code Section Enhancement */
.promo-code-section {
  position: relative;
  overflow: hidden;
}

.promo-message {
  padding: 10px;
  margin-top: 15px;
  border-radius: 8px;
  animation: slideUp 0.3s ease-out;
}

.promo-message.success {
  background: rgba(72, 187, 120, 0.1);
  color: #38a169;
  border: 1px solid rgba(72, 187, 120, 0.2);
}

.promo-message.error {
  background: rgba(245, 101, 101, 0.1);
  color: #e53e3e;
  border: 1px solid rgba(245, 101, 101, 0.2);
}

/* Empty Cart Enhancement */
.empty-cart {
  text-align: center;
  padding: 80px 40px;
  position: relative;
  overflow: hidden;
}

.empty-cart::before {
  content: '📚';
  font-size: 4rem;
  display: block;
  margin-bottom: 20px;
  animation: float 3s ease-in-out infinite;
}

/* Loading Animation Enhancement */
.loading-container {
  position: relative;
  overflow: hidden;
}

.loading-container::after {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 200%;
  height: 100%;
  background: linear-gradient(
    90deg,
    transparent,
    rgba(106, 90, 205, 0.1),
    transparent
  );
  animation: loading 1.5s infinite;
}

/* Animations */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateX(-20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes float {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

@keyframes loading {
  from {
    transform: translateX(0);
  }
  to {
    transform: translateX(50%);
  }
}

/* Quantity Controls Enhancement */
.quantity-controls {
  display: flex;
  align-items: center;
  gap: 10px;
  background: white;
  padding: 5px;
  border-radius: 20px;
  border: 2px solid rgba(106, 90, 205, 0.1);
}

.quantity-btn {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  border: none;
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  color: white;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.quantity-btn:hover {
  transform: scale(1.1);
  box-shadow: 0 2px 10px rgba(106, 90, 205, 0.2);
}

.quantity-value {
  font-weight: 600;
  color: #6a5acd;
  min-width: 30px;
  text-align: center;
}

.cart-title {
  background: linear-gradient(45deg, #7c4dff, #6200ea);
}

.cart-item-price {
  color: #7c4dff;
}

.remove-btn {
  background: linear-gradient(45deg, #7c4dff, #6200ea);
}

.remove-btn:hover {
  background: linear-gradient(45deg, #6200ea, #5502c7);
  box-shadow: 0 4px 15px rgba(124, 77, 255, 0.3);
}

.checkout-btn {
  background: linear-gradient(45deg, #7c4dff, #6200ea);
}

.checkout-btn:hover {
  background: linear-gradient(45deg, #6200ea, #5502c7);
  box-shadow: 0 4px 15px rgba(124, 77, 255, 0.3);
}

.continue-shopping-btn {
  background: linear-gradient(45deg, #7c4dff, #6200ea);
}

.continue-shopping-btn:hover {
  background: linear-gradient(45deg, #6200ea, #5502c7);
  box-shadow: 0 4px 15px rgba(124, 77, 255, 0.3);
}
</style>

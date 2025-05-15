<template>
  <div class="payment-success">
    <h1>Pagamento avvenuto con successo</h1>
    <p>
      Grazie per il tuo acquisto! Riceverai una email di conferma a breve.<br />
      Se hai domande o necessiti di assistenza, contatta il nostro supporto
      clienti.
    </p>
    <button
      @click="goToShop"
      class="continue-shopping-btn">
      Torna allo shop
    </button>
  </div>
</template>

<script setup>
import { useRouter, useRoute } from "vue-router";
import { onMounted } from "vue";
import { createClient } from "@supabase/supabase-js";

const router = useRouter();
const route = useRoute();

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

onMounted(async () => {
  // Prendi gli id dei prodotti acquistati dalla query
  const productIds = (route.query.productIds || "").split(",").filter(Boolean);
  if (!productIds.length) return;

  // Recupera gli stripe_product_id dal database
  const { data: products, error } = await supabase
    .from("products")
    .select("stripe_product_id, id")
    .in("id", productIds);

  if (error) {
    console.error("Errore nel recupero degli Stripe ID:", error);
    return;
  }

  const stripeProductIds = (products || [])
    .map((p) => p.stripe_product_id)
    .filter(Boolean);

  if (stripeProductIds.length > 0) {
    await fetch("http://localhost:3000/api/delete-stripe-products", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ productIds: stripeProductIds }),
    });
  }

  // Elimina i prodotti anche da Supabase
  const { error: deleteError } = await supabase
    .from("products")
    .delete()
    .in("id", productIds);

  if (deleteError) {
    console.error("Errore eliminazione prodotti da Supabase:", deleteError);
  }

  // Rimuovi questi prodotti dal carrello
  const cart = JSON.parse(localStorage.getItem("cart") || "[]");
  const updatedCart = cart.filter((id) => !productIds.includes(id));
  localStorage.setItem("cart", JSON.stringify(updatedCart));
});

function goToShop() {
  router.push("/shop");
}
</script>

<style scoped>
.payment-success {
  text-align: center;
  margin-top: 50px;
}

.payment-success h1 {
  color: #28a745;
  font-size: 24px;
}

.payment-success p {
  margin: 20px 0;
  font-size: 18px;
  color: #333;
}

/* Bottone uguale a Cart.vue */
.continue-shopping-btn {
  display: inline-block;
  padding: 15px 30px;
  background: linear-gradient(45deg, #6a5acd, #5a4cba);
  color: white;
  text-decoration: none;
  border-radius: 12px;
  font-weight: 600;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  border: none;
  font-size: 16px;
  cursor: pointer;
  margin-top: 20px;
}

.continue-shopping-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(106, 90, 205, 0.3);
}
</style>

<template>
  <div class="payment-cancel">
    <h1>Pagamento annullato</h1>
    <p>Il tuo pagamento è stato annullato. Se hai bisogno di assistenza, contatta il nostro supporto clienti.</p>
    <button @click="goToShop" class="continue-shopping-btn">Torna allo shop</button>
  </div>
</template>

<script>
export default {
  name: "PaymentCancel",
  methods: {
    goToShop() {
      this.$router.push("/shop");
    },
  },
};
</script>

<style scoped>
.payment-cancel {
  text-align: center;
  margin-top: 50px;
}

.payment-cancel h1 {
  color: #ff0000;
  font-size: 24px;
}

.payment-cancel p {
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
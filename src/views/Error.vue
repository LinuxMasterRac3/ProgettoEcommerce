<template>
  <div class="page-container">
    <Navbar />
    <div class="content">
      <div class="error-container">
        <h1>Errore</h1>
        <p>La pagina che stai cercando non esiste.</p>
        <router-link to="/">Torna alla Home</router-link>
      </div>
    </div>
    <Footer />
  </div>
</template>

<script setup>
import Navbar from "../components/Navbar.vue";
import Footer from "../components/footer.vue"; // Importa il Footer
</script>

<style lang="scss" scoped>
.page-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh; /* Assicura che l'altezza copra l'intera finestra */
}

.content {
  flex: 1; /* Spinge il footer in fondo */
}

.error-container {
  text-align: center;
  margin-top: 50px;
}

h1 {
  font-size: 36px;
  color: #333;
}

p {
  font-size: 18px;
  color: #666;
}

a {
  color: #6a5acd;
  text-decoration: none;
  font-weight: bold;
}
</style>

<script setup lang="ts">
import { RouterLink, RouterView } from "vue-router";
// filepath: /Users/effe/Downloads/ProgettoEcommerce-main/src/main.js
import "./assets/main.css";
</script>

<template>
  <RouterView />
</template>

<style>
@import "./assets/main.css";

body {
  margin: 0;
  padding: 0;
}

/* Aggiungi stili globali per gestire il layout con navbar fissa */
main {
  padding-top: 70px; /* Altezza della navbar + padding extra */
  min-height: calc(100vh - 70px);
}

.app-container {
  width: 100%;
}

.content-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}
</style>

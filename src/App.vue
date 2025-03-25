<script setup lang="ts">
import { RouterLink, RouterView } from "vue-router";
import HelloWorld from "./components/HelloWorld.vue";
</script>

<template>
  <header>
    <nav></nav>
  </header>

  <RouterView />
</template>

<style scoped>
nav {
  padding: 1rem;
  display: flex;
  gap: 1rem;
}
</style>

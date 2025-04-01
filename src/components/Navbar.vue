<!-- filepath: /Users/effe/Downloads/ProgettoEcommerce-main/src/components/Navbar.vue -->
<template>
  <header>
    <h1>PiegaLibro</h1>
    <nav>
      <button class="add-book">Aggiungi Libro +</button>
      <span class="icon">❤️</span>
      <span class="icon">🛒</span>
      <span class="icon">👤</span>
    </nav>
  </header>
</template>

<script setup></script>

<style scoped>
header {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  background: white;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

header h1 {
  color: black;
  margin: 0;
  font-size: 24px;
}

nav {
  display: flex;
  align-items: center;
  gap: 15px;
}

.add-book {
  background: #d6c3f5;
  border: none;
  padding: 10px 15px;
  border-radius: 20px;
  cursor: pointer;
  font-weight: bold;
}

.icon {
  font-size: 18px;
  cursor: pointer;
}
</style>

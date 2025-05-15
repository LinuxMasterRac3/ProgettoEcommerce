<template>
  <header>
    <RouterLink
      to="/shop"
      class="logo">
      <h1>PiegaLibro</h1>
    </RouterLink>
    <nav>
      <RouterLink
        to="/addbook"
        class="add-book"
        >Aggiungi Libro +</RouterLink
      >
      <RouterLink
        to="/contact"
        class="icon"
        >💬</RouterLink
      >
      <RouterLink
        to="/wishlist"
        class="icon"
        >❤️</RouterLink
      >
      <RouterLink
        to="/cart"
        class="icon"
        >🛒</RouterLink
      >
      <RouterLink
        to="/account"
        class="icon"
        >👤</RouterLink
      >
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

.logo {
  text-decoration: none;
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
  text-decoration: none;
  display: inline-block;
}

.icon {
  font-size: 18px;
  cursor: pointer;
  text-decoration: none;
}
</style>

<template>
  <header class="navbar-container">
    <div class="navbar-content">
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
          to="/favorites"
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
    </div>
  </header>
</template>

<script setup></script>

<style scoped>
.navbar-container {
  width: 100%;
  background: white;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
}

.navbar-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
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

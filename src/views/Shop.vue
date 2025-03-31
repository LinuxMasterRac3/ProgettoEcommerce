<script setup lang="ts">
import { ref } from "vue";
import { RouterLink } from "vue-router";

// Data for the page
const searchData = ref({
  query: "",
  category: "",
  location: "",
});

// You can add methods here directly
const searchProducts = () => {
  // Search functionality implementation
  console.log("Searching with:", searchData.value);
};

// For Font Awesome you have two options:
// 1. Add Font Awesome CDN to index.html:
//    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
// 2. Install and import the packages:
//    npm install @fortawesome/fontawesome-svg-core @fortawesome/free-solid-svg-icons @fortawesome/free-regular-svg-icons @fortawesome/vue-fontawesome
</script>

<template>
  <div class="app-container">
    <!-- Header/Navigation Bar -->
    <header class="header">
      <div class="logo">
        <RouterLink to="/">
          <h2>PiegaLibro</h2>
        </RouterLink>
      </div>
      <nav class="nav-buttons">
        <RouterLink
          to="/cart"
          class="nav-item cart-button"
          title="Carrello">
          <i class="fas fa-shopping-cart"></i>
          <span class="nav-text">Carrello</span>
        </RouterLink>

        <RouterLink
          to="/wishlist"
          class="nav-item favorites-button"
          title="Preferiti">
          <i class="far fa-heart"></i>
          <span class="nav-text">Preferiti</span>
        </RouterLink>

        <button class="add-book-button">
          <i class="fas fa-plus"></i>
          <span>Aggiungi Libro</span>
        </button>

        <RouterLink
          to="/account"
          class="nav-item profile-icon"
          title="Account">
          <i class="fas fa-user-circle"></i>
          <span class="nav-text">Account</span>
        </RouterLink>
      </nav>
    </header>

    <!-- Hero Banner / Slider -->
    <div class="hero-banner">
      <div class="slider-content">
        <h2 class="slider-title">Sara uno slider</h2>
        <p class="slider-description">Inserire immagine trend del sito</p>
      </div>
    </div>

    <!-- Search Section -->
    <div class="search-section">
      <div class="search-container">
        <div class="search-field">
          <label>Cosa cerchi ?</label>
          <input
            v-model="searchData.query"
            type="text"
            placeholder="Nome libro" />
        </div>
        <div class="search-field">
          <label>Categoria</label>
          <input
            v-model="searchData.category"
            type="text"
            placeholder="Categoria" />
        </div>
        <div class="search-field">
          <label>Dove ?</label>
          <input
            v-model="searchData.location"
            type="text"
            placeholder="Località" />
        </div>
        <button
          class="search-button"
          @click="searchProducts">
          <i class="fas fa-search"></i>
        </button>
      </div>
    </div>

    <!-- Product Recommendations Section -->
    <section class="product-section">
      <div class="section-header">
        <div class="category-indicator">
          <span class="category-icon"></span>
          <span>Categories</span>
        </div>
        <h2 class="section-title">Potrebbe Piacerti</h2>
      </div>

      <div class="product-grid">
        <!-- Product Card 1 -->
        <div class="product-card">
          <div class="product-image">
            <div class="discount-tag">-35%</div>
            <button class="favorite-button">
              <i class="far fa-heart"></i>
            </button>
            <button class="view-button">
              <i class="far fa-eye"></i>
            </button>
          </div>
          <div class="product-details">
            <h3 class="product-title">HAVIT HV-G92 Gamepad</h3>
            <div class="product-price">
              <span class="current-price">$120</span>
              <span class="original-price">$160</span>
            </div>
            <div class="rating">
              <span class="stars">★★★★★</span>
              <span class="review-count">(88)</span>
            </div>
          </div>
        </div>

        <!-- Product Card 2 -->
        <div class="product-card">
          <div class="product-image">
            <div class="discount-tag">-35%</div>
            <button class="favorite-button">
              <i class="far fa-heart"></i>
            </button>
            <button class="view-button">
              <i class="far fa-eye"></i>
            </button>
            <div class="add-to-cart-overlay">
              <button class="add-to-cart-button">Add To Cart</button>
            </div>
          </div>
          <div class="product-details">
            <h3 class="product-title">AK-900 Wired Keyboard</h3>
            <div class="product-price">
              <span class="current-price">$960</span>
              <span class="original-price">$1160</span>
            </div>
            <div class="rating">
              <span class="stars">★★★★★</span>
              <span class="review-count">(75)</span>
            </div>
          </div>
        </div>

        <!-- Product Card 3 -->
        <div class="product-card">
          <div class="product-image">
            <div class="discount-tag">-35%</div>
            <button class="favorite-button">
              <i class="far fa-heart"></i>
            </button>
            <button class="view-button">
              <i class="far fa-eye"></i>
            </button>
          </div>
          <div class="product-details">
            <h3 class="product-title">IPS LCD Gaming Monitor</h3>
            <div class="product-price">
              <span class="current-price">$370</span>
              <span class="original-price">$400</span>
            </div>
            <div class="rating">
              <span class="stars">★★★★★</span>
              <span class="review-count">(99)</span>
            </div>
          </div>
        </div>

        <!-- Product Card 4 -->
        <div class="product-card">
          <div class="product-image">
            <div class="discount-tag">-35%</div>
            <button class="favorite-button">
              <i class="far fa-heart"></i>
            </button>
            <button class="view-button">
              <i class="far fa-eye"></i>
            </button>
          </div>
          <div class="product-details">
            <h3 class="product-title">S-Series Comfort Chair</h3>
            <div class="product-price">
              <span class="current-price">$375</span>
              <span class="original-price">$400</span>
            </div>
            <div class="rating">
              <span class="stars">★★★★★</span>
              <span class="review-count">(99)</span>
            </div>
          </div>
        </div>

        <!-- Product Card 5 -->
        <div class="product-card">
          <div class="product-image">
            <div class="discount-tag">-35%</div>
          </div>
          <div class="product-details">
            <h3 class="product-title">S-Series Comfort Chair</h3>
            <div class="product-price">
              <span class="current-price">$375</span>
              <span class="original-price">$400</span>
            </div>
            <div class="rating">
              <span class="stars">★★★★★</span>
              <span class="review-count">(99)</span>
            </div>
          </div>
        </div>
      </div>

      <div class="view-all-container">
        <button class="view-all-button">View All Products</button>
      </div>
    </section>

    <!-- Book Categories Section -->
    <section class="categories-section">
      <div class="section-header">
        <div class="category-indicator">
          <span class="category-icon"></span>
          <span>Categories</span>
        </div>
        <h2 class="section-title">Scegli per tipo di Libro</h2>
        <div class="navigation-arrows">
          <button class="arrow-left">
            <i class="fas fa-arrow-left"></i>
          </button>
          <button class="arrow-right">
            <i class="fas fa-arrow-right"></i>
          </button>
        </div>
      </div>

      <div class="category-grid">
        <div class="category-card">
          <div class="category-icon">
            <i class="fas fa-book"></i>
          </div>
          <span class="category-name">Fantasy</span>
        </div>
        <div class="category-card">
          <div class="category-icon">
            <i class="fas fa-desktop"></i>
          </div>
          <span class="category-name">Saggi</span>
        </div>
        <div class="category-card">
          <div class="category-icon">
            <i class="fas fa-clock"></i>
          </div>
          <span class="category-name">Biografie</span>
        </div>
        <div class="category-card active">
          <div class="category-icon">
            <i class="fas fa-camera"></i>
          </div>
          <span class="category-name">Gialli</span>
        </div>
        <div class="category-card">
          <div class="category-icon">
            <i class="fas fa-headphones"></i>
          </div>
          <span class="category-name">Horror</span>
        </div>
        <div class="category-card">
          <div class="category-icon">
            <i class="fas fa-gamepad"></i>
          </div>
          <span class="category-name">rosa</span>
        </div>
      </div>
    </section>

    <!-- Publishers Section -->
    <section class="publishers-section">
      <div class="section-header">
        <div class="category-indicator">
          <span class="category-icon"></span>
          <span>Categories</span>
        </div>
        <h2 class="section-title">Per Casa Editrice</h2>
        <div class="navigation-arrows">
          <button class="arrow-left">
            <i class="fas fa-arrow-left"></i>
          </button>
          <button class="arrow-right">
            <i class="fas fa-arrow-right"></i>
          </button>
        </div>
      </div>

      <div class="publisher-grid">
        <div class="publisher-card">
          <div class="publisher-icon">
            <i class="fas fa-book"></i>
          </div>
          <span class="publisher-name">Feltrinelli</span>
        </div>
        <div class="publisher-card">
          <div class="publisher-icon">
            <i class="fas fa-desktop"></i>
          </div>
          <span class="publisher-name">Ipperboria</span>
        </div>
        <div class="publisher-card">
          <div class="publisher-icon">
            <i class="fas fa-clock"></i>
          </div>
          <span class="publisher-name">Mondadori</span>
        </div>
        <div class="publisher-card active">
          <div class="publisher-icon">
            <i class="fas fa-camera"></i>
          </div>
          <span class="publisher-name">Giunti</span>
        </div>
        <div class="publisher-card">
          <div class="publisher-icon">
            <i class="fas fa-headphones"></i>
          </div>
          <span class="publisher-name">StarComics</span>
        </div>
        <div class="publisher-card">
          <div class="publisher-icon">
            <i class="fas fa-gamepad"></i>
          </div>
          <span class="publisher-name">Panini</span>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
/* Base Styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: "Inter", sans-serif;
}

.app-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

/* Header Styles */
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 0;
  border-bottom: 1px solid #eaeaea;
}

.logo a {
  text-decoration: none;
}

.logo h2 {
  font-weight: 600;
  color: #333;
  transition: color 0.3s;
}

.logo h2:hover {
  color: #6a5acd;
}

nav.nav-buttons {
  display: flex;
  align-items: center;
  gap: 20px;
}

.nav-item {
  display: flex;
  align-items: center;
  text-decoration: none;
  color: #333;
  gap: 5px;
  padding: 5px;
  border-radius: 5px;
  transition: background-color 0.3s, color 0.3s;
}

.nav-item:hover {
  background-color: rgba(106, 90, 205, 0.1);
  color: #6a5acd;
}

.nav-text {
  font-size: 0.85rem;
  display: none;
}

.cart-button i,
.favorites-button i,
.profile-icon i {
  font-size: 20px;
  vertical-align: middle;
}

.add-book-button {
  display: flex;
  align-items: center;
  gap: 5px;
  background-color: #6a5acd;
  color: white;
  padding: 8px 15px;
  border: none;
  border-radius: 20px;
  cursor: pointer;
  font-weight: 500;
  transition: background-color 0.3s;
}

.add-book-button:hover {
  background-color: #5a4cba;
}

@media (min-width: 768px) {
  .nav-text {
    display: inline;
  }
}

/* Hero Banner Styles */
.hero-banner {
  background-color: #eef1ff;
  height: 180px;
  border-radius: 10px;
  display: flex;
  justify-content: center;
  align-items: center;
  text-align: center;
  margin-bottom: 30px;
}

.slider-content {
  color: #a5b0d6;
}

.slider-title {
  font-size: 28px;
  font-weight: 400;
  margin-bottom: 10px;
}

/* Search Section Styles */
.search-section {
  margin-bottom: 40px;
}

.search-container {
  display: flex;
  border: 1px solid #e5e5e5;
  border-radius: 8px;
  padding: 20px;
}

.search-field {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 0 15px;
}

.search-field label {
  margin-bottom: 8px;
  font-weight: 500;
}

.search-field input {
  border: none;
  padding: 5px 0;
  font-size: 14px;
  border-bottom: 1px solid #e5e5e5;
}

.search-button {
  background-color: #7b68ee;
  color: white;
  border: none;
  border-radius: 8px;
  width: 40px;
  height: 40px;
  align-self: flex-end;
  cursor: pointer;
}

/* Section Header Styles */
.section-header {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
  position: relative;
}

.category-indicator {
  display: flex;
  align-items: center;
  margin-right: 15px;
}

.category-icon {
  display: inline-block;
  width: 20px;
  height: 20px;
  background-color: #333;
  margin-right: 8px;
}

.section-title {
  font-size: 22px;
  font-weight: 600;
}

.navigation-arrows {
  position: absolute;
  right: 0;
  display: flex;
  gap: 10px;
}

.arrow-left,
.arrow-right {
  background: none;
  border: 1px solid #e5e5e5;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Product Grid Styles */
.product-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 20px;
  margin-bottom: 30px;
}

.product-card {
  border-radius: 8px;
  overflow: hidden;
}

.product-image {
  height: 160px;
  background-color: #f5f5f5;
  position: relative;
}

.discount-tag {
  position: absolute;
  top: 10px;
  left: 10px;
  background-color: #db4444;
  color: white;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
}

.favorite-button,
.view-button {
  position: absolute;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background-color: white;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}

.favorite-button {
  top: 10px;
  right: 10px;
}

.view-button {
  bottom: 10px;
  right: 10px;
}

.add-to-cart-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background-color: black;
  padding: 10px;
  text-align: center;
}

.add-to-cart-button {
  background: none;
  border: none;
  color: white;
  font-weight: 500;
  cursor: pointer;
}

.product-details {
  padding: 10px 0;
}

.product-title {
  font-size: 14px;
  font-weight: 500;
  margin-bottom: 5px;
}

.product-price {
  margin-bottom: 5px;
}

.current-price {
  font-weight: 500;
  color: #db4444;
  margin-right: 5px;
}

.original-price {
  text-decoration: line-through;
  color: #999;
  font-size: 14px;
}

.rating {
  font-size: 14px;
}

.stars {
  color: #ffad33;
}

.review-count {
  color: #777;
  margin-left: 5px;
}

.view-all-container {
  text-align: center;
  margin-bottom: 40px;
}

.view-all-button {
  background-color: #db4444;
  color: white;
  border: none;
  padding: 12px 30px;
  border-radius: 4px;
  font-weight: 500;
  cursor: pointer;
}

/* Category/Publisher Grid Styles */
.category-grid,
.publisher-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 20px;
  margin-bottom: 40px;
}

.category-card,
.publisher-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border: 1px solid #e5e5e5;
  border-radius: 4px;
  padding: 25px 0;
  cursor: pointer;
}

.category-card.active,
.publisher-card.active {
  background-color: #2b3238;
  color: white;
}

.category-icon,
.publisher-icon {
  font-size: 24px;
  margin-bottom: 15px;
}

.category-name,
.publisher-name {
  font-size: 14px;
}

/* Responsive Styles */
@media (max-width: 1024px) {
  .product-grid {
    grid-template-columns: repeat(4, 1fr);
  }

  .category-grid,
  .publisher-grid {
    grid-template-columns: repeat(4, 1fr);
  }
}

@media (max-width: 768px) {
  .product-grid {
    grid-template-columns: repeat(3, 1fr);
  }

  .category-grid,
  .publisher-grid {
    grid-template-columns: repeat(3, 1fr);
  }

  .search-container {
    flex-direction: column;
    gap: 15px;
  }

  .search-field {
    padding: 0;
  }
}

@media (max-width: 576px) {
  .product-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .category-grid,
  .publisher-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>

<template>
  <footer>
    <div class="footer-content">
      <div class="about">
        <h2>PiegaLibro</h2>
        <p>
          PiegaLibro è la tua libreria digitale di fiducia. Scopri, organizza e
          condividi i tuoi libri preferiti.
        </p>
      </div>
      <div class="links">
        <h3>Link Utili</h3>
        <ul>
          <li><a href="#about">Chi Siamo</a></li>
          <li><a href="#contact">Contattaci</a></li>
          <li><a href="#privacy">Privacy Policy</a></li>
        </ul>
      </div>
      <div class="social">
        <h3>Seguici</h3>
        <div class="icons">
          <a href="#"><span>🌐</span></a>
          <a href="#"><span>📘</span></a>
          <a href="#"><span>🐦</span></a>
        </div>
      </div>
    </div>
    <div class="footer-bottom">
      <p>&copy; 2025 PiegaLibro. Tutti i diritti riservati.</p>
    </div>
  </footer>
</template>

<script setup></script>

<style scoped>
header {
  width: 100%;
  display: flex;
  justify-content: space-between;
  align-items: bottom;
  padding: 20px;
  background: rgb(0, 0, 0);
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

header h1 {
  color: black;
  margin: 0;
  font-size: 24px;
}

footer {
  width: 100%;
  background: #222;
  color: #fff;
  padding: 20px 0;
  box-shadow: 0 -2px 5px rgba(0, 0, 0, 0.1);
  margin-top: 40px; /* Aggiunto margine superiore per staccare il footer */
}

.footer-content {
  display: flex;
  justify-content: space-between;
  padding: 0 20px;
}

.about,
.links,
.social {
  flex: 1;
  margin: 0 10px;
}

.about h2 {
  font-size: 20px;
  margin-bottom: 10px;
}

.about p {
  font-size: 14px;
  line-height: 1.5;
}

.links h3,
.social h3 {
  font-size: 16px;
  margin-bottom: 10px;
}

.links ul {
  list-style: none;
  padding: 0;
}

.links ul li {
  margin-bottom: 5px;
}

.links ul li a {
  color: #fff;
  text-decoration: none;
  font-size: 14px;
}

.links ul li a:hover {
  text-decoration: underline;
}

.social .icons a {
  margin-right: 10px;
  font-size: 20px;
  color: #fff;
  text-decoration: none;
}

.social .icons a:hover {
  color: #ff5722;
}

.footer-bottom {
  text-align: center;
  margin-top: 20px;
  font-size: 14px;
  color: #aaa;
}
</style>

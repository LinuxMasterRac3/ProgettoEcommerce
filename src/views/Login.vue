<template>
  <div class="login-page">
    <Navbar />
    <main>
      <div class="container">
        <div class="image-section">
          <img
            src="../assets/pexels-mikhail-nilov-9158370.jpg"
            alt="Persona con libri" />
        </div>

        <div class="form-section">
          <h2>Accedi all'Account</h2>
          <p>Inserisci i tuoi dati</p>

          <!-- Mostra messaggi di errore -->
          <div
            v-if="errorMessage"
            class="error-message">
            {{ errorMessage }}
          </div>

          <form @submit.prevent="submitForm">
            <input
              v-model="email"
              type="text"
              placeholder="Email o Numero di Telefono"
              required />
            <input
              v-model="password"
              type="password"
              placeholder="Password"
              required />
            <button
              type="submit"
              class="create-account">
              Accedi
            </button>
          </form>

          <button
            @click="signInWithGoogle"
            class="google-signup">
            <img
              src="../assets/Google.png"
              alt="Accedi con Google" />
            Accedi con Google
          </button>

          <a
            href="#"
            class="forgot-password-link"
            >Password dimenticata?</a
          >
          <p class="account-info">
            Non hai un account?
            <router-link to="/register">Registrati</router-link>
          </p>
        </div>
      </div>
    </main>
    <Footer />
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { createClient } from "@supabase/supabase-js";
import Navbar from "../components/Navbar.vue";
import Footer from "../components/footer.vue";
// Supabase configuration
const supabaseUrl = "https://tiylfyyfitqzwstftzpg.supabase.co";
const supabaseKey =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpeWxmeXlmaXRxendzdGZ0enBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNjYyNDcsImV4cCI6MjA1Njc0MjI0N30.CvIx_vI-KGGcFlcZy66-DIC8Itk03Olw3lzEMhnJP_c";
const supabase = createClient(supabaseUrl, supabaseKey);

// Router setup
const router = useRouter();

// Form state
const email = ref("");
const password = ref("");
const isLogin = ref(true);
const errorMessage = ref("");

// Check if user is already logged in
onMounted(async () => {
  const { data } = await supabase.auth.getSession();
  if (data.session) {
    router.push("/shop");
  }
});

// Handle form submission
const submitForm = async () => {
  try {
    errorMessage.value = "";

    if (isLogin.value) {
      // Handle login
      const { data, error } = await supabase.auth.signInWithPassword({
        email: email.value,
        password: password.value,
      });

      if (error) throw error;

      // Successful login
      router.push("/shop");
    } else {
      // Handle registration
      const { data, error } = await supabase.auth.signUp({
        email: email.value,
        password: password.value,
      });

      if (error) throw error;

      if (
        data.user &&
        data.user.identities &&
        data.user.identities.length === 0
      ) {
        errorMessage.value = "This email is already registered. Please login.";
        isLogin.value = true;
        return;
      }

      // If email confirmation is required
      if (data.user && !data.session) {
        errorMessage.value = "Please check your email for confirmation link.";
        return;
      }

      // If auto-confirmed
      router.push("/shop");
    }
  } catch (error) {
    errorMessage.value =
      error.message || "An error occurred during authentication.";
    console.error("Authentication error:", error);
  }
};

// Handle Google Sign-In
const signInWithGoogle = async () => {
  try {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: "google",
      options: {
        redirectTo: window.location.origin + "/shop",
      },
    });

    if (error) throw error;
  } catch (error) {
    errorMessage.value = error.message || "Errore durante l'accesso con Google";
    console.error("Google authentication error:", error);
  }
};
</script>

<style scoped>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: Arial, sans-serif;
}

body {
  background-color: white; /* Sfondo bianco */
  display: flex;
  flex-direction: column;
  align-items: center;
}

.container {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 50px;
  width: 90%; /* Riduce la larghezza per centrare meglio il contenuto */
}

.image-section {
  display: flex;
  justify-content: flex-end; /* Sposta l'immagine verso destra */
  align-items: center;
  margin-right: 40px; /* Aggiunge spazio tra l'immagine e il form */
}

.image-section img {
  width: 400px; /* Mantiene la dimensione dell'immagine */
  border-radius: 10px;
}

.form-section {
  background: white;
  padding: 40px;
  border-radius: 10px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
  margin-left: 20px;
  width: 800px;
  box-sizing: border-box;
}

h2 {
  font-size: 24px;
  margin-bottom: 10px;
  color: black; /* Cambia il colore del testo in nero */
}

p {
  margin-bottom: 15px;
  color: black; /* Cambia il colore del testo in nero */
}

input {
  width: 100%;
  padding: 10px;
  margin: 10px 0;
  border: 1px solid #ccc;
  border-radius: 5px;
}

.create-account {
  width: 100%;
  padding: 10px;
  background: #c7c3d6;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-size: 16px;
}

.google-signup {
  width: 100%;
  padding: 10px;
  background: white;
  border: 1px solid #ccc;
  border-radius: 5px;
  cursor: pointer;
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 15px;
}

.google-signup img {
  width: 20px;
  height: 20px;
  margin-right: 10px;
}

a {
  color: black; /* Cambia il colore dei link in nero */
  text-decoration: none;
}

.forgot-password-link {
  display: block;
  margin-top: 15px;
  color: gray; /* Colore grigio per il link */
  text-decoration: none;
  font-size: 14px;
}

.account-info {
  margin-top: 20px; /* Sposta la frase leggermente più in basso */
  text-align: center;
  color: gray; /* Cambia il colore della frase in grigio */
}

.account-info a {
  color: black; /* Mantiene "Registrati" nero */
  font-weight: bold;
  text-decoration: none;
}

.error-message {
  background-color: #ffebee;
  color: #d32f2f;
  padding: 10px;
  border-radius: 5px;
  margin-bottom: 15px;
  font-size: 14px;
}
</style>

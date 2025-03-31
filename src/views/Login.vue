<template>
  <meta charset="UTF-8" />
  <meta
    name="viewport"
    content="width=device-width, initial-scale=1.0" />
  <title>Accedi - PiegaLibro</title>
  <link
    rel="stylesheet"
    href="styles.css" />
  <header>
    <h1>PiegaLibro</h1>
    <nav>
      <button class="add-book">Aggiungi Libro +</button>
      <span class="icon">❤️</span>
      <span class="icon">🛒</span>
      <span class="icon">👤</span>
    </nav>
  </header>
  <div class="container">
    <div class="image-section">
      <img
        src="../assets/pexels-mikhail-nilov-9158370.jpg"
        alt="Persona con libri" />
    </div>
    <div class="form-section">
      <h2>Accedi all'Account</h2>
      <p>Inserisci i tuoi dati</p>
      <div
        v-if="errorMessage"
        class="error-message">
        {{ errorMessage }}
      </div>
      <form @submit.prevent="submitForm">
        <input
          type="email"
          v-model="email"
          placeholder="Email o Numero di Telefono"
          required />
        <input
          type="password"
          v-model="password"
          placeholder="Password"
          required />
        <button
          type="submit"
          class="create-account">
          Accedi
        </button>
      </form>

      <button
        class="google-signup"
        @click="signInWithGoogle">
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
      <p>Non hai un account? <a href="/Signup.html">Registrati</a></p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { createClient } from "@supabase/supabase-js";

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
<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: Arial, sans-serif;
}

body {
  background-color: #f9f9f9;
  display: flex;
  flex-direction: column;
  align-items: center;
}

header {
  width: 100%;
  display: flex;
  justify-content: space-between;
  padding: 20px;
  background: white;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
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

.container {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 50px;
  width: 80%;
}

.image-section img {
  width: 400px;
  border-radius: 10px;
}

.form-section {
  background: white;
  padding: 40px;
  border-radius: 10px;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
  margin-left: 20px;
  width: 800px; /* Larghezza Aumentata */
  box-sizing: border-box; /* Importante per includere padding e bordi */
}

h2 {
  font-size: 24px;
  margin-bottom: 10px;
}

p {
  margin-bottom: 15px;
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
  box-sizing: border-box;
}

.google-signup img {
  width: 20px;
  height: 20px;
}

a {
  color: #6a5acd;
  text-decoration: none;
}

.forgot-password-link {
  display: inline-block;
  margin-top: 10px;
  color: #6a5acd;
  text-decoration: none;
  font-size: 0.9em;
}

.forgot-password-link:hover {
  text-decoration: underline;
}

.error-message {
  color: #e74c3c;
  background-color: #fdecea;
  padding: 10px;
  border-radius: 5px;
  margin-bottom: 15px;
  font-size: 14px;
  text-align: center;
}
</style>

<template>
  <div class="registration-page">
    <header>
      <h1>PiegaLibro</h1>
      <nav>
        <button class="add-book">Aggiungi Libro +</button>
        <span class="icon">❤️</span>
        <span class="icon">🛒</span>
        <span class="icon">👤</span>
      </nav>
    </header>

    <main>
      <div class="container">
        <div class="image-section">
          <img
            src="../assets/pexels-george-milton-7034789.jpg"
            alt="Donna con libri" />
        </div>

        <div class="form-section">
          <h2>Crea un account</h2>
          <p>Inserisci i tuoi dati</p>

          <form @submit.prevent="handleSubmit">
            <input
              v-model="formData.name"
              type="text"
              placeholder="Nome"
              required />
            <input
              v-model="formData.email"
              type="email"
              placeholder="Email o Numero di telefono"
              required />
            <input
              v-model="formData.password"
              type="password"
              placeholder="Password"
              required />
            <button
              type="submit"
              class="create-account">
              Crea Account
            </button>
          </form>

          <button class="google-signup">
            <img
              src="../assets/Google.png"
              alt="Sign up con Google" />
            Registrati con Google
          </button>

          <p>
            Hai già un account? <router-link to="/login">Accedi</router-link>
          </p>
        </div>
      </div>
    </main>
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
</script>

<style scoped>
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
  width: 800px;
  box-sizing: border-box;
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
  margin-top: 15px;
}

.google-signup img {
  width: 20px;
  height: 20px;
  margin-right: 10px;
}

a {
  color: #6a5acd;
  text-decoration: none;
}
</style>

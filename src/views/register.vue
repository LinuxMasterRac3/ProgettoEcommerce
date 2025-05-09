<template>
  <div class="page-container">
    <Navbar />
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

          <!-- Mostra messaggi di errore -->
          <div
            v-if="errorMessage"
            class="error-message">
            {{ errorMessage }}
          </div>

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

          <p class="account-info">
            Hai già un account? <router-link to="/login">Accedi</router-link>
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
const formData = ref({
  name: "",
  email: "",
  password: "",
});
const errorMessage = ref("");

// Check if user is already logged in
onMounted(async () => {
  const { data } = await supabase.auth.getSession();
  if (data.session) {
    router.push("/shop");
  }
});

// Handle form submission
const handleSubmit = async () => {
  try {
    errorMessage.value = "";

    // Handle registration
    const { data, error } = await supabase.auth.signUp({
      email: formData.value.email,
      password: formData.value.password,
      options: {
        data: {
          name: formData.value.name,
        },
      },
    });

    if (error) throw error;

    if (
      data.user &&
      data.user.identities &&
      data.user.identities.length === 0
    ) {
      errorMessage.value = "Questa email è già registrata. Accedi.";
      return;
    }

    // If email confirmation is required
    if (data.user && !data.session) {
      errorMessage.value = "Controlla la tua email per il link di conferma.";
      return;
    }

    // Create profile record
    if (data.user) {
      const { error: profileError } = await supabase.from("profiles").insert({
        id: data.user.id,
        first_name: formData.value.name,
        last_name: "",
      });

      if (profileError) {
        console.error("Error creating profile:", profileError);
      }
    }

    // If auto-confirmed
    router.push("/shop");
  } catch (error) {
    errorMessage.value =
      error.message || "Si è verificato un errore durante la registrazione.";
    console.error("Authentication error:", error);
  }
};

// Handle Google Sign Up
const signUpWithGoogle = async () => {
  try {
    const { error } = await supabase.auth.signInWithOAuth({
      provider: "google",
    });

    if (error) throw error;
  } catch (error) {
    errorMessage.value =
      error.message || "Errore durante l'accesso con Google.";
    console.error("Google auth error:", error);
  }
};
</script>

<style scoped>
.page-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

main {
  flex: 1;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: Arial, sans-serif;
}

body {
  background-color: white;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.container {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 50px;
  width: 90%;
}

.image-section {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  margin-right: 40px;
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
  color: black;
}

p {
  margin-bottom: 15px;
  color: black;
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
  color: black;
  text-decoration: none;
}

.account-info {
  margin-top: 20px;
  text-align: center;
  color: gray;
}

.account-info a {
  color: black;
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

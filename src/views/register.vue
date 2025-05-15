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
  background-color: #f8f9fa;
}

main {
  flex: 1;
  padding: 4rem 2rem;
}

.container {
  max-width: 1800px;
  margin: 0 auto;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 4rem;
}

.image-section {
  flex: 1;
  max-width: 600px;
}

.image-section img {
  width: 100%;
  border-radius: 24px;
  box-shadow: 0 8px 30px rgba(107, 70, 193, 0.12);
  transition: transform 0.3s ease;
}

.image-section img:hover {
  transform: translateY(-5px);
}

.form-section {
  flex: 1;
  max-width: 600px;
  background: white;
  padding: 4rem;
  border-radius: 24px;
  box-shadow: 0 8px 30px rgba(107, 70, 193, 0.08);
  border: 1px solid rgba(107, 70, 193, 0.1);
}

h2 {
  font-size: 2.8rem;
  color: #2c3e50;
  margin-bottom: 1rem;
  font-weight: 800;
  position: relative;
  padding-bottom: 1.5rem;
}

h2::after {
  content: "";
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100px;
  height: 4px;
  background: #6b46c1;
  border-radius: 4px;
}

p {
  color: #4a5568;
  font-size: 1.1rem;
  margin-bottom: 2rem;
}

form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

input {
  width: 100%;
  padding: 1.2rem;
  border: 2px solid #e6e6e6;
  border-radius: 12px;
  font-size: 1rem;
  transition: all 0.3s ease;
  background: #ffffff;
}

input:focus {
  border-color: #6b46c1;
  box-shadow: 0 0 0 4px rgba(107, 70, 193, 0.1);
  outline: none;
}

.create-account {
  background: #6b46c1;
  color: white;
  padding: 1.2rem;
  border-radius: 12px;
  font-weight: 600;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  font-size: 1rem;
  margin-top: 1rem;
}

.create-account:hover {
  background: #553c9a;
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(107, 70, 193, 0.25);
}

.google-signup {
  background: white;
  border: 2px solid #e6e6e6;
  padding: 1.2rem;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 1rem;
  margin-top: 1rem;
}

.google-signup:hover {
  border-color: #6b46c1;
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(107, 70, 193, 0.1);
}

.account-info {
  margin-top: 2rem;
  text-align: center;
  color: #4a5568;
  font-size: 1rem;
}

.account-info a {
  color: #6b46c1;
  font-weight: 600;
  text-decoration: none;
  transition: color 0.3s ease;
}

.account-info a:hover {
  color: #553c9a;
  text-decoration: underline;
}

.error-message {
  background: #fee2e2;
  color: #dc2626;
  padding: 1.2rem 2rem;
  border-radius: 12px;
  margin-bottom: 2rem;
  font-weight: 600;
  text-align: center;
}

/* Responsive Design */
@media (max-width: 1200px) {
  .container {
    flex-direction: column;
    gap: 2rem;
  }

  .image-section,
  .form-section {
    max-width: 100%;
  }
}

@media (max-width: 768px) {
  main {
    padding: 2rem 1rem;
  }

  .form-section {
    padding: 2rem;
  }

  h2 {
    font-size: 2rem;
  }

  input,
  .create-account,
  .google-signup {
    padding: 1rem;
  }
}
</style>

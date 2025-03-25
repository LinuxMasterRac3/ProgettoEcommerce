<template>
  <div class="login-container">
    <div class="auth-card">
      <h1>{{ isLogin ? "Login" : "Register" }}</h1>

      <div
        v-if="errorMessage"
        class="error-message">
        {{ errorMessage }}
      </div>

      <form @submit.prevent="submitForm">
        <div class="form-group">
          <label for="email">Email</label>
          <input
            id="email"
            type="email"
            v-model="email"
            required
            placeholder="your@email.com" />
        </div>

        <div class="form-group">
          <label for="password">Password</label>
          <input
            id="password"
            type="password"
            v-model="password"
            required
            placeholder="Your password" />
        </div>

        <button
          type="submit"
          class="submit-btn">
          {{ isLogin ? "Login" : "Register" }}
        </button>
      </form>

      <div class="toggle-form">
        <p v-if="isLogin">
          Don't have an account?
          <a
            href="#"
            @click.prevent="isLogin = false"
            >Register</a
          >
        </p>
        <p v-else>
          Already have an account?
          <a
            href="#"
            @click.prevent="isLogin = true"
            >Login</a
          >
        </p>
      </div>
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
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: #f5f5f5;
}

.auth-card {
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  padding: 2rem;
  width: 100%;
  max-width: 400px;
}

h1 {
  text-align: center;
  margin-bottom: 1.5rem;
  color: #333;
}

.form-group {
  margin-bottom: 1rem;
}

label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
}

input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 1rem;
}

.submit-btn {
  width: 100%;
  background-color: #4361ee;
  color: white;
  padding: 0.75rem;
  border: none;
  border-radius: 4px;
  font-size: 1rem;
  cursor: pointer;
  margin-top: 1rem;
  transition: background-color 0.2s;
}

.submit-btn:hover {
  background-color: #3a56d4;
}

.toggle-form {
  text-align: center;
  margin-top: 1.5rem;
}

.toggle-form a {
  color: #4361ee;
  text-decoration: none;
  font-weight: 500;
}

.error-message {
  background-color: #ffebee;
  color: #d32f2f;
  padding: 0.75rem;
  border-radius: 4px;
  margin-bottom: 1rem;
  font-size: 0.875rem;
}
</style>

import "./assets/main.css";
import { createApp } from "vue";
import App from "./App.vue";
import router from "./router";

// Create the app instance
const app = createApp(App);

// Disable Vue DevTools completely for all environments
// This will hide the Vue tab in browser dev tools
app.config.performance = false;
app.config.devtools = false;

// For Vue 3, we should also use the compile-time flag
// This needs to be added to vite.config.ts, not here

// Mount the app
app.use(router);
app.mount("#app");

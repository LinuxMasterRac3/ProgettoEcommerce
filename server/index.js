/** @format */

import express from "express";
import bodyParser from "body-parser";
import cors from "cors";
import apiRoutes from "../api/api.js"; // Importa il file API con estensione .js
import createCheckoutSession from "../api/create-checkout-session.js";
import { deleteStripeProducts } from "../api/delete-stripe-products.js";
import sendConfirmationEmail from "../api/send-confirmation-email.js";

const app = express();

// Middleware
app.use(cors()); // Abilita CORS per consentire richieste dal frontend
app.use(bodyParser.json()); // Analizza il corpo delle richieste in formato JSON

// Rotte
app.use("/api/stripe-create-product", apiRoutes); // Usa app.use per collegare l'endpoint

app.use("/api/delete-stripe-products", deleteStripeProducts); // Usa app.use per collegare l'endpoint

// Add the email endpoint
app.use("/api/send-confirmation-email", sendConfirmationEmail);

// Porta del server
const PORT = 3000; // Cambia la porta
app.post("/api/create-checkout-session", createCheckoutSession);
app.listen(PORT, () => {
  console.log(`Server avviato su http://localhost:${PORT}`);
});

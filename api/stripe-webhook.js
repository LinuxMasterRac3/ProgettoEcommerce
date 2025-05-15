// api/stripe-webhook.js
import { buffer } from 'micro'; // Helper per leggere il raw body, installa 'micro' se necessario
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

// Disabilita il parsing del body di default per questa funzione
export const config = {
  api: {
    bodyParser: false,
  },
};

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).end('Method Not Allowed');
  }

  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
  if (!webhookSecret) {
      console.error("Errore: STRIPE_WEBHOOK_SECRET non configurato.");
      return res.status(500).send("Configurazione webhook incompleta.");
  }

  const buf = await buffer(req); // Legge il corpo grezzo della richiesta
  const sig = req.headers['stripe-signature'];

  let event;

  try {
    event = stripe.webhooks.constructEvent(buf.toString(), sig, webhookSecret);
  } catch (err) {
    console.error(`⚠️  Webhook signature verification failed:`, err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Gestisci l'evento (es. checkout.session.completed)
  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    console.log('Checkout Session completata (serverless)!', session.id);
    } else {
    console.log(`Evento Stripe non gestito: ${event.type}`);
  }

  res.status(200).json({ received: true });
}
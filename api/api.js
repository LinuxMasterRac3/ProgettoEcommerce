/** @format */

import { createStripeProduct } from './stripe.js';

export default async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Metodo non consentito' });
  }

  try {
    const productData = req.body;
    // --- Controllo che il campo name sia presente ---
    if (!productData.name) {
      return res.status(400).json({ message: 'Il campo name è obbligatorio' });
    }
    // ------------------------------------------------
    const stripeResponse = await createStripeProduct(productData);
    // stripeResponse DEVE contenere almeno { id: ... }
    return res.status(200).json(stripeResponse);
  } catch (error) {
    console.error('Errore durante la creazione del prodotto su Stripe:', error);
    return res.status(500).json({
      message: 'Errore durante la creazione del prodotto su Stripe',
      error,
    });
  }
};
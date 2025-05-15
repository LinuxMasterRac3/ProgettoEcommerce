/** @format */

import Stripe from 'stripe';
import dotenv from 'dotenv';
dotenv.config({ path: '.env.local' });

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

/**
 * Crea un prodotto e un prezzo su Stripe.
 * @param {Object} productData - Dati del prodotto (name, description, price)
 * @returns {Promise<Object>} - Prodotto e prezzo Stripe
 */
export async function createStripeProduct(productData) {
  // 1. Crea il prodotto
  const product = await stripe.products.create({
    name: productData.name,
    description: productData.description,
  });

  // 2. Crea il prezzo associato
  const price = await stripe.prices.create({
    product: product.id,
    unit_amount: Math.round(Number(productData.price) * 100), // prezzo in centesimi
    currency: 'eur',
  });

  return { product, price };
}

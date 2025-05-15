/** @format */

// api/create-checkout-session.js

import Stripe from "stripe";
import { createClient } from "@supabase/supabase-js";

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
// Non usare require('dotenv').config() qui; Vercel/Netlify iniettano le variabili d'ambiente.

export default async function (req, res) {
  // Recupera le variabili d'ambiente impostate sulla piattaforma di hosting
  // Usa solo la anon key per Supabase
  const supabaseUrl = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL;
  const supabaseAnonKey =
    process.env.SUPABASE_ANON_KEY || process.env.VITE_SUPABASE_ANON_KEY;
  const clientUrl = process.env.CLIENT_URL || `https://${req.headers.host}`; // In produzione usa l'URL attuale o una variabile VERCEL_URL/SITE_URL
  const shippingCostPerItemCents = parseInt(
    process.env.SHIPPING_COST_PER_ITEM_CENTS || "199"
  );

  if (!supabaseUrl || !supabaseAnonKey || !process.env.STRIPE_SECRET_KEY) {
    console.error("Errore: Variabili d'ambiente Supabase o Stripe mancanti.");
    return res
      .status(500)
      .json({ error: "Configurazione del server incompleta." });
  }
  const supabase = createClient(supabaseUrl, supabaseAnonKey);

  if (req.method !== "POST") {
    res.setHeader("Allow", "POST");
    return res.status(405).end("Method Not Allowed");
  }

  const { items, couponId, customerEmail } = req.body;

  if (!items || !Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ error: "Nessun prodotto specificato." });
  }

  try {
    const line_items = [];
    let totalQuantity = 0;

    for (const item of items) {
      const productId = item.id;
      const quantity = Number(item.quantity);

      if (!productId || !quantity || quantity <= 0) {
        return res
          .status(400)
          .json({ error: `Dati prodotto non validi per ID: ${productId}` });
      }

      const { data: productData, error: productError } = await supabase
        .from("products")
        .select("name, description, price, metadata")
        .eq("id", productId)
        .single();

      if (productError) throw productError;
      if (!productData || typeof productData.price !== "number") {
        return res.status(404).json({
          error: `Dettagli o prezzo mancanti per il prodotto ${productId}.`,
        });
      }

      const priceInCents = Math.round(productData.price * 100);
      totalQuantity += quantity;

      line_items.push({
        price_data: {
          currency: "eur",
          product_data: {
            name: productData.name,
            description: productData.description || undefined,
            images: productData.metadata?.additional_images?.[0]
              ? [productData.metadata.additional_images[0]]
              : undefined,
            metadata: { supabase_product_id: productId },
          },
          unit_amount: priceInCents,
        },
        quantity: quantity,
      });
    }

    if (totalQuantity > 0 && shippingCostPerItemCents > 0) {
      const totalShippingCost = totalQuantity * shippingCostPerItemCents;
      line_items.push({
        price_data: {
          currency: "eur",
          product_data: { name: "Costo di Spedizione" },
          unit_amount: totalShippingCost,
        },
        quantity: 1,
      });
    }

    const sessionParams = {
      payment_method_types: ["card", "paypal"],
      line_items: line_items,
      mode: "payment",
      success_url: `${clientUrl}/payment-success?productIds=${items
        .map((i) => i.id)
        .join(",")}`,
      cancel_url: `${clientUrl}/payment-cancel`, // Rimosso ".vue"
      customer_email: customerEmail || undefined,
    };

    if (couponId) {
      sessionParams.discounts = [{ coupon: couponId }];
    }

    const session = await stripe.checkout.sessions.create(sessionParams);
    return res.status(200).json({ url: session.url, sessionId: session.id });
  } catch (error) {
    console.error("Errore in create-checkout-session:", error);
    let statusCode = 500;
    let errorMessage = "Errore interno del server.";
    if (error.type === "StripeInvalidRequestError") {
      statusCode = 400;
      errorMessage = error.message;
    } else if (error.code && error.code.startsWith("PGRST")) {
      // Errori Supabase (es. PGRST116 not found)
      statusCode = 404;
      errorMessage = `Errore database: ${error.message}`;
    }
    return res.status(statusCode).json({ error: errorMessage });
  }
}

import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

async function deleteStripeProducts(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Metodo non consentito' });
  }
  const { productIds } = req.body;
  if (!Array.isArray(productIds)) {
    return res.status(400).json({ message: 'productIds deve essere un array' });
  }
  try {
    for (const id of productIds) {
      await stripe.products.del(id);
    }
    return res.status(200).json({ success: true });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
}

export { deleteStripeProducts };  
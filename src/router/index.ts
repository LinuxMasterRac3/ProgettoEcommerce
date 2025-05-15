import { createRouter, createWebHistory } from "vue-router";
import HomeView from "../views/HomeView.vue";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: "/",
      name: "home",
      component: () => import("../views/Shop.vue"),
    },
    {
      path: "/home",
      name: "homepage",
      component: HomeView,
    },
    {
      path: "/about",
      name: "about",
      // route level code-splitting
      // this generates a separate chunk (About.[hash].js) for this route
      component: () => import("../views/AboutView.vue"),
    },
    {
      path: "/login",
      name: "login",
      component: () => import("../views/Login.vue"),
    },
    {
      path: "/register",
      name: "register",
      component: () => import("../views/register.vue"),
    },
    {
      path: "/account",
      name: "account",
      component: () => import("../views/Account.vue"),
    },
    {
      path: "/wishlist",
      name: "wishlist",
      component: () => import("../views/wishlist.vue"),
    },
    {
      path: "/cart",
      name: "cart",
      component: () => import("../views/Cart.vue"),
    },
    {
      path: "/checkout",
      name: "checkout",
      component: () => import("../views/Checkout.vue"),
    },
    {
      path: "/contact",
      name: "contact",
      component: () => import("../views/Contact.vue"),
    },
    {
      path: "/error",
      name: "error",
      component: () => import("../views/Error.vue"),
    },
    {
      path: "/product",
      name: "product",
      component: () => import("../views/Product.vue"),
    },
    {
      path: "/payment-cancel",
      name: "payment-cancel",
      component: () => import("../views/payment-cancel.vue"),
    },
    {
      path: "/payment-success",
      name: "payment-success",
      component: () => import("../views/payment-success.vue"),
    },
    {
      path: "/product/:id",
      name: "product-detail",
      component: () => import("../views/product/[id].vue"),
    },
    {
      path: "/shop",
      redirect: "/",
    },
    {
      path: "/addbook",
      name: "addbook",
      component: () => import("../views/AggiungiLibro.vue"),
    },
    {
      path: "/allbooks",
      name: "allbooks",
      component: () => import("../views/Allbooks.vue"),
    },
    // Add the new route for editing books
    {
      path: "/editbook/:id",
      name: "editbook",
      component: () => import("../views/EditBook.vue"),
    },
    // Add a catch-all route for 404 errors
    {
      path: "/:pathMatch(.*)*",
      name: "not-found",
      component: () => import("../views/Error.vue"),
    },
  ],
});

export default router;

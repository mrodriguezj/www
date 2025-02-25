import { createRouter, createWebHistory } from 'https://unpkg.com/vue-router@4/dist/vue-router.esm-browser.js';

/* Definición de las vistas */
const Dashboard = {
  template: `
    <div>
      <h2 class="text-3xl font-semibold mb-4">Dashboard</h2>
      <p>Bienvenido al sistema de cobranza.</p>
    </div>
  `,
};

const Clientes = {
  template: `<div><h2 class="text-2xl">Clientes (Próximamente)</h2></div>`,
};

const Propiedades = {
  template: `<div><h2 class="text-2xl">Propiedades (Próximamente)</h2></div>`,
};

/* Definición de rutas */
const routes = [
  { path: '/', component: Dashboard },
  { path: '/clientes', component: Clientes },
  { path: '/propiedades', component: Propiedades },
];

/* Creación del router */
export default createRouter({
  history: createWebHistory(),
  routes,
});

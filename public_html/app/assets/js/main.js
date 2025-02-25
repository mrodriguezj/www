const { createApp } = Vue;
const { createRouter, createWebHistory } = VueRouter;

/* COMPONENTES */

// Layout principal
const Layout = {
  template: `
    <div class="flex h-screen">
      <Sidebar />
      <div class="flex-1 flex flex-col">
        <Header />
        <main class="p-6 flex-1 overflow-y-auto">
          <router-view></router-view>
        </main>
      </div>
    </div>
  `,
  components: {
    Sidebar: {
      template: `
        <aside class="w-64 bg-white border-r p-4">
          <nav class="space-y-4">
            <router-link to="/" class="menu-item" exact>Dashboard</router-link>
            <router-link to="/clientes" class="menu-item">Clientes</router-link>
            <router-link to="/propiedades" class="menu-item">Propiedades</router-link>
          </nav>
        </aside>
      `,
    },
    Header: {
      template: `
        <header class="bg-white shadow p-4">
          <h1 class="text-2xl font-bold text-gray-700">Sistema de Cobranza</h1>
        </header>
      `,
    },
  },
};

/* VISTAS */
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

/* RUTAS */
const routes = [
  { path: '/', component: Dashboard },
  { path: '/clientes', component: Clientes },
  { path: '/propiedades', component: Propiedades },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

/* INICIALIZACIÓN */
const app = createApp(Layout);
app.use(router);
app.mount('#app');

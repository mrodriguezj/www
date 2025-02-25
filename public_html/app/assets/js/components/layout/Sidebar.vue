<template>
  <aside class="w-64 bg-white border-r p-4">
    <nav class="space-y-4">
      <router-link to="/" class="menu-item" exact>Dashboard</router-link>
      <router-link to="/clientes" class="menu-item">Clientes</router-link>
      <router-link to="/propiedades" class="menu-item">Propiedades</router-link>
    </nav>
  </aside>
</template>

<style scoped>
.menu-item {
  display: block;
  padding: 0.75rem;
  border-radius: 0.5rem;
  color: #374151;
  font-weight: 500;
  transition: background-color 0.2s ease;
}
.menu-item:hover {
  background-color: #e5e7eb;
}
</style>

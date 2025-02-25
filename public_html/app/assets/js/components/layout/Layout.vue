<template>
  <div class="flex h-screen">
    <Sidebar />
    <div class="flex-1 flex flex-col">
      <Header />
      <main class="p-6 flex-1 overflow-y-auto">
        <router-view></router-view>
      </main>
    </div>
  </div>
</template>

<script>
import Sidebar from './Sidebar.vue';
import Header from './Header.vue';

export default {
  components: { Sidebar, Header },
};
</script>

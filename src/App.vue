<script setup lang="ts">
import Loading from './Loading.vue'

import { onMounted } from 'vue'
import { ref } from 'vue'
import { checkNetWork } from './utils/network.js'

const isLoading = ref(true)

onMounted(() => {
  setTimeout(async() => {
    await checkNetWork()
    isLoading.value = false
  }, 3000);
})
</script>

<template>
  <Loading v-if="isLoading" />
  <div v-else>
    <router-link to="/" />
    <router-link to="/leadboard" />
    <router-view />
  </div>
</template>

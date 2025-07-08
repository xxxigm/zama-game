<script setup lang="ts">
import { TresCanvas } from '@tresjs/core'
import { useHead } from '@vueuse/head'
import GameLoading from './components/GameLoading.vue'

useHead({
  title: 'Loading...',
})

</script>

<template>
  <div class="modal">
    <div id="world" class="world">
      <TresCanvas alpha antialias use-legacy-lights class="game-holder">
        <TresPerspectiveCamera :position="[0, 200, 100]" />
        <TresFog :args="[0xF7D9AA, 100, 950]" />
        <GameLoading />
      </TresCanvas>
    </div>
    <div id="replayMessage" class="message message--replay">
      Loading...
    </div>
  </div>
</template>

<style>
.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 1000000;
}
</style>

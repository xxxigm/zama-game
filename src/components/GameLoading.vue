<script setup lang="ts">
import { onMounted } from 'vue'
import Light from './Light.vue'
import Pilot from './Pilot/index.vue'
import AirPlane from './AirPlane/index.vue'

import { useGame } from '../composables/useGame'

import { useObjectsManager } from '../composables/useObjectManager'
const { airplane } = useObjectsManager()

const { game } = useGame()


function runWithInterval() {
  const intervalTime = 30;

  function performEvent() {
    airplane.value.position.x = airplane.value.position.x + 1
  }

  function checkTime() {
    if (airplane.value.position.x < 20) {
      performEvent();
    } else {
      clearInterval(intervalId);
    }
  }

  const intervalId = setInterval(checkTime, intervalTime);
}

onMounted(() => {
  game.status = 'waitingReplay'
  airplane.value.position.y = 200
  airplane.value.position.x = -20
  runWithInterval()
})


</script>

<template>
  <Light />
  <AirPlane>
    <Pilot :position="[-10, 27, 0]" />
  </AirPlane>
</template>

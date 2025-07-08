import { createApp } from 'vue'
import { createHead } from '@vueuse/head'
import { createRouter, createWebHistory } from 'vue-router'

import App from './App.vue'
import Game from './Game.vue'
import Faucet from './Faucet.vue'
import Leadboaed from './Leaderboard.vue'
import './styles/demo.css'
import './styles/game.css'

// https://github.com/YunYouJun/wc-github-corners
import 'wc-github-corners'

const app = createApp(App)

const router = new createRouter({
    history: createWebHistory(),
    routes: [
      { path: '/', component: Game },
      { path: '/faucet', component: Faucet },
      { path: '/leaderboard', component: Leadboaed },
    ]
  })

const head = createHead()

app.use(router)
app.use(head)
app.mount('#app')

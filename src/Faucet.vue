<script setup lang="ts">
import { ref, watchEffect } from 'vue'
import { useHead } from '@vueuse/head'

import { toast } from 'vue3-toastify';
import 'vue3-toastify/dist/index.css'

import { ethers } from "ethers";

import { PRIVATE_KEY_WALLET, SEPOLIA_RPC_URL } from './constants/index.js'

useHead({
  title: 'The Aviator',
})

const address = ref('')
const enabledBtn = ref(false)

watchEffect(() => enabledBtn.value = !!address.value)

const handleFaucet = () => {
  if(!address.value) return

  const provider = new ethers.providers.JsonRpcProvider(SEPOLIA_RPC_URL);
  const privateKey = PRIVATE_KEY_WALLET;
  const wallet = new ethers.Wallet(privateKey, provider);
  const recipientAddress = address.value;
  const amountToSend = ethers.utils.parseEther("1");
  const transaction = {
    to: recipientAddress,
    value: amountToSend,
    gasPrice: ethers.utils.parseUnits('90', 'gwei'),
    gasLimit: 91000, 
  };

  toast.info('Fauceting ...!', {
    icon: '⏳',
    position: toast.POSITION.BOTTOM_RIGHT
  });

  enabledBtn.value = false

  wallet.sendTransaction(transaction)
  .then(() => {
      toast.success("Successful!", {
        position: toast.POSITION.BOTTOM_RIGHT
      });
  })
  .catch((e) => {
    console.log(e)
    toast.error("Something went wrong!", {
      position: toast.POSITION.BOTTOM_RIGHT
    });
  })
  .finally(() => {
    address.value = ''
  });
}

</script>

<template>
  <div class="game-holder">
    <div class="header">
      <h1><span>the</span>Aviator</h1>
      <h2>fly it to the end</h2>
      <h3 style="position: fixed; top: 50px; left: 50px; z-index: 9999;">Leaderboard</h3>
    </div>
    <div class="faucetWrap">
      <input v-model="address" class="faucetInput" placeholder="Enter evm address ..." />
      <div :class="['faucetBtn', {'enabled': enabledBtn}]" @click="handleFaucet">Faucet</div>
      <div class="back">
        <router-link to="/">Back</router-link>
      </div>
    </div>
  </div>
</template>


<style>
.faucetWrap {
	height: 100vh;
	width: 100vw;
	display: flex;
	align-items: center;
	justify-content: center;
	flex-direction: column;
	background: -webkit-linear-gradient(#e4e0ba, #f7d9aa);
	background: linear-gradient(#e4e0ba, #f7d9aa);
}

.faucetInput {
	width: 590px;
  height: 50px;
  padding: 0px 12px;
  outline: none;
  font-size: 16px;
	border: none;
  color: rgb(169, 169, 169);
  font-family: 'Playfair Display';
}

.faucetInput::placeholder {
  font-family: 'Playfair Display';
  color: rgb(169, 169, 169);
}

.faucetBtn {
	font-family: 'Playfair Display';
  height: 50px;
	width: 590px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #68c3c0;
  color: white;
  margin-top: 10px;
  margin-bottom: 20px;
	opacity: 0.8;
}

.faucetBtn.enabled {
	opacity: 1;
	cursor: pointer;
}

.back {
  width: 590px;
}
</style>
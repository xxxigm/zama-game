<script setup lang="ts">
import { ref, watch } from 'vue'

import { SYMBOL } from '../constants/index.js'

const props = defineProps({
    modalType: Number,
    closeModal: Function,
    actionModal: Function,
    reward: Number,
    level: Number,
});

const disabledBtn = ref(false)

const handleAgree = () => {
    if(disabledBtn.value) return
    props.actionModal()
    disabledBtn.value = true
}

const onCloseModal = () => {
    props.closeModal();
    disabledBtn.value = false
}

const handleReward = () => {
  if(props.level === 1) {
    onCloseModal()
  } else {
    handleAgree()
  }
}

watch(() => props.modalType, () => disabledBtn.value = false)

</script>

<template>
<div v-if="!!props.modalType" :class="['modal-window', {'show': !!props.modalType}]">
  <div v-if="modalType === 1" class="wrapModal">
    <a href="#" title="Close" class="modal-close" @click.self="props.closeModal">Close</a>
    <h1>Warning</h1>
    <div>You don't have enough <strong>{{ SYMBOL }}</strong> in your wallet. Please faucet the token using the link below!</div>
    <br>
    <div><small>Check out 👇</small></div>
    <div class="btnFaucet">
        <a href="https://testnet.monad.xyz/" target="_blank">Faucet</a>
    </div>
  </div>
  <div v-if="modalType === 2" class="wrapModal">
    <a href="#" title="Close" class="modal-close" @click.self="onCloseModal">Close</a>
    <h1>Attention</h1>
    <div>When starting the game, you will need to pay a fee of <strong>0.009 {{ SYMBOL }}</strong>. Do you agree?</div>
    <br>
    <div><small>Check out 👇</small></div>
    <div @click.self="handleAgree" :class="['btnFaucet', {'disabledBtn': disabledBtn}]">Agree</div>
  </div>
  <div v-if="modalType === 3" class="wrapModal">
    <a href="#" title="Close" class="modal-close" @click.self="onCloseModal">Close</a>
    <h1>Attention</h1>
    <div v-if="level === 1">Unfortunately, you didn't pass any levels, so you don't get any rewards.</div>
    <div v-else>Congratulations! You have not passed level <strong>{{ level }}</strong>. Your reward is <strong>{{ reward }}</strong> <strong>{{ SYMBOL }}</strong></div>
    <br>
    <div><small>Check out 👇</small></div>
    <div @click.self="handleReward" :class="['btnFaucet', {'disabledBtn': disabledBtn}]">{{ level === 1 ? 'Continute' : 'Claim' }}</div>
  </div>
</div>
</template>


<style>

.modal-window {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  z-index: 999;
  visibility: hidden;
  opacity: 0;
  pointer-events: none;
  transition: all 0.3s;
  background-color: rgba(255, 255, 255, 0.2);
}

.modal-window.show {
    visibility: visible;
    opacity: 1;
    pointer-events: auto;
}

.modal-window.show .wrapModal {
    width: 570px;
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    padding: 2em;
    background: white;
}

.modal-window h1 {
    font-size: 150%;
    margin: 0 0 15px;
    font-family: 'Playfair Display';
}

.modal-close {
  color: #aaa;
  line-height: 50px;
  font-size: 80%;
  position: absolute;
  right: 0;
  text-align: center;
  top: 0;
  width: 70px;
  text-decoration: none;
}

.modal-close:hover {
    color: black; 
}

html {
  font-size: 18px;
  line-height: 1.4;
}

.container {
  display: grid;
  justify-content: center;
  align-items: center;
  height: 100vh;
}

.modal-window > div {
    border-radius: 1rem;
}

.modal-window div:not(:last-of-type) {
  margin-bottom: 15px;
}

.logo {
  max-width: 150px;
  display: block;
}

small {
  color: lightgray;
}

.btn {
  background-color: white;
  padding: 1em 1.5em;
  border-radius: 0.5rem;
  text-decoration: none;
}

.btnFaucet a {
    height: 50px;
    width: 100%;
    background-color:#68c3c0;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 4px;
    color: white;
    font-family: 'Playfair Display';
}

.btnFaucet {
    height: 50px;
    width: 100%;
    background-color:#68c3c0;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 4px;
    color: white;
    font-family: 'Playfair Display';
    cursor: pointer;
}

.btnFaucet a:hover {
    color: white;
}

.btnFaucet a:focus {
    color: white;
}

.disabledBtn {
    opacity: 0.8;
    cursor: default;
}

div {
    font-family: 'Playfair Display';
}
</style>
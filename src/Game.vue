<script setup lang="ts">
import { useRouter } from "vue-router";
import { onMounted, ref, watch } from "vue";
import { TresCanvas } from "@tresjs/core";
import { useEventListener } from "@vueuse/core";
import { useHead } from "@vueuse/head";
import Game from "./components/Game.vue";
import Modal from "./components/Modal.vue";
import { useGame } from "./composables/useGame.js";

import { toast } from "vue3-toastify";
import "vue3-toastify/dist/index.css";

import { requestBalance } from "./utils/network.js";

import ABI from "./constants/abi.json";
import {
  CONTRACT_ADDRESS,
  SEPOLIA_RPC_URL,
  PRIVATE_KEY_WALLET,
} from "./constants/index.js";
import {
  initSDK,
  createInstance,
  SepoliaConfig,
} from "@zama-fhe/relayer-sdk/bundle";

import { ethers } from "ethers";

useHead({
  title: "The Aviator",
});

const { game, resetGame } = useGame();
const router = useRouter();

const modalDisplayType = ref(0);
const isCloseClickTriggered = ref(false);
const userWalletAddress = ref("");
const contractInstance = ref<ethers.Contract | null>(null);
const modalActionHandler = ref<(() => Promise<void>) | undefined>(undefined);
const gameReward = ref(0);
const gameLevel = ref(0);
const relayerSDKInstance = ref<any | undefined>(undefined);

useEventListener(document, ["mouseup", "touchend"], async (event) => {
  if (!event?.target?.closest(".game-holder")) return;
  if (game.status === "playing") return;

  const currentBalance = await requestBalance();

  if (isCloseClickTriggered.value) {
    isCloseClickTriggered.value = false;
    return;
  }

  if (currentBalance.currentBalance < 0.00901) {
    modalDisplayType.value = 1;
  } else {
    modalDisplayType.value = 2;
    modalActionHandler.value = handleGameTransaction;
  }
});

const closeGameModal = () => {
  modalDisplayType.value = 0;
  isCloseClickTriggered.value = true;
};

const handleGameTransaction = async () => {
  try {
    const transactionResponse = await contractInstance?.value?.transfer({
      value: ethers.utils.parseEther("0.009"),
    });

    toast.warning("Transaction in progress!", {
      position: toast.POSITION.BOTTOM_RIGHT,
    });

    await transactionResponse.wait();

    if (game.status === "waitingReplay") {
      resetGame();
    }

    toast.success("Transaction successful!", {
      position: toast.POSITION.BOTTOM_RIGHT,
    });
  } catch (error: any) {
    console.error("Error during transaction:", error);
  } finally {
    modalDisplayType.value = 0;
  }
};

const initializeRelayerSDK = async () => {
  try {
    await initSDK();

    const config = { ...SepoliaConfig, network: window.ethereum };
    relayerSDKInstance.value = await createInstance(config);
  } catch (error) {
    console.error("Error initializing Relayer SDK:", error);
  }
};

const encryptUint64 = async (value: number) => {
  const encryptedInputBuilder = relayerSDKInstance.value.createEncryptedInput(
    CONTRACT_ADDRESS,
    userWalletAddress.value
  );

  const encryptedData = await encryptedInputBuilder.add64(value).encrypt();

  return {
    ciphertext: encryptedData.handles[0],
    proof: encryptedData.inputProof,
  };
};

const callUpdateUserOnContract = async (
  _userAddress: string,
  _newLevelPlaintext: number
) => {
  try {
    const encryptedLevelData = await encryptUint64(_newLevelPlaintext);
    const _newLevelEncrypted = encryptedLevelData.ciphertext;
    const _inputProof = encryptedLevelData.proof;

    const tx = await contractInstance?.value?.updateUser(
      _userAddress,
      _newLevelEncrypted,
      _inputProof
    );

    await tx.wait();
  } catch (error: any) {
    console.error("Error calling updateUser on contract:", error);
  }
};

const initializeContractAndWallet = async () => {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);
  const address = await signer.getAddress();
  userWalletAddress.value = address;
  contractInstance.value = contract;
};

const calculateTotalReward = (level: number): number => {
  let sum = 0;
  for (let i = 1; i < level; i++) {
    sum += i * 0.003;
  }
  return sum;
};

const claimGameReward = async () => {
  isCloseClickTriggered.value = true;
  const provider = new ethers.providers.JsonRpcProvider(SEPOLIA_RPC_URL);
  const wallet = new ethers.Wallet(PRIVATE_KEY_WALLET, provider);
  const recipientAddress = userWalletAddress.value;
  const amountToSend = ethers.utils.parseEther(`${gameReward.value}`);

  const transactionDetails = {
    to: recipientAddress,
    value: amountToSend,
    gasPrice: ethers.utils.parseUnits("100", "gwei"),
    gasLimit: 100000,
  };

  toast.info("Preparing to update your level...", {
    icon: "⏳",
    position: toast.POSITION.BOTTOM_RIGHT,
  });
  await callUpdateUserOnContract(userWalletAddress.value, gameLevel.value);

  toast.info("Submitting level decryption request...", {
    icon: "🔐",
    position: toast.POSITION.BOTTOM_RIGHT,
  });
  const requestTx = await contractInstance?.value?.requestUserLevelDecryption(
    userWalletAddress.value
  );
  await requestTx.wait();

  toast.info("Claiming reward...!", {
    icon: "⏳",
    position: toast.POSITION.BOTTOM_RIGHT,
  });

  wallet
    .sendTransaction(transactionDetails)
    .then(() => {
      toast.success("Reward claimed successfully!", {
        position: toast.POSITION.BOTTOM_RIGHT,
      });
      modalDisplayType.value = 0;
    })
    .catch((error) => {
      toast.error("Failed to claim reward!", {
        position: toast.POSITION.BOTTOM_RIGHT,
      });
      console.error("Error sending reward transaction:", error);
    });
};

const navigateToLeaderboard = () => {
  router.push("/leaderboard");
};

function shortenWalletAddress(
  address: string = userWalletAddress.value
): string {
  if (address.length <= 8) return address;
  return `${address.slice(0, 6)}...${address.slice(-5)}`;
}

watch(
  () => game.status,
  () => {
    if (game.status === "gameover") {
      modalDisplayType.value = 3;
      gameReward.value = calculateTotalReward(game.level);
      gameLevel.value = game.level;
      modalActionHandler.value = claimGameReward;
    }
  }
);

onMounted(async () => {
  try {
    game.status = "waitingReplay";
    await initializeContractAndWallet();
    await initializeRelayerSDK();
  } catch (error) {
    console.log(error);
  }
});
</script>

<template>
  <Modal
    :modalType="modalDisplayType"
    :reward="gameReward"
    :level="gameLevel"
    :closeModal="closeGameModal"
    :actionModal="modalActionHandler"
  />
  <div
    style="position: fixed; z-index: 3; right: 0; top: 0; background-color: red"
  ></div>

  <div class="game-holder">
    <h2 class="address">{{ shortenWalletAddress() }}</h2>
    <div class="header">
      <h1><span>the</span>Aviator</h1>
      <h2>fly it to the end</h2>
      <div id="score" class="score">
        <div id="level" class="score__content">
          <div class="score__label">level</div>
          <div id="levelValue" class="score__value score__value--level">
            {{ game.level }}
          </div>
          <svg id="levelCircle" class="level-circle" viewBox="0 0 200 200">
            <circle
              id="levelCircleBgr"
              r="80"
              cx="100"
              cy="100"
              fill="none"
              stroke="#d1b790"
              stroke-width="24px"
            />
            <circle
              id="levelCircleStroke"
              r="80"
              cx="100"
              cy="100"
              fill="none"
              stroke="#68c3c0"
              stroke-width="14px"
              stroke-dasharray="502"
              :stroke-dashoffset="
                502 *
                (1 -
                  (game.distance % game.distanceForLevelUpdate) /
                    game.distanceForLevelUpdate)
              "
            />
          </svg>
        </div>
        <div id="dist" class="score__content">
          <div class="score__label">distance</div>
          <div id="distValue" class="score__value score__value--dist">
            {{ Math.floor(game.distance) }}
          </div>
        </div>
        <div id="energy" class="score__content">
          <div class="score__label">energy</div>
          <div id="energyValue" class="score__value score__value--energy">
            <div
              id="energyBar"
              class="energy-bar"
              :style="{
                right: `${100 - game.energy}%`,
                backgroundColor: game.energy < 50 ? '#f25346' : '#68c3c0',
                animationName: game.energy < 30 ? 'blinking' : 'none',
              }"
            />
          </div>
        </div>
      </div>
    </div>

    <div id="world" class="world">
      <TresCanvas
        :alpha="!(game.level % 2 === 0)"
        antialias
        use-legacy-lights
        class="game-holder"
      >
        <TresPerspectiveCamera :position="[0, 200, game.planeDefaultHeight]" />
        <TresFog :args="[0xf7d9aa, 100, 950]" />
        <Game />
      </TresCanvas>
    </div>
    <div
      v-show="game.status === 'waitingReplay'"
      id="replayMessage"
      class="message message--replay"
    >
      Click to Play
    </div>
    <div id="instructions" class="message message--instructions">
      Grab the blue pills<span>avoid the red ones</span>
    </div>
    <div
      @click="navigateToLeaderboard"
      style="
        position: fixed;
        bottom: 10px;
        left: 50%;
        transform: translateX(-50%);
        padding: 12px 24px;
        background: linear-gradient(135deg, #ff7e5f, #feb47b);
        color: white;
        font-size: 18px;
        font-weight: bold;
        border-radius: 8px;
        text-align: center;
        cursor: pointer;
        transition: all 0.3s ease;
        box-shadow: 2px 4px 10px rgba(0, 0, 0, 0.2);
      "
    >
      Leaderboard
    </div>
  </div>
</template>

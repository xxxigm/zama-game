<script setup lang="ts">
import { useRouter } from "vue-router";
import { ref, watchEffect, onMounted } from "vue";
import { useHead } from "@vueuse/head";
import { toast } from "vue3-toastify";

import {
  initSDK,
  createInstance,
  SepoliaConfig,
} from "@zama-fhe/relayer-sdk/bundle";

import "vue3-toastify/dist/index.css";

import { ethers } from "ethers";

import ABI from "./constants/abi.json";
import { CONTRACT_ADDRESS } from "./constants/index.js";

useHead({
  title: "The Aviator",
});

interface User {
  address: string;
  level: string | number;
  rank: number;
}

const router = useRouter();

const viewUserCurrent = ref({});
const searchInput = ref("");
const users = ref<User[]>([]);
const usersOrigin = ref<User[]>([]);
const contractInstance = ref<ethers.Contract | null>(null);
const relayerSDKInstance = ref<any | undefined>(undefined);

const handeleSearch = async () => {
  const keyword = searchInput.value;
  const data: Array<[string, string]> =
    (await contractInstance.value?.getAllUsersEncryptedLevels()) || [];

  users.value = data
    .map(
      ([address], index): User => ({
        address: address.toString(),
        level: "*********",
        rank: index + 1,
      })
    )
    .filter((user) => user.address.includes(keyword))
    .sort((a, b) => Number(b.level) - Number(a.level));

  if (!keyword) usersOrigin.value = [...users.value];
};

watchEffect(() => handeleSearch());

const initializeContractAndWallet = async () => {
  const provider = new ethers.providers.Web3Provider(window.ethereum);
  const signer = provider.getSigner();
  const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

  contractInstance.value = contract;
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

const getDecryptedLevelOfUser = async (address: string) => {
  try {
    const data = await contractInstance.value?.getDecryptedLevelOfUser(address);
    viewUserCurrent.value = { address, level: data.toNumber() };
  } catch (error) {
    console.log(error)
    toast.warning(
      "Your level is still being revealed. Please wait a few seconds and try again!",
      {
        position: toast.POSITION.BOTTOM_RIGHT,
        toastClassName: "custom-toast-class",
      }
    );
  }
};

const goToPage = () => {
  router.push("/");
};

onMounted(async () => {
  await initializeContractAndWallet();
  await initializeRelayerSDK();
});
</script>

<template>
  <div class="container">
    <div class="header-top">
      <h4 @click="goToPage">Back</h4>
      <h2>Leaderboard</h2>
    </div>
    <div class="input-container">
      <input
        type="text"
        class="styled-input"
        placeholder="Enter your address ..."
        v-model="searchInput"
      />
    </div>
    <div class="responsive-table-wrap">
      <ul class="responsive-table">
        <li class="table-header">
          <div class="col col-3">Address</div>
          <div class="col col-2">Level</div>
        </li>
        <li v-for="(user, index) in users" :key="index" class="table-row">
          <div class="col col-3" data-label="Customer Name">
            {{ user.address }}
          </div>
          <div class="viewColumn">
            <div
              v-if="viewUserCurrent.address === user.address"
              class="col col-1"
              data-label="Job Id"
            >
              {{ viewUserCurrent?.level }}
            </div>
            <div v-else class="col col-1" data-label="Job Id">
              {{ user.level }}
            </div>
            <div
              class="view"
              data-label="View"
              @click="getDecryptedLevelOfUser(user.address)"
            >
              View
            </div>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>

<style>
body {
  font-family: "lato", sans-serif;
  height: 100vh;
  overflow: hidden;
}

h5:hover {
  cursor: pointer;
}

.header-top {
  width: 1000px;
  position: relative;
  display: flex;
  justify-content: center;
  margin-right: auto;
  margin-left: auto;
  position: relative;

  h4 {
    position: absolute;
    left: 0;
    top: 5px;
    cursor: pointer;
  }
}

.input-container {
  position: relative;
  display: flex;
  justify-content: center;

  input {
    width: 1000px;
    border-color: #ddd !important;
  }
}

.styled-input {
  width: 100%;
  padding: 12px 16px;
  font-size: 16px;
  border: 2px solid #ddd;
  border-radius: 8px;
  outline: none;
  transition: all 0.3s ease;
  background-color: white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.styled-input:focus {
  border-color: #007bff;
  box-shadow: 0 4px 8px rgba(0, 123, 255, 0.2);
}

.styled-input::placeholder {
  color: #aaa;
  transition: color 0.3s ease;
}

.styled-input:focus::placeholder {
  color: transparent;
}

.container {
  margin-left: auto;
  margin-right: auto;
  padding-left: 10px;
  padding-right: 10px;
  display: block;
  background: linear-gradient(135deg, #ff7e5f, #feb47b);
}

h2 {
  font-size: 26px;
  margin: 20px 0;
  text-align: center;

  small {
    font-size: 0.5em;
  }
}

.responsive-table-wrap {
  padding: 20px;
  height: calc(100vh - 150px);
  overflow-y: auto;
  display: flex;
  justify-content: center;
}

.responsive-table {
  width: 1000px;
  padding-left: 0px;

  li {
    border-radius: 3px;
    padding: 25px 30px;
    display: flex;
    justify-content: space-between;
    margin-bottom: 25px;
  }

  .table-header {
    background-color: #95a5a6;
    font-size: 14px;
    text-transform: uppercase;
    letter-spacing: 0.03em;
  }

  .table-row {
    background-color: #ffffff;
    box-shadow: 0px 0px 9px 0px rgba(0, 0, 0, 0.1);
  }

  .col-1 {
    flex-basis: 20%;
  }

  .col-2 {
    width: 172px;
  }

  .col-3 {
    flex-basis: 60%;
  }

  .viewColumn {
    width: 172px;
    display: flex;

    > div {
      min-width: 100px;
    }

    .view {
      margin-left: 25px;
      position: relative;
      top: -4px;
      cursor: pointer;
    }
  }

  @media all and (max-width: 767px) {
    .table-header {
      display: none;
    }

    .table-row {
    }

    li {
      display: block;
    }

    .col {
      flex-basis: 100%;
    }

    .col {
      display: flex;
      padding: 10px 0;

      &:before {
        color: #6c7a89;
        padding-right: 10px;
        content: attr(data-label);
        flex-basis: 50%;
        text-align: right;
      }
    }
  }
}

.custom-toast-class {
  width: fit-content;
  white-space: normal;
  height: 110px !important;
}
</style>

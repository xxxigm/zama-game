export const CHAIN_ID = "0xaa36a7";

export const CHAIN_NAME = "Ethereum Sepolia";

export const SYMBOL = "ETH";

export const NATIVE_CURRENCY = {
  name: CHAIN_NAME,
  symbol: SYMBOL,
  decimals: 18,
};

export const RPC_URLS = ["https://sepolia.infura.io"];

export const NETWORK_INFO = {
  chainId: CHAIN_ID,
  chainName: CHAIN_NAME,
  nativeCurrency: NATIVE_CURRENCY,
  rpcUrls: RPC_URLS,
};

export const PRIVATE_KEY_WALLET = import.meta.env.VITE_PRIVATE_KEY;
export const CONTRACT_ADDRESS = import.meta.env.VITE_CONTRACT_ADDRESS;
export const SEPOLIA_RPC_URL = import.meta.env.VITE_SEPOLIA_RPC_URL;

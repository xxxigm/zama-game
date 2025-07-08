import { NETWORK_INFO, CHAIN_ID } from '../constants/index.js'

export function isEthereum() {
  if (window.ethereum) {
    return true;
  }
  return false;
}

export function getChainID() {
  if (isEthereum()) {
    return window.ethereum.request({ method: 'eth_chainId' });
  }
  return 0;
}

export async function handleConnection(accounts) {
  if (accounts.length === 0) {
    const fetchedAccounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    return fetchedAccounts;
  }

  return accounts;
}

export async function requestAccount() {
  let currentAccount = 0x0;
  if (isEthereum() && getChainID() !== 0) {
    let accounts = await window.ethereum.request({ method: 'eth_accounts' });
    accounts = await handleConnection(accounts);
    currentAccount = accounts[0];
  }
  return currentAccount;
}

export async function requestBalance() {
  const currentAccount = await requestAccount()
  let currentBalance = 0;
  if (isEthereum()) {
    try {
      currentBalance = await window.ethereum.request({
        method: 'eth_getBalance',
        params: [currentAccount, 'latest'],
      });

      currentBalance = parseInt(currentBalance, 16) / 1e18;

      return { currentBalance, err: false };
    } catch (err) {
      return { currentBalance, err: true };
    }
  }
  return { currentBalance, err: true };
}

export async function switchNetwork() {
    const networkInfo = NETWORK_INFO;

    try {
      await ethereum.request({ method: 'wallet_addEthereumChain', params: [networkInfo] });
      await ethereum.request({ method: "wallet_switchEthereumChain", params: [{ chainId: CHAIN_ID }] });

      return true;

    } catch (error) {
      console.error('Error adding network to MetaMask:', error);

      return false;
    }
  }

export async function checkNetWork() {
    if (isEthereum() && window.ethereum.isMetaMask) {
        try {
          const chainId = await getChainID();
  
          if(chainId !== CHAIN_ID) {
            await ethereum.request({
              method: "wallet_switchEthereumChain",
              params: [{ chainId: CHAIN_ID }]
            });

          } else {
            switchNetwork()
          }

          await ethereum.request({
            method: 'wallet_requestPermissions',
            params: [{ eth_accounts: {} }],
          });
      
          await ethereum.request({ method: 'eth_requestAccounts' });
  
        } catch (error) {
            switchNetwork()
        }
      } else {
        console.error("MetaMask extension not detected");
      }
  }

# 🎮 FHE Aviator

> **Fly it to the end — with full privacy!**

**FHE Aviator** is a Web3 mini-game built on top of the [FHEVM](https://docs.zama.ai/). Players control a small plane, collect **blue pills** (good points), and avoid **red pills** (bad points). Player progress is stored and processed entirely in encrypted form to ensure maximum privacy.

## 🚀 Key Features

- ✅ **Encrypted user levels** with FHE — no one (not even the smart contract) can read your actual score without proper decryption.
- 🛡️ **On-demand decryption** — users can request to decrypt their own score after playing.
- 📊 **Leaderboard** displaying encrypted levels (decrypted values only if permissioned).
- 🔒 **High security** — decryption is verified via signature checks.

## 🌐 Play the Game

👉 [Click here to play FHE Aviator](https://xxxigm-zama-game.netlify.app)

> *Grab the blue pills, avoid the red ones.*

## 📄 Smart Contract

The smart contract is written in Solidity (`^0.8.24`) and leverages `@fhevm/solidity`. It provides the following features:

- Stores encrypted player levels (`euint64`) per address.
- Only updates levels if the new level is greater than the previous one.
- Supports secure decryption requests using `FHE.requestDecryption` and handles decryption callbacks.
- Maps decryption statuses and request IDs to users for accurate history tracking.

## 🧩 Frontend Integration

The frontend is built with standard HTML5 and JavaScript. It is integrated with the [`@zama-fhe/relayer-sdk`](https://www.npmjs.com/package/@zama-fhe/relayer-sdk), which is used to:

- Initialize FHEVM relayer client-side.
- Generate encrypted scores and proofs to be sent to the smart contract.
- Manage decryption requests securely from the user's browser.

## 🧪 Tech Stack

- **Frontend**: HTML5 Canvas, JavaScript, `@zama-fhe/relayer-sdk`
- **Smart Contract**: Solidity `^0.8.24`
- **Encryption Layer**: [FHEVM by Zama](https://docs.zama.ai/)
- **Blockchain**: Sepolia Testnet

---

Made with 🔐 by privacy-focused devs.

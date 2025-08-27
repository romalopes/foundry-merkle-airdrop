import { useState } from "react";
import { ethers } from "ethers";
import { contractAddress, contractABI } from "./contract";

function TokenApp() {
  const [balance, setBalance] = useState(null);

  async function getBalance() {
    if (!window.ethereum) return;

    const provider = new ethers.BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    const contract = new ethers.Contract(contractAddress, contractABI, signer);

    const address = await signer.getAddress();
    const bal = await contract.balanceOf(address);
    setBalance(ethers.formatEther(bal));
  }

  return (
    <div>
      <button onClick={getBalance}>Ver Saldo</button>
      {balance && <p>Saldo: {balance} Tokens</p>}
    </div>
  );
}

export default TokenApp;

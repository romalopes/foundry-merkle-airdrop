// import logo from './logo.svg';
// import './App.css';

// function App() {
//   return (
//     <div className="App">
//       <header className="App-header">
//         <img src={logo} className="App-logo" alt="logo" />
//         <p>
//           Edit <code>src/App.js</code> and save to reload.
//         </p>
//         <a
//           className="App-link"
//           href="https://reactjs.org"
//           target="_blank"
//           rel="noopener noreferrer"
//         >
//           Learn React
//         </a>
//       </header>
//     </div>
//   );
// }

// export default App;

import { useState } from "react";
import { ethers } from "ethers";

function App() {
  const [account, setAccount] = useState(null);

  // Conectar carteira
  async function connectWallet() {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        setAccount(accounts[0]);
      } catch (error) {
        console.error(error);
      }
    } else {
      alert("MetaMask não encontrado. Instale a extensão!");
    }
  }

  return (
    <div>
      <h1>Minha DApp</h1>
      {account ? (
        <p>Conectado: {account}</p>
      ) : (
        <button onClick={connectWallet}>Conectar MetaMask</button>
      )}
    </div>
  );
}

export default App;

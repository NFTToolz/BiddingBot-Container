const { ethers } = require("ethers");
const axios = require("axios");

// Token contract addresses on Ethereum mainnet
const WETH_ADDRESS = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const BETH_ADDRESS = "0x0000000000A39bb272e79075ade125fd351887Ac"; // Blur ETH

// NFTTools configuration
const API_ENDPOINT = "https://nfttools.pro";
const API_KEY = "a4eae399-f135-4627-829a-18435bb631ae";

// Minimal ERC20 ABI for balanceOf
const ERC20_ABI = [
	"function balanceOf(address owner) view returns (uint256)",
	"function decimals() view returns (uint8)",
	"function symbol() view returns (string)",
];

async function makeRequest(address) {
	// Common headers for all requests
	const headers = {
		url: "https://ethereum.publicnode.com",
		"x-nft-api-key": API_KEY,
		"Content-Type": "application/json",
	};

	// ETH Balance Request
	const ethBalanceRequest = {
		jsonrpc: "2.0",
		method: "eth_getBalance",
		params: [address, "latest"],
		id: 1,
	};

	// WETH Balance Request
	const wethData = ethers.Interface.from(ERC20_ABI).encodeFunctionData(
		"balanceOf",
		[address]
	);
	const wethBalanceRequest = {
		jsonrpc: "2.0",
		method: "eth_call",
		params: [
			{
				to: WETH_ADDRESS,
				data: wethData,
			},
			"latest",
		],
		id: 2,
	};

	// BETH Balance Request
	const bethBalanceRequest = {
		jsonrpc: "2.0",
		method: "eth_call",
		params: [
			{
				to: BETH_ADDRESS,
				data: wethData,
			},
			"latest",
		],
		id: 3,
	};

	try {
		const responses = await Promise.all([
			axios.post(API_ENDPOINT, ethBalanceRequest, { headers }),
			axios.post(API_ENDPOINT, wethBalanceRequest, { headers }),
			axios.post(API_ENDPOINT, bethBalanceRequest, { headers }),
		]);

		return {
			eth: responses[0].data.result,
			weth: responses[1].data.result,
			beth: responses[2].data.result,
		};
	} catch (error) {
		console.error("Request error:", error.message);
		if (error.response) {
			console.error("Response data:", error.response.data);
			console.error("Response status:", error.response.status);
		}
		throw error;
	}
}

async function getBalances(walletAddress) {
	try {
		if (!ethers.isAddress(walletAddress)) {
			throw new Error("Invalid Ethereum address");
		}

		const balances = await makeRequest(walletAddress);

		// Convert balances from hex to readable format
		const ethBalance = ethers.formatEther(balances.eth);
		const wethBalance = ethers.formatEther(balances.weth);
		const bethBalance = ethers.formatEther(balances.beth);

		// Display balances
		console.log(`\nETH Balance: ${ethBalance} ETH`);
		console.log(`WETH Balance: ${wethBalance} WETH`);
		console.log(`Blur ETH Balance: ${bethBalance} BETH`);

		// Calculate total
		const totalInEth =
			parseFloat(ethBalance) +
			parseFloat(wethBalance) +
			parseFloat(bethBalance);

		console.log(`\nTotal ETH Value: ${totalInEth.toFixed(4)} ETH`);
	} catch (error) {
		console.error("Error:", error.message);
	}
}

// Check if wallet address is provided as command line argument
const walletAddress = process.argv[2];
if (!walletAddress) {
	console.log("Please provide a wallet address as argument:");
	console.log("node script.js 0x...");
} else {
	getBalances(walletAddress);
}

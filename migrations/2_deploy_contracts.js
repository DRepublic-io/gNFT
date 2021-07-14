const GameNFTs = artifacts.require("GameNFTs.sol");
const Arrays = artifacts.require("../contracts/utils/Arrays.sol");
const GenericAttribute = artifacts.require("../contracts/attributes/GenericAttribute.sol");
const UpgradableAttribute = artifacts.require("../contracts/attributes/UpgradableAttribute.sol");
const TransferableAttribute = artifacts.require("../contracts/attributes/TransferableAttribute.sol");
const EvolutiveAttribute = artifacts.require("../contracts/attributes/EvolutiveAttribute.sol");

module.exports = async (deployer) => {
	let proxyRegistryAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";

	await deployer.deploy(GameNFTs, "gNFT", "OGN",
		"https://nfts-api.drepublic.io/api/nfts/{id}", proxyRegistryAddress, {gas: 5000000});

	// deploy nft attributes
	await deployer.deploy(Arrays);
	await deployer.link(Arrays, GenericAttribute);
	await deployer.deploy(GenericAttribute);
	await deployer.link(Arrays, UpgradableAttribute);
	await deployer.deploy(UpgradableAttribute);
	await deployer.link(Arrays, TransferableAttribute);
	await deployer.deploy(TransferableAttribute, GameNFTs.address);
	await deployer.link(Arrays, EvolutiveAttribute);
	await deployer.deploy(EvolutiveAttribute, GameNFTs.address);
};

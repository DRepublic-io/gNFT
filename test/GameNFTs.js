const truffleAssert = require('truffle-assertions');

const Arrays = artifacts.require("../contracts/utils/Arrays.sol");
const GameNFTs = artifacts.require("../contracts/GameNFTs.sol");
const GenericAttribute = artifacts.require("../contracts/attributes/GenericAttribute.sol");
const UpgradableAttribute = artifacts.require("../contracts/attributes/UpgradableAttribute.sol");
const TransferableAttribute = artifacts.require("../contracts/attributes/TransferableAttribute.sol");
const EvolutiveAttribute = artifacts.require("../contracts/attributes/EvolutiveAttribute.sol");

const toBN = web3.utils.toBN;

contract("GameNFTs", (accounts) => {
	const proxyAddress = "0xf57b2c51ded3a29e6891aba85459d600256cf317";
	const owner = accounts[0];
	const userA = accounts[1];
	const operator = accounts[2];
	const treasury = accounts[3];

	// NFTs
	const frostFlower = 10001;
	const ironSword = 10002;
	const crystal = 10003;
	const ironSwordB = 10004;

	// Attributes
	const frost = 20001;
	const attack = 20002;
	const prefix = 20003;
	const evolve = 20004;

	let myNFTs;
	let genericAttr;
	let upgradableAttr;
	let transferableAttr;
	let evolutiveAttr;

	before(async () => {
		myNFTs = await GameNFTs.new(
			"gNFT", "OGN",
			"https://nfts-api.drepublic.io/api/nfts/{id}",
			proxyAddress
		);

		GenericAttribute.link(Arrays);
		genericAttr = await GenericAttribute.new();

		UpgradableAttribute.link(Arrays);
		upgradableAttr = await UpgradableAttribute.new();

		TransferableAttribute.link(Arrays);
		transferableAttr = await TransferableAttribute.new(myNFTs.address);

		EvolutiveAttribute.link(Arrays);
		evolutiveAttr = await EvolutiveAttribute.new(myNFTs.address);
	});

	describe('1. attach frost attribute to iron sword', () => {
		it('create 1000 frost flower SFT（semi-fungible token）', async () => {
			const quantity = toBN(1000);
			await myNFTs.create(
				userA,
				frostFlower,
				quantity,
				"https://nfts-api.drepublic.io/api/nfts/{id}",
				"0x0",
				{from: owner}
			);

			const balanceUserA = await myNFTs.balanceOf(
				userA,
				frostFlower
			);
			assert.isOk(balanceUserA.eq(quantity));
		});

		it('create iron sword NFT', async () => {
			const quantity = toBN(1);
			await myNFTs.create(
				userA,
				ironSword,
				quantity,
				"https://nfts-api.drepublic.io/api/nfts/{id}",
				"0x0",
				{from: owner}
			);

			const balanceUserA = await myNFTs.balanceOf(
				userA,
				ironSword
			);
			assert.isOk(balanceUserA.eq(quantity));
		});

		it('create transferable frost attribute FT', async () => {
			await transferableAttr.create(
				frost,
				"attack",
				"attack attribute",
				18,
				{from: owner}
			);

			assert.equal(
				await transferableAttr.name(frost),
				'attack'
			);
		});

		it('consume 100 frost flower to attach frost attributes to the iron sword', async () => {
			await myNFTs.setApprovalForAll(
				operator,
				true,
				{from: userA}
			);

			const quantity = toBN(100);
			await myNFTs.safeTransferFrom(
				userA,
				treasury,
				frostFlower,
				quantity,
				"0x",
				{from: operator}
			);

			const balanceUserA = await myNFTs.balanceOf(
				userA,
				frostFlower
			);

			assert.isOk(balanceUserA.eq(toBN(900)));

			await transferableAttr.attach(
				ironSword,
				frost,
				100,
				{from: owner}
			);

			assert.equal(
				await transferableAttr.attributeValue(ironSword, frost),
				100
			);
		});
	});

	describe('2. modify the attack power of the iron sword', () => {
		it('create 1000 crystal SFT（semi-fungible token）', async () => {
			const quantity = toBN(1000);
			await myNFTs.create(
				userA,
				crystal,
				quantity,
				"https://nfts-api.drepublic.io/api/nfts/{id}",
				"0x0",
				{from: owner}
			);

			const balanceUserA = await myNFTs.balanceOf(
				userA,
				crystal
			);
			assert.isOk(balanceUserA.eq(quantity));
		});

		it('create generic attack power attribute FT', async () => {
			await genericAttr.create(
				attack,
				"attack",
				"attack power attribute",
				18,
				{from: owner}
			);

			assert.equal(
				await genericAttr.name(attack),
				'attack'
			);
		});

		it('attach attack power attributes to the iron sword, initial attack power is 100', async () => {
			await genericAttr.attach(
				ironSword,
				attack,
				100,
				{from: owner}
			);

			assert.equal(
				await genericAttr.attributeValue(ironSword, attack),
				100
			);
		});

		it('consume 100 crystal to increase 10 points attack power attributes to the iron sword', async () => {
			await myNFTs.setApprovalForAll(
				operator,
				true,
				{from: userA}
			);

			const quantity = toBN(100);
			await myNFTs.safeTransferFrom(
				userA,
				treasury,
				crystal,
				quantity,
				"0x",
				{from: operator}
			);

			const balanceUserA = await myNFTs.balanceOf(
				userA,
				crystal
			);

			assert.isOk(balanceUserA.eq(toBN(900)));

			await genericAttr.increase(
				ironSword,
				attack,
				10,
				{from: owner}
			);

			assert.equal(
				await genericAttr.attributeValue(ironSword, attack),
				110
			);
		});
	});

	describe('3. upgrade the iron sword level', () => {
		it('create upgradable level prefix attribute FT', async () => {
			await upgradableAttr.create(
				prefix,
				"prefix",
				"level prefix attribute",
				3,
				13,
				{from: owner}
			);

			assert.equal(
				await upgradableAttr.name(prefix),
				'prefix'
			);
		});

		it('attach level prefix attributes to the iron sword, initial level prefix is 1 (common)', async () => {
			await upgradableAttr.attach(
				ironSword,
				prefix,
				{from: owner}
			);
		});

		it('consume 100 crystal to upgrade iron sword to level 2 (superior)', async () => {
			await myNFTs.setApprovalForAll(
				operator,
				true,
				{from: userA}
			);

			const quantity = toBN(100);
			await myNFTs.safeTransferFrom(
				userA,
				treasury,
				crystal,
				quantity,
				"0x",
				{from: operator}
			);

			const balanceUserA = await myNFTs.balanceOf(
				userA,
				crystal
			);

			assert.isOk(balanceUserA.eq(toBN(800)));

			await upgradableAttr.upgradeLevel(
				ironSword,
				prefix,
				2,
				{from: owner}
			);
		});
	});

	describe('4. transfer iron sword attributes', () => {
		it('create iron sword B NFT', async () => {
			const quantity = toBN(1);
			await myNFTs.create(
				userA,
				ironSwordB,
				quantity,
				"https://nfts-api.drepublic.io/api/nfts/{id}",
				"0x0",
				{from: owner}
			);

			const balanceUserA = await myNFTs.balanceOf(
				userA,
				ironSwordB
			);
			assert.isOk(balanceUserA.eq(quantity));
		});

		it('transfer 100 crystal and burn iron sword A', async () => {
			await myNFTs.setApprovalForAll(
				operator,
				true,
				{from: userA}
			);

			const quantity = toBN(100);
			await myNFTs.safeTransferFrom(
				userA,
				treasury,
				crystal,
				quantity,
				"0x",
				{from: operator}
			);

			const balanceUserA = await myNFTs.balanceOf(
				userA,
				crystal
			);

			assert.isOk(balanceUserA.eq(toBN(700)));

			await myNFTs.burn(
				ironSword,
				1,
				{from: userA}
			);

			const a = await myNFTs.balanceOf(
				userA,
				ironSword
			);
			assert.isOk(a.eq(toBN(0)));
		});

		it('transfer iron sword A frost attribute to iron sword B', async () => {
			await transferableAttr.approve(
				ironSword,
				ironSwordB,
				frost,
				{from: owner}
			);

			await transferableAttr.transferFrom(
				ironSword,
				ironSwordB,
				frost,
				{from: owner}
			);

			assert.equal(
				await transferableAttr.attributeValue(ironSwordB, frost),
				100
			);
		});
	});

	describe('5. the iron sword B evolves over time', () => {
		it('create evolutive attribute FT', async () => {
			await evolutiveAttr.create(
				evolve,
				"evolve",
				"evolve attribute",
				2,
				[80, 60],
				[0, 0],
				{from: owner}
			);

			assert.equal(
				await evolutiveAttr.name(evolve),
				'evolve'
			);
		});

		it('attach evolutive attributes to the iron sword B', async () => {
			await evolutiveAttr.attach(
				ironSwordB,
				evolve,
				{from: owner}
			);
		});

		it('try iron sword B evolution after some time interval', async () => {
			await evolutiveAttr.evolutive(
				ironSwordB,
				evolve,
				2,
				{from: owner}
			);
		});
	});
});

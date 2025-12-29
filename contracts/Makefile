-include .env

.PHONY: deploy-mock-sepolia deploy-diamond-sepolia deploy-anvil

# Загружаем переменные из .env
export

# Деплой MockERC20 в Sepolia
deploy-mock-sepolia:
	forge script script/DeployMockERC20.s.sol:DeployMockERC20 \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--verify

# Деплой Diamond в Sepolia
deploy-diamond-sepolia:
	forge script script/DeployDiamond.s.sol:DeployDiamond \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast \
		--verify

# Деплой всё в локальный Anvil
deploy-anvil:
	forge script script/DeployMockERC20.s.sol:DeployMockERC20 \
		--rpc-url http://127.0.0.1:8545 \
		--private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
		--broadcast


# Апгрейд AccessFacet в Sepolia
upgrade-access-sepolia:
	forge script script/UpgradeAccessFacet.s.sol:UpgradeAccessFacet \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast
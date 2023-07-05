-include .env

#VS-CODE-HACK
#ctrl + p /// type ```>view: toggle word wrap`` -- to avoid stretching lines


#now running `make depsec` will substitute `forge script ........s.sol`
depsec:; forge script script/DeployFundMe.s.sol

#cmd: /next line tab
#only_running_``make deploy-sepolia``_does-the_below_job_+
deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(alsepoly) --private-key $(personal_key) --broadcast --verify --etherscan-api-key $(etherscan_api) -vvvv

# {{ deployed at 
# https://sepolia.etherscan.io/address/0x0a857ce19226ba094e172e5f95c9d807b622b45c 
# }}

#Note: ```--verify --etherscan-api-key $(etherscan_api)```
#this automatically verifies our contract without doing any manual job

#compile-shorcut
cc :; forge compile --force
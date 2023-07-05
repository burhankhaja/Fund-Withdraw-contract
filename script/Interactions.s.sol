//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

/**

WATCH AGAIN:   (status: skipped)
https://www.youtube.com/watch?v=5u02NBfV4PY&list=PL2-Nvp2Kn0FPH2xU3IbKrrkae-VVXs1vk&index=100

 */
contract FundFundMe is Script {
    function run() external {}
}

contract WithdrawFundMe is Script {
    function run() external {}
}

/**
**REQUIREMENTS
 - foundry-devops
    **githublink: https://github.com/Cyfrin/foundry-devops
    **command:
        forge install Cyfrin/foundry-devops --no-commit

    **import:
        import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    uint256 constant SEND_VALUE = 0.1 ether; //MAGIC-NUMBER-FOR-SENDING-VALUE
    uint256 constant STARTING_BALANCE = 10 ether; //money for USER => VM.DEAL
    address USER = makeAddr("user"); //FOUNDRY-CHEATCODE => Creates New user addrs
    uint256 constant GAS_PRICE = 1;

    //deployer ----- speculation

    // deployFundMe.fundMe();
    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); //foundry-cheatcode-to-give-balance-to-addr
    }

    function testGetVersion() public view {
        console.log(fundMe.getVersion());
    }

    function testFundNotEnoughEth() public {
        vm.expectRevert();
        //reverts test if function doen't revert.... works fine targetfunction reverts
        fundMe.fund();
    }

    function testFundUpdatesDS() public {
        vm.prank(USER); //FOUDRY-CHEATCODE => next transaction ties with USER
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    //REMEMBER EACH TIME YOU RUN TEST, IT RESETS AND STARTS FROM SETUP && THEN TEST
    // FUNCTION ....EVEN IF YOU JUST CALLED IT BEFORE

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testAddsFundersToArrayOfFunders() public funded {
        // vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();
        assertEq(USER, fundMe.getFunders(0));
    }

    function testOnlyOwnerCanWithdraw() public funded {
        // REPLACED WITH MODIFIER ``FUNDED``
        // vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testCanOwnerWithdraw() public {
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
    }

    function testWithdrawWithOwner() public {
        //ARRANGE
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //ACT
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //ASSERT
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        ); //BECAUSE IF A IS OWNER B IS CONTRACT
        // A HAS 10 RS IN WALLET
        // B HAS 10K
        // SO WHEN A WITHDRAWS FROM B
        // A HAS 10 + 10K
    }

    //check `forge snapshot ` && see difference between
    //above and below test in gas costs
    //above test calls fundMe.withdraw()
    //below test calls fundMe.withdrawCheaper()
    ///ERROOOOOOR => I GETTING OPPOSITE RESULTS *********/.\\\...///..\\\******
    function testWithdrawWithOwnerCheaper() public {
        //ARRANGE
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //ACT
        vm.prank(fundMe.getOwner());
        fundMe.withdrawCheaper();

        //ASSERT
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        ); //BECAUSE IF A IS OWNER B IS CONTRACT
        // A HAS 10 RS IN WALLET
        // B HAS 10K
        // SO WHEN A WITHDRAWS FROM B
        // A HAS 10 + 10K
    }

    // BELOW TEST:::::
    //FUND WITH MULTIPLE ADDRESS
    //THEN WITHDRAWS WITH OWNER

    function testWithdrawFromMultiFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10; //uint160, because compactable with address(n)
        uint160 startingFunderIndex = 1; //sometimes address(0) reverts ..that is why we started from 1
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank(newuser)
            //vm.deal(newuser)
            //forge standard => `hoax` cheat does both
            //it will prank and deal together
            hoax(address(i), SEND_VALUE); //address(i=0,1,2----) //0x00-0x001-0x02 etc
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank(); //pranks everything in between

        //ASSERT
        assertEq(address(fundMe).balance, 0); //because all money is withdrawn
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            fundMe.getOwner().balance
        );
    }

    //LETS SIMULATE GAS PRICES ON ANVIL
    /* 
    ```
        forge snapshot --match-test testAnyFunction    
    ```    
        => this will create a .gas-snapshot file for that function along with
        details about the amount of gas it willl use
        => next iteration of same over-rides contents

    ```
        forge snapshot 

    ```
    => will take snapshot of all gas cost of all functions
    */
    function testSimulatedGas() public {
        uint256 gasStart = gasleft(); //gasleft() - solidity func to calc gas left
        vm.txGasPrice(GAS_PRICE); //SETS GAS PRICE // FOUNDRY CHEATCODE
        uint256 gasEnd = gasleft();
        uint256 gasCost = (gasStart - gasEnd) * tx.gasprice; //tx.gasprice - foundry cheatcode
        console.log("gasStart: ", gasStart);
        console.log("gasEnd: ", gasEnd);
        console.log("gasCost: ", gasCost);
        console.log("tx.gasprice: ", tx.gasprice);
    }
}

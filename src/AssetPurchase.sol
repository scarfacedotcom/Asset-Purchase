// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "lib/chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol";

/**
 * @author Scar Face dot ETH
 * @title Market Contract
 * @notice This contract allows users to list and purchase NFTs with DAI.
 */

contract Market {
    using SafeCast for int256; // use SafeCast library to convert int256 to uint

    // declare a struct to store the details of an item
    struct ItemDetails {
        uint tokenID; // id of the NFT token
        address seller; // address of the seller
        bool status; // status of the item
    }

    address owner; // address of the contract owner
    IERC721 nftAddress; // address of the ERC721 token contract
    IERC20 DaiContract; // address of the DAI token contract
    AggregatorV3Interface internal ETHusdpriceFeed; // Chainlink Price Feed for ETH/USD
    AggregatorV3Interface internal DAIusdpriceFeed; // Chainlink Price Feed for DAI/USD
    mapping(uint => ItemDetails) itemInfo; // mapping to store the details of all listed items

    // constructor function to initialize the contract
    constructor(address _nftAddress) {
        nftAddress = IERC721(_nftAddress); // set the address of the ERC721 token contract
        DaiContract = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F); // set the address of the DAI token contract
        owner = msg.sender; // set the address of the contract owner

        // set the addresses of the Chainlink Price Feed contracts for ETH/USD and DAI/USD
        DAIusdpriceFeed = AggregatorV3Interface(
            0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9
        );
        ETHusdpriceFeed = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
    }

    // function to list an item for sale
    function listItem(uint _tokenitemID) public {
        ItemDetails storage _a = itemInfo[_tokenitemID]; // get the details of the item from the mapping
        _a.tokenID = _tokenitemID; // set the id of the NFT token
        _a.seller = msg.sender; // set the address of the seller
        _a.status = true; // set the status of the item to true, which means it is for sale
    }

    // function to purchase an item
    function purchaseItem(uint _tokenID) public payable {
        uint balance = DaiContract.balanceOf(msg.sender); // get the balance of the DAI token of the buyer
        require(itemInfo[_tokenID].status == true, "not for sale"); // check if the item is for sale
        require(balance >= 3.5 ether); // check if the buyer has enough balance to make the purchase
        uint ethusdCurrentPrice = getETHUSDPrice(); // get the current ETH/USD price from the Chainlink Price Feed
        uint usdtusdCurrentPrice = getDAIUSDPrice(); // get the current DAI/USD price from the Chainlink Price Feed
        uint _amountINUSdt = (3.5 ether * ethusdCurrentPrice) /
            usdtusdCurrentPrice;
        DaiContract.transferFrom(msg.sender, address(this), _amountINUSdt);
        nftAddress.transferFrom(owner, msg.sender, _tokenID);
    }

    function getDAIUSDPrice() public view returns (uint) {
        (, int price, , , ) = DAIusdpriceFeed.latestRoundData();
        return price.toUint256();
    }

    function getETHUSDPrice() public view returns (uint) {
        (, int price, , , ) = ETHusdpriceFeed.latestRoundData();
        return price.toUint256();
    }
}

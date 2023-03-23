// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/AssetPurchase.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../contracts/AssetPurchase.sol";

contract AssetPurchaseTest is Test {
    using Addresses for address;
    using Expect for uint256;

    AssetPurchase public assetPurchase;
    AggregatorV3Interface public priceFeed;

    function setUp() public {
        // Deploy a new instance of AssetPurchase
        address priceFeedAddress = 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e; 
        
        assetPurchase = new AssetPurchase(priceFeedAddress);
        priceFeed = AggregatorV3Interface(priceFeedAddress);

        // Set the asset price to 3.5 ether
        assetPurchase.assetPrice().set(3.5 ether);
    }

    function testPurchaseAsset() public {
        // Get the latest price from the Price Feed
        int256 price = assetPurchase.getLastestPrice();
        price.expect().to.be.above(0);

        // Calculate the expected value in USDT for the asset
        uint256 usdtValue = uint256(price) * uint256(assetPurchase.assetPrice()) / 10 ** 18;

        // Call purchaseAsset with enough Ether to buy the asset
        uint256 ethValue = usdtValue * 10 ** 10; // Multiply by 10^10 because 1 USDT = 10^10 Wei
        expect(() => assetPurchase.purchaseAsset{ value: ethValue }()).to.change(() => assetPurchase.purchased()).from(false).to(true);
    }
}

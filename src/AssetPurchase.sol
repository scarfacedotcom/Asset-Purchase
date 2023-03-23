// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// Import interfaces
import "../interfaces/AggregatorV3Interface.sol";
import "./IERC20.sol";

contract AssetPurchase {
    // Declare variables
    address payable public owner;

    uint256 public price;

    uint256 public assetPrice = 3.5 ether;

    bool public purchased;

    address public priceFeedAddress;

    AggregatorV3Interface public priceFeed;

    // Constructor function
    constructor(address _priceFeedAddress) {
        // Set the price feed address
        priceFeedAddress = _priceFeedAddress;

        // Create a new price feed interface
        priceFeed = AggregatorV3Interface(priceFeedAddress);

        // Set purchased to false
        purchased = false;

        // priceFeedAddress = 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e;
    }

    // Function to get the latest price
    function getLastestPrice() public view returns (int256) {
        // Get the latest round data from the price feed
        (, int256 priceOfToken, , , ) = priceFeed.latestRoundData();

        // Check if the price is greater than 0
        require(priceOfToken > 0, "Network error");

        // Return the price of the token
        return priceOfToken;
    }

    // Function to purchase the asset
    function purchaseAsset() public payable {
        // Check if the asset has already been purchased
        require(!purchased, "Item sold out");

        // Get the latest price
        price = uint256(getLastestPrice());

        // Calculate the value of the asset in USDT
        uint256 usdtValue = price * assetPrice / 10 ** 18;

        // Check if the user has sent enough funds to purchase the asset
        require(msg.value >= usdtValue, "Insufficient funds");

        // Transfer the funds to the owner
        owner.transfer(msg.value);

        // Set purchased to true
        purchased = true;
    }
}


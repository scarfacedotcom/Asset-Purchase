// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "./IERC20.sol";

contract AssetPurchase {
    
    address public owner;
    uint256 public price;
    uint256 public assetPrice = 3.5 ether;
    bool public purchased;
    address public priceFeedAddress;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeedAddress) {
        priceFeedAddress = _priceFeedAddress;

        priceFeed = AggregatorV3Interface(
            priceFeedAddress
        );
        purchased = false;

        // priceFeedAddress = 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e;
    }

    // Returns latest price
    function getLastestPrice() public view returns (int256) {
        (, int256 priceOfToken, , , ) = priceFeed.lastRoundData();
        require(priceOfToken > 0, "Network error");
    }

    function purchaseAsset() public payable {
        require(!purchased, "item sold out");
        price = getLastestPrice();
        uint256 usdtValue = price * assetPrice / 10 ** 18;
        require(msg.value >= usdtValue, "Yoooo, you ate broke");
        owner.transfer(msg.value);
        purchased = true;
    }
}


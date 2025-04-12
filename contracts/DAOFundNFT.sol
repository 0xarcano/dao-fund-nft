// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DAOFundNFT is ERC721, ERC721Enumerable {
    using Counters for Counters.Counter;

    Counters.Counter private _idCounter;
    uint public maxSupply;

    uint256 public priceUSD;
    uint256 public donationPercentage; // in basis points (1% = 100)
    address public daoTreasury;
    
    IERC20 public usdcToken;
    IERC20 public usdtToken;
    IERC20 public daiToken;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _priceUSD,
        address _daoTreasury,
        uint256 _donationPercentage,
        address _usdcAddress,
        address _usdtAddress,
        address _daiAddress
    ) ERC721(_name, _symbol) {
        require(_donationPercentage <= 10000, "Donation percentage too high");
        maxSupply = _maxSupply;
        priceUSD = _priceUSD;
        daoTreasury = _daoTreasury;
        donationPercentage = _donationPercentage;
        usdcToken = IERC20(_usdcAddress);
        usdtToken = IERC20(_usdtAddress);
        daiToken = IERC20(_daiAddress);
    }

    function calculateTokenAmount() internal view returns (uint256) {
        return priceUSD * 1e18;
    }

    function calculateDonation(uint256 amount) internal view returns (uint256) {
        return (amount * donationPercentage) / 10000;
    }

    function mint(uint8 paymentMethod) external {
        uint256 current = _idCounter.current();
        require(current < maxSupply, "No CypherHumas left :(");
        
        uint256 amount = calculateTokenAmount();
        uint256 donation = calculateDonation(amount);
        IERC20 token;

        if (paymentMethod == 0) { // USDC
            token = usdcToken;
        } else if (paymentMethod == 1) { // USDT
            token = usdtToken;
        } else if (paymentMethod == 2) { // DAI
            token = daiToken;
        } else {
            revert("Invalid payment method");
        }

        require(token.transferFrom(msg.sender, address(this), amount - donation), "Token transfer failed");
        require(token.transferFrom(msg.sender, daoTreasury, donation), "Donation transfer failed");

        _safeMint(msg.sender, current);
        _idCounter.increment();
    }

    // Override required
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(_from, _to, _tokenId);
    }

    function supportsInterface(bytes4 _interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }
}
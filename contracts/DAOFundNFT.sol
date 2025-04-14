// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Base64.sol";
import "./DAOFundDNA.sol";

contract DAOFundNFT is ERC721, ERC721Enumerable, DAOFundDNA {
    using Counters for Counters.Counter;

    address private immutable _deployer;
    Counters.Counter private _idCounter;
    uint public maxSupply;
    string private description;
    mapping (uint256 => uint256) public tokenDNA;

    uint256 public priceUSD;
    uint256 public donationPercentage; // in percentage (1% = 1)
    address public daoTreasury;
    
    IERC20 public usdcToken;
    IERC20 public usdtToken;
    IERC20 public daiToken;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _description,
        uint256 _maxSupply,
        uint256 _priceUSD,
        address _daoTreasury,
        uint256 _donationPercentage,
        address _usdcAddress,
        address _usdtAddress,
        address _daiAddress
    ) ERC721(_name, _symbol) {
        require(_donationPercentage <= 100, "Donation percentage too high");
        _deployer = msg.sender;
        description = _description;
        maxSupply = _maxSupply;
        priceUSD = _priceUSD;
        daoTreasury = _daoTreasury;
        donationPercentage = _donationPercentage;
        usdcToken = IERC20(_usdcAddress);
        usdtToken = IERC20(_usdtAddress);
        daiToken = IERC20(_daiAddress);
    }

    // This pseudo-random function is deterministic and should not be used for projects
    // that require true randomness. YOU SHOULD IMPLEMENT YOUR OWN RANDOMNESS FOR PRODUCTION
    // FOR PROJECTS THAT NEED TO RELY IN TRUE RANDOMNESS.
    function deterministicPseudoRandomDNA(
        uint256 _tokenId,
        address _minter
    ) public pure returns (uint256) {
            require(_tokenId > 0, "Token ID must be greater than 0");
            require(_minter != address(0), "Minter address cannot be zero");
            uint256 combindedParams = _tokenId + uint256(uint160(_minter));
            bytes memory encondedParams = abi.encodePacked(combindedParams);
            bytes32 hasedParams = keccak256(encondedParams);

            return uint256(hasedParams);
    }

    function calculateTokenAmount() internal view returns (uint256) {
        return priceUSD * 1e6;
    }

    function calculateDonation(uint256 amount) internal view returns (uint256) {
        return (amount * donationPercentage) / 100;
    }

    function mint(uint8 paymentMethod) public {
        uint256 current = _idCounter.current();
        require(current < maxSupply, string(abi.encodePacked("No ", name(), " left :(")));
        
        uint256 amount = calculateTokenAmount();
        uint256 donation = calculateDonation(amount);
        uint256 totalAmount = amount;
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

        token.approve(address(this), totalAmount);
        
        require(token.transferFrom(msg.sender, _deployer , amount - donation), "Token transfer failed");
        require(token.transferFrom(msg.sender, daoTreasury, donation), "Donation transfer failed");

        tokenDNA[current] = deterministicPseudoRandomDNA(current, msg.sender);
        _safeMint(msg.sender, current);
        _idCounter.increment();
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://avataaars.io/";
    }

function _paramsURI(uint256 _dna) internal view returns (string memory) {
    string memory params;

    {
        params = string(
            abi.encodePacked(
                "accessoriesType=",
                getAccessoriesType(_dna),
                "&clotheColor=",
                getClotheColor(_dna),
                "&clotheType=",
                getClotheType(_dna),
                "&eyeType=",
                getEyeType(_dna),
                "&eyebrowType=",
                getEyeBrowType(_dna),
                "&facialHairColor=",
                getFacialHairColor(_dna),
                "&facialHairType=",
                getFacialHairType(_dna),
                "&hairColor=",
                getHairColor(_dna),
                "&hatColor=",
                getHatColor(_dna),
                "&graphicType=",
                getGraphicType(_dna),
                "&mouthType=",
                getMouthType(_dna),
                "&skinColor=",
                getSkinColor(_dna)
            )
        );
    }

    return string(abi.encodePacked(params, "&topType=", getTopType(_dna)));
}  

    function imageByDNA(uint256 _dna) public view returns (string memory) {
        string memory params = _paramsURI(_dna);
        string memory baseURI = _baseURI();
        return string(abi.encodePacked(baseURI, "?", params));
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        require(_exists(_tokenId), "Token does not exist");
        string memory jsonURI =  Base64.encode(abi.encodePacked(
            '{ "name": "',
            name(),
            ' #',
            _tokenId,
            '", "description": "',
            description,
            '", "image": "'
            '// TODO: Calculate image URL', 
            '"}'
        ));

        return string(abi.encodePacked(
            'data:application/json;base64,',
            jsonURI
        ));
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
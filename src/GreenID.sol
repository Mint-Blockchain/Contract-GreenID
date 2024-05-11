// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract GreenID is Initializable, ERC721Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
    using Strings for uint256;

    mapping(uint256 tokenId => bool) public claimedTokens;
    event TokenClaimed(address indexed owner, uint256 tokenId);

    string private _defaultURI;
    string private _dynamicURI;

    struct MintParam {
        address to;
        uint256 tokenId;
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) initializer public {
        __ERC721_init("GreenID", "GID");
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    function mint(address to, uint256 tokenId) public onlyOwner {
        require(balanceOf(to) == 0, "GreenID: one address can only own one token");
        _mint(to, tokenId);
    }

    function mintBatch(MintParam[] calldata params) public onlyOwner {
        for (uint256 i = 0; i < params.length; ) {
            mint(params[i].to, params[i].tokenId);
            unchecked {
                ++i;
            }
        }
    }

    function claim(uint256 tokenId) external {
        address owner = _requireOwned(tokenId);
        require(msg.sender == owner, "GreenID: incorrect token owner");
        require(!claimedTokens[tokenId], "GreenID: token has already been claimed");

        claimedTokens[tokenId] = true;
        emit TokenClaimed(owner, tokenId);
    }

    function setDefaultURI(string calldata uri) public onlyOwner {
        _defaultURI = uri;
    }

    function setDynamicURI(string calldata uri) public onlyOwner {
        _dynamicURI = uri;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        return claimedTokens[tokenId] ? string.concat(_dynamicURI, tokenId.toString()) : _defaultURI;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function transferFrom(address from, address to, uint256 tokenId) public override  {
        require(msg.sender == address(0), "GreenID: Soul Bound Token");
        super.transferFrom(from, to, tokenId);
    }

}
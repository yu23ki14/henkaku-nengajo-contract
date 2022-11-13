// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./MintManager.sol";
import "./InteractHenkakuToken.sol";

contract Nengajo is ERC1155, ERC1155Supply, ERC1155URIStorage, MintManager, InteractHenakuToken {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string public name;
    string public symbol;

    mapping(uint256 => uint256) private maxSupply;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _open_blockTimestamp,
        uint256 _close_blockTimestamp,
        address _henkakuTokenV2,
        address _henkakuPoolWallet
    ) ERC1155("") MintManager(_open_blockTimestamp, _close_blockTimestamp) InteractHenakuToken(_henkakuTokenV2, _henkakuPoolWallet) {
        name = _name;
        symbol = _symbol;
    }

    function registerCreative(uint256 _maxSupply, string memory _metaDataURL)
        public
    {
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _setURI(tokenId, _metaDataURL);
        maxSupply[tokenId] = _maxSupply;
    }

    function mint(uint256 _tokenId) public {
        require(
            (block.timestamp > open_blockTimestamp &&
                close_blockTimestamp > block.timestamp) || mintable,
            "not minting time and not mintable"
        );
        uint256 currentSupply = totalSupply(_tokenId);
        require(maxSupply[_tokenId] > currentSupply, "not available");
        require(balanceOf(msg.sender, _tokenId) == 0, "you already have this nengajo");
        _mint(msg.sender, _tokenId, 1, "");
    }

    function uri(uint256 _tokenId)
        public
        view
        override(ERC1155, ERC1155URIStorage)
        returns (string memory)
    {
        return ERC1155URIStorage.uri(_tokenId);
    }

    function _beforeTokenTransfer(
        address _operator,
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) internal virtual override(ERC1155, ERC1155Supply) {
        ERC1155Supply._beforeTokenTransfer(
            _operator,
            _from,
            _to,
            _ids,
            _amounts,
            _data
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './ERC721.sol';

contract ERC721Enumerable is ERC721 {

    uint256[] private _allTokens;

    // Mapping from tokenId to position in _allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    // Mapping of owner to list of all owner token ids
    mapping(address => uint256[]) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list (_ownedTokens)
    mapping(uint256 => uint256) private _ownedTokensIndex;


    /// @notice Count NFTs tracked by this contract
    /// @return A count of valid NFTs tracked by this contract, 
    /// where each of them has an assigned and queryable owner
    // not equal to the zero address

    function totalSupply() external view returns(uint256) {
        return _allTokens.length;
    }


    /// @notice Enumerate valid NFTs
    /// @dev Throws if `_index` >= `totalSupply()`
    /// @param _index A counter less than `totalSupply()`
    /// @return The token identifier for the `_index`th NFT,
    /// (sort order not specified)

    function tokenByIndex(uint256 _index) external view returns(uint256) {

        require(_index < _allTokens.length, 'Global index is out of bounds!');
        return _allTokens[_index];
    
    }


    /// @notice Enumerate NFTs assigne to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    /// `_owner` is the zero address, representing invalid NFTs.
    /// @param _owner An address where we are interested in NFTs owner
    /// @param _index A counter less than `balanceOf(_owner)`
    /// @return The token identifier for the `_index`th NFT assigned 
    /// (sort order not specified)
    
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256){

        // require(_owner != address(0));
        require(_index < balanceOf(_owner), 'Owner index is out of bounds!');
        return _ownedTokens[_owner][_index];

    }


    // Add tokens to the _allTokens array and set position of the tokens indexes
    function _addTokensToAllTokenEnumeration(uint256 tokenId) private {


        /* There are 2 ways to get the position of the tokenId in _allTokens
            1st:
                We push the tokenId on _allTokens array
                Then we get the indexOf tokenId in the array:

                _allTokens.push(tokenId);
                _allTokensIndex[tokenId] = _allTokens.indexOf(tokenId);

            2nd:
                Before pushing tokenId in the array, we get the length of the array and we assign it in _allTokenIndex[tokenId]
                Then we push tokenId, so the position of tokenId will be the length we got before:
        */
        
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);

    }

    function _addTokensToOwnerEnumeration(address to, uint256 tokenId) private {

        // 1. Add address and token id to the _ownedTokens
        // 2. ownedTokenIndex[tokenId] set to index of the owner tokens list (_ownedTokens)
        // 3. We want to execute the function with minting
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);

    }


    function _mint(address to, uint256 tokenId) internal override(ERC721) {

        super._mint(to, tokenId);

        /* 
            2 things:
                A. Add tokens to the owner
                B. Add tokens to our totalSupply - to allTokens
        */

        // A.
        _addTokensToAllTokenEnumeration(tokenId);

        // B.
        _addTokensToOwnerEnumeration(to, tokenId);

    }



}
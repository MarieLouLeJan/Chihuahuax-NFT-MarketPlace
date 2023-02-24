// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './ERC721Metadata.sol';

contract ERC721Connector is ERC721Metadata {

    // We deploy connector right away 
    // We want to carry the metadata info over

    constructor(string memory name, string memory symbol) ERC721Metadata(name, symbol) {
        
    }

}
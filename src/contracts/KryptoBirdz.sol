// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './ERC721Connector.sol';

contract KryptoBird is ERC721Connector {

    constructor() ERC721Connector('KryptoBird', 'KBIRDZ') { }

}
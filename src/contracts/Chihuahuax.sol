// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './ERC721Connector.sol';

contract Chihuahuax is ERC721Connector {

    // Array to store our nfts
    string[] public chihuahuax;

    mapping(string => bool) _chihuahuaxExists;

    function mint(string memory _chihuahua) public {

        require(!_chihuahuaxExists[_chihuahua], 'Error - chihuahua had already been minted');

        // this is deprecated - uint _id = chihuahuax.push(_chihuahua);
        // .push not longer returns the length but a ref to the added element

        // I should test out if this can replace the 2 lines under
        // uint _id = chihuahuax.push(_chihuahua).length - 1;

        chihuahuax.push(_chihuahua);
        uint _id = chihuahuax.length - 1;

        _mint(msg.sender, _id);

        _chihuahuaxExists[_chihuahua] = true;

    }

    constructor() ERC721Connector('Chihuahuax', 'CHIX') { }

}
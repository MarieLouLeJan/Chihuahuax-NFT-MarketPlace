// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* 

    All the strandards ERC721: https://eips.ethereum.org/EIPS/eip-721

    Building out the minting function:
        a. NFT to point to an address
        b. Keep track of the token ids
        c. keep track of the token owner addresses to token ids
        d. Keep track of how many tokens an owner address has
        e. Create an event that emits a transfer log - contract addresses where it is being minted to, the id

*/

contract ERC721 {

    // The Transfer event is called whenever a mint or transferFrom function is called

    event Transfer(
        address indexed from, 
        address indexed to, 
        uint256 indexed tokenId
    ); 

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    // Mapping in solidity creates a hash table of key pair values

    // Mapping from token id to the owner
    mapping(uint256 => address) private _tokenOwner;

    // Mapping from owner to number owned token
    mapping(address => uint256) private _ownedTokenCount;

    // Mapping from token id to approved addresses
    mapping(uint256 => address) private _tokenApprovals;



    function _exists(uint256 tokenId) internal view returns(bool) {

        // Setting the address of NFT owner to check the mapping
        // of the address from tokenOwner at the tokenId
        address owner = _tokenOwner[tokenId];

        // Return truthiness that address isn't 0
        return owner != address(0);

    }


    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid
    // function throw for queries about the zero address
    /// @param _owner An address for whom to query the balance 
    /// @return The number of NFTs owned by `_owner`, possibly zero

    function balanceOf(address _owner) public view returns(uint256) {

        require(_owner != address(0), 'ERC721: token query for non existent owner');
        return _ownedTokenCount[_owner];

    }


    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid
    /// and queries about them do throw
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT

    function ownerOf(uint _tokenId) public view returns(address) {

        require(_tokenOwner[_tokenId] != address(0), 'ERC721: Non existent token');
        return owner;

    }


    function _mint(address to, uint256 tokenId) internal virtual {

        // Requires that the address isn't zero
        require(to != address(0), 'ERC721: minting to the zero address');

        // Requires that the token hadn't already been minted 
        // (by calling the function exists that we created above)

        require(!_exists(tokenId), 'ERC721: token already minted');
        // We are adding a new address with a token id for minting
        _tokenOwner[tokenId] = to;

        // We're keeping track of each address that is minting 
        // and adding one to the count
        _ownedTokenCount[to] += 1;

        emit Transfer(address(0), to, tokenId);

    }


    // The purpose of the transfer functions is to manage the resale purchase 
    // of an NFT AFTER it has been minted

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    /// TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTs OR ELSE
    /// THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an aythorized
    /// operatof, or the approved address for this NFT. Throw if `_from` is
    /// not the current owner. Throws if `_to` is the zero address. Throws if
    /// `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer

    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {

        // Add some safe functionnalities:
        //  a. require that the address receiving a token is not a zero address
        require(_to != address(0), 'ERC721 Transfer to the zero address');
        //  b. require the address transfering the token actually owns the token
        //      We've already created a function for that return the owner of 
        //      a specific token, as well as checking if token exists
        require(ownerOf(_tokenId) == _from, 'ERC721: Trying to transger a token  the address does not own !');

        // Update the balance of the address `_from`
        _ownedTokenCount[_from] -= 1;

        // Update the balance of the address `_to`
        _ownedTokenCount[_to] += 1;

        // Add the `_tokenId` to the address receiving `_to` - which receive the token
        _tokenOwner[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);

    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        require(isApprovedOrOWner(msg.sender, _tokenId));
        _transferFrom(_from, _to, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) public {

        address owner = ownerOf(_tokenId);

        // Require that the person approving is the owner
        require(owner == msg.sender, 'Error - approver (current caller) is not the owner of the token');
        // Require that we can't approve sending token of the owner to the owner (current caller)
        require(_to != owner, 'Error - approval to current owner');

        // Update the map of the approval addresses
        _tokenApprovals[_tokenId] = _to;

        // Approve an address to a token (_tokenId)
        emit Approval(owner, _to, _tokenId);

    }

    function isApprovedOrOWner(address _spender, uint256 _tokenId) internal view returns(bool) {
        require(_exists(_tokenId), ' Token does not exist');
        address owner = ownerOf(_tokenId);
        return(_spender == owner);
    }

}
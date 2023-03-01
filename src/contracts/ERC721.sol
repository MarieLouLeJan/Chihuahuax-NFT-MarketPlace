// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './ERC165.sol';
// import './ERC721TokenReceiver.sol';
import './interfaces/IERC721.sol';


contract ERC721 is ERC165, IERC721 {

    // Mapping from token id to the owner
    mapping(uint256 => address) private _tokenOwner;

    // Mapping from owner to number owned token
    mapping(address => uint256) private _ownedTokenCount;

    // Mapping from token id to approved addresses
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner address to mapping of operator address to bool 
    // If true, owner allows operator to manage NFT
    mapping(address => mapping(address => bool)) private _operatorApprovals;



    /// @notice Check if the tokenIf exists
    /// @dev assign to `ower` the address of owner of the `tokenId` (`_tokenOwner`)
    /// @return bool, truthiness if the owner address is not 0 
    /// which means that the NFT has alreadu been minted as it's assign to a valid address
    function _exists(uint256 tokenId) internal view returns(bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function isApprovedOrOWner(address _spender, uint256 _tokenId) internal view returns(bool) {
        require(_exists(_tokenId), 'Token does not exist');
        address owner = ownerOf(_tokenId);
        bool operatorAllowance = _operatorApprovals[owner][_spender];
        return(_spender == owner || operatorAllowance == true);
    }


    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid
    // function throw for queries about the zero address
    /// @param _owner An address for whom to query the balance 
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) public override view returns(uint256) {
        require(_owner != address(0), 'ERC721: token query for non existent owner');
        return _ownedTokenCount[_owner];
    }

    
    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid
    /// and queries about them do throw
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint _tokenId) public override view returns(address) {
        require(_tokenOwner[_tokenId] != address(0), 'ERC721: Non existent token');
        return _tokenOwner[_tokenId];
    }

    /* 
        Building out the minting function:
            a. NFT to point to an address
            b. Keep track of the token ids
            c. keep track of the token owner addresses to token ids
            d. Keep track of how many tokens an owner address has
            e. Create an event that emits a transfer log - contract addresses where it is being minted to, the id
    */
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


    // The purpose of the transferFrom functions is to manage the resale purchase 
    // of an NFT AFTER it has been minted
    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    /// TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTs OR ELSE
    /// THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an aythorized
    /// operator, or the approved address for this NFT. Throw if `_from` is
    /// not the current owner. Throws if `_to` is the zero address. Throws if
    /// `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {

        /// rows unless `msg.sender` is the current owner, an authorized
        /// operator, or the approved address for this NFT.
        /// Throws if `_tokenId` is not a valid NFT.
        require(isApprovedOrOWner(msg.sender, _tokenId));

        // Throws if `_to` is the zero address.
        require(_to != address(0), 'ERC721 Transfer to the zero address');

        /// Throw if `_from` is not the current owner.
        require(ownerOf(_tokenId) == _from, 'ERC721: Trying to transfer a token the address does not own !');

        // Update the balance of the address `_from`
        _ownedTokenCount[_from] -= 1;

        // Update the balance of the address `_to`
        _ownedTokenCount[_to] += 1;

        // Add the `_tokenId` to the address receiving `_to` - which receive the token
        _tokenOwner[_tokenId] = _to;

        if(_tokenApprovals[_tokenId] != address(0)){
           delete _tokenApprovals[_tokenId];
        }

        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) override public {
        _transferFrom(_from, _to, _tokenId);
        
    }


    /*
    @notice Transfers the ownership of an NFT from one address to another address
    @dev This works identically to the other function with an extra data parameter,
     except this function just sets data to "".
    @param _from The current owner of the NFT
    @param _to The new owner
    @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes4 data) public {
        transferFrom(_from, _to, _tokenId);
        uint32 size;
        assembly {
            size := extcodesize(_to)
        }
        if(size > 0) {
            ERC721TokenReceiver receiver = ERC721TokenReceiver(_to);
            require(receiver.onERC721Received(msg.sender, _from, _tokenId, data)
                    ==
                    bytes4(keccak256("onERC721Received(address, address, uint256, bytes4)"))
                    )
            ;
        }
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {
        safeTransferFrom(_from,_to,_tokenId,"");
    }
    */

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _to The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _to, uint256 _tokenId) override public {
        address owner = ownerOf(_tokenId);

        // Thorw if the person approving isn't the owner or an authorized operator
        require( isApprovedOrOWner(msg.sender, _tokenId), 'ERC721 - approver (current caller) is not the owner of the token neither an authorized operator');

        // Throw if `_from` is not the current owner.
        require(_to != owner, 'ERC721 - sending token to the current owner');

        // Update the map of the approval addresses
        _tokenApprovals[_tokenId] = _to;

        // Approve an address to a token (_tokenId)
        emit Approval(owner, _to, _tokenId);
    }


    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) override public {
        require(_operator != msg.sender, 'ERC 721 - Approve to caller');
        _operatorApprovals[msg.sender][_operator] = _approved;  
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }


    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) public override  view returns(address) {
        require(_exists(_tokenId), 'Token does not exist');
        return _tokenApprovals[_tokenId];
    }


    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) public override view returns(bool) {
        return _operatorApprovals[_owner][_operator];
    }

}
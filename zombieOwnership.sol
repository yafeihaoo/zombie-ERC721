pragma solidity ^0.5.12;

import "./zombieHelper.sol";
import "./erc721.sol";

contract ZombieOwnership is ZombieHelper,ERC721 {
    
    mapping (uint => address) zombieApprovals;

    function balanceOf(address _owner) public view returns (uint256 _balance) {
        return ownerZombieCount[_owner];
    }
    
    //重新写zombieToOwner这个映射的函数是因为 ownerOf是标准的erc721
    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return zombieToOwner[_tokenId];
    }
    
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
        ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
        zombieToOwner[_tokenId] = _to;
        emit Transfer(_from,_to,_tokenId);//erc721标准里面的函数
    }
    
    function transfer(address _to, uint256 _tokenId) public {
        _transfer(msg.sender,_to,_tokenId);
    }
    
    function approve(address _to, uint256 _tokenId) public {
        zombieApprovals[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);//erc721标准里面的函数
    }
    
    function takeOwnership(uint256 _tokenId) public {
        require(zombieApprovals[_tokenId] == msg.sender);
        address owner = ownerOf(_tokenId);
        _transfer(owner, msg.sender,_tokenId);
    }
    
    
}
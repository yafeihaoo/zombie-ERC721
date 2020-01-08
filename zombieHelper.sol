pragma solidity ^0.5.12;

import "./zombieFactory.sol";

contract ZombieHelper is ZombieFactory {
    
    uint levelUpFee = 0.001 ether;
    
    //修饰符
    modifier aboveLevel(uint _level, uint _zombieId){
        require(zombies[_zombieId].level >= _level);
        _;//_;这个行代码的意思是，上面的代码会被加在调用这个修饰符的其他函数里面的代码的前面。
    }
    
    modifier onlyOwnerOf(uint _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        _;
    }
    
    function setLevelUpFee(uint _fee) external onlyOwner {
        levelUpFee = _fee;
    }
    
    function levelUp(uint _zombieId) external payable {
        require(msg.value >= levelUpFee);
        zombies[_zombieId].level++;
    }
    
    //可视范围是external的时候，制定string的存储位置就不能是memory，要用calldata
    function changeName(uint _zombieId, string calldata _newName)external aboveLevel(2,_zombieId) onlyOwnerOf(_zombieId){
        zombies[_zombieId].name = _newName;
    }
    
    function getZombiesByOwner(address _owner)external view returns(uint[] memory) {
        //根据拥有者拥有的僵尸数量，作为长度创建一个数组，数组存在memory里面
        uint[] memory result = new uint[](ownerZombieCount[_owner]);
        uint counter = 0;
        for(uint i = 0; i<zombies.length; i++){
            if(zombieToOwner[i] == _owner){
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
    
    //传入构造体时，存储位置为storage
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(now + cooldownTime) - uint32((now + cooldownTime) % 1 days);
    }
    
    function _isReady(Zombie storage _zombie) internal view returns(bool) {
        return(_zombie.readyTime <= now);
    }
    
    function multiply(uint _zombieId, uint _targetDna) internal onlyOwnerOf(_zombieId) {
        Zombie storage myZombie = zombies[_zombieId];
        require(_isReady(myZombie));
        _targetDna = _targetDna % dnaModulus;
        uint newDna = (myZombie.dna + _targetDna) / 2;
        newDna = newDna - newDna % 10 + 9;
        _createZombie("NoName",newDna);
        _triggerCooldown(myZombie);
    }
    
    
    
}
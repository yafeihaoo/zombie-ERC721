pragma solidity ^0.5.12;

import "./zombieOwnership.sol";

contract ZombieMarket is ZombieOwnership {
    uint public tax = 1 finney;
    uint public minPrice = 1 finney;//1finney = 0.001ether
    
    struct zombieSales{
        //在有钱的交易的地址前面要加payable
        address payable seller;
        uint price;
    }
    
    mapping (uint => zombieSales) public zombieShop;
    
    event SaleZombie(uint indexed zombieId, address indexed seller);
    event BuyShopZombie(uint indexed zombieId, address indexed buyer , address indexed seller);
    
    function saleMyZombie(uint _zombieId, uint _price) public onlyOwnerOf(_zombieId) {
        require(_price >= minPrice + tax);
        zombieShop[_zombieId] = zombieSales(msg.sender,_price);
        emit SaleZombie(_zombieId,msg.sender);
    }
    
    function buyShopZombie(uint _zombieId) public payable {
        //变量存储在memory比较节省gas
        zombieSales memory _zombieSales = zombieShop[_zombieId];
        require(msg.value >= _zombieSales.price);
        _transfer(_zombieSales.seller, msg.sender, _zombieId);
        _zombieSales.seller.transfer(msg.value-tax);//这里面的transfer是solidity的内置函数
        delete zombieShop[_zombieId];//删除映射，节省空间
        emit BuyShopZombie(_zombieId, msg.sender, _zombieSales.seller);
    }
    
    function setTax(uint _value) public onlyOwner {
        tax = _value;
    }
    
    function setMinPrice(uint _value) public onlyOwner {
        minPrice = _value;
    }
    
    
    
}
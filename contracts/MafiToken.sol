pragma solidity 0.6.6;

import "./ERC20/ERC20.sol";

contract MafiToken is ERC20 {
    constructor() public ERC20("Mafi Token", "MAFI") {
        _mint(msg.sender, 10000000 * (10 ** 18));
    }
}

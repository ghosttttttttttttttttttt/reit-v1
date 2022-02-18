//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./libraries/SafeMath.sol";

import "./interfaces/IERC20.sol";
import "./interfaces/IMIL.sol";
import "./interfaces/IERC20Permit.sol";

import "./types/ERC20Permit.sol";
import "./types/OlympusAccessControlled.sol"; // ???

contract MILERC20 is ERC20Permit, IMIL, OlympusAccessControlled {
    using SafeMath for uint256;

    address public owner;
    address public treasury;

    constructor(address _owner)
        ERC20("Magic Internet Land", "MIL", 9)
        ERC20Permit("MagicInternetLand")
        OlympusAccessControlled(IOlympusAuthority(_authority))
    {
        owner = msg.sender; // Only multi-sig or treasury contract can mint. 
    }

     /// @notice Only allows the `owner and Treasury contract` to execute mint burn functions.
    modifier onlyOwner_or_Treasury() {
        require(msg.sender == owner || msg.sender == treasury, "Owner or Treasury: caller is not the owner or treasury");
        _;
    }

    function mint(address account_, uint256 amount_) external override onlyOwner_or_Treasury {
        _mint(account_, amount_);
    }

    function burn(uint256 amount) external override {
        _burn(msg.sender, amount);
    }

    function burnFrom(address account_, uint256 amount_) external override {
        _burnFrom(account_, amount_);
    }

    function _burnFrom(address account_, uint256 amount_) internal {
        uint256 decreasedAllowance_ = allowance(account_, msg.sender).sub(
            amount_,
            "ERC20: burn amount exceeds allowance"
        );

        _approve(account_, msg.sender, decreasedAllowance_);
        _burn(account_, amount_);
    }
}
/*
This file is part of the RepuDAO project.

The RepuDAO Contract is free software: you can redistribute it and/or
modify it under the terms of the GNU lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The RepuDAO Contract is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the RepuDAO Contract. If not, see <http://www.gnu.org/licenses/>.

@author Ilya Svirin <is.svirin@gmail.com>
*/
// SPDX-License-Identifier: GNU lesser General Public License


pragma solidity ^0.8.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract RepuStaking is ERC20
{
    event Deployed();
    event Staked(address indexed owner, uint256 repu, uint256 lprepu);
    event Unstaked(address indexed owner, uint256 repu, uint256 lprepu);

    IERC20 public _governance;

    constructor(address governance)
        ERC20("Liquidity provider REPU token", "lpREPU")
    {
        _governance = IERC20(governance);
        emit Deployed();
    }

    function burn(uint256 lprepu) public returns (uint256 repu)
    {
        require(balanceOf(_msgSender()) >= lprepu, "RepuStaking: not enough lpREPU");
        uint256 repuPoolSize = _governance.balanceOf(address(this));
        uint256 lprepuSupply = totalSupply();
        repu = lprepu * repuPoolSize / lprepuSupply;
        require(_governance.transfer(_msgSender(), repu), "RepuStaking: not enough REPU");
        _burn(_msgSender(), lprepu);
        emit Unstaked(_msgSender(), repu, lprepu);
    }

    function stake(uint256 repu) public returns (uint256 lprepu)
    {
        require(_governance.transferFrom(_msgSender(), address(this), repu), "RepuStaking: can't transfer governance tokens");
        uint256 repuPoolSize = _governance.balanceOf(address(this));
        uint256 lprepuSupply = totalSupply();
        uint256 p = repu / (repu + repuPoolSize);
        lprepu = (lprepuSupply == 0) ?
            repuPoolSize :
            p * lprepuSupply / (1 - p);
        require(lprepu > 0, "RepuStaking: can't mint zero amount of lpREPU");
        _mint(_msgSender(), lprepu);
        emit Staked(_msgSender(), repu, lprepu);
    }
}

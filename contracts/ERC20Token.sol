// SPDX-License-Identifier: MIT

//** Whitelisted ERC20 TOKEN for Mainnet */

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "./Whitelisted.sol";

contract ERC20Token is ERC20, Whitelisted {

  address public constant DEAD_ADDRESS = address(0xdead);

  /**
   *
   * @dev mint initialSupply in constructor with symbol and name
   *
   */
  constructor(
    string memory _name,
    string memory _symbol,
    uint256 _initialSupply,
    uint256 _time,
    uint256 _startTime,
    uint256 _blockSellTime,
    address _router,
    address _liquidityToken
  )
    ERC20(_name, _symbol)
    Whitelisted(_time, _startTime, _blockSellTime)
  {
    _mint(_msgSender(), _initialSupply);

    IUniswapV2Router02 router = IUniswapV2Router02(_router);

    address pair = IUniswapV2Factory(router.factory()).createPair(
      address(this),
      _liquidityToken
    );

    isPair[pair] = true;
  }

  /**
   *
   * @dev lock tokens by sending to DEAD address
   *
   */
  function lockTokens(uint256 amount) external onlyOwner returns (bool) {
    _transfer(_msgSender(), DEAD_ADDRESS, amount);
    return true;
  }

  /**
   * @dev Destroys `amount` tokens from the caller.
   *
   * See {ERC20-_burn}.
   */
  function burn(uint256 amount) external returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     */

    /* solhint-disable */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    )
        internal
        override
        notBlackListed(from, to)
        isTimeLocked(from, to)
        isSaleBlocked(from, to)
    {}
    /* solhint-enable */
}
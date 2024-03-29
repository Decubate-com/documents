// SPDX-License-Identifier: MIT

//** Decubate Whitelisted Contract */
//** Author Aceson */
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Whitelisted is Ownable {
    mapping(address => bool) public isWhitelisted;
    mapping(address => bool) public isBlackListed;
    mapping(address => bool) public isPair;

    uint256 public startTime;
    uint256 public blockSellUntil;

    bool public isBlackListEnabled;
    bool public isTimeLockEnabled;

    event WhiteListSet(address addr, bool value);
    event BlackListSet(address addr, bool value);
    event BulkBlackList(address[] addr, bool[] value);
    event BlackListEnabled(bool value);
    event TimeLockEnabled(bool value);

    //Modifier which allows only whitelisted addresses
    modifier onlyWhiteListed() {
        require(isWhitelisted[_msgSender()], "Caller is not whitelister");
        _;
    }

    //Modifier which allows only non blacklisted addresses
    modifier notBlackListed(address from, address to) {
        if (isBlackListEnabled) {
            require(
                !isBlackListed[from] && !isBlackListed[to],
                "Address is blacklisted"
            );
        }
        _;
    }

    //Modifier which controls transfer on a set time period
    modifier isTimeLocked(address from, address to) {
        if (isTimeLockEnabled) {
            if (!isWhitelisted[from] && !isWhitelisted[to]) {
                require(
                    block.timestamp >= startTime,
                    "Trading not enabled yet"
                );
            }
        }
        _;
    }

    //Modifier which blocks sell until blockSellUntil value
    modifier isSaleBlocked(address from, address to) {
        if (!isWhitelisted[from] && isPair[to]) {
            require(block.timestamp >= blockSellUntil, "Sell disabled!");
        }
        _;
    }

    //time - amount of time in seconds before trading is enabled from
    constructor(
        uint256 time,
        uint256 _startTime,
        uint256 _blockSellUntil
    ) {
        isWhitelisted[_msgSender()] = true;
        isBlackListEnabled = true;
        isTimeLockEnabled = true;

        startTime = _startTime + time;
        blockSellUntil = _blockSellUntil;
    }

    /**
     *
     * @dev Include/Exclude an address in whitelist
     *
     * @param {addr} Address of user
     * @param {value} Whitelist status
     *
     * @return {bool} Status of whitelisting
     *
     */
    function whiteList(address addr, bool value)
        external
        onlyOwner
        returns (bool)
    {
        isWhitelisted[addr] = value;
        emit WhiteListSet(addr, value);
        return true;
    }

    /**
     *
     * @dev Include/Exclude an address in bllacklist
     *
     * @param {addr} Address of user
     * @param {value} Blacklist status
     *
     * @return {bool} Status of blacklisting
     *
     */
    function blackList(address addr, bool value)
        external
        onlyWhiteListed
        returns (bool)
    {
        isBlackListed[addr] = value;
        emit BlackListSet(addr, value);
        return true;
    }

    /**
     *
     * @dev Include/Exclude multiple address in blacklist
     *
     * @param {addr} Address array of users
     * @param {value} Whitelist status of users
     *
     * @return {bool} Status of bulk blacklist
     *
     */
    function bulkBlackList(address[] calldata addr, bool[] calldata value)
        external
        onlyWhiteListed
        returns (bool)
    {
        require(addr.length == value.length, "Array length mismatch");
        uint256 len = addr.length;

        for (uint256 i = 0; i < len; i++) {
            isBlackListed[addr[i]] = value[i];
        }

        emit BulkBlackList(addr, value);
        return true;
    }

    /**
     *
     * @dev Enable/disable blacklist usage in contract
     *
     * @param {value} Set/remove blacklist
     *
     * @return {bool} Status of enable/disable
     *
     */
    function setBlackList(bool value) external onlyWhiteListed returns (bool) {
        isBlackListEnabled = value;
        emit BlackListEnabled(value);
        return true;
    }

    /**
     *
     * @dev Enable/disable timelock usage in contract
     *
     * @param {value} Set/remove timelock
     *
     * @return {bool} Status of enable/disable
     *
     */
    function setTimeLocked(bool _isTimeLockEnabled, uint256 _startTime)
        external
        onlyWhiteListed
        returns (bool)
    {
        isTimeLockEnabled = _isTimeLockEnabled;
        startTime = _startTime;
        emit TimeLockEnabled(_isTimeLockEnabled);
        return true;
    }

    /**
     *
     * @dev Set blockSellUntil
     *
     * @param {value} time to block sales until
     *
     * @return {bool} Status of enable/disable
     *
     */
    function setBlockSellUntil(uint256 value)
        external
        onlyWhiteListed
        returns (bool)
    {
        blockSellUntil = value;
        return true;
    }

    /// @notice Sets status of an address to pair or not
    /// @dev true = is pair, false = not pair
    /// @param addr Address you want to change status
    /// @param status Whether pair or not
    function setPairAddress(address addr, bool status) external onlyOwner {
        isPair[addr] = status;
    }
}
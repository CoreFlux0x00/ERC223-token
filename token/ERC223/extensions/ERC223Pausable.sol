pragma solidity ^0.8.0;

import "../ERC223.sol";

/**
 * @dev ERC223 token with pausable token transfers.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
contract ERC223Pausable is ERC223Token {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;
    address private _pauser;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor(string memory name, string memory symbol, uint8 decimals) 
        ERC223Token(name, symbol, decimals) 
    {
        _paused = false;
        _pauser = msg.sender;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "ERC223Pausable: token transfer while paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only by the pauser.
     */
    modifier onlyPauser() {
        require(msg.sender == _pauser, "ERC223Pausable: caller is not the pauser");
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Called by the pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser {
        require(!_paused, "ERC223Pausable: already paused");
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by the pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser {
        require(_paused, "ERC223Pausable: already unpaused");
        _paused = false;
        emit Unpaused(msg.sender);
    }

    /**
     * @dev Override the transfer function to add the whenNotPaused modifier
     */
    function transfer(address to, uint value, bytes calldata data) 
        public 
        override 
        whenNotPaused 
        returns (bool success)
    {
        return super.transfer(to, value, data);
    }
} 
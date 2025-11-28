// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IERC1820Registry} from "lib/openzeppelin-contracts/contracts/interfaces/IERC1820Registry.sol";

contract ERC1820RegistryMock is IERC1820Registry {
    mapping(address => address) private _managers;
    mapping(address => mapping(bytes32 => address)) private _implementers;

    function setManager(address account, address newManager) external override {
        require(_managers[account] == address(0) || _managers[account] == msg.sender, "Not the manager");
        _managers[account] = newManager;
        emit ManagerChanged(account, newManager);
    }

    function getManager(address account) external view override returns (address) {
        address manager = _managers[account];
        return manager == address(0) ? account : manager;
    }

    function setInterfaceImplementer(
        address account,
        bytes32 _interfaceHash,
        address implementer
    ) external override {
        address accountToUse = account == address(0) ? msg.sender : account;
        address manager = _managers[accountToUse];
        require(
            manager == address(0) ? accountToUse == msg.sender : manager == msg.sender,
            "Not the manager"
        );
        _implementers[accountToUse][_interfaceHash] = implementer;
        emit InterfaceImplementerSet(accountToUse, _interfaceHash, implementer);
    }

    function getInterfaceImplementer(address account, bytes32 _interfaceHash)
        external
        view
        override
        returns (address)
    {
        address accountToUse = account == address(0) ? msg.sender : account;
        return _implementers[accountToUse][_interfaceHash];
    }

    function interfaceHash(string calldata interfaceName) external pure override returns (bytes32) {
        return keccak256(abi.encodePacked(interfaceName));
    }

    function updateERC165Cache(address /* account */, bytes4 /* interfaceId */) external override {
        // Mock implementation - no-op
    }

    function implementsERC165Interface(address /* account */, bytes4 /* interfaceId */)
        external
        pure
        override
        returns (bool)
    {
        // Mock implementation - always return false
        return false;
    }

    function implementsERC165InterfaceNoCache(address /* account */, bytes4 /* interfaceId */)
        external
        pure
        override
        returns (bool)
    {
        // Mock implementation - always return false
        return false;
    }
}


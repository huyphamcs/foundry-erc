# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Foundry-based Ethereum smart contract project that implements various ERC token standards (ERC20, ERC721, ERC777) using OpenZeppelin contracts. The project follows a test-driven development approach with behavior-driven test structures.

## Essential Commands

### Build & Test
```shell
forge build          # Compile contracts
forge test           # Run all tests
forge test --mt <testName>  # Run specific test by name
forge test -vvvv     # Run tests with verbose output (useful for debugging)
forge fmt            # Format Solidity code
```

### Gas Analysis
```shell
forge snapshot       # Create gas snapshot for tests
```

### Local Development
```shell
anvil                # Start local Ethereum node
```

## Architecture

### Contract Structure
- **src/**: Contains token implementations that inherit from OpenZeppelin contracts
  - `MyERC20.sol`: Basic ERC20 with unrestricted minting
  - `MyERC721.sol`: NFT implementation using Ownable and Counters pattern
  - `MyERC777.sol`: Advanced fungible token with operator functionality

### Test Architecture
Tests use a **nested inheritance pattern** for behavior-driven testing:

1. **BaseSetup**: Establishes test users and labels (Alice, Bob, etc.)
2. **Context Contracts** (e.g., `WhenTransferingTokens`): Define specific scenarios
3. **State Contracts** (e.g., `WhenAliceHasSufficientFunds`): Set up preconditions
4. **Test Functions**: Execute assertions within the context

This structure allows tests to inherit setup logic and build complex scenarios hierarchically. When writing new tests, follow this pattern by creating context contracts that inherit from appropriate base contracts.

### Dependencies
- `forge-std`: Foundry's standard library for testing (Test contract, console, vm cheatcodes)
- `openzeppelin-contracts`: OpenZeppelin's audited contract implementations

### Import Paths
Use relative paths from lib: `lib/openzeppelin-contracts/contracts/...` and `lib/forge-std/src/...`

## Codacy Integration

This project uses Codacy's MCP Server for automated code analysis. After editing any Solidity file, the `codacy_cli_analyze` tool must be run to check for issues. See `.cursor/rules/codacy.mdc` for complete integration rules.

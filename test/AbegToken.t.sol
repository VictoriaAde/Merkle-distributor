// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdJson} from "forge-std/Test.sol";

import {Merkle} from "../src/AbegToken.sol";

contract AbegTest is Test {
    using stdJson for string;
    Merkle public merkle;
    struct Result {
        bytes32 leaf;
        bytes32[] proof;
    }

    struct User {
        address user;
        uint amount;
        uint256 tokenId;
    }
    Result public result;
    User public user;
    bytes32 root =
        0x4320c8d7728c67e7d376b164d088990f2ce16d6c90ea8d0793804c051f20249b;
    address user1 = 0xb0e52BBE49E57d9Bc5bAed1644958866fc5FDFBc;

    function setUp() public {
        merkle = new Merkle(root);
        string memory _root = vm.projectRoot();
        string memory path = string.concat(_root, "/merkle_tree.json");

        string memory json = vm.readFile(path);
        string memory data = string.concat(_root, "/address_data.json");

        string memory dataJson = vm.readFile(data);

        bytes memory encodedResult = json.parseRaw(
            string.concat(".", vm.toString(user1))
        );
        user.user = vm.parseJsonAddress(
            dataJson,
            string.concat(".", vm.toString(user1), ".address")
        );
        user.amount = vm.parseJsonUint(
            dataJson,
            string.concat(".", vm.toString(user1), ".amount")
        );
        user.tokenId = vm.parseJsonUint(
            dataJson,
            string.concat(".", vm.toString(user1), ".tokenId")
        );
        result = abi.decode(encodedResult, (Result));
        console2.logBytes32(result.leaf);
    }

    function testClaimed() public {
        bool success = merkle.claim(
            user.user,
            user.amount,
            user.tokenId,
            result.proof
        );
        assertTrue(success);
    }

    // function testAlreadyClaimed() public {
    //     merkle.claim(user.user, user.amount, user.tokenId, result.proof);
    //     vm.expectRevert("already claimed");
    //     merkle.claim(user.user, user.amount, user.tokenId, result.proof);
    // }

    function testIncorrectProof() public {
        bytes32[] memory fakeProofleaveitleaveit;

        vm.expectRevert("not whitelisted");
        merkle.claim(
            user.user,
            user.amount,
            user.tokenId,
            fakeProofleaveitleaveit
        );
    }
}

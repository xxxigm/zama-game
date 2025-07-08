// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@fhevm/solidity/lib/FHE.sol";
import "@fhevm/solidity/config/ZamaConfig.sol";

contract FHEAviator is SepoliaConfig {
    constructor() SepoliaConfig() {}

    struct UserInfo {
        address user;
        euint64 encryptedLevel;
        uint256 lastDecryptionRequestId;
    }

    address[] private _userAddresses;
    address payable public constant fixedAddress = payable(0x20fE49B4DA89004D57839193bDEca011d3ed87e5);

    enum DecryptionStatus {
        NotRequested,
        InProgress,
        Decrypted
    }

    mapping(address => mapping(uint256 => DecryptionStatus)) public userLevelDecryptionStatus;
    mapping(uint256 => uint256) public decryptedLevels;
    mapping(uint256 => address) private _requestIdToUser;
    mapping(address => UserInfo) private _users;

    uint256 private currentDecryptionRequestId;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event UserLevelUpdated(address indexed user, euint64 newEncryptedLevel);
    event DecryptionRequested(address indexed user, uint256 requestId);
    event DecryptionFulfilled(uint256 indexed requestId, address indexed user, uint64 decryptedValue);
    event DebugLog(string message, address requestId);

    function transfer() external payable {
        require(msg.value > 0, "Amount must be greater than 0");
        fixedAddress.transfer(msg.value);
        emit Transfer(msg.sender, fixedAddress, msg.value);
    }

    function updateUser(address _user, externalEuint64 _newLevel, bytes memory _inputProof) external {
        euint64 newLevelEnc = FHE.fromExternal(_newLevel, _inputProof);
        FHE.allowThis(newLevelEnc);

        bool userExists = false;
        if (_users[_user].user != address(0)) {
            userExists = true;
        }

        if (userExists) {
            euint64 currentLevelEnc = _users[_user].encryptedLevel;
            if (FHE.isInitialized(currentLevelEnc)) {
                FHE.allowThis(currentLevelEnc);
                ebool isNewLevelHigher = FHE.gt(newLevelEnc, currentLevelEnc);
                _users[_user].encryptedLevel = FHE.select(isNewLevelHigher, newLevelEnc, currentLevelEnc);
            } else {
                _users[_user].encryptedLevel = newLevelEnc;
            }
        } else {
            _users[_user] = UserInfo(_user, newLevelEnc, 0);
            _userAddresses.push(_user);
        }

        FHE.allowThis(_users[_user].encryptedLevel);

        emit UserLevelUpdated(_user, _users[_user].encryptedLevel);
    }

    function requestUserLevelDecryption(address _user) external {
        UserInfo storage userinfo = _users[_user];
        require(userinfo.user != address(0), "User does not exist");
        require(_user == msg.sender, "Can only request decryption for your own level.");
        require(FHE.isInitialized(userinfo.encryptedLevel), "User level is not initialized");

        bytes32[] memory cts = new bytes32[](1);
        cts[0] = FHE.toBytes32(userinfo.encryptedLevel);

        uint256 requestId = FHE.requestDecryption(cts, this.callbackDecryptUserLevel.selector);

        userLevelDecryptionStatus[_user][requestId] = DecryptionStatus.InProgress;
        _users[_user].lastDecryptionRequestId = requestId;
        _requestIdToUser[requestId] = _user;
        emit DecryptionRequested(_user, requestId);
    }

    function callbackDecryptUserLevel(uint256 requestId, uint64 decryptedValue, bytes[] memory signatures) public {
        address userForRequestId = _requestIdToUser[requestId];
        require(userForRequestId != address(0), "User not found for requestId");

        FHE.checkSignatures(requestId, signatures);

        decryptedLevels[requestId] = decryptedValue;
        userLevelDecryptionStatus[userForRequestId][requestId] = DecryptionStatus.Decrypted;

        emit DecryptionFulfilled(requestId, userForRequestId, decryptedValue);
    }

    function getAllUsersEncryptedLevels() external view returns (UserInfo[] memory) {
        UserInfo[] memory allUsers = new UserInfo[](_userAddresses.length);
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            address currentUserAddress = _userAddresses[i];
            allUsers[i] = _users[currentUserAddress];
        }
        return allUsers;
    }

    function getDecryptedLevelOfUser(address _userAddress) external view returns (uint64) {
        UserInfo storage userInfo = _users[_userAddress];
        require(userInfo.user != address(0), "User does not exist.");

        uint256 lastRequestId = userInfo.lastDecryptionRequestId;
        require(lastRequestId != 0, "No decryption request made by this user.");

        DecryptionStatus status = userLevelDecryptionStatus[_userAddress][lastRequestId];
        require(status == DecryptionStatus.Decrypted, "Decryption is not fulfilled for this user's level.");

        uint64 decryptedLvl = uint64(decryptedLevels[lastRequestId]);
        require(decryptedLvl != 0, "Decrypted level is zero or not properly stored.");

        return decryptedLvl;
    }
}

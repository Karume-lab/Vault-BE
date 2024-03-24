// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Vault {
    // tags to be used for files
    enum Tags {
        OTHER,
        EDUCATION,
        HEALTH,
        FINANCE,
        BUSINESS,
        FAMILY,
        RANDOM
    }

    // contains metadata for each file
    struct File {
        uint id;
        address owner;
        uint dateUploaded;
        uint dateModified;
        uint dateAccessed;
        bool isFavourite;
        bool isArchived;
        string cid;
        string name;
        string description;
        string extension;
        Tags tag;
    }

    // defines who has access to a user's vault
    struct Access {
        address user;
        bool hasAccess;
    }

    // stores a user's file metadata
    mapping(address => File[]) Files;
    // stores the logged in user's files
    mapping(address => mapping(address => bool)) MyVault;
    // Defines the people who have access to your vault
    mapping(address => Access[]) AccessList;
    // Stores the previous access value
    mapping(address => mapping(address => bool)) PreviousAccess;

    function uploadFile(
        address _owner,
        string memory _name,
        string memory _description,
        string memory _extension,
        bool _isFavourite,
        Tags _tag,
        string memory _cid
    ) external {
        File memory file = File({
            id: getId(),
            owner: _owner,
            dateUploaded: block.timestamp,
            dateModified: 0,
            dateAccessed: 0,
            isFavourite: _isFavourite,
            isArchived: false,
            cid: _cid,
            name: _name,
            description: _description,
            extension: _extension,
            tag: _tag
        });
        Files[msg.sender].push(file);
    }

    // generates a unique ID based on the number of the files uploaded by the user
    function getId() internal view returns (uint) {
        uint id;
        uint noOfFiles = Files[msg.sender].length;
        if (noOfFiles == 0) {
            id = 0;
        } else {
            id = noOfFiles + 1;
        }
        return id;
    }

    // get all files for the connected wallet
    function getFiles(address _user) external view returns (File[] memory) {
        require(
            _user == msg.sender || MyVault[_user][msg.sender],
            "You don't have access"
        );
        return Files[_user];
    }

    // share your vault to an address
    function shareVault(address user) external {
        MyVault[msg.sender][user] = true;
        if (PreviousAccess[msg.sender][user]) {
            for (uint i = 0; i < AccessList[msg.sender].length; i++) {
                if (AccessList[msg.sender][i].user == user) {
                    AccessList[msg.sender][i].hasAccess = true;
                }
            }
        } else {
            AccessList[msg.sender].push(Access(user, true));
            PreviousAccess[msg.sender][user] = true;
        }
    }

    // unshare your vault from an address
    function unshareVault(address user) public {
        MyVault[msg.sender][user] = false;
        for (uint i = 0; i < AccessList[msg.sender].length; i++) {
            if (AccessList[msg.sender][i].user == user) {
                AccessList[msg.sender][i].hasAccess = false;
            }
        }
    }

    // get the tags in the enum
    function getTags() public pure returns (string[] memory) {
        string[] memory tags = new string[](7);

        // Assign the enum values to the array
        tags[uint(Tags.OTHER)] = "Other";
        tags[uint(Tags.EDUCATION)] = "Education";
        tags[uint(Tags.HEALTH)] = "Health";
        tags[uint(Tags.FINANCE)] = "Finance";
        tags[uint(Tags.BUSINESS)] = "Business";
        tags[uint(Tags.FAMILY)] = "Family";
        tags[uint(Tags.RANDOM)] = "Random";

        return tags;
    }

    // retrieve all the users with access to your vault
    function getUsersWithAccess() public view returns (Access[] memory) {
        return AccessList[msg.sender];
    }
}

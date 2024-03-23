// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Upload {
    // tags to be used for files
    enum Tags {
        EDUCATION,
        HEALTH,
        FINANCE,
        BUSINESS,
        FAMILY,
        RANDOM,
        OTHER
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
    // struct Access {
    //     address user;
    //     bool hasAccess;
    // }

    struct Access {
        address user;
        bool access;
    }
    mapping(address => string[]) value; // store our hash value
    mapping(address => mapping(address => bool)) ownership;
    mapping(address => Access[]) accessList;
    mapping(address => mapping(address => bool)) previousData;

    // stores a user's file metadata
    mapping(address => File[]) Files;
    // stores the logged in user's files
    mapping(address => mapping(address => bool)) Vault;
    // Defines the people who have access to your vault
    mapping(address => Access[]) AccessList;
    // Stores the previous access value
    mapping(address => mapping(address => bool)) PreviousAccess;

    function add(
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

    function allow(address user) external {
        ownership[msg.sender][user] = true;
        if (previousData[msg.sender][user]) {
            for (uint i = 0; i < accessList[msg.sender].length; i++) {
                if (accessList[msg.sender][i].user == user) {
                    accessList[msg.sender][i].access = true;
                }
            }
        } else {
            accessList[msg.sender].push(Access(user, true));
            previousData[msg.sender][user] = true;
        }
    }

    function disallow(address user) public {
        ownership[msg.sender][user] = false;
        for (uint i = 0; i < accessList[msg.sender].length; i++) {
            if (accessList[msg.sender][i].user == user) {
                accessList[msg.sender][i].access = false;
            }
        }
    }

    function display(address _user) external view returns (string[] memory) {
        require(
            _user == msg.sender || ownership[_user][msg.sender],
            "You don't have access"
        );
        return value[_user];
    }

    function shareAccess() public view returns (Access[] memory) {
        return accessList[msg.sender];
    }
}

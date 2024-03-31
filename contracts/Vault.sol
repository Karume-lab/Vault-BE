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
        string size;
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
        string memory _size,
        string memory _extension,
        bool _isFavourite,
        Tags _tag,
        string memory _cid
    ) external {
        File memory file = File({
            owner: _owner,
            dateUploaded: block.timestamp,
            dateModified: 0,
            dateAccessed: 0,
            isFavourite: _isFavourite,
            isArchived: false,
            size: _size,
            cid: _cid,
            name: _name,
            description: _description,
            extension: _extension,
            tag: _tag
        });
        Files[msg.sender].push(file);
    }

    // get all files for the connected wallet
    function getFiles(address _user) external view returns (File[] memory) {
        require(
            _user == msg.sender || MyVault[_user][msg.sender],
            "You don't have access"
        );
        return Files[_user];
    }

    // mark or unmark a file as a favourite and return the CID
    function toggleFavourite(
        string memory _cid
    ) external returns (string memory) {
        for (uint i = 0; i < Files[msg.sender].length; i++) {
            if (
                keccak256(abi.encodePacked(Files[msg.sender][i].cid)) ==
                keccak256(abi.encodePacked(_cid))
            ) {
                Files[msg.sender][i].isFavourite = !Files[msg.sender][i]
                    .isFavourite;
                return _cid;
            }
        }
        revert("File with the given CID not found");
    }

    // share a file in your vault to an address
    function shareFile(address user) external {
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

    // unshare a file in your vault from an address
    function unshareFile(address user) public {
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

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

    // Events to log file sharing and access changes
    event FileShared(
        address indexed fileOwner,
        address indexed sharedWith,
        string cid,
        bool hasAccess
    );
    event AccessChanged(
        address indexed fileOwner,
        address indexed sharedWith,
        bool hasAccess
    );

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

    // Function to toggle a user's access to another user's file
    function toggleAccess(
        address _fileOwner,
        string memory _cid,
        address _sharedWith
    ) external {
        bool fileFound = false;
        uint256 fileIndex;
        // Loop through the files of the file owner to find the specified file
        for (uint256 i = 0; i < Files[_fileOwner].length; i++) {
            if (
                keccak256(abi.encodePacked(Files[_fileOwner][i].cid)) ==
                keccak256(abi.encodePacked(_cid))
            ) {
                fileFound = true;
                fileIndex = i;
                break;
            }
        }
        require(fileFound, "File with the given CID not found");

        // Check if the caller is the file owner
        require(
            msg.sender == _fileOwner,
            "Only the file owner can toggle access"
        );

        // Toggle access for the shared user
        if (!MyVault[_fileOwner][_sharedWith]) {
            AccessList[_fileOwner].push(Access(_sharedWith, true));
        } else {
            for (uint256 j = 0; j < AccessList[_fileOwner].length; j++) {
                if (AccessList[_fileOwner][j].user == _sharedWith) {
                    AccessList[_fileOwner][j].hasAccess = !AccessList[
                        _fileOwner
                    ][j].hasAccess;
                    break;
                }
            }
        }
        // Update the mapping of access
        MyVault[_fileOwner][_sharedWith] = !MyVault[_fileOwner][_sharedWith];
        emit AccessChanged(
            _fileOwner,
            _sharedWith,
            MyVault[_fileOwner][_sharedWith]
        );
    }

    // Function to return all the files shared to a user
    function getSharedFiles(
        address _user
    ) external view returns (File[] memory) {
        require(_user != address(0), "Invalid address");

        uint256 sharedCount = 0;
        for (uint256 i = 0; i < AccessList[_user].length; i++) {
            if (AccessList[_user][i].hasAccess) {
                sharedCount += Files[AccessList[_user][i].user].length;
            }
        }

        File[] memory sharedFiles = new File[](sharedCount);
        uint256 index = 0;
        for (uint256 i = 0; i < AccessList[_user].length; i++) {
            if (AccessList[_user][i].hasAccess) {
                address sharedWith = AccessList[_user][i].user;
                for (uint256 j = 0; j < Files[sharedWith].length; j++) {
                    sharedFiles[index] = Files[sharedWith][j];
                    index++;
                }
            }
        }

        return sharedFiles;
    }
}

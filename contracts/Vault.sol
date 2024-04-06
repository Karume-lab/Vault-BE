// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault
 * @dev A smart contract for storing files on the blockchain and managing file-related operations.
 */
contract Vault {
    // Enum for file tags
    enum Tags {
        OTHER,
        EDUCATION,
        HEALTH,
        FINANCE,
        BUSINESS,
        FAMILY,
        RANDOM
    }

    /**
     * @title File
     * @dev Struct representing a file, containing various attributes such as owner, name, description, etc.
     */
    struct File {
        address owner; // Address of the file owner
        string name; // Name of the file
        string description; // Description of the file
        uint256 size; // Size of the file
        uint256 dateUploaded; // Timestamp when the file was uploaded
        uint256 dateAccessed; // Timestamp when the file was last accessed
        uint256 dateDeleted; // Timestamp when the file was marked as deleted
        uint256 dateModified; // Timestamp when the file was last modified
        string cid; // IPFS CID of the file
        bool isFavourite; // Flag indicating if the file is marked as favorite
        bool isArchived; // Flag indicating if the file is archived
        bool isDeleted; // Flag indicating if the file is deleted
        string extension; // File extension
        Tags tag; // Tag of the file
    }

    /**
     * @title SharedFile
     * @dev Struct to represent a shared file, containing details such as IPFS CID, owner, and recipient
     */
    struct SharedFile {
        string cid; // IPFS CID of the shared file
        address owner; // Address of the owner who shared the file
        address recipient; // Address of the recipient who received the file
    }

    // Mapping to store user files
    mapping(address => mapping(string => File)) userFiles;

    // Mapping to store shared files using the SharedFile struct
    mapping(string => SharedFile[]) sharedFiles;

    // Mapping to track shared files with specific users
    mapping(string => mapping(address => bool)) sharedWith;

    // Mapping to track deleted files
    mapping(string => bool) deletedFiles;

    // Array to store all file keys
    string[] private allKeys;

    // Modifier to check if the file exists
    modifier fileExists(address _owner, string memory _cid) {
        require(userFiles[_owner][_cid].owner == _owner, "File does not exist");
        _;
    }

    // Modifier to check if the file is not deleted
    modifier fileNotDeleted(string memory _cid) {
        require(!deletedFiles[_cid], "File is already deleted");
        _;
    }

    /**
     * @dev Uploads a file to the blockchain.
     * @param _cid IPFS CID of the file
     * @param _name Name of the file
     * @param _description Description of the file
     * @param _isFavourite Flag indicating if the file is marked as favorite
     * @param _size Size of the file
     * @param _extension File extension
     * @param _tag Tag of the file
     */
    function uploadFile(
        string memory _cid,
        string memory _name,
        string memory _description,
        bool _isFavourite,
        uint256 _size,
        string memory _extension,
        Tags _tag
    ) external {
        require(
            bytes(userFiles[msg.sender][_cid].cid).length == 0,
            "File already exists"
        );
        userFiles[msg.sender][_cid] = File({
            owner: msg.sender,
            name: _name,
            description: _description,
            size: _size,
            dateUploaded: block.timestamp,
            dateAccessed: block.timestamp,
            dateModified: block.timestamp,
            dateDeleted: 0,
            cid: _cid,
            isFavourite: _isFavourite,
            isArchived: false,
            isDeleted: false,
            extension: _extension,
            tag: _tag
        });
        allKeys.push(_cid);
    }

    /**
     * @dev Gets all files for the caller's address.
     * @return Array of file objects.
     */
    function getFiles() external returns (File[] memory) {
        File[] memory files = new File[](allKeys.length);

        uint256 index = 0;
        for (uint256 i = 0; i < allKeys.length; i++) {
            string memory cid = allKeys[i];
            if (userFiles[msg.sender][cid].owner == msg.sender) {
                userFiles[msg.sender][cid].dateAccessed = block.timestamp;
                files[index] = userFiles[msg.sender][cid];
                index++;
            }
        }

        return files;
    }

    /**
     * @dev Gets a specific file for the caller's address.
     * @param _cid IPFS CID of the file.
     * @return File object.
     */
    function getFile(string memory _cid) external returns (File memory) {
        userFiles[msg.sender][_cid].dateAccessed = block.timestamp;
        return userFiles[msg.sender][_cid];
    }

    /**
     * @dev Edits the details of a file.
     * @param _cid IPFS CID of the file.
     * @param _name New name of the file.
     * @param _description New description of the file.
     * @param _tag New tag of the file.
     * @param _extension New extension of the file.
     */
    function editFile(
        string memory _cid,
        string memory _name,
        string memory _description,
        Tags _tag,
        string memory _extension
    ) external fileExists(msg.sender, _cid) {
        File storage file = userFiles[msg.sender][_cid];
        file.name = _name;
        file.description = _description;
        file.tag = _tag;
        file.extension = _extension;
        file.dateModified = block.timestamp;
    }

    /**
     * @dev Updates the access timestamp of a file.
     * @param _cid IPFS CID of the file.
     */
    function updateDateAccessed(
        string memory _cid
    ) external fileExists(msg.sender, _cid) {
        userFiles[msg.sender][_cid].dateAccessed = block.timestamp;
    }

    /**
     * @dev Updates the modification timestamp of a file.
     * @param _cid IPFS CID of the file.
     */
    function updateDateModified(
        string memory _cid
    ) external fileExists(msg.sender, _cid) {
        userFiles[msg.sender][_cid].dateModified = block.timestamp;
    }

    /**
     * @dev Toggles the favorite status of a file.
     * @param _cid IPFS CID of the file.
     */
    function toggleFavourite(
        string memory _cid
    ) external fileExists(msg.sender, _cid) {
        userFiles[msg.sender][_cid].isFavourite = !userFiles[msg.sender][_cid]
            .isFavourite;
        userFiles[msg.sender][_cid].dateModified = block.timestamp;
    }

    /**
     * @dev Toggles the archive status of a file.
     * @param _cid IPFS CID of the file.
     */
    function toggleArchive(
        string memory _cid
    ) external fileExists(msg.sender, _cid) {
        userFiles[msg.sender][_cid].isArchived = !userFiles[msg.sender][_cid]
            .isArchived;
        userFiles[msg.sender][_cid].dateModified = block.timestamp;
    }

    /**
     * @dev Toggles the deletion status of a file.
     * @param _cid IPFS CID of the file.
     */
    function toggleDelete(
        string memory _cid
    ) external fileExists(msg.sender, _cid) {
        if (userFiles[msg.sender][_cid].isDeleted) {
            // If the file is already marked as deleted, unmark it
            userFiles[msg.sender][_cid].isDeleted = false;
            deletedFiles[_cid] = false;
            userFiles[msg.sender][_cid].dateModified = block.timestamp;
            userFiles[msg.sender][_cid].dateDeleted = 0;
        } else {
            // If the file is not marked as deleted, mark it as deleted
            userFiles[msg.sender][_cid].isDeleted = true;
            userFiles[msg.sender][_cid].dateDeleted = block.timestamp;
            deletedFiles[_cid] = true;
        }
    }

    /**
     * @dev Shares a file with another user.
     * @param _cid IPFS CID of the file to be shared.
     * @param _user Address of the user to share the file with.
     */
    function shareFile(
        string memory _cid,
        address _user
    ) external fileExists(msg.sender, _cid) {
        require(_user != address(0), "Invalid user address");
        SharedFile memory sharedFile = SharedFile({
            cid: _cid,
            owner: msg.sender,
            recipient: _user
        });
        sharedFiles[_cid].push(sharedFile);
        sharedWith[_cid][_user] = true;
        userFiles[msg.sender][_cid].dateAccessed = block.timestamp;
    }

    /**
     * @dev Unshares a file from a user.
     * @param _cid IPFS CID of the file to be unshared.
     * @param _user Address of the user to unshare the file from.
     */
    function unshareFile(
        string memory _cid,
        address _user
    ) external fileExists(msg.sender, _cid) {
        require(sharedWith[_cid][_user], "File is not shared with this user");
        SharedFile[] storage files = sharedFiles[_cid];
        for (uint256 i = 0; i < files.length; i++) {
            if (files[i].recipient == _user) {
                files[i] = files[files.length - 1];
                files.pop();
                sharedWith[_cid][_user] = false;
                break;
            }
        }
        userFiles[msg.sender][_cid].dateModified = block.timestamp;
    }

    /**
     * @dev Lists all users with whom a file is shared.
     * @param _cid IPFS CID of the file.
     * @return Array of addresses of users with whom the file is shared.
     */
    function getFileAccessors(
        string memory _cid
    ) external view returns (address[] memory) {
        SharedFile[] storage files = sharedFiles[_cid];
        address[] memory accessors = new address[](files.length);
        for (uint256 i = 0; i < files.length; i++) {
            accessors[i] = files[i].recipient;
        }
        return accessors;
    }

    /**
     * @dev Retrieves the names of all enum tags.
     * @return Array of tag names.
     */
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

    /**
     * @dev Retrieves all files shared with the connected wallet address.
     * @return Array of SharedFile structs representing files shared with the connected wallet address.
     */
    function getFilesSharedWithMe()
        external
        view
        returns (SharedFile[] memory)
    {
        uint256 totalFilesShared = 0;

        // Count the total number of files shared with the connected wallet address
        for (uint256 i = 0; i < allKeys.length; i++) {
            string memory cid = allKeys[i];
            totalFilesShared += sharedFiles[cid].length;
        }

        // Create an array to store shared files
        SharedFile[] memory sharedFilesWithMe = new SharedFile[](
            totalFilesShared
        );
        uint256 index = 0;

        // Populate the array with shared files
        for (uint256 i = 0; i < allKeys.length; i++) {
            string memory cid = allKeys[i];
            for (uint256 j = 0; j < sharedFiles[cid].length; j++) {
                if (sharedFiles[cid][j].recipient == msg.sender) {
                    sharedFilesWithMe[index] = sharedFiles[cid][j];
                    index++;
                }
            }
        }

        return sharedFilesWithMe;
    }
}

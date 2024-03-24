import { useState } from "react";
import { useSnackbar } from "notistack";

const Display = ({ contract, account }) => {
  const { enqueueSnackbar } = useSnackbar();
  const [files, setFiles] = useState([]);
  const [otherAddress, setOtherAddress] = useState(""); // State to manage the input value

  const getdata = async () => {
    let dataArray;
    try {
      dataArray = await contract.getFiles(otherAddress ? otherAddress : account);
    } catch (error) {
      enqueueSnackbar("You don't have access", { variant: 'error' });
      console.error(error);
    }
    const isEmpty = dataArray.length === 0;

    if (!isEmpty) {
      setFiles(dataArray);
      enqueueSnackbar('Get files successfully', { variant: 'success' });
    } else {
      enqueueSnackbar('No file to display', { variant: 'info' });
    }
  };
  const timestamp2DateTime = (timestamp) => {
    let date;
    if (timestamp.toString() === "0") {
      date = null;
    } else {
      date = new Date(timestamp * 1000).toUTCString();
    }
    return date;
  };
  return (
    <>
      <input
        type="text"
        placeholder="Enter Address"
        value={otherAddress}
        onChange={(e) => setOtherAddress(e.target.value)}
        className="address border rounded p-2 mb-4 mr-4 md:w-[300px] xl:w-[500px]"
      />
      <button
        className="center button bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
        onClick={getdata}
      >
        Get Data
      </button>
      <div className="flex flex-col flex-grow md:flex-row justify-between flex-wrap md:p-4">
        {files?.map(({ owner, dateUploaded, dateModified, dateAccessed, isFavourite, isArchived, cid, name, description, extension, tag }) => (
          <div key={cid} className="mb-4 w-[330px] h-[200px]">
            <img
              src={`https://ipfs.io/ipfs/${cid}`}
              alt="new images"
              className="rounded-lg shadow-md h-full w-full object-fill"
            />
            <div>{owner}</div>
            <div>{timestamp2DateTime(dateAccessed)}</div>
            <div>{timestamp2DateTime(dateModified)}</div>
            <div>{timestamp2DateTime(dateUploaded)}</div>
            <div>{isFavourite}</div>
            <div>{isArchived}</div>
            <div>{name}</div>
            <div>{description}</div>
            <div>{extension}</div>
            <div>{tag}</div>
          </div>
        ))}

      </div>
    </>
  );
};

export default Display;

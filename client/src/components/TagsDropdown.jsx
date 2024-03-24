import { useState, useEffect } from 'react';

const TagsDropdown = ({ contract }) => {
    const [tags, setTags] = useState([]);
    
    useEffect(() => {
        const getTags = async () => {
            const fetchedTags = contract? await contract.getTags() : [];
            setTags(fetchedTags);
        };

        const fetchData = async () => {
            await getTags();
        };
        fetchData();
    }, [contract]);

    return (
        <div style={{ margin: 50 }}>
            <span>Get Tags</span>
            <select>
                {tags.map((tag, index) => (
                    <option key={index} value={tag}>{tag}</option>
                ))}
            </select>
        </div>
    );
};

export default TagsDropdown;

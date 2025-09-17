import React, { useState } from 'react';
import axios from 'axios'; // You'll need to run: npm install axios

// The API endpoint will be provided by our Terraform output
const API_ENDPOINT = 'https://your-cloudfront-url/api/uploads';

function App() {
  const [selectedFile, setSelectedFile] = useState(null);
  const [status, setStatus] = useState('Please select a receipt to upload.');

  const handleFileChange = (event) => {
    setSelectedFile(event.target.files[0]);
  };

  const handleUpload = async () => {
    if (!selectedFile) {
      setStatus('No file selected!');
      return;
    }

    setStatus('Requesting permission to upload...');
    try {
      // 1. Get the presigned URL from our API Gateway
      const response = await axios.post(API_ENDPOINT, {
        fileName: selectedFile.name,
        fileType: selectedFile.type,
      });

      const { uploadUrl, key } = response.data;
      setStatus('Permission granted. Now uploading...');

      // 2. Upload the file directly to S3 using the presigned URL
      await axios.put(uploadUrl, selectedFile, {
        headers: {
          'Content-Type': selectedFile.type,
        },
      });

      setStatus(`Upload successful! File is processing. Key: ${key}`);
    } catch (error) {
      console.error('Upload failed:', error);
      setStatus('Upload failed. Please check the console.');
    }
  };

  return (
    <div>
      <h1>Upload Your Receipt</h1>
      <input type="file" onChange={handleFileChange} accept="image/png, image/jpeg" />
      <button onClick={handleUpload}>Upload</button>
      <p>Status: {status}</p>
    </div>
  );
}

export default App;
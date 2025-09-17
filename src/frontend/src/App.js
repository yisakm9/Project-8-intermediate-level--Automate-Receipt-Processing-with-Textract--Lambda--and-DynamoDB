import React, { useState } from 'react';
import axios from 'axios';
import './App.css'; // Optional: for basic styling

// --- IMPORTANT: URL 
// terraform output cloudfront_distribution_domain_name command
const API_ENDPOINT = `${process.env.REACT_APP_API_BASE_URL}/api/uploads`;

function App() {
  const [selectedFile, setSelectedFile] = useState(null);
  const [status, setStatus] = useState('Please select a receipt to upload.');
  const [isUploading, setIsUploading] = useState(false);

  const handleFileChange = (event) => {
    setSelectedFile(event.target.files[0]);
    setStatus('File selected. Click "Upload".');
  };

  const handleUpload = async () => {
    if (!selectedFile) {
      setStatus('No file selected!');
      return;
    }

    setIsUploading(true);
    setStatus('Requesting permission to upload...');
    try {
      // 1. Get the presigned URL
      const response = await axios.post(API_ENDPOINT, {
        fileName: selectedFile.name,
        fileType: selectedFile.type,
      });

      const { uploadUrl, key } = response.data;
      setStatus('Permission granted. Now uploading...');

      // 2. Upload the file directly to S3
      await axios.put(uploadUrl, selectedFile, {
        headers: {
          'Content-Type': selectedFile.type,
        },
      });

      setStatus(`Success! Your receipt has been submitted for processing.`);
    } catch (error) {
      console.error('Upload failed:', error);
      setStatus('Upload failed. Check the browser console for details.');
    } finally {
      setIsUploading(false);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>Automated Receipt Processor</h1>
        <p>Select a receipt image (.png or .jpg) and click Upload.</p>
        <div className="upload-container">
          <input type="file" onChange={handleFileChange} accept="image/png, image/jpeg" />
          <button onClick={handleUpload} disabled={isUploading}>
            {isUploading ? 'Uploading...' : 'Upload'}
          </button>
        </div>
        <p className="status">Status: {status}</p>
      </header>
    </div>
  );
}

export default App;
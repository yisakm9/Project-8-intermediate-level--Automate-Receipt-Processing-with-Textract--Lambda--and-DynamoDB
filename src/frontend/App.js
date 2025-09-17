// This URL will be replaced by the  CI/CD pipeline.
const API_ENDPOINT = '%%API_BASE_URL%%/api/uploads';

const fileInput = document.getElementById('file-input');
const uploadButton = document.getElementById('upload-button');
const statusElement = document.getElementById('status');

uploadButton.addEventListener('click', async () => {
    const file = fileInput.files[0];
    if (!file) {
        statusElement.textContent = 'No file selected!';
        return;
    }

    uploadButton.disabled = true;
    statusElement.textContent = 'Requesting permission to upload...';

    try {
        const response = await fetch(API_ENDPOINT, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                fileName: file.name,
                fileType: file.type,
            }),
        });

        if (!response.ok) {
            throw new Error(`Failed to get presigned URL: ${response.statusText}`);
        }

        const { uploadUrl } = await response.json();
        statusElement.textContent = 'Permission granted. Now uploading...';

        const uploadResponse = await fetch(uploadUrl, {
            method: 'PUT',
            headers: {
                'Content-Type': file.type,
            },
            body: file,
        });

        if (!uploadResponse.ok) {
            throw new Error(`S3 upload failed: ${uploadResponse.statusText}`);
        }

        statusElement.textContent = 'Success! Your receipt has been submitted for processing.';
    } catch (error) {
        console.error('Upload failed:', error);
        statusElement.textContent = `Upload failed: ${error.message}`;
    } finally {
        uploadButton.disabled = false;
    }
});
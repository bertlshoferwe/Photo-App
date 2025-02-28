import { Storage } from "aws-amplify";
import { useState } from "react";

export default function ImageUpload() {
  const [file, setFile] = useState(null);
  const [uploading, setUploading] = useState(false);

  const handleUpload = async () => {
    if (!file) return;

    setUploading(true);
    try {
      await Storage.put(`uploads/${file.name}`, file, {
        contentType: file.type,
      });
      alert("Upload successful!");
    } catch (error) {
      alert("Upload failed: " + error.message);
    }
    setUploading(false);
  };

  return (
    <div>
      <input type="file" onChange={(e) => setFile(e.target.files[0])} />
      <button onClick={handleUpload} disabled={uploading}>
        {uploading ? "Uploading..." : "Upload"}
      </button>
    </div>
  );
}
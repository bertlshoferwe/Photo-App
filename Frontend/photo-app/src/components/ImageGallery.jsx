import { API, Storage } from "aws-amplify";
import { useEffect, useState } from "react";

export default function ImageGallery() {
  const [images, setImages] = useState([]);

  useEffect(() => {
    async function fetchImages() {
      try {
        const { Contents } = await Storage.list("uploads/");
        const imageUrls = await Promise.all(
          Contents.map(async (item) => ({
            key: item.key,
            url: await Storage.get(item.key),
            metadata: await fetchMetadata(item.key),
          }))
        );
        setImages(imageUrls);
      } catch (error) {
        console.error("Error fetching images:", error);
      }
    }

    async function fetchMetadata(imageKey) {
      try {
        const response = await API.get("PhotoAPI", "/metadata", {
          queryStringParameters: { image_id: imageKey },
        });
        return response;
      } catch {
        return null;
      }
    }

    fetchImages();
  }, []);

  return (
    <div>
      <h2>Your Images</h2>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: "10px" }}>
        {images.map((img) => (
          <div key={img.key}>
            <img src={img.url} alt="Uploaded" width="200" />
            {img.metadata && (
              <p>
                Labels: {img.metadata.labels?.join(", ") || "No labels"}
              </p>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}

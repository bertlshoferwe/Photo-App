import Auth from "./components/Auth";
import ImageUpload from "./components/ImageUpload";
import ImageGallery from "./components/ImageGallery";

export default function App() {
  return (
    <Auth>
      <h1>Google Photos Clone</h1>
      <ImageUpload />
      <ImageGallery />
    </Auth>
  );
}
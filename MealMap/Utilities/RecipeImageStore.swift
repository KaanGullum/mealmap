import UIKit

enum RecipeImageStoreError: Error {
    case invalidImageData
    case writeFailed
}

enum RecipeImageStore {
    private static let directoryName = "RecipeImages"
    private static let maxDimension: CGFloat = 1200
    private static let compressionQuality: CGFloat = 0.8

    static func save(imageData: Data, for recipeID: UUID) throws -> String {
        guard let image = UIImage(data: imageData),
              let resized = resize(image, maxDimension: maxDimension),
              let jpegData = resized.jpegData(compressionQuality: compressionQuality)
        else {
            throw RecipeImageStoreError.invalidImageData
        }

        let fileName = "\(recipeID.uuidString)-\(UUID().uuidString).jpg"
        let fileURL = imageDirectoryURL.appendingPathComponent(fileName)

        do {
            try FileManager.default.createDirectory(at: imageDirectoryURL, withIntermediateDirectories: true)
            try jpegData.write(to: fileURL, options: .atomic)
            return fileName
        } catch {
            throw RecipeImageStoreError.writeFailed
        }
    }

    static func loadImage(named fileName: String) -> UIImage? {
        let fileURL = imageDirectoryURL.appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        return UIImage(contentsOfFile: fileURL.path)
    }

    static func delete(named fileName: String) {
        let fileURL = imageDirectoryURL.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }

    private static var imageDirectoryURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(directoryName)
    }

    private static func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage? {
        let size = image.size
        guard size.width > maxDimension || size.height > maxDimension else {
            return image
        }

        let scale: CGFloat
        if size.width > size.height {
            scale = maxDimension / size.width
        } else {
            scale = maxDimension / size.height
        }

        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

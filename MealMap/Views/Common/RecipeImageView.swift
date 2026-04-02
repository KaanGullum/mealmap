import SwiftUI

struct RecipeImageView: View {
    let imageName: String?
    var height: CGFloat = 56
    var cornerRadius: CGFloat = 12

    var body: some View {
        Group {
            if let imageName, let loadedImage = loadImage(named: imageName) {
                Image(uiImage: loadedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                LinearGradient(
                    colors: [Color.green.opacity(0.3), Color.teal.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay {
                    Image(systemName: "fork.knife")
                        .font(.system(size: min(height * 0.35, 28)))
                        .foregroundStyle(.green.opacity(0.6))
                }
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private func loadImage(named name: String) -> UIImage? {
        if let diskImage = RecipeImageStore.loadImage(named: name) {
            return diskImage
        }
        return UIImage(named: name)
    }
}

struct RecipeThumbnailView: View {
    let imageName: String?
    var size: CGFloat = 56

    var body: some View {
        Group {
            if let imageName, let loadedImage = loadImage(named: imageName) {
                Image(uiImage: loadedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                LinearGradient(
                    colors: [Color.green.opacity(0.3), Color.teal.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay {
                    Image(systemName: "fork.knife")
                        .font(.system(size: size * 0.35))
                        .foregroundStyle(.green.opacity(0.6))
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func loadImage(named name: String) -> UIImage? {
        if let diskImage = RecipeImageStore.loadImage(named: name) {
            return diskImage
        }
        return UIImage(named: name)
    }
}

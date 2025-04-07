import SwiftUI
import UIKit // Using UIKit for UIImage

struct GlassImageGrid: View {
    var images: [UIImage]
    var columns: Int = 2
    var spacing: CGFloat = 16
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns), 
                      spacing: spacing) {
                ForEach(images.indices, id: \.self) { index in
                    ImageTile(image: images[index])
                }
            }
            .padding(.horizontal, spacing)
            .padding(.vertical, 24)
        }
    }
}

struct ImageTile: View {
    var image: UIImage
    @State private var isShowingDetail = false
    
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium))
        }
        .onTapGesture {
            isShowingDetail = true
        }
        .sheet(isPresented: $isShowingDetail) {
            ImageDetailSheet(image: image)
        }
    }
}

struct ImageDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    var image: UIImage
    
    var body: some View {
        if #available(iOS 16.4, *) {
            ZStack {
                // Background blur
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Drag indicator
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(ThemeManager.Colors.textSecondary)
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                    
                    // Large image view
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: UIScreen.main.bounds.height * 0.4)
                        .clipShape(RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.large))
                    
                    // Action buttons in a glass container
                    HStack(spacing: 16) {
                        Button(action: {
                            // Save image
                        }) {
                            Label("Save", systemImage: "square.and.arrow.down")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(GlassButtonStyle())
                        
                        Button(action: {
                            // Share image
                        }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(GlassButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.large)
                            .fill(ThemeManager.Materials.regularGlass)
                    )
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.hidden) // We have our custom indicator
        } else {
            // Fallback on earlier versions
        }
    }
}

// Animation extension for staggered appearance
extension View {
    func staggeredAppearanceAnimation(delay: Double) -> some View {
        self
            .opacity(0)
            .scaleEffect(0.8)
            .onAppear {
                withAnimation(ThemeManager.Animation.standard.delay(delay)) {
                    self.opacity(1)
                    self.scaleEffect(1)
                }
            }
    }
}

#Preview {
    struct Wrapper: View {
        @State var previewImages: [UIImage] = [
            UIImage(systemName: "photo")!,
            UIImage(systemName: "photo")!,
            UIImage(systemName: "photo")!,
            UIImage(systemName: "photo")!
        ]
        
        var body: some View {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        ThemeManager.Colors.pinkPurpleGradientStart,
                        ThemeManager.Colors.pinkPurpleGradientEnd
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                GlassImageGrid(images: previewImages)
            }
        }
    }
    
    return Wrapper()
} 

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
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium))
                
            // Glass overlay on press
            if isPressed {
                RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                    .fill(ThemeManager.Materials.thinGlass)
                    .overlay(
                        HStack {
                            Button(action: {
                                // Save image
                            }) {
                                Label("Save", systemImage: "square.and.arrow.down")
                                    .foregroundColor(ThemeManager.Colors.textPrimary)
                            }
                            .buttonStyle(GlassButtonStyle())
                            
                            Button(action: {
                                // Share image
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .foregroundColor(ThemeManager.Colors.textPrimary)
                            }
                            .buttonStyle(GlassButtonStyle())
                        }
                        .padding()
                    )
            }
        }
        .shadow(radius: isPressed ? ThemeManager.Shadows.medium : ThemeManager.Shadows.small)
        .onTapGesture {
            withAnimation(ThemeManager.Animation.standard) {
                isPressed.toggle()
            }
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
import SwiftUI

struct ButtonPreview: View {
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    ThemeManager.Colors.pinkPurpleGradientStart,
                    ThemeManager.Colors.pinkPurpleGradientEnd
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("Button Styles")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 30) {
                    Text("Icon Styles")
                        .font(.title3)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 20) {
                        // Standard white icon
                        VStack {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                                        .fill(ThemeManager.Materials.regularGlass)
                                )
                            
                            Text("White")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        
                        // Gradient icon
                        VStack {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .iconGradient()
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                                        .fill(ThemeManager.Materials.regularGlass)
                                )
                            
                            Text("Gradient")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        
                        // Clean button style (similar to image)
                        VStack {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .iconGradient()
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    ThemeManager.Colors.purpleButtonStart,
                                                    ThemeManager.Colors.purpleButtonEnd
                                                ]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                )
                            
                            Text("Clean")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                VStack(spacing: 30) {
                    Text("Button Styles")
                        .font(.title3)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 20) {
                        // Original glass button
                        Button(action: {}) {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(GlassButtonStyle())
                        
                        // Clean button (like in the image)
                        Button(action: {
                            isLoading.toggle()
                        }) {
                            Image(systemName: isLoading ? "stop.circle.fill" : "sparkles")
                                .font(.system(size: 22, weight: .medium))
                                .iconGradient()
                        }
                        .buttonStyle(GlowingButtonStyle())
                        
                        // Larger clean button
                        Button(action: {}) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 28, weight: .medium))
                                .iconGradient()
                        }
                        .buttonStyle(GlowingButtonStyle(size: 60))
                    }
                }
                
                // Show in context with text field
                HStack(spacing: 12) {
                    // Text field with glass effect
                    TextField("Enter a prompt", text: .constant(""))
                        .padding(.vertical, 15)
                        .padding(.horizontal, 20)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                                .fill(ThemeManager.Materials.thinGlass)
                        )
                    
                    // Clean button without any glow
                    Button(action: {}) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 22, weight: .medium))
                            .iconGradient()
                    }
                    .buttonStyle(GlowingButtonStyle())
                }
                .padding(.horizontal, 20)
            }
            .padding()
        }
    }
}

#Preview {
    ButtonPreview()
} 
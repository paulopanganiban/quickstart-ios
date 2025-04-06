import SwiftUI

// A theme system to create consistent glass-like UI elements throughout the app
struct ThemeManager {
    // MARK: - Colors
    struct Colors {
        // Original purple gradient
        static let primaryGradientStart = Color(red: 0.25, green: 0.05, blue: 0.35) // Dark purple
        static let primaryGradientEnd = Color(red: 0.1, green: 0.05, blue: 0.2) // Darker purple
        
        // Pink gradient options
        static let pinkGradientStart = Color(red: 0.8, green: 0.1, blue: 0.5) // Bright pink
        static let pinkGradientEnd = Color(red: 0.4, green: 0.1, blue: 0.4) // Deep pink-purple
        
        // Pink-purple gradient - primary theme
        static let pinkPurpleGradientStart = Color(red: 0.7, green: 0.2, blue: 0.5) // Pink
        static let pinkPurpleGradientEnd = Color(red: 0.2, green: 0.05, blue: 0.3) // Deep purple
        
        static let accentColor = Color(red: 0.5, green: 0.3, blue: 0.9) // Bright purple
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.7)
    }
    
    // MARK: - Materials
    struct Materials {
        static let thinGlass = Material.ultraThinMaterial
        static let regularGlass = Material.regularMaterial
        static let thickGlass = Material.thickMaterial
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
    }
    
    // MARK: - Animation
    struct Animation {
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
    }
}

// MARK: - View Extensions for Theming
extension View {
    // Apply a glass background with customizable properties
    func glassBackground(
        cornerRadius: CGFloat = ThemeManager.CornerRadius.medium,
        material: Material = ThemeManager.Materials.thinGlass,
        shadowRadius: CGFloat = ThemeManager.Shadows.medium
    ) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(material)
                .shadow(radius: shadowRadius)
        )
    }
    
    // Apply a gradient background
    func gradientBackground(isPink: Bool = true) -> some View {
        self.background(
            LinearGradient(
                gradient: Gradient(colors: [
                    isPink ? ThemeManager.Colors.pinkPurpleGradientStart : ThemeManager.Colors.primaryGradientStart,
                    isPink ? ThemeManager.Colors.pinkPurpleGradientEnd : ThemeManager.Colors.primaryGradientEnd
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
    
    // Apply a pink gradient background
    func pinkGradientBackground() -> some View {
        self.background(
            LinearGradient(
                gradient: Gradient(colors: [
                    ThemeManager.Colors.pinkGradientStart,
                    ThemeManager.Colors.pinkGradientEnd
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
    
    // Apply a glass card style
    func glassCard(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .glassBackground()
    }
}

// Custom glass button style
struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(ThemeManager.Colors.textPrimary)
            .background(
                RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                    .fill(ThemeManager.Materials.regularGlass)
                    .shadow(radius: configuration.isPressed ? 
                            ThemeManager.Shadows.small : ThemeManager.Shadows.medium)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(ThemeManager.Animation.standard, value: configuration.isPressed)
    }
}

// Glass input field style
struct GlassInputFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .foregroundColor(ThemeManager.Colors.textPrimary)
            .background(
                RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                    .fill(ThemeManager.Materials.thinGlass)
                    .shadow(radius: ThemeManager.Shadows.small)
            )
    }
}

// MARK: - Custom Views
// Glass overlay for progress indicators
struct GlassProgressOverlay: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                .fill(ThemeManager.Materials.thinGlass)
                .frame(width: 120, height: 100)
                .shadow(radius: ThemeManager.Shadows.medium)

            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(ThemeManager.Colors.textPrimary)

                Text("Loading...")
                    .font(.subheadline)
                    .foregroundColor(ThemeManager.Colors.textSecondary)
            }
        }
    }
} 
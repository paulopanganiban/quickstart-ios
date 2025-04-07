import SwiftUI

struct GlassAppHeader: View {
    var title: String
    var subtitle: String? = nil
    var trailingContent: (() -> AnyView)? = nil
    
    init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    init<T: View>(title: String, subtitle: String? = nil, @ViewBuilder trailingContent: @escaping () -> T) {
        self.title = title
        self.subtitle = subtitle
        self.trailingContent = { AnyView(trailingContent()) }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Top section with title and optional action
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(ThemeManager.Colors.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(ThemeManager.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                if let trailingContent = trailingContent {
                    trailingContent()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                    .fill(ThemeManager.Materials.thinGlass)
                  
            )
        }
        .padding(.horizontal)
    }
}

// Extension for View to add a glass app header
extension View {
    func glassAppHeader(title: String, subtitle: String? = nil) -> some View {
        VStack(spacing: 0) {
            GlassAppHeader(title: title, subtitle: subtitle)
            self
        }
    }
    
    func glassAppHeader<T: View>(title: String, subtitle: String? = nil, @ViewBuilder trailingContent: @escaping () -> T) -> some View {
        VStack(spacing: 0) {
            GlassAppHeader(title: title, subtitle: subtitle, trailingContent: trailingContent)
            self
        }
    }
}

#Preview {
    ZStack {
        // Pink gradient background
        LinearGradient(
            gradient: Gradient(colors: [
                ThemeManager.Colors.pinkPurpleGradientStart,
                ThemeManager.Colors.pinkPurpleGradientEnd
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 20) {
            GlassAppHeader(title: "Imagen", subtitle: "Create beautiful images")
            
            GlassAppHeader(title: "Settings") {
                Button(action: {}) {
                    Image(systemName: "gear")
                        .font(.title2)
                        .foregroundColor(ThemeManager.Colors.textPrimary)
                }
                .buttonStyle(GlassButtonStyle())
            }
            
            Spacer()
        }
        .padding(.top)
    }
} 

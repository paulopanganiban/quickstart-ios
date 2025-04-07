import SwiftUI

public struct GlassInputField<Label>: View where Label: View {
    @Binding
    private var text: String

    private var title: String?
    private var label: () -> Label
    private var onSubmit: (() -> Void)?

    public init(_ title: String? = nil, text: Binding<String>,
                onSubmit: (() -> Void)? = nil,
                @ViewBuilder label: @escaping () -> Label) {
        self.title = title
        _text = text
        self.onSubmit = onSubmit
        self.label = label
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    TextField(
                        title ?? "",
                        text: $text,
                        axis: .vertical
                    )
                    .foregroundColor(ThemeManager.Colors.textPrimary)
                    .padding(.vertical, 4)
                    .onSubmit {
                        onSubmit?()
                    }
                    .placeholder(when: text.isEmpty) {
                        Text(title ?? "")
                            .foregroundColor(ThemeManager.Colors.textPrimary.opacity(0.8))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                        .fill(ThemeManager.Materials.thinGlass)
                        // .shadow(radius: ThemeManager.Shadows.small)
                )

                Button(action: {
                    onSubmit?()
                }, label: label)
                .buttonStyle(GlassButtonStyle())
            }
        }
        .padding(8)
    }
}

// Extension for placeholder styling
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// Glass-themed button for the input field
struct GlassActionButton<Content: View>: View {
    var action: () -> Void
    var content: () -> Content
    
    init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content
    }
    
    var body: some View {
        Button(action: action) {
            content()
                .foregroundColor(ThemeManager.Colors.textPrimary)
        }
        .buttonStyle(GlassButtonStyle())
    }
}

#Preview {
    struct Wrapper: View {
        @State var userInput: String = ""

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
                
                VStack {
                    GlassInputField("Enter your message", text: $userInput, onSubmit: {
                        print("Submitted: \(userInput)")
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.title2)
                    }
                    
                    Spacer()
                }
            }
        }
    }

    return Wrapper()
} 
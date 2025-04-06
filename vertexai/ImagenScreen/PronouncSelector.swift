import SwiftUI

struct PronounSelector: View {
    @Binding var selectedPronoun: Pronoun
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Determine my pronoun 🤗")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(ThemeManager.Colors.textPrimary)
            
            HStack(spacing: 16) {
                ForEach(Pronoun.allCases, id: \.self) { pronoun in
                    Button(action: {
                        selectedPronoun = pronoun
                    }) {
                        Text(pronoun.rawValue)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SelectionPillButtonStyle(isSelected: selectedPronoun == pronoun))
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 30)
        .glassBackground(cornerRadius: ThemeManager.CornerRadius.medium)
        .padding(.horizontal)
    }
}

// Pronoun options
enum Pronoun: String, CaseIterable {
    case she = "She"
    case he = "He"
    case they = "They"
}

// Custom name entry field
struct NameEntryField: View {
    @Binding var name: String
    
    var body: some View {
        VStack(spacing: 24) {
            Text("What do you want to call me? 👋")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(ThemeManager.Colors.textPrimary)
            
            TextField("", text: $name)
                .padding(.vertical, 15)
                .padding(.horizontal, 20)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: ThemeManager.CornerRadius.medium)
                        .fill(ThemeManager.Materials.thinGlass)
                )
                .multilineTextAlignment(.center)
                .font(.title3)
                .fontWeight(.medium)
        }
        .padding(.vertical, 30)
        .glassBackground(cornerRadius: ThemeManager.CornerRadius.medium)
        .padding(.horizontal)
    }
}

#Preview {
    struct ContentView: View {
        @State private var selectedPronoun: Pronoun = .she
        @State private var name: String = ""
        
        var body: some View {
            ZStack {
                // Pink-purple gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        ThemeManager.Colors.pinkPurpleGradientStart,
                        ThemeManager.Colors.pinkPurpleGradientEnd
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    NameEntryField(name: $name)
                    
                    PronounSelector(selectedPronoun: $selectedPronoun)
                }
            }
        }
    }
    
    return ContentView()
} 
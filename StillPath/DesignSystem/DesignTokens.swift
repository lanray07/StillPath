import SwiftUI

enum StillPathColor {
    static let sage = Color(red: 0.25, green: 0.40, blue: 0.34)
    static let moss = Color(red: 0.16, green: 0.27, blue: 0.23)
    static let cream = Color(red: 0.96, green: 0.94, blue: 0.89)
    static let clay = Color(red: 0.72, green: 0.48, blue: 0.36)
    static let mist = Color(red: 0.88, green: 0.91, blue: 0.88)
}

enum StillPathSpacing { static let xs: CGFloat = 6; static let sm: CGFloat = 12; static let md: CGFloat = 20; static let lg: CGFloat = 32; static let xl: CGFloat = 48 }
enum StillPathRadius { static let small: CGFloat = 12; static let card: CGFloat = 24; static let capsule: CGFloat = 999 }

struct CalmBackground: View {
    var body: some View {
        LinearGradient(colors: [StillPathColor.cream.opacity(0.72), Color(.systemBackground)], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

struct StillPathCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content.padding(StillPathSpacing.md).frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: StillPathRadius.card, style: .continuous))
            .overlay { RoundedRectangle(cornerRadius: StillPathRadius.card).stroke(StillPathColor.sage.opacity(0.12)) }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.headline).frame(maxWidth: .infinity).padding(.vertical, 16)
            .foregroundStyle(.white).background(StillPathColor.moss.opacity(configuration.isPressed ? 0.8 : 1), in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}


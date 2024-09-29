import SwiftUI
/// HUD showing the page number
struct HUDView: View {
    var state: DocumentState

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("\(state.pageNum)")
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .foregroundColor(.white)
                    .background(Color(.black).opacity(0.25),
                                in: RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                    .offset(x: -10, y: -10)
            }
        }
    }
}

#Preview {
    HUDView(state: DocumentState())
}

import SwiftUI

struct HUDView: View {
    var state: DocumentState
    @State private var opacity: Double = 0

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("\(state.pageNum)")
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .monospacedDigit()
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .foregroundColor(.white)
                    .background(Color(.black).opacity(0.25),
                                in: RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                    .offset(x: -10, y: -10)
                    .opacity(opacity)
            }
        }
        .onChange(of: state.pageNum) { oldValue, newValue in updateHUD() }
        .onAppear { updateHUD() }
    }

    private func updateHUD() {
        withAnimation(.easeIn(duration: 0.3)) { opacity = 1 }
        withAnimation(.easeOut(duration: 0.3).delay(1)) { opacity = 0}
    }
}

#Preview {
    HUDView(state: DocumentState())
}

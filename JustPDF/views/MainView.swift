import SwiftUI

struct MainView: View {
    let document: Document
    @State private var state = DocumentState()
    
    var body: some View {
        MinimalPDFView(pdf: document.pdf, state: state)
            .ignoresSafeArea()
            .focusedSceneValue(\.state, state)
            .overlay {
                HUDView(state: state)
            }
    }
}

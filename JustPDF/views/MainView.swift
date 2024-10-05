import SwiftUI
import SwiftData

struct MainView: View {
    let doc: Document

    @Query private var docStates: [DocState]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        let docState = docStates.first(where: { $0.id == doc.id }) ?? {
            let newState = DocState(id: doc.id, scaleFactor: 1.0, pageNum: 1)
            modelContext.insert(newState)
            return newState
        }()

        MinimalPDFView(doc: doc.pdf, docState: docState)
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay { HUDView(pageNum: docState.pageNum) }
            .focusedSceneValue(\.docState, docState)
    }
}

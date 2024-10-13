import SwiftUI
import SwiftData

struct MainView: View {
    let doc: Document
    @State var showGotoDialog = false

    @Query private var docStates: [DocState]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        let docState = docStates.first(where: { $0.id == doc.id }) ?? {
            let newState = DocState(id: doc.id, scaleFactor: 1.0, pageNum: 1, totalPages: doc.pdf.pageCount, displayMode: .singlePage)
            modelContext.insert(newState)
            return newState
        }()

        MinimalPDFView(doc: doc.pdf, docState: docState)
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay { HUDView(pageNum: docState.pageNum, totalPages: docState.totalPages) }
            .focusedSceneValue(\.docState, docState)
            .focusedSceneValue(\.showGotoDialog, $showGotoDialog)
            .sheet(isPresented: $showGotoDialog) {
                GoToPageDialog(
                    isPresented: $showGotoDialog,
                    docState: docState,
                    pageNumText: "\(docState.pageNum)"
                )
            }
    }
}

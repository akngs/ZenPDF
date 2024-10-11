import SwiftUI

struct GoToPageDialog: View {
    @Binding var isPresented: Bool
    @State var docState: DocState
    @State var pageNumText: String
    @State private var isInputValid = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            HStack() {
                Text("Go to page (1 to \(docState.totalPages)):")
                TextField("Page number", text: $pageNumText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
                    .focused($isTextFieldFocused)
                    .onChange(of: pageNumText) { isInputValid = docState.isValid(pageNum: Int(pageNumText) ?? 0) }
                    .onSubmit { onSubmit() }
            }
            
            HStack() {
                Button("Cancel") { isPresented = false }
                    .keyboardShortcut(.cancelAction)
                
                Button("Go") { onSubmit() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!isInputValid)
            }
        }
        .padding()
        .onAppear { isTextFieldFocused = true }
    }
    
    func onSubmit() {
        if let pageNum = Int(pageNumText), docState.isValid(pageNum: pageNum) {
            docState.gotoPage(at: pageNum)
            isPresented = false
        }
    }
}

import SwiftUI

struct GoToPageDialog: View {
    @Binding var isPresented: Bool
    @Binding var pageNumber: String
    var onSubmit: (Int) -> Void

    @State private var isInputValid = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            HStack() {
                Text("Go to page:")
                TextField("Page number", text: $pageNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 60)
                    .focused($isTextFieldFocused)
                    .onChange(of: pageNumber) { oldValue, newValue in
                        isInputValid = Int(newValue) != nil && Int(newValue)! > 0
                    }
                    .onSubmit(submitIfValid)
            }
            
            HStack() {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Go") {
                    submitIfValid()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isInputValid)
            }
        }
        .padding()
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private func submitIfValid() {
        if let page = Int(pageNumber), page > 0 {
            onSubmit(page)
            isPresented = false
        }
    }
}

#Preview {
    GoToPageDialog(isPresented: .constant(true), pageNumber: .constant("1"), onSubmit: { _ in })
}

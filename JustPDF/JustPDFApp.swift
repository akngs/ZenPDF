import SwiftUI

@main
struct JustPDFApp: App {
    @StateObject private var state = State()

    var body: some Scene {
        DocumentGroup(newDocument: JustPDFDocument()) { file in
            ContentView(document: file.$document, state: state)
        }
        .commands {
            CommandGroup(after: .sidebar) {
                Button("Reset zoom") { state.resetZoom() }.keyboardShortcut("0", modifiers: [.command])
                Button("Zoom-in") { state.zoomIn() }.keyboardShortcut("=", modifiers: [.command])
                Button("Zoom-out") { state.zoomOut() }.keyboardShortcut("-", modifiers: [.command])
                Divider()
                Button("Previous page") { state.goToPreviousPage() }.keyboardShortcut(.leftArrow, modifiers: [])
                Button("Next page") { state.goToNextPage() }.keyboardShortcut(.rightArrow, modifiers: [])
                Divider()
            }
        }
    }
}

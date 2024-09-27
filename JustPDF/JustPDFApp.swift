import SwiftUI

@main
struct JustPDFApp: App {
    @StateObject private var pdfViewerState = PDFViewerState()

    var body: some Scene {
        DocumentGroup(newDocument: JustPDFDocument()) { file in
            ContentView(document: file.$document, pdfViewerState: pdfViewerState)
        }
        .commands {
            // Add commands into "View" menu
            CommandGroup(after: .sidebar) {
                Button("Fit to window") { pdfViewerState.command = .fitToWindow }.keyboardShortcut("0", modifiers: [.command])
                Button("Zoom-in") { pdfViewerState.command = .zoomIn }.keyboardShortcut("=", modifiers: [.command])
                Button("Zoom-out") { pdfViewerState.command = .zoomOut }.keyboardShortcut("-", modifiers: [.command])
                Divider()
                Button("Previous page") { pdfViewerState.command = .prevPage }.keyboardShortcut(.leftArrow, modifiers: [])
                Button("Next page") { pdfViewerState.command = .nextPage }.keyboardShortcut(.rightArrow, modifiers: [])
                Divider()
            }
        }
    }
}

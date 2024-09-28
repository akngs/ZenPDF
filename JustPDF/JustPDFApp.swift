import SwiftUI
import PDFKit
import Cocoa
import UniformTypeIdentifiers

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

struct ContentView: View {
    @Binding var document: JustPDFDocument
    @ObservedObject var state: State

    var body: some View {
        ChromelessPDF(document: document.pdfDocument, pdfViewerState: state)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .ignoresSafeArea()
    }
}

class State: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var scaleFactor: CGFloat = 1.0

    func zoomIn() { scaleFactor *= 1.02 }
    func zoomOut() { scaleFactor *= 0.98 }
    func resetZoom() { scaleFactor = 1.0 }
    func goToPreviousPage() { currentPage = max(currentPage - 1, 0) }
    func goToNextPage() { currentPage += 1 }
}

struct ChromelessPDF: NSViewRepresentable {
    let document: PDFDocument?
    @ObservedObject var pdfViewerState: State

    func makeNSView(context: Context) -> JustPDFView {
        let pdfView = JustPDFView()
        pdfView.autoScales = true
        pdfView.displaysPageBreaks = false
        pdfView.displayMode = .singlePage

        DispatchQueue.main.async {
            if let window = pdfView.window {
                window.styleMask = [.borderless, .miniaturizable, .resizable, .closable]
                window.isMovableByWindowBackground = true
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.standardWindowButton(.closeButton)?.isHidden = true
                window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                window.standardWindowButton(.zoomButton)?.isHidden = true
                pdfView.setScaleFactor(pdfViewerState.scaleFactor)
            }
        }

        return pdfView
    }

    func updateNSView(_ pdfView: JustPDFView, context: Context) {
        pdfView.document = document
        pdfView.goToPage(pdfViewerState.currentPage)
        pdfView.setScaleFactor(pdfViewerState.scaleFactor)
    }
}

class JustPDFView: PDFView {
    private var zoomStep: CGFloat = 0.02

    func setScaleFactor(_ scaleFactor: CGFloat) {
        self.scaleFactor = scaleFactorForSizeToFit * scaleFactor
    }

    func goToPage(_ pageNumber: Int) {
        if let page = document?.page(at: pageNumber) { go(to:page) }
    }
}

class JustPDFDocument: FileDocument {
    // Define the supported content types
    static var readableContentTypes: [UTType] { [.pdf] }
    
    @Published var pdfDocument: PDFDocument?

    // Initialize from a file
    required init(configuration: ReadConfiguration) throws {
        // Load the PDF document from the file data
        if let data = configuration.file.regularFileContents {
            pdfDocument = PDFDocument(data: data)
        }
    }

    // Save logic (if needed, can be adapted for PDF creation/saving)
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let pdf = pdfDocument else { throw CocoaError(.fileReadCorruptFile) }
        guard let data = pdf.dataRepresentation() else { throw CocoaError(.fileReadCorruptFile) }
        return FileWrapper(regularFileWithContents: data)
    }

    // Initialize an empty document
    init() {
        self.pdfDocument = PDFDocument()
    }
}

#Preview {
    ContentView(document: .constant(JustPDFDocument()), state: State())
}

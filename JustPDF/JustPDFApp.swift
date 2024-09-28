import SwiftUI
import PDFKit
import Cocoa
import UniformTypeIdentifiers

@main
struct JustPDFApp: App {
    var body: some Scene {
        DocumentGroup(viewing: Document.self) { file in
            ContentView(document: file.document).background(WindowAccessor())
        }
        .commands {
            CommandGroup(after: .sidebar) {
                Button("Reset zoom") { coord?.resetZoom() }
                    .keyboardShortcut("0")
                
                Button("Zoom-in") { coord?.zoomIn() }
                    .keyboardShortcut("=")
                
                Button("Zoom-out") { coord?.zoomOut() }
                    .keyboardShortcut("-")
                
                Divider()
                
                Button("Previous page") { coord?.goToPreviousPage() }
                    .keyboardShortcut(.leftArrow, modifiers: [])
                    .disabled(coord == nil)
                
                Button("Next page") { coord?.goToNextPage() }
                    .keyboardShortcut(.rightArrow, modifiers: [])
                    .disabled(coord == nil)
                
                Divider()
            }
        }
        .windowStyle(.hiddenTitleBar)
    }
    
    @FocusedValue(\.pdfCoord) var coord: PDFViewCoord?
}

struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                let controller = NSWindowController(window: window)
                controller.window?.delegate = context.coordinator
                context.coordinator.configureWindowAppearance(window)
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    class Coordinator: NSObject, NSWindowDelegate {
        func windowDidResignKey(_ notification: Notification) {
            guard let window = notification.object as? NSWindow else { return }
            configureWindowAppearance(window)
        }
        
        func configureWindowAppearance(_ window: NSWindow) {
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.styleMask.insert(.fullSizeContentView)
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
            window.standardWindowButton(.closeButton)?.isHidden = true
        }
    }
}

struct ContentView: View {
    let document: Document
    @StateObject private var pdfCoordinator = PDFViewCoord()
    
    var body: some View {
        ChromelessPDF(pdf: document.pdf, coordinator: pdfCoordinator)
            .ignoresSafeArea()
            .focusedSceneValue(\.pdfCoord, pdfCoordinator)
    }
}

struct ChromelessPDF: NSViewRepresentable {
    let pdf: PDFDocument?
    var coordinator: PDFViewCoord
    
    func makeNSView(context: Context) -> PDFView {
        let pdfView = TrickedPDFView()
        pdfView.autoScales = true
        pdfView.displaysPageBreaks = false
        pdfView.displayMode = .singlePage
        pdfView.shadow = .none
        pdfView.pageShadowsEnabled = false
        pdfView.backgroundColor = .black
        
        coordinator.pdfView = pdfView
        
        return pdfView
    }
    
    func updateNSView(_ pdfView: PDFView, context: Context) {
        pdfView.document = pdf
    }
    
    private class TrickedPDFView: PDFView {
        private let ZOOM_FACTOR: CGFloat = 1.05
        
        override func layout() {
            super.layout()
            if let scrollView = self.subviews.first as? NSScrollView {
                scrollView.automaticallyAdjustsContentInsets = false
                scrollView.contentInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
        
        override func zoomIn(_ sender: Any?) { gradualZoom(isZoomingIn: true) }
        override func zoomOut(_ sender: Any?) { gradualZoom(isZoomingIn: false) }
        
        private func gradualZoom(isZoomingIn: Bool) {
            let newScale = isZoomingIn ? self.scaleFactor * ZOOM_FACTOR : self.scaleFactor / ZOOM_FACTOR
            self.scaleFactor = min(max(newScale, minScaleFactor), maxScaleFactor)
        }
    }
}

class PDFViewCoord: ObservableObject {
    weak var pdfView: PDFView?
    
    func resetZoom() { pdfView?.scaleFactor = pdfView?.scaleFactorForSizeToFit ?? 1.0 }
    func zoomIn() { pdfView?.zoomIn(nil) }
    func zoomOut() { pdfView?.zoomOut(nil) }
    func goToNextPage() { pdfView?.goToNextPage(nil) }
    func goToPreviousPage() { pdfView?.goToPreviousPage(nil) }
}

struct PDFCoordKey: FocusedValueKey {
    typealias Value = PDFViewCoord
}

extension FocusedValues {
    var pdfCoord: PDFViewCoord? {
        get { self[PDFCoordKey.self] }
        set { self[PDFCoordKey.self] = newValue }
    }
}

struct Document: FileDocument {
    static var readableContentTypes: [UTType] { [.pdf] }
    
    var pdf: PDFDocument?
    
    init() { self.pdf = PDFDocument() }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else { throw DocumentError.unableToReadFile }
        guard let pdf = PDFDocument(data: data) else { throw DocumentError.invalidPDFData }
        self.pdf = pdf
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let pdf = pdf else { throw DocumentError.noPDFDocument }
        guard let data = pdf.dataRepresentation() else { throw DocumentError.unableToCreateFileWrapper }
        return FileWrapper(regularFileWithContents: data)
    }
}

enum DocumentError: Error {
    case unableToReadFile
    case invalidPDFData
    case noPDFDocument
    case unableToCreateFileWrapper
}

#Preview {
    ContentView(document: Document())
}

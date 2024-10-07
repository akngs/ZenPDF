import SwiftUI
@preconcurrency import PDFKit
import UniformTypeIdentifiers
import CryptoKit

@main
struct JustPDFApp: App {
    @FocusedValue(\.docState) var docState: DocState?
    @FocusedBinding(\.showGotoDialog) var showGotoDialog

    var body: some Scene {
        DocumentGroup(viewing: Document.self) { file in
            MainView(doc: file.document)
                .background(WindowAccessor())
                .modelContainer(for: [DocState.self])
        }
        .commands {
            CommandGroup(after: .sidebar) {
                Button("Reset zoom") { docState?.resetZoom() }
                    .keyboardShortcut("0")
                
                Button("Zoom-in") { docState?.zoomIn() }
                    .keyboardShortcut("=")
                
                Button("Zoom-out") { docState?.zoomOut() }
                    .keyboardShortcut("-")
                
                Divider()
                
                Button("Previous page") { docState?.prevPage() }
                    .keyboardShortcut(.leftArrow, modifiers: [])
                    .disabled(docState == nil)
                
                Button("Next page") { docState?.nextPage() }
                    .keyboardShortcut(.rightArrow, modifiers: [])
                    .disabled(docState == nil)

                Button("Go to page...") { showGotoDialog? = true }
                    .keyboardShortcut("g")
                    .disabled(docState == nil)

                Divider()
            }
        }
        .windowStyle(.hiddenTitleBar)
    }
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
        
        @MainActor func configureWindowAppearance(_ window: NSWindow) {
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.styleMask.insert(.fullSizeContentView)
            window.standardWindowButton(.miniaturizeButton)?.layer?.opacity = 0.25
            window.standardWindowButton(.zoomButton)?.layer?.opacity = 0.25
            window.standardWindowButton(.closeButton)?.layer?.opacity = 0.25
        }
    }
}

struct Document: FileDocument {
    static var readableContentTypes: [UTType] { [.pdf] }
    
    let id: String
    let pdf: PDFDocument
    
    init() {
        self.id = "Untitled"
        self.pdf = PDFDocument()
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else { throw DocumentError.unableToReadFile }
        guard let pdf = PDFDocument(data: data) else { throw DocumentError.invalidPDFData }
        
        self.id = Document.generateId(document: pdf, filename: configuration.file.filename)
        self.pdf = pdf
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        throw DocumentError.readonly
    }
    
    private static func generateId(document: PDFDocument, filename: String?) -> String {
        let pageCount = document.pageCount
        let text0 = document.page(at: 0)?.string ?? ""
        let text1 = document.page(at: 1)?.string ?? ""
        let identifier = "\(filename ?? "Untitled")_\(pageCount)_\(text0)_\(text1)"
        return SHA256.hash(data: Data(identifier.utf8)).compactMap { String(format: "%02x", $0) }.joined()
    }
}

enum DocumentError: Error {
    case unableToReadFile
    case invalidPDFData
    case readonly
}

struct DocStateKey: FocusedValueKey {
    typealias Value = DocState
}

struct ShowGotoDialogKey: FocusedValueKey {
    typealias Value = Binding<Bool>
}

extension FocusedValues {
    var docState: DocState? {
        get { self[DocStateKey.self] }
        set { self[DocStateKey.self] = newValue }
    }
    
    var showGotoDialog: Binding<Bool>? {
        get { self[ShowGotoDialogKey.self] }
        set { self[ShowGotoDialogKey.self] = newValue }
    }
}

#Preview {
    MainView(doc: Document())
}

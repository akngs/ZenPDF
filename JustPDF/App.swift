import SwiftUI

@main
struct JustPDFApp: App {
    @State private var showGoToPageDialog = false
    @State private var goToPageNumber = "1"

    var body: some Scene {
        DocumentGroup(viewing: Document.self) { file in
            MainView(document: file.document)
                .background(WindowAccessor())
                .sheet(isPresented: $showGoToPageDialog) {
                    GoToPageDialog(
                        isPresented: $showGoToPageDialog,
                        pageNumber: $goToPageNumber,
                        onSubmit: { page in state?.goToPage(at: page) }
                    )
                }
        }
        .commands {
            CommandGroup(after: .sidebar) {
                Button("Reset zoom") { state?.resetZoom() }
                    .keyboardShortcut("0")
                
                Button("Zoom-in") { state?.zoomIn() }
                    .keyboardShortcut("=")
                
                Button("Zoom-out") { state?.zoomOut() }
                    .keyboardShortcut("-")
                
                Divider()
                
                Button("Previous page") { state?.goToPreviousPage() }
                    .keyboardShortcut(.leftArrow, modifiers: [])
                    .disabled(state == nil)
                
                Button("Next page") { state?.goToNextPage() }
                    .keyboardShortcut(.rightArrow, modifiers: [])
                    .disabled(state == nil)

                Button("Go to page...") {
                    if let pageNum = state?.pageNum {
                        goToPageNumber = "\(pageNum)"
                        showGoToPageDialog = true
                    }
                }
                    .keyboardShortcut("g")
                    .disabled(state == nil)

                Divider()
            }
        }
        .windowStyle(.hiddenTitleBar)
    }
    
    @FocusedValue(\.state) var state: DocumentState?
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

#Preview {
    MainView(document: Document())
}

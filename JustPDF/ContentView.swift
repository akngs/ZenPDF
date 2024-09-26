import SwiftUI
import PDFKit
import Cocoa

struct ContentView: View {
    @Binding var document: JustPDFDocument
    @StateObject private var windowDelegate = WindowDelegate()
    
    var body: some View {
        PDFViewer(document: $document)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .ignoresSafeArea()
            .onAppear {
                for window in NSApplication.shared.windows {
                    window.delegate = windowDelegate
                    windowDelegate.applyWindowSettings(to: window)
                }
            }
    }
}

class WindowDelegate: NSObject, NSWindowDelegate, ObservableObject {
    func windowDidBecomeKey(_ notification: Notification) {
        if let window = notification.object as? NSWindow { applyWindowSettings(to: window) }
    }
    
    func windowDidResignKey(_ notification: Notification) {
        if let window = notification.object as? NSWindow { applyWindowSettings(to: window) }
    }

    func applyWindowSettings(to window: NSWindow) {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.isMovableByWindowBackground = true
            window.styleMask.insert(.fullSizeContentView)
            window.backgroundColor = .clear

            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
        }
    }
}

/// Chromeless PDF viewer
struct PDFViewer: NSViewRepresentable {
    @Binding var document: JustPDFDocument

    func makeNSView(context: Context) -> NSView {
        let containerView = NSView()
        let pdfView = JustPDFView()
        pdfView.autoScales = true
        pdfView.displaysPageBreaks = false
        pdfView.displayMode = .singlePage
        pdfView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(pdfView)
        NSLayoutConstraint.activate([
            pdfView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pdfView.topAnchor.constraint(equalTo: containerView.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let pdfView = nsView.subviews.first as? JustPDFView {
            pdfView.document = document.pdfDocument
        }
    }
}

/// This view adds two things to the PDFView:
///
/// - Fine-grained zoom
/// - Page navigation using the left and right arrows.
///
class JustPDFView: PDFView {
    private var zoomIncrement: CGFloat = 0.02
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        setupContentInsets()
        NotificationCenter.default.addObserver(self, selector: #selector(pageDidChange(_:)), name: .PDFViewPageChanged, object: self)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupContentInsets()
        NotificationCenter.default.addObserver(self, selector: #selector(pageDidChange(_:)), name: .PDFViewPageChanged, object: self)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .PDFViewPageChanged, object: self)
    }

    @objc private func pageDidChange(_ notification: Notification) {
        adjustContentInsets()
    }

    private func setupContentInsets() {
        adjustContentInsets()
    }

    // Without this code, goToPreviousPage() and goToNextPage() will shrink the content
    private func adjustContentInsets() {
        if let scrollView = subviews.first as? NSScrollView {
            scrollView.automaticallyAdjustsContentInsets = false
            scrollView.contentInsets = NSEdgeInsetsZero
            scrollView.contentView.contentInsets = NSEdgeInsetsZero
        }
    }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 126: // Up
            goToPreviousPage(self)
        case 123: // Left
            goToPreviousPage(self)
        case 125: // Down
            goToNextPage(self)
        case 124: // Right
            goToNextPage(self)
        case 32: // Space
            event.modifierFlags.contains(.shift) ? goToPreviousPage(self) : goToNextPage(self)
        default: // Everything else
            super.keyDown(with: event)
        }
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.modifierFlags.contains(.command), let characters = event.charactersIgnoringModifiers {
            switch characters {
            case "=":
                zoomIn()
                return true
            case "-":
                zoomOut()
                return true
            case "0":
                resetZoom()
                return true
            default:
                break
            }
        }
        return super.performKeyEquivalent(with: event)
    }
    
    private func zoomIn() {
        scaleFactor = min(scaleFactor * (1.0 + zoomIncrement), maxScaleFactor)
    }
    
    private func zoomOut() {
        scaleFactor = max(scaleFactor * (1.0 - zoomIncrement), minScaleFactor)
    }
    
    private func resetZoom() {
        scaleFactor = scaleFactorForSizeToFit
    }
}

#Preview {
    ContentView(document: .constant(JustPDFDocument()))
}

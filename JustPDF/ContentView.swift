import SwiftUI
import PDFKit
import Cocoa

struct ContentView: View {
    @Binding var document: JustPDFDocument
    @ObservedObject var pdfViewerState: PDFViewerState
    
    var body: some View {
        ChromelessPDF(document: document.pdfDocument, pdfViewerState: pdfViewerState)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .ignoresSafeArea()
    }
}

class PDFViewerState: ObservableObject {
    @Published var command: PDFViewerCommand?
}

enum PDFViewerCommand {
    case fitToWindow
    case zoomIn
    case zoomOut
    case prevPage
    case nextPage
}

struct ChromelessPDF: NSViewRepresentable {
    let document: PDFDocument?
    @ObservedObject var pdfViewerState: PDFViewerState

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
            }
        }

        return pdfView
    }

    func updateNSView(_ pdfView: JustPDFView, context: Context) {
        pdfView.document = document
        
        if let command = pdfViewerState.command {
            execute(command, on: pdfView)
        }
    }

    func execute(_ command: PDFViewerCommand, on pdfView: JustPDFView) {
        switch command {
        case .fitToWindow:
            pdfView.fitToWindow()
        case .zoomIn:
            pdfView.zoomIn()
        case .zoomOut:
            pdfView.zoomOut()
        case .prevPage:
            pdfView.goToPreviousPage(nil)
        case .nextPage:
            pdfView.goToNextPage(nil)
        }

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            pdfViewerState.command = nil
        }
    }
}

class JustPDFView: PDFView {
    private var zoomStep: CGFloat = 0.02

    func zoomIn() {
        scaleFactor = min(scaleFactor * (1.0 + zoomStep), maxScaleFactor)
    }
    
    func zoomOut() {
        scaleFactor = max(scaleFactor * (1.0 - zoomStep), minScaleFactor)
    }
    
    func fitToWindow() {
        scaleFactor = scaleFactorForSizeToFit
    }
}

#Preview {
    ContentView(document: .constant(JustPDFDocument()), pdfViewerState: PDFViewerState())
}

import SwiftUI
import PDFKit

/// PDFView without shadow and margins
struct MinimalPDFView: NSViewRepresentable {
    let pdf: PDFDocument?
    var state: DocumentState
    
    func makeNSView(context: Context) -> PDFView {
        let pdfView = GraduallyZoomablePDFView()
        pdfView.autoScales = true
        pdfView.displaysPageBreaks = false
        pdfView.displayMode = .singlePage
        pdfView.shadow = .none
        pdfView.pageShadowsEnabled = false
        
        state.pdfView = pdfView
        
        return pdfView
    }
    
    func updateNSView(_ pdfView: PDFView, context: Context) {
        pdfView.document = pdf
    }
    
    private class GraduallyZoomablePDFView: PDFView {
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

#Preview {
    MinimalPDFView(pdf: nil, state: DocumentState())
}

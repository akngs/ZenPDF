import SwiftUI
import PDFKit

/// PDFView without shadow and margins
struct MinimalPDFView: NSViewRepresentable {
    let doc: PDFDocument?
    var docState: DocState
    
    func makeNSView(context: Context) -> PDFView {
        let pdfView = LayoutAdjustedPDFView()
        pdfView.autoScales = true
        pdfView.displaysPageBreaks = false
        pdfView.displayMode = .singlePage
        pdfView.shadow = .none
        pdfView.pageShadowsEnabled = false
        pdfView.document = doc
        
        if let doc, let page = doc.page(at: docState.pageNum - 1) {
            pdfView.go(to: page)
            // TODO: pdfView.scaleFactorForSizeToFit is zero right after the doc has opened
            pdfView.scaleFactor = docState.scaleFactor * max(pdfView.scaleFactorForSizeToFit, 1.0)
        }

        context.coordinator.registerForNotifications(pdfView: pdfView)

        return pdfView
    }

    func updateNSView(_ pdfView: PDFView, context: Context) {
        pdfView.document = doc
        if let doc,
           let page = doc.page(at: docState.pageNum - 1) {

            pdfView.go(to: page)
            // TODO: pdfView.scaleFactorForSizeToFit is zero right after the doc has opened
            pdfView.scaleFactor = docState.scaleFactor * max(pdfView.scaleFactorForSizeToFit, 1.0)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject {
        var parent: MinimalPDFView
         
        init(_ parent: MinimalPDFView) {
            self.parent = parent
        }

        func registerForNotifications(pdfView: PDFView) {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(pageChanged(_:)),
                                                   name: .PDFViewPageChanged,
                                                   object: pdfView)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(scaleChanged(_:)),
                                                   name: .PDFViewScaleChanged,
                                                   object: pdfView)
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self, name: .PDFViewPageChanged, object: nil)
            NotificationCenter.default.removeObserver(self, name: .PDFViewScaleChanged, object: nil)
        }
        
        @MainActor @objc func pageChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView,
                  let currentPage = pdfView.currentPage,
                  let doc = pdfView.document else { return }
            parent.docState.gotoPage(at: doc.index(for: currentPage) + 1)
        }
        
        @MainActor @objc func scaleChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView else { return }
            parent.docState.setZoom(to: pdfView.scaleFactor / pdfView.scaleFactorForSizeToFit)
        }
    }
    
    private class LayoutAdjustedPDFView: PDFView {
        override func layout() {
            super.layout()
            if let scrollView = self.subviews.first as? NSScrollView {
                scrollView.automaticallyAdjustsContentInsets = false
                scrollView.contentInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
    }
}

#Preview {
    MinimalPDFView(doc: nil, docState: DocState(id: "Untitled", scaleFactor: 1.0, pageNum: 1, totalPages: 10))
}

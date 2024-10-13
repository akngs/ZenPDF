import SwiftUI
import PDFKit

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
        
        context.coordinator.registerForNotifications(pdfView: pdfView)

        return pdfView
    }

    func updateNSView(_ pdfView: PDFView, context: Context) {
        pdfView.document = doc
        context.coordinator.updatePDFView(pdfView)
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
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(displayModeChanged(_:)),
                                                   name: .PDFViewDisplayModeChanged,
                                                   object: pdfView)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(boundsChanged(_:)),
                                                   name: NSView.frameDidChangeNotification,
                                                   object: pdfView)
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        @MainActor @objc func pageChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView,
                  let currentPage = pdfView.currentPage,
                  let doc = pdfView.document else { return }
            parent.docState.gotoPage(at: doc.index(for: currentPage) + 1)
        }
        
        @MainActor @objc func scaleChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView else { return }
            pdfView.scaleFactor = parent.docState.scaleFactor * pdfView.scaleFactorForSizeToFit
        }
        
        @MainActor @objc func displayModeChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView else { return }
            parent.docState.setDisplayMode(to: pdfView.displayMode)
        }

        @MainActor @objc func boundsChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView else { return }
            pdfView.scaleFactor = parent.docState.scaleFactor * pdfView.scaleFactorForSizeToFit
        }
        
        @MainActor func updatePDFView(_ pdfView: PDFView) {
            if let doc = parent.doc,
               let page = doc.page(at: parent.docState.pageNum - 1) {

                pdfView.displayMode = PDFDisplayMode(rawValue: parent.docState.displayMode)!
                pdfView.go(to: page)
                pdfView.scaleFactor = parent.docState.scaleFactor * pdfView.scaleFactorForSizeToFit
            }
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
    MinimalPDFView(doc: nil, docState: DocState(id: "Untitled", scaleFactor: 1.0, pageNum: 1, totalPages: 10, displayMode: .singlePage))
}

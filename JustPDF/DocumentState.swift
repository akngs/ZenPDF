import SwiftUI
import PDFKit

@Observable
class DocumentState {
    weak var pdfView: PDFView?
    var pageNum: Int = 1

    func resetZoom() { pdfView?.scaleFactor = pdfView?.scaleFactorForSizeToFit ?? 1.0 }
    func zoomIn() { pdfView?.zoomIn(nil) }
    func zoomOut() { pdfView?.zoomOut(nil) }

    func goToNextPage() {
        pdfView?.goToNextPage(nil)
        pageNum = pdfView?.currentPage?.pageRef?.pageNumber ?? pageNum
    }

    func goToPreviousPage() {
        pdfView?.goToPreviousPage(nil)
        pageNum = pdfView?.currentPage?.pageRef?.pageNumber ?? pageNum
    }
}

struct PDFViewStateKey: FocusedValueKey {
    typealias Value = DocumentState
}

extension FocusedValues {
    var state: DocumentState? {
        get { self[PDFViewStateKey.self] }
        set { self[PDFViewStateKey.self] = newValue }
    }
}

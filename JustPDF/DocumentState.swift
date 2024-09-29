import SwiftUI
import PDFKit
import CryptoKit

@Observable
class DocumentState {
    weak var pdfView: PDFView?
    weak var pdf: PDFDocument? {
        didSet {
            guard let pdf = pdf else { return }
            docId = generateDocId(for: pdf)
            loadState()
        }
    }
    
    var docId: String?
    var scaleFactor: CGFloat = 1.0
    var pageNum: Int = 1
    
    func resetZoom() {
        guard let pdfView = pdfView else { return }
        
        pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
        updateState()
    }

    func zoomIn() {
        pdfView?.zoomIn(nil)
        updateState()
    }

    func zoomOut() {
        pdfView?.zoomOut(nil)
        updateState()
    }
    
    func goToNextPage() {
        guard let pdfView = pdfView, pdfView.canGoToNextPage else { return }
        pdfView.goToNextPage(nil)
        updateState()
    }
    
    func goToPreviousPage() {
        guard let pdfView = pdfView, pdfView.canGoToPreviousPage else { return }
        pdfView.goToPreviousPage(nil)
        updateState()
    }
    
    func goToPage(at pageNum: Int) {
        guard let pdfView = pdfView,
              let document = pdfView.document,
              let page = document.page(at: pageNum - 1) else { return }
        
        pdfView.go(to: page)
        updateState()
    }
    
    private func updateState() {
        guard let pdfView = pdfView else { return }

        scaleFactor = pdfView.scaleFactor
        pageNum = pdfView.currentPage?.pageRef?.pageNumber ?? pageNum

        if let docId = docId {
            UserDefaults.standard.set(Float(scaleFactor), forKey: "\(docId)/scaleFactor")
            UserDefaults.standard.set(pageNum, forKey: "\(docId)/pageNum")
        }
    }

    private func loadState() {
        guard let docId = docId, let pdfView = pdfView else { return }
           
        let savedScaleFactor = UserDefaults.standard.float(forKey: "\(docId)/scaleFactor")
        if savedScaleFactor > 0 {
            pdfView.scaleFactor = CGFloat(savedScaleFactor)
        } else {
            pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
        }
        
        if let savedPageNum = UserDefaults.standard.object(forKey: "\(docId)/pageNum") as? Int {
            pageNum = savedPageNum
            goToPage(at: pageNum)
        }
    }
    
    private func generateDocId(for document: PDFDocument) -> String {
        if let url = document.documentURL?.absoluteString {
            return url
        } else {
            let pageCount = document.pageCount
            let pageText0 = document.page(at: 0)?.string ?? ""
            let pageText1 = document.page(at: 1)?.string ?? ""
            let identifier = "\(pageCount)_\(pageText0)_\(pageText1)"
            return SHA256.hash(data: Data(identifier.utf8)).compactMap { String(format: "%02x", $0) }.joined()
        }
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

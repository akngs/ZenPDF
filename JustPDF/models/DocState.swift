import SwiftUI
import SwiftData

@Model
final class DocState {
    private static let MIN_SCALE_FACTOR: CGFloat = 0.5
    private static let MAX_SCALE_FACTOR: CGFloat = 2.0
    private static let SCALE_STEP: CGFloat = 0.05

    private(set) var id: String
    private(set) var scaleFactor: CGFloat
    private(set) var pageNum: Int
    private(set) var totalPages: Int

    init(id: String, scaleFactor: CGFloat, pageNum: Int, totalPages: Int) {
        self.id = id
        self.scaleFactor = scaleFactor
        self.pageNum = pageNum
        self.totalPages = totalPages
    }
    
    func zoomIn() {
        scaleFactor = min(scaleFactor + DocState.SCALE_STEP, DocState.MAX_SCALE_FACTOR)
    }
    
    func zoomOut() {
        scaleFactor = max(scaleFactor - DocState.SCALE_STEP, DocState.MIN_SCALE_FACTOR)
    }
    
    func resetZoom() {
        scaleFactor = 1.0
    }
    
    func setZoom(to newScaleFctor: CGFloat) {
        if DocState.MIN_SCALE_FACTOR <= newScaleFctor && newScaleFctor <= DocState.MAX_SCALE_FACTOR { scaleFactor = newScaleFctor }
    }
    
    func nextPage() {
        pageNum = min(pageNum + 1, totalPages)
    }
    
    func prevPage() {
        pageNum = max(pageNum - 1, 1)
    }
    
    func goToPage(at targetPageNum: Int) {
        if 0 < targetPageNum && targetPageNum <= totalPages { pageNum = targetPageNum }
    }
    
    func isValid(pageNum: Int) -> Bool {
        return 0 < pageNum && pageNum <= totalPages
    }
    
    func isValid(scaleFactor: CGFloat) -> Bool {
        return DocState.MIN_SCALE_FACTOR < scaleFactor && scaleFactor <= DocState.MAX_SCALE_FACTOR
    }
}

struct DocStateKey: FocusedValueKey {
    typealias Value = DocState
}

extension FocusedValues {
    var docState: DocState? {
        get { self[DocStateKey.self] }
        set { self[DocStateKey.self] = newValue }
    }
}

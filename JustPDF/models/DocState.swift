import SwiftUI
import SwiftData

@Model
final class DocState {
    var id: String
    var scaleFactor: CGFloat
    var pageNum: Int

    init(id: String, scaleFactor: CGFloat, pageNum: Int) {
        self.id = id
        self.scaleFactor = scaleFactor
        self.pageNum = pageNum
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

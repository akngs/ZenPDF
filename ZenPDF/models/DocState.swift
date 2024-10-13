import SwiftUI
@preconcurrency import SwiftData
import PDFKit

@Model
final class DocState {
    private static let MIN_SCALE_FACTOR: CGFloat = 0.5
    private static let MAX_SCALE_FACTOR: CGFloat = 2.0
    private static let SCALE_STEP: CGFloat = 0.05

    private(set) var id: String
    private(set) var scaleFactor: CGFloat
    private(set) var pageNum: Int
    private(set) var totalPages: Int
    private(set) var displayMode: Int

    init(id: String, scaleFactor: CGFloat, pageNum: Int, totalPages: Int, displayMode: PDFDisplayMode) {
        self.id = id
        self.scaleFactor = scaleFactor
        self.pageNum = pageNum
        self.totalPages = totalPages
        self.displayMode = displayMode.rawValue
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
        guard let mode = PDFDisplayMode(rawValue: self.displayMode) else { return }
        pageNum = min(pageNum + ((mode == .singlePage || mode == .singlePageContinuous) ? 1 : 2), totalPages)
    }

    func prevPage() {
        guard let mode = PDFDisplayMode(rawValue: self.displayMode) else { return }
        pageNum = max(pageNum - ((mode == .singlePage || mode == .singlePageContinuous) ? 1 : 2), 1)
    }

    func gotoPage(at targetPageNum: Int) {
        if 0 < targetPageNum && targetPageNum <= totalPages { pageNum = targetPageNum }
    }

    func setDisplayMode(to newDisplayMode: PDFDisplayMode) {
        displayMode = newDisplayMode.rawValue
    }

    func isValid(pageNum: Int) -> Bool {
        return 0 < pageNum && pageNum <= totalPages
    }

    func isValid(scaleFactor: CGFloat) -> Bool {
        return DocState.MIN_SCALE_FACTOR < scaleFactor && scaleFactor <= DocState.MAX_SCALE_FACTOR
    }
}

enum DocStateSchemaV1: VersionedSchema {
    nonisolated(unsafe) static var versionIdentifier: Schema.Version = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [DocState.self] }

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
    }
}

enum DocStateSchemaV2: VersionedSchema {
    nonisolated(unsafe) static var versionIdentifier: Schema.Version = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] { [DocState.self] }
}

enum DocStateSchemaMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [DocStateSchemaV1.self, DocStateSchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static let migrateV1toV2 = MigrationStage.lightweight(fromVersion: DocStateSchemaV1.self, toVersion: DocStateSchemaV2.self)
}

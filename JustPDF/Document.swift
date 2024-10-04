import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct Document: FileDocument {
    static var readableContentTypes: [UTType] { [.pdf] }
    
    var pdf: PDFDocument
    
    init() { pdf = PDFDocument() }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else { throw DocumentError.unableToReadFile }
        guard let pdf = PDFDocument(data: data) else { throw DocumentError.invalidPDFData }
        self.pdf = pdf
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        throw DocumentError.readonly
    }
}

enum DocumentError: Error {
    case unableToReadFile
    case invalidPDFData
    case readonly
}

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct Document: FileDocument {
    static var readableContentTypes: [UTType] { [.pdf] }
    
    var pdf: PDFDocument?
    
    init() { self.pdf = PDFDocument() }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else { throw DocumentError.unableToReadFile }
        guard let pdf = PDFDocument(data: data) else { throw DocumentError.invalidPDFData }
        self.pdf = pdf
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let pdf = pdf else { throw DocumentError.noPDFDocument }
        guard let data = pdf.dataRepresentation() else { throw DocumentError.unableToCreateFileWrapper }
        return FileWrapper(regularFileWithContents: data)
    }
}

enum DocumentError: Error {
    case unableToReadFile
    case invalidPDFData
    case noPDFDocument
    case unableToCreateFileWrapper
}

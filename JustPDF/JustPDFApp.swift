import SwiftUI

@main
struct JustPDFApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: JustPDFDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}


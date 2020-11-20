import SwiftUI
import Slab

import UIKit
import PDFKit
import LinkPresentation

struct SwiftUIPDFView: UIViewRepresentable {
    let document: PDFDocument

    init(_ document: PDFDocument) {
        self.document = document
    }

    func makeUIView(context: Context) -> UIView {
        let pdfv = PDFView()
        pdfv.document = self.document
        pdfv.autoScales = true
        pdfv.displayMode = .singlePageContinuous
        pdfv.displayDirection = .vertical
        return pdfv
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the view.
    }
}

struct AttestationViewer: View {
    var qr: UIImage
    var pdf: PDFDocument
    var attestation: Attestation
    var person: Person
    
    @State private var displayMode = 0
    
    init(attestation: Attestation, person: Person) {
        self.attestation = attestation
        self.person = person
        
        self.attestation.makeValidForToday()
        guard let qr = Generator.qrCode(self.attestation, self.person) else { fatalError() }
        guard let pdf = Generator.pdf(self.attestation, self.person) else { fatalError() }
        
        self.qr = qr
        self.pdf = pdf
    }
    
    
    var body: some View {
        TabView(selection: $displayMode) {
            Image(uiImage: qr)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(32)
                .tag(0)
            
            SwiftUIPDFView(pdf).tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker(selection: $displayMode, label: Text("Mode"), content: {
                    Image(systemName: "qrcode").tag(0)
                    Image(systemName: "doc.text").tag(1)
                }).pickerStyle(InlinePickerStyle())
            }
            ToolbarItem(placement: .automatic) {
                Button(action: share, label: {
                    Image(systemName: "square.and.arrow.up")
                })
                
            }
        }
    }
    
    func share() {
        guard let data = pdf.dataRepresentation() else { return }
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Attestation \(person.firstName) \(attestation.leavingTime, using: Generator.df2) \(attestation.leavingTime, using: Generator.tf).pdf")
        do {
            try data.write(to: url)
        }
        catch {
            return
        }

        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    }
}

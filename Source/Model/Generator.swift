import Foundation
import Slab
import CoreImage
import CoreImage.CIFilterBuiltins
import CoreGraphics
import SwiftUI
import UIKit
import PDFKit

enum Generator {
    static func qrCode(_ attestation: Attestation, _ person: Person) -> UIImage? {
        let string = [
            "Cree le: \(attestation.creationTime, using: df) a \(attestation.creationTime, using: tf)",
            "Nom: \(person.lastName)",
            "Prenom: \(person.firstName)",
            "Naissance: \(person.birthday, using: df) a \(person.placeOfBirth)",
            "Adresse: \(person.address) \(person.zipcode) \(person.city)",
            "Sortie: \(attestation.leavingTime, using: df) a \(attestation.leavingTime, using: tf)",
            "Motifs: \(attestation.reasons.map({$0.forQR}).joined(separator: ", "))"
        ].joined(separator: ";\n ")
            
        guard let data = string.data(using: .utf8) else { return nil }
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        guard let output = filter.outputImage?.transformed(by: .init(scaleX: 6, y: 6)) else { return nil }
        
        let ctx = CIContext()
        guard let cg = ctx.createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cg)
    }
    
    static func pdf(_ attestation: Attestation, _ person: Person) -> PDFDocument? {
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [
            kCGPDFContextTitle: "COVID-19 - Déclaration de déplacement",
            kCGPDFContextSubject: "Attestation de déplacement dérogatoire"
        ] as [String: Any]
        let original = PDFDocument(data: NSDataAsset(name: "pdf")!.data)!
        let page = original.page(at: 0)!
        let bounds = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds, format: format)
        let qr = qrCode(attestation, person)!
        
        func text(_ foo: String, x: CGFloat, y: CGFloat) {
            foo.draw(in: CGRect(x: x, y: y, width: 1000, height: 100), withAttributes: [
                .font: UIFont(name: "TrebuchetMS", size: 10.56)! // Taken from original PDF
            ])
        }
        
        let data = renderer.pdfData { (ctx) in
            ctx.beginPage()
            
            // Original page is flipped. Dunno why.
            // We just need to flip the context back after drawing!
            ctx.cgContext.scaleBy(x: 1, y: -1)
            ctx.cgContext.translateBy(x: 0, y: -bounds.height)
            page.draw(with: .mediaBox, to: ctx.cgContext)
            ctx.cgContext.translateBy(x: 0, y: bounds.height)
            ctx.cgContext.scaleBy(x: 1, y: -1)
            
            text(person.fullName, x: 97, y: 129)
            text(df.string(from: person.birthday), x: 97, y: 147)
            text(person.placeOfBirth, x: 213, y: 147)
            text(person.fullAddress, x: 108, y: 165)
            
            for reason in Reason.allCases where attestation.reasons.contains(reason) {
                text("✔︎", x: 46.5, y: reason.y)
            }
            
            text(person.city, x: 82, y: 754)
            text(df.string(from: attestation.leavingTime), x: 63, y: 772.5)
            text(tf.string(from: attestation.leavingTime), x: 229, y: 772.5)
            
            qr.draw(in: CGRect(x: 411, y: 653, width: 150, height: 150))
        }
        
        let pdfDocument = PDFDocument(data: data)
        return pdfDocument
    }
    
    static let df = DateFormatter(dateFormat: "dd/MM/yyyy")
    static let df2 = DateFormatter(dateFormat: "dd-MM-yyyy")
    static let tf = DateFormatter(dateFormat: "HH'h'mm")
    static let dcf: DateComponentsFormatter = {
        let dcf = DateComponentsFormatter()
        dcf.unitsStyle = .abbreviated
        dcf.maximumUnitCount = 1
        dcf.allowsFractionalUnits = true
        return dcf
    }()
}


extension Reason {
    var y: CGFloat {
        switch self {
            case .work:      return 278.5
            case .purchases: return 349.5
            case .health:    return 397.5
            case .family:    return 421.5
            case .handicap:  return 458.5
            case .walk:      return 482.5
            case .summons:   return 555.5
            case .missions:  return 579.5
            case .children:  return 603.5
        }
    }
}

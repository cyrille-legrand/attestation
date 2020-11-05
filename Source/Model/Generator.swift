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
        
        let pageWidth = 595
        let pageHeight = 842
        let leadingMargin = pageWidth / 8
        let pageWidthWithMargin = pageWidth - 2 * leadingMargin
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let qr = qrCode(attestation, person)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.alignment = .center
            
            let textParagraphStyle = NSMutableParagraphStyle()
            textParagraphStyle.alignment = .left

            let titleAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                NSAttributedString.Key.paragraphStyle: titleParagraphStyle
            ]
            
            let subtitleAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                NSAttributedString.Key.paragraphStyle: titleParagraphStyle
            ]
            
            let textAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10),
                NSAttributedString.Key.paragraphStyle: textParagraphStyle
            ]
            
            let indicesAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 8),
                NSAttributedString.Key.paragraphStyle: textParagraphStyle
            ]

            let titleText = "ATTESTATION DE DÉPLACEMENT DÉROGATOIRE"
            let textRect = CGRect(x: leadingMargin,
                                  y: 20,
                                  width: pageWidthWithMargin,
                                  height: 20)
            titleText.draw(in: textRect, withAttributes: titleAttributes)
            
            let subtitleText = "En application du décret n°2020-1310 du 29 octobre 2020 prescrivant les mesures générales nécessaires pour faire face à l'épidémie de Covid19 dans le cadre de l'état d'urgence sanitaire"
            let subtitleRect = CGRect(x: leadingMargin,
                                          y: 50,
                                          width: pageWidthWithMargin,
                                          height: 50)
            subtitleText.draw(in: subtitleRect, withAttributes: subtitleAttributes)
            
            let text1Text = "Je soussigné(e),"
            let text1Rect = CGRect(x: leadingMargin,
                                          y: 110,
                                          width: pageWidthWithMargin,
                                          height: 15)
            text1Text.draw(in: text1Rect, withAttributes: textAttributes)
            
            let text2Text = "Mme/M. : \(person.firstName) \(person.lastName)"
            let text2Rect = CGRect(x: leadingMargin,
                                          y: 130,
                                          width: pageWidthWithMargin,
                                          height: 15)
            text2Text.draw(in: text2Rect, withAttributes: textAttributes)

            let text3Text = "Né(e) le : \(person.birthday, using: df)" //TODO
            let text3Rect = CGRect(x: leadingMargin,
                                          y: 150,
                                          width: pageWidthWithMargin,
                                          height: 15)
            text3Text.draw(in: text3Rect, withAttributes: textAttributes)

            let text4Text = "à : \(person.placeOfBirth)" //TODO
            let text4Rect = CGRect(x: leadingMargin + pageWidthWithMargin / 2,
                                          y: 150,
                                          width: pageWidthWithMargin,
                                          height: 15)
            text4Text.draw(in: text4Rect, withAttributes: textAttributes)

            let text5Text = "Demeurant : \([person.address, person.zipcode, person.city].compactMap({$0}).joined(separator: " "))" //TODO
            let text5Rect = CGRect(x: leadingMargin,
                                          y: 170,
                                          width: pageWidthWithMargin,
                                          height: 15)
            text5Text.draw(in: text5Rect, withAttributes: textAttributes)

            let text6Text = "certifie que mon déplacement est lié au motif suivant (cocher la case) autorisé par le décret n°2020-1310 du 29 octobre 2020 prescrivant les mesures générales nécessaires pour faire face à l'épidémie de Covid19 dans le cadre de l'état d'urgence sanitaire (1) :"
            let text6Rect = CGRect(x: leadingMargin,
                                          y: 190,
                                          width: pageWidthWithMargin,
                                          height: 45)
            text6Text.draw(in: text6Rect, withAttributes: textAttributes)

            let image = UIImage(systemName: attestation.reasons.contains(.work) ? "checkmark.square" : "square")
            let rect = CGRect(x: leadingMargin,
                              y: 240,
                              width: 30,
                              height: 30)
            
            image?.draw(in: rect)
            
            let imageText = "Déplacements entre le domicile et le lieu d’exercice de l’activité professionnelle ou un établissement d’enseignement ou de formation, déplacements professionnels ne pouvant être différés (2), déplacements pour un concours ou un examen."
            let imageTextRect = CGRect(x: leadingMargin + 40,
                                          y: 240,
                                          width: pageWidthWithMargin,
                                          height: 45)
            imageText.draw(in: imageTextRect, withAttributes: textAttributes)

            
            let image2 = UIImage(systemName: attestation.reasons.contains(.purchases) ? "checkmark.square" : "square")
            let rect2 = CGRect(x: leadingMargin,
                              y: 290,
                              width: 30,
                              height: 30)
            
            image2?.draw(in: rect2)

            let image2Text = "Déplacements pour effectuer des achats de fournitures nécessaires à l'activité professionnelle, des achats de première nécessité (3) dans des établissements dont les activités demeurent autorisées, le retrait de commande et les livraisons à domicile."
            let image2TextRect = CGRect(x: leadingMargin + 40,
                                          y: 290,
                                          width: pageWidthWithMargin,
                                          height: 45)
            image2Text.draw(in: image2TextRect, withAttributes: textAttributes)

            let image3 = UIImage(systemName: attestation.reasons.contains(.health) ? "checkmark.square" : "square")
            let rect3 = CGRect(x: leadingMargin,
                              y: 340,
                              width: 30,
                              height: 30)
            
            image3?.draw(in: rect3)

            let image3Text = "Consultations, examens et soins ne pouvant être assurés à distance et l’achat de médicaments."
            let image3TextRect = CGRect(x: leadingMargin + 40,
                                          y: 340,
                                          width: pageWidthWithMargin,
                                          height: 45)
            image3Text.draw(in: image3TextRect, withAttributes: textAttributes)

            let image4 = UIImage(systemName: attestation.reasons.contains(.family) ? "checkmark.square" : "square")
            let rect4 = CGRect(x: leadingMargin,
                              y: 380,
                              width: 30,
                              height: 30)
            
            image4?.draw(in: rect4)

            let image4Text = "Déplacements pour motif familial impérieux, pour l'assistance aux personnes vulnérables et précaires ou la garde d'enfants."
            let image4TextRect = CGRect(x: leadingMargin + 40,
                                          y: 380,
                                          width: pageWidthWithMargin,
                                          height: 45)
            image4Text.draw(in: image4TextRect, withAttributes: textAttributes)

            let image5 = UIImage(systemName: attestation.reasons.contains(.handicap) ? "checkmark.square" : "square")
            let rect5 = CGRect(x: leadingMargin,
                              y: 430,
                              width: 30,
                              height: 30)
            
            image5?.draw(in: rect5)

            let image5Text = "Déplacement des personnes en situation de handicap et leur accompagnant."
            let image5TextRect = CGRect(x: leadingMargin + 40,
                                          y: 430,
                                          width: pageWidthWithMargin,
                                          height: 45)
            image5Text.draw(in: image5TextRect, withAttributes: textAttributes)

            let image6 = UIImage(systemName: attestation.reasons.contains(.walk) ? "checkmark.square" : "square")
            let rect6 = CGRect(x: leadingMargin,
                              y: 470,
                              width: 30,
                              height: 30)
            
            image6?.draw(in: rect6)

            let image6Text = "Déplacements brefs, dans la limite d'une heure quotidienne et dans un rayon maximal d'un kilomètre autour du domicile, liés soit à l'activité physique individuelle des personnes, à l'exclusion de toute pratique sportive collective et de toute proximité avec d'autres personnes, soit à la promenade avec les seules personnes regroupées dans un même domicile, soit aux besoins des animaux de compagnie."
            let image6TextRect = CGRect(x: leadingMargin + 40,
                                          y: 470,
                                          width: pageWidthWithMargin,
                                          height: 45)
            image6Text.draw(in: image6TextRect, withAttributes: textAttributes)

            let image7 = UIImage(systemName: attestation.reasons.contains(.summons) ? "checkmark.square" : "square")
            let rect7 = CGRect(x: leadingMargin,
                              y: 520,
                              width: 30,
                              height: 30)
            
            image7?.draw(in: rect7)

            let image7Text = "Convocation judiciaire ou administrative et pour se rendre dans un service public"
            let image7TextRect = CGRect(x: leadingMargin + 40,
                                          y: 520,
                                          width: pageWidthWithMargin,
                                          height: 45)
            image7Text.draw(in: image7TextRect, withAttributes: textAttributes)

            let image8 = UIImage(systemName: attestation.reasons.contains(.missions) ? "checkmark.square" : "square")
            let rect8 = CGRect(x: leadingMargin,
                              y: 570,
                              width: 30,
                              height: 30)
            
            image8?.draw(in: rect8)

            let image8Text = "Participation à des missions d'intérêt général sur demande de l'autorité administrative périscolaires"
            let image8TextRect = CGRect(x: leadingMargin + 40,
                                          y: 570,
                                          width: pageWidthWithMargin,
                                          height: 45)
            image8Text.draw(in: image8TextRect, withAttributes: textAttributes)

            let image9 = UIImage(systemName: attestation.reasons.contains(.children) ? "checkmark.square" : "square")
            let rect9 = CGRect(x: leadingMargin,
                              y: 620,
                              width: 30,
                              height: 30)
            
            image9?.draw(in: rect9)

            let image9Text = "Déplacement pour chercher les enfants à l’école et à l’occasion de leurs activités périscolaires"
            let image9TextRect = CGRect(x: leadingMargin + 40,
                                          y: 620,
                                          width: pageWidthWithMargin,
                                          height: 45)
            image9Text.draw(in: image9TextRect, withAttributes: textAttributes)

            let text7Text = "Fait à : \(person.city)" //TODO
            let text7Rect = CGRect(x: leadingMargin,
                                          y: 660,
                                          width: pageWidthWithMargin,
                                          height: 15)
            text7Text.draw(in: text7Rect, withAttributes: textAttributes)

            let text8Text = "Le : \(attestation.leavingTime, using: df)" //TODO
            let text8Rect = CGRect(x: leadingMargin,
                                          y: 680,
                                          width: pageWidthWithMargin,
                                          height: 15)
            text8Text.draw(in: text8Rect, withAttributes: textAttributes)

            let text9Text = "à : \(attestation.leavingTime, using: tf)" //TODO
            let text9Rect = CGRect(x: leadingMargin + pageWidthWithMargin / 2,
                                          y: 680,
                                          width: pageWidthWithMargin,
                                          height: 15)
            text9Text.draw(in: text9Rect, withAttributes: textAttributes)

            let text10Text = "(Date et heure de début de sortie à mentionner obligatoirement)"
            let text10Rect = CGRect(x: leadingMargin,
                                          y: 700,
                                          width: pageWidthWithMargin,
                                          height: 15)
            text10Text.draw(in: text10Rect, withAttributes: textAttributes)

            let text11Text = "Signature :"
            let text11Rect = CGRect(x: leadingMargin,
                                          y: 720,
                                          width: pageWidthWithMargin,
                                          height: 15)
            text11Text.draw(in: text11Rect, withAttributes: textAttributes)
            
            let imageQRCodeRect = CGRect(x: leadingMargin + pageWidthWithMargin - 80,
                              y: 640,
                              width: 100,
                              height: 100)
            qr?.draw(in: imageQRCodeRect)
            
            let indices1Title = "1."
            let indices1TitleRect = CGRect(x: leadingMargin,
                                          y: 750,
                                          width: pageWidthWithMargin,
                                          height: 10)
            indices1Title.draw(in: indices1TitleRect, withAttributes: indicesAttributes)

            let indices1Text = "Les personnes souhaitant bénéficier de l'une de ces exceptions doivent se munir s'il y a lieu, lors de leurs déplacements hors de leur domicile, d'un document leur permettant de justifier que le déplacement considéré entre dans le champ de l'une de ces exceptions."
            let indices1Rect = CGRect(x: leadingMargin + 10,
                                          y: 750,
                                          width: pageWidthWithMargin - 20,
                                          height: 30)
            indices1Text.draw(in: indices1Rect, withAttributes: indicesAttributes)

            let indices2Title = "2."
            let indices2TitleRect = CGRect(x: leadingMargin,
                                          y: 780,
                                          width: pageWidthWithMargin,
                                          height: 10)
            indices2Title.draw(in: indices2TitleRect, withAttributes: indicesAttributes)

            let indices2Text = "A utiliser par les travailleurs non-salariés, lorsqu'ils ne peuvent disposer d'un justificatif de déplacement établi par leur employeur."
            let indices2Rect = CGRect(x: leadingMargin + 10,
                                          y: 780,
                                          width: pageWidthWithMargin - 20,
                                          height: 30)
            indices2Text.draw(in: indices2Rect, withAttributes: indicesAttributes)

            let indices3Title = "3."
            let indices3TitleRect = CGRect(x: leadingMargin,
                                          y: 800,
                                          width: pageWidthWithMargin,
                                          height: 10)
            indices3Title.draw(in: indices3TitleRect, withAttributes: indicesAttributes)

            let indices3Text = "Y compris les acquisitions à titre gratuit (distribution de denrées alimentaires...) et les déplacements liés à la perception de prestations sociales et au retrait d'espèces."
            let indices3Rect = CGRect(x: leadingMargin + 10,
                                          y: 800,
                                          width: pageWidthWithMargin - 20,
                                          height: 25)
            indices3Text.draw(in: indices3Rect, withAttributes: indicesAttributes)
            
            
            context.beginPage()
            let bigRect = CGRect(x: leadingMargin, y: 40, width: 300, height: 300)
            qr?.draw(in: bigRect)
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



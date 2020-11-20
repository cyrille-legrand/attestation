//
//  AttestationWidget.swift
//  AttestationWidget
//
//  Created by Cyrille Legrand on 18/11/2020.
//

import WidgetKit
import SwiftUI
import Slab

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> WidgetContent {
        WidgetContent(date: Date(), attestation: nil, person: nil, placeholder: true)
    }
    
    func getRealContent(for configuration: PersonPickerIntent, in context: Context) -> WidgetContent {
        // Reload database every time
        let db = Database()
        let person = configuration.person?.identifier.flatMap(UUID.init).flatMap(db.person)
        let attestation = person.flatMap(db.validAttestation)
        
        return WidgetContent(date: Date(), attestation: attestation, person: person, placeholder: false)
    }

    func getSnapshot(for configuration: PersonPickerIntent, in context: Context, completion: @escaping (WidgetContent) -> Void) {
        completion(
            getRealContent(for: configuration, in: context)
        )
    }
    
    func getTimeline(for configuration: PersonPickerIntent, in context: Context, completion: @escaping (Timeline<WidgetContent>) -> Void) {
        completion(
            Timeline(
                entries: [
                    getRealContent(for: configuration, in: context)
                ],
                policy: .after(10.minutes.fromNow)
            )
        )
    }
}


struct AttestationWidgetEntryView : View {
    var entry: Provider.Entry
    var database = Database.shared

    var body: some View {
        VStack {
            if let p = entry.person {
                Text(p.firstName)
                Spacer()
            }
            else if entry.placeholder {
                Text("Cyrille").redacted(reason: .placeholder)
                Spacer()
            }
            
            
            if let a = entry.attestation, let p = entry.person, let qr = Generator.qrCode(a, p) {
                Image(uiImage: qr).resizable().aspectRatio(contentMode: .fit)
            }
            else {
                Image("AppIcon-Transparent").resizable().aspectRatio(contentMode: .fit)
            }
            
            Spacer()
            if let a = entry.attestation {
                Text("\(a.reasons.map({$0.titleForWidget}).joined(separator: ", ")), \(DateFormatter.shortTime.string(from: a.leavingTime))")
            }
            else if entry.placeholder {
                Text("Sortie, 22h22").redacted(reason: .placeholder)
            }
            else {
                Text("Pas d’attestation en cours.")
            }
        }
        .foregroundColor(.white)
        .font(.caption)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("WidgetBackground"))
    }
}

@main
struct AttestationWidget: Widget {
    let kind: String = "AttestationWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: PersonPickerIntent.self, provider: Provider()) { entry in
            AttestationWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Mon attestation")
        .description("Affiche l’attestation en cours de validité.")
        
    }
}

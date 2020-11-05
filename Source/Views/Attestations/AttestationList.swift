import SwiftUI
import Slab

struct AttestationList: View {
    @EnvironmentObject var database: Database
    @State private var isPresentingCreator: Bool = false
    
    var body: some View {
        list
        .navigationTitle("Attestations")
        .toolbar(content: {
            ToolbarItem(placement: .automatic) {
                if database.selectedPersonID == nil {
                    EmptyView()
                }
                else {
                    Button(
                        action: { isPresentingCreator = true },
                        label: { Image(systemName: "plus") }
                    )
                }
            }
        })
        .sheet(isPresented: $isPresentingCreator, content: {
            AttestationCreator(isPresented: $isPresentingCreator).environmentObject(database)
        })
    }
    
    var list: some View {
        Group {
            if database.people.isEmpty {
                Text("Utilisez d’abord l’onglet Personnes pour créer une personne.")
                    .foregroundColor(.secondary)
            }
            else if database.attestations.isEmpty {
                Text("Utilisez le bouton + pour créer une attestation.")
                    .foregroundColor(.secondary)
            }
            else {
                List {
                    
                    if database.nonRecurringAttestations.isNotEmpty {
                        Section(header: Text("Ponctuelles") ) {
                            ForEach(database.nonRecurringAttestations, id: \.id) { attestation in
                                AttestationCard(attestation: attestation, person: database.person(with: attestation.personID)!)
                            }
                            .onDelete(perform: deleteNonRecurring)
                        }
                    }
                    
                    if database.recurringAttestations.isNotEmpty {
                        Section(header: Text("Récurrentes") ) {
                            ForEach(database.recurringAttestations, id: \.id) { attestation in
                                AttestationCard(attestation: attestation, person: database.person(with: attestation.personID)!)
                            }
                            .onDelete(perform: deleteRecurring)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
    }
    
    func deleteNonRecurring(at indices: IndexSet) {
        guard indices.count == 1 else { return }
        database.remove(database.nonRecurringAttestations[indices.first!])
    }
    
    func deleteRecurring(at indices: IndexSet) {
        guard indices.count == 1 else { return }
        database.remove(database.recurringAttestations[indices.first!])
    }
}

struct AttestationCard: View {
    var attestation: Attestation
    var person: Person
    
    var body: some View {
        NavigationLink(
            destination: LazyView(AttestationViewer(attestation: attestation, person: person)),
            label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(person.firstName)
                        Text(attestation.allowedLeavingPeriodDescription).foregroundColor(attestation.color)
                        Text(attestation.reasons.map({$0.title}).joined(separator: "\n")).foregroundColor(.secondary).font(.caption)
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "qrcode")
                        Image(systemName: "doc.text")
                    }
                }
            }
        )
        
    }
}

extension Attestation {
    var allowedLeavingPeriodDescription: String {
        if let rd = recurringDaysDescription {
            if let rt = returnTime {
                return "\(rd) de \(leavingTime, using: Generator.tf) à \(rt, using: Generator.tf)"
            }
            else {
                return "\(rd) à \(leavingTime, using: Generator.tf)"
            }
        }
        else {
            if isCurrent {
                if let rt = returnTime {
                    return "Jusqu’à \(rt, using: Generator.tf)"
                }
                else {
                    return "Depuis \(leavingTime, using: Generator.tf)"
                }
            }
            if leavingTime.isToday {
                if let rt = returnTime {
                    return "De \(leavingTime, using: Generator.tf) à \(rt, using: Generator.tf) ce jour"
                }
                else {
                    return "À \(leavingTime, using: Generator.tf) ce jour"
                }
            }
            if leavingTime.isTomorrow {
                if let rt = returnTime {
                    return "Demain, de \(leavingTime, using: Generator.tf) à \(rt, using: Generator.tf)"
                }
                else {
                    return "Demain, à partir de \(leavingTime, using: Generator.tf)"
                }
            }
            
            if let rt = returnTime {
                return "Le \(leavingTime, using: Generator.df), de \(leavingTime, using: Generator.tf) à \(rt, using: Generator.tf)"
            }
            else {
                return "Le \(leavingTime, using: Generator.df), à partir de \(leavingTime, using: Generator.tf)"
            }
        }
    }
    
    static var longDays = ["lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"]
    var recurringDaysDescription: String? {
        guard recurringDays.isNotEmpty else { return nil }
        let arr = Array(recurringDays).sorted()
        if arr.last! - arr.first! == (arr.count - 1) {
            return "Du \(Self.longDays[arr.first!]) au \(Self.longDays[arr.last!])"
        }
        else if arr.count == 1 {
            return "Le \(Self.longDays[arr.first!])"
        }
        else {
            return "Les \(arr.map({Self.longDays[$0]}).joined(separator: ", "))"
        }
    }
    
    
    var color: Color {
        if recurringDays.isNotEmpty { return Color.primary }
        if isPast { return Color("ErrorColor") }
        if isFuture { return Color.secondary }
        return Color.primary
    }
}

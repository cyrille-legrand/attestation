import SwiftUI
import Slab
import UIKit

struct AttestationCreator: View {
    static let none = UUID()
    
    @EnvironmentObject var database: Database
    @Binding var isPresented: Bool
    
    @State private var attestation: Attestation = Attestation()
    @State private var generalError: Errors<Attestation>? = nil
    @State private var fieldErrors: Errors<Attestation> = .none
    
    @State private var timeMode = 0
    @State private var minutesFromNow = 0 { didSet { timeMode = 0 }}
    @State private var selectedTime = Date() { didSet { timeMode = 1 }}
    @State private var recurringDays = Set<Int>([0,1,2,3,4]) { didSet { timeMode = recurringDays.isEmpty ? 1 : 2 }}
    @State private var recurringTime = Date() { didSet { timeMode = recurringDays.isEmpty ? 1 : 2 }}
    private static var days: [String] = ["l", "m", "m", "j", "v", "s", "d"]
    
    @State private var showReasonDetails = false
        
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: $attestation.personID, label: Text("Personne")) {
                        ForEach(database.people.sorted()) { person in
                            Text(person.fullName).tag(Optional(person.id))
                        }
                    }
                }
                
                Section(header: Text("Heure de sortie")) {
                    HStack {
                        Button(action: {timeMode = 0}, label: {
                            Image(systemName: timeMode == 0 ? "checkmark.circle" : "circle")
                        })
                        Stepper(
                            minutesFromNow == 0 ? "Maintenant" :
                            minutesFromNow < 0 ? "Il y a \(-minutesFromNow) min" :
                            "Dans \(minutesFromNow) min",
                            onIncrement: { minutesFromNow += 5 },
                            onDecrement: { minutesFromNow -= 5 },
                            onEditingChanged: { _ in timeMode = 0 }
                        )
                    }
                    HStack {
                        Button(action: {timeMode = 1}, label: {
                            Image(systemName: timeMode == 1 ? "checkmark.circle" : "circle")
                        })
                        DatePicker("Fixe", selection: $selectedTime, displayedComponents: [.date, .hourAndMinute])
                    }
                    HStack {
                        Button(action: {timeMode = 2}, label: {
                            Image(systemName: timeMode == 2 ? "checkmark.circle" : "circle")
                        })
                        VStack {
                            HStack {
                                Text("Chaque")
                                Spacer()
                                ForEach(0..<7, id: \.self) { i in
                                    Button(
                                        action: { recurringDays.toggle(i) },
                                        label: { Image(systemName: "\(Self.days[i]).\(recurringDays.contains(i) ? "square.fill" : "square")") }
                                    ).buttonStyle(BorderlessButtonStyle())
                                }
                            }
                            DatePicker("Heure", selection: $recurringTime, displayedComponents: [.hourAndMinute])
                        }
                    }
                }
                
                Section(header: HStack {
                    Text("Motif(s) de sortie")
                    Spacer()
                    Button(
                        action: {
                            showReasonDetails.toggle()
                        },
                        label: {
                            Image(systemName: showReasonDetails ? "info.circle.fill" : "info.circle")
                        }
                    )
                }) {
                    ForEach(Reason.allCases, id: \.self) { reason in
                        HStack {
                            Button(action: { attestation.reasons.toggle(reason) }, label: {
                                Image(systemName: attestation.reasons.contains(reason) ? "checkmark.square" : "square")
                            })
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(reason.title)
                                    if let dur = reason.maximumDuration {
                                        Spacer()
                                        Text("\(Generator.dcf.string(from: dur)!) max").capsuleText()
                                    }
                                }
                                if showReasonDetails {
                                    Text(reason.description).multilineTextAlignment(.leading).font(.caption2).foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Nouvelle attestation")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        switch timeMode {
                            case 0:
                                attestation.leavingTime = Date().addingTimeInterval(TimeInterval(60 * minutesFromNow))
                                attestation.recurringDays = []
                            case 1:
                                attestation.leavingTime = selectedTime
                                attestation.recurringDays = []
                            case 2:
                                attestation.leavingTime = recurringTime
                                attestation.recurringDays = recurringDays
                            default: break
                        }
                        
                        attestation.creationTime = min(Date(), attestation.leavingTime)
                        
                        let errors = database.errorsPreventingAddition(of: attestation)
                        generalError = errors.onlyGeneralErrors
                        fieldErrors = errors.onlyFieldErrors ?? .none
                        
                        if errors.hasNoError {
                            database.add(attestation)
                            database.selectedPersonID = attestation.personID
                            isPresented = false
                        }
                    }, label: {
                        Text("Créer")
                    })
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        isPresented = false
                    }, label: {
                        Text("Annuler")
                    })
                }
            }
            .alert(item: $generalError) { err in
                Alert(title: Text("Erreur"), message: Text(err.description))
            }
        }
        .onAppear(perform: {
            attestation.personID = database.selectedPersonID ?? UUID()
        })
    }
    
}

struct CapsuleText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .foregroundColor(Color(.systemBackground))
            .padding(EdgeInsets(top: 3, leading: 6, bottom: 3, trailing: 6))
            .background(Color.accentColor)
            .clipShape(Capsule())
    }
}

extension View {
    func capsuleText() -> some View {
        self.modifier(CapsuleText())
    }
}

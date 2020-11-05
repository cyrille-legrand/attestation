import SwiftUI
import Slab

struct PersonCreator: View {
    
    @EnvironmentObject var database: Database
    @Binding var isPresented: Bool
    
    @State private var person = Person()
    @State private var generalError: Errors<Person>? = nil
    @State private var fieldErrors: Errors<Person> = .none
        
    var body: some View {
        NavigationView {
            PersonForm(person: $person, fieldErrors: $fieldErrors)
            .navigationTitle("Nouvelle personne")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        let errors = database.errorsPreventingAddition(of: person)
                        generalError = errors.onlyGeneralErrors
                        fieldErrors = errors.onlyFieldErrors ?? .none
                        
                        if errors.hasNoError {
                            database.add(person)
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
    }
}


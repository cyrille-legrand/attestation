//
//  Editor.swift
//  formTest
//
//  Created by Cyrille Legrand on 14/11/2020.
//

import SwiftUI
import Slab

struct PersonEditor: View {
    
    @EnvironmentObject var database: Database
    @Environment(\.presentationMode) var presentation
    
    class Edition: ObservableObject {
        @Published var original: Person
        @Published var edited: Person { didSet {
            hasChanges = edited != original
        }}
        @Published var hasChanges = false
        
        init(editing person: Person) {
            original = person
            edited = person
        }
    }
    
    @ObservedObject private var edition: Edition
    @State private var generalError: Errors<Person>? = nil
    @State private var fieldErrors: Errors<Person> = .none
    
    init(editing person: Person) {
        edition = Edition(editing: person)
    }
    
    var body: some View {
        PersonForm(person: $edition.edited, fieldErrors: $fieldErrors)
        .navigationTitle(edition.original.fullName)
        .navigationBarBackButtonHidden(edition.hasChanges)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if edition.hasChanges {
                    Button(
                        action: { presentation.wrappedValue.dismiss() },
                        label: { Text("Annuler") }
                    )
                }
                else {
                    EmptyView()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                if edition.hasChanges {
                    Button(
                        action: {
                            let errors = database.errorsPreventingReplacement(of: edition.original, with: edition.edited)
                            generalError = errors.onlyGeneralErrors
                            fieldErrors = errors.onlyFieldErrors ?? .none
                            
                            if errors.hasNoError {
                                database.replace(edition.original, with: edition.edited)
                                presentation.wrappedValue.dismiss()
                            }
                        },
                        label: { Text("Modifier") }
                    )
                }
                else {
                    EmptyView()
                }
            }
        }
        .alert(item: $generalError) { err in
            Alert(title: Text("Erreur"), message: Text(err.description))
        }
    }
    
}

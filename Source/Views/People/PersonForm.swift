//
//  PersonForm.swift
//  formTest
//
//  Created by Cyrille Legrand on 14/11/2020.
//

import SwiftUI
import Slab

struct PersonForm: View {
    @Binding var person: Person
    @Binding var fieldErrors: Errors<Person>
    
    var body: some View {
        Form {
            FormField_String(\Person.lastName, $person.lastName, errors: $fieldErrors)
            FormField_String(\Person.firstName, $person.firstName, errors: $fieldErrors)
            FormField_Date(\Person.birthday, $person.birthday, errors: $fieldErrors)
            FormField_String(\Person.placeOfBirth, $person.placeOfBirth, errors: $fieldErrors)
            FormField_String(\Person.address, $person.address, errors: $fieldErrors)
            FormField_String(\Person.city, $person.city, errors: $fieldErrors)
            FormField_String(\Person.zipcode, $person.zipcode, errors: $fieldErrors)
        }
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

extension Person: FormEditable {
    static func name(forField field: PartialKeyPath<Person>) -> String? {
        switch field {
            case \Person.lastName: return "Nom de famille"
            case \Person.firstName: return "Prénom"
            case \Person.birthday: return "Date de naissance"
            case \Person.placeOfBirth: return "Lieu de naissance"
            case \Person.address: return "Adresse"
            case \Person.city: return "Ville"
            case \Person.zipcode: return "Code postal"
            default: return nil
        }
    }
    
    static func textFieldConfiguration(forField field: PartialKeyPath<Person>) -> TextFieldConfiguration {
        switch field {
            case \Person.lastName:
                return TextFieldConfiguration(
                    placeholder: "Simpson",
                    disableAutocorrection: true,
                    textContentType: .familyName
                )
                
            case \Person.firstName:
                return TextFieldConfiguration(
                    placeholder: "Homer",
                    disableAutocorrection: true,
                    textContentType: .givenName
                )
                
            case \Person.placeOfBirth:
                return TextFieldConfiguration(
                    placeholder: "Springfield",
                    disableAutocorrection: true,
                    textContentType: .addressCity
                )
                
            case \Person.address:
                return TextFieldConfiguration(
                    placeholder: "742 Evergreen Terrace",
                    disableAutocorrection: true,
                    textContentType: .fullStreetAddress
                )
                
            case \Person.city:
                return TextFieldConfiguration(
                    placeholder: "Springfield",
                    disableAutocorrection: true,
                    textContentType: .addressCity
                )
                
            case \Person.zipcode:
                return TextFieldConfiguration(
                    placeholder: "58008",
                    disableAutocorrection: true,
                    textContentType: .postalCode
                )
                
            default:
                return .defaultConfiguration
        }
    }
}

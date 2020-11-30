import Foundation
import Slab

struct Person: Identifiable, Codable {
    var id: UUID = UUID()
    var lastName: String = ""
    var firstName: String = ""
    var birthday: Date = 30.years.ago
    var placeOfBirth: String = ""
    var address: String = ""
    var city: String = ""
    var zipcode: String = ""
}

extension Person {
    var fullName: String {
        [firstName, lastName].joined(separator: " ")
    }
    
    var fullAddress: String {
        [address, zipcode, city].joined(separator: " ")
    }
}

extension Person: Validable {
    func validate() -> Errors<Person> {
        var errors = Errors<Person>.none
        if lastName.isEmpty { errors.add("Le nom de famille doit être saisi", for: \Person.lastName) }
        if firstName.isEmpty { errors.add("Le prénom doit être saisi", for: \Person.firstName) }
        if birthday.isFuture { errors.add("La date de naissance doit être dans le passé", for: \Person.birthday) }
        if placeOfBirth.isEmpty { errors.add("Le lieu de naissance doit être saisi", for: \Person.placeOfBirth) }
        if address.isEmpty { errors.add("L’adresse doit être saisie", for: \Person.address) }
        if city.isEmpty { errors.add("La ville doit être saisie", for: \Person.city) }
        if zipcode.isEmpty { errors.add("Le code postal doit être saisi", for: \Person.zipcode) }
        
        return errors
    }
}



extension Person: Equatable {
    static func == (lhs: Person, rhs: Person) -> Bool {
        lhs.lastName     == rhs.lastName     &&
        lhs.firstName    == rhs.firstName    &&
        lhs.birthday     == rhs.birthday     &&
        lhs.placeOfBirth == rhs.placeOfBirth &&
        lhs.address      == rhs.address      &&
        lhs.city         == rhs.city         &&
        lhs.zipcode      == rhs.zipcode
    }
}

extension Person: Comparable {
    static func < (lhs: Person, rhs: Person) -> Bool {
        lhs.fullName < rhs.fullName
    }
}

import Foundation
import Slab
import WidgetKit

final class Database: ObservableObject {
    static let shared = Database()
    
    @Published var people: [Person]
    @Published var attestations: [Attestation]
    @Published var selectedPersonID: UUID? { didSet {
        if let p = selectedPersonID {
            UserDefaults.standard.set(p.uuidString, forKey: "selectedPerson")
        }
        else {
            UserDefaults.standard.removeObject(forKey: "selectedPerson")
        }
    }}

    init() {
        do {
            let data = try Data(contentsOf: self.peopleURL)
            self.people = try decoder.decode([Person].self, from: data)
        }
        catch {
            self.people = []
        }
        
        do {
            let data = try Data(contentsOf: self.attestationsURL)
            self.attestations = try decoder.decode([Attestation].self, from: data)
        }
        catch {
            self.attestations = []
        }
        
        self.selectedPersonID = UserDefaults.standard.string(forKey: "selectedPerson").flatMap(UUID.init)
    }
    
    func allAttestationsWithPerson() -> [(Attestation, Person)] {
        attestations.sorted().reversed().compactMap { attestation in
            guard let person = people.first(where: { $0.id == attestation.personID }) else { return nil }
            return (attestation, person)
        }
    }
    
    //MARK: - CRUD - People
    
    func add(_ new: Person) {
        people.append(new)
        
        if people.count == 1 {
            selectedPersonID = new.id
        }
        
        savePeople()
    }
    
    func remove(_ person: Person) {
        guard let idx = people.firstIndex(where: { $0.id == person.id }) else { return }
        people.remove(at: idx)
        removeAttestations(for: person)
        
        if selectedPersonID == person.id {
            selectedPersonID = people.first?.id
        }
        
        savePeople()
    }
    
    func remove(_ persons: [Person]) {
        let ids = persons.map { $0.id }
        people.removeAll(where: { ids.contains($0.id) })
        persons.forEach { removeAttestations(for: $0) }
        
        if let sel = selectedPersonID, people.firstIndex(where: { $0.id == sel }) == nil {
            selectedPersonID = people.first?.id
        }
        savePeople()
    }
    
    func removePeople(at indices: IndexSet) {
        indices.forEach { removeAttestations(for: people[$0]) }
        people.remove(atOffsets: indices)
        
        if let sel = selectedPersonID, people.firstIndex(where: { $0.id == sel }) == nil {
            selectedPersonID = people.first?.id
        }
        savePeople()
    }
    
    func replace(_ person: Person, with new: Person) {
        var new = new
        guard let idx = people.firstIndex(where: { $0.id == person.id }) else { return }
        new.id = person.id
        people[idx] = new
        
        savePeople()
    }
    
    func person(with id: UUID) -> Person? {
        people.first(where: {$0.id == id})
    }
    
    //MARK: - CRUD - Attestations
    
    func add(_ new: Attestation) {
        attestations.append(new)
        saveAttestations()
    }
    
    func remove(_ attestation: Attestation) {
        guard let idx = attestations.firstIndex(where: { $0.id == attestation.id }) else { return }
        attestations.remove(at: idx)
        saveAttestations()
    }
    
    func remove(_ manyAttestations: [Attestation]) {
        for a in manyAttestations {
            if let idx = attestations.firstIndex(where: { $0.id == a.id }) {
                attestations.remove(at: idx)
            }
        }
        saveAttestations()
    }
    
    func removeAttestations(at indices: IndexSet) {
        attestations.remove(atOffsets: indices)
        saveAttestations()
    }
    
    func removeAttestations(for person: Person) {
        attestations.removeAll(where: { $0.personID == person.id })
        saveAttestations()
    }
    
    var nonRecurringAttestations: [Attestation] {
        attestations.filter({ $0.recurringDays.isEmpty }).sorted(by: >)
    }
    
    var recurringAttestations: [Attestation] {
        attestations.filter({ $0.recurringDays.isNotEmpty }).sorted(by: ↑\.leavingTime.timeIntervalSinceMidnight)
    }
    
    func validAttestation(for person: Person) -> Attestation? {
        // prioritize non-recurring attestations
        if let nonRecurring = attestations.filter({ $0.personID == person.id && $0.recurringDays.isEmpty && $0.leavingTime.isPast }).sorted(by: <).last {
            return nonRecurring
        }
        
        // find all matching recurring attestations for today
        let dayIndex = (Calendar.current.component(.weekday, from: Date()) + 6) % 7
        let timeOfDay = Date().timeIntervalSinceMidnight
        let recurring = attestations.filter({ $0.personID == person.id && $0.recurringDays.contains(dayIndex) && $0.leavingTime.timeIntervalSinceMidnight <= timeOfDay }).sorted(by: ↑\.leavingTime.timeIntervalSinceMidnight)
        return recurring.last
    }
    
    //MARK: - Guards
    
    func errorsPreventingAddition(of new: Person) -> Errors<Person> {
        var errors = new.validate()
        if people.contains(new) {
            errors.add("Cette personne existe déjà.")
        }
        return errors
    }
    
    func errorsPreventingReplacement(of person: Person, with new: Person) -> Errors<Person> {
        var errors = new.validate()
        if people.firstIndex(where: { $0 == new && $0 != person }) != nil {
            errors.add("Cette personne existe déjà.")
        }
        return errors
    }
    
    func errorsPreventingAddition(of new: Attestation) -> Errors<Attestation> {
        var errors = new.validate().generalized
        
        if person(with: new.personID) == nil {
            errors.add("Une personne doit être spécifiée")
        }
        
        return errors
    }
    
    //MARK: - State
    
    fileprivate func savePeople() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            do {
                let data = try self.encoder.encode(self.people)
                try data.write(to: self.peopleURL)
                DispatchQueue.main.async {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
            catch {}
        }
    }
    
    fileprivate func saveAttestations() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            do {
                let data = try self.encoder.encode(self.attestations)
                try data.write(to: self.attestationsURL)
                DispatchQueue.main.async {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
            catch {}
        }
    }
    
    fileprivate let peopleURL: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.io.uad.attestation.contents")!.appendingPathComponent("people", conformingTo: .json)
    fileprivate let attestationsURL: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.io.uad.attestation.contents")!.appendingPathComponent("attestations", conformingTo: .json)
    
    fileprivate let encoder = JSONEncoder()
    fileprivate let decoder = JSONDecoder()
}

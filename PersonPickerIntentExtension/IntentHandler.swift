//
//  IntentHandler.swift
//  PersonPickerIntentExtension
//
//  Created by Cyrille Legrand on 18/11/2020.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}

extension IntentHandler: PersonPickerIntentHandling {
    func providePersonOptionsCollection(for intent: PersonPickerIntent, with completion: @escaping (INObjectCollection<WidgetPerson>?, Error?) -> Void) {
        let allPeople = Database.shared.people.sorted().map {
            WidgetPerson(identifier: $0.id.uuidString, display: $0.fullName)
        }
        completion(INObjectCollection(items: allPeople), nil)
    }
}

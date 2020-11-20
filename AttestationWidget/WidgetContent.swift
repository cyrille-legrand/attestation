//
//  WidgetContent.swift
//  Attestation
//
//  Created by Cyrille Legrand on 18/11/2020.
//

import Foundation
import Slab
import WidgetKit

struct WidgetContent: TimelineEntry {
    var date = Date()
    
    let attestation: Attestation?
    let person: Person?
    let placeholder: Bool
}

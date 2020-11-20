import Foundation
import Slab

struct Attestation: Identifiable, Codable {
    var id: UUID
    var creationTime: Date
    var leavingTime: Date
    var reasons: Set<Reason>
    
    var recurringDays: Set<Int>
    
    var personID: UUID
    
    init() {
        self.id = UUID()
        self.creationTime = Date()
        self.leavingTime = Date()
        self.reasons = []
        self.personID = UUID()
        self.recurringDays = []
    }
}

extension Attestation: Validable {
    func validate() -> Errors<Attestation> {
        var errors = Errors<Attestation>.none
        
        if reasons.isEmpty { errors.add("Au moins une raison doit être choisie", for: \Attestation.reasons) }
        
        return errors
    }
}

extension Attestation: Comparable {
    static func < (lhs: Attestation, rhs: Attestation) -> Bool {
        lhs.leavingTime < rhs.leavingTime
    }
}

extension Attestation {
    var returnTime: Date? {
        reasons.compactMap(\.maximumDuration).min().map { leavingTime.advanced(by: $0) }
    }
    
    var isCurrent: Bool { leavingTime.isPast && (returnTime?.isFuture ?? leavingTime.isToday) }
    var isPast: Bool { returnTime?.isPast ?? (leavingTime.isPast && !leavingTime.isToday)}
    var isFuture: Bool { leavingTime.isFuture }
    
    mutating func makeValidForToday() {
        //I'm such an anarchist.
        if recurringDays.isNotEmpty {
            let h = Calendar.current.component(.hour, from: leavingTime)
            let m = Calendar.current.component(.minute, from: leavingTime)
            leavingTime = Calendar.current.date(bySettingHour: h, minute: m, second: 0, of: Date())!
            creationTime = leavingTime
        }
    }
}



enum Reason: String, CaseIterable, Codable {
    case walk
    case children
    case purchases
    case family
    case health
    case work
    case handicap
    case summons
    case missions
}
    
extension Reason {
    var maximumDuration: TimeInterval? {
        switch self {
            case .walk: return 3600
            default: return nil
        }
    }
    
    var title: String {
        switch self {
            case .work: return "Travail"
            case .purchases: return "Courses"
            case .health: return "Santé"
            case .family: return "Famille"
            case .handicap: return "Déplacement handicapé"
            case .walk: return "Promenade / Sport / Animaux"
            case .summons: return "Service public / Convocation"
            case .missions: return "Mission publique"
            case .children: return "Enfants (école, crèche, …)"
        }
    }
    
    var titleForWidget: String {
        switch self {
            case .work: return "Travail"
            case .purchases: return "Courses"
            case .health: return "Santé"
            case .family: return "Famille"
            case .handicap: return "Handicap"
            case .walk: return "Promenade"
            case .summons: return "Convocation"
            case .missions: return "Mission"
            case .children: return "Enfants"
        }
    }
    
    var forQR: String {
        switch self {
            case .work: return "travail"
            case .purchases: return "achats"
            case .health: return "sante"
            case .family: return "famille"
            case .handicap: return "handicap"
            case .walk: return "sport_animaux"
            case .summons: return "convocation"
            case .missions: return "missions"
            case .children: return "enfants"
        }
    }
    
    var description: String {
        switch self {
            case .work: return "Déplacements entre le domicile et le lieu d’exercice de l’activité professionnelle ou un établissement d’enseignement ou de formation, déplacements professionnels ne pouvant être différés, déplacements pour un concours ou un examen."
            case .purchases: return "Déplacements pour effectuer des achats de fournitures nécessaires à l'activité professionnelle, des achats de première nécessité dans des établissements dont les activités demeurent autorisées, le retrait de commande et les livraisons à domicile."
            case .health: return "Consultations, examens et soins ne pouvant être assurés à distance et l’achat de médicaments."
            case .family: return "Déplacements pour motif familial impérieux, pour l'assistance aux personnes vulnérables et précaires ou la garde d'enfants."
            case .handicap: return "Déplacement des personnes en situation de handicap et leur accompagnant."
            case .walk: return "Déplacements brefs, dans la limite d'une heure quotidienne et dans un rayon maximal d'un kilomètre autour du domicile, liés soit à l'activité physique individuelle des personnes, à l'exclusion de toute pratique sportive collective et de toute proximité avec d'autres personnes, soit à la promenade avec les seules personnes regroupées dans un même domicile, soit aux besoins des animaux de compagnie."
            case .summons: return "Convocation judiciaire ou administrative et pour se rendre dans un service public."
            case .missions: return "Participation à des missions d'intérêt général sur demande de l'autorité administrative."
            case .children: return "Déplacement pour chercher les enfants à l’école et à l’occasion de leurs activités périscolaires."
        }
    }
}


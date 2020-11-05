import Foundation
import SwiftUI

public protocol FormEditable {
    static func name(forField field: PartialKeyPath<Self>) -> String?
    static func textFieldConfiguration(forField field: PartialKeyPath<Self>) -> TextFieldConfiguration
}


public struct TextFieldConfiguration {
    public var placeholder: String?
    public var disableAutocorrection: Bool
    public var textContentType: UITextContentType?
    
    public init(placeholder: String? = nil, disableAutocorrection: Bool = false, textContentType: UITextContentType? = nil) {
        self.placeholder = placeholder
        self.disableAutocorrection = disableAutocorrection
        self.textContentType = textContentType
    }
    
    public static let defaultConfiguration = TextFieldConfiguration(placeholder: nil, disableAutocorrection: false, textContentType: nil)
}


extension Errors where T: FormEditable {
    public var description: String {
        var all = generalErrors
        all.append(contentsOf: fieldErrors.map({
            if let name = T.name(forField: $0.0) {
                return "\(name) : \($0.1.joined(separator: " ; "))"
            }
            return $0.1.joined(separator: " ; ")
        }))
        return all.joined(separator: "\n")
    }
}

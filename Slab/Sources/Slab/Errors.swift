import Foundation

public protocol Validable {
    func validate() -> Errors<Self>
}

public struct Errors<T>: CustomStringConvertible, Identifiable {
    public var id: UUID
    
    public var generalErrors: [String]
    public var fieldErrors: [PartialKeyPath<T>: [String]]
    
    public init(_ general: [String] = [], _ field: [PartialKeyPath<T>: [String]] = [:]) {
        self.id = UUID()
        self.generalErrors = general
        self.fieldErrors = field
    }
    
    public init(general: String) {
        self.init([general], [:])
    }
    
    public init(_ field: PartialKeyPath<T>, _ error: String) {
        self.init([], [field: [error]])
    }
    
    public mutating func add(_ other: Errors<T>) {
        generalErrors.append(contentsOf: other.generalErrors)
        for (kp, errs) in other.fieldErrors {
            if var prev = fieldErrors[kp] {
                prev.append(contentsOf: errs)
                fieldErrors[kp] = prev
            }
            else {
                fieldErrors[kp] = errs
            }
        }
    }
    
    public mutating func add(_ general: String) {
        generalErrors.append(general)
    }
    
    public mutating func add(_ error: String, for kp: PartialKeyPath<T>) {
        if var prev = fieldErrors[kp] {
            prev.append(error)
            fieldErrors[kp] = prev
        }
        else {
            fieldErrors[kp] = [error]
        }
    }
    
    public mutating func remove(for kp: PartialKeyPath<T>) {
        fieldErrors.removeValue(forKey: kp)
    }
    
    public static var none: Errors<T> { .init() }
    
    public var hasNoError: Bool {
        generalErrors.isEmpty && fieldErrors.allSatisfy({ $0.1.isEmpty })
    }
    
    public var hasGeneralErrors: Bool {
        generalErrors.isNotEmpty
    }
    
    public var hasFieldErrors: Bool {
        fieldErrors.firstIndex(where: { $0.1.isNotEmpty }) != nil
    }
    
    public var hasErrors: Bool {
        hasGeneralErrors || hasFieldErrors
    }
    
    public var nilIfEmpty: Self? {
        hasNoError ? nil : self
    }
    
    public var onlyGeneralErrors: Self? {
        hasGeneralErrors ? Self.init(generalErrors, [:]) : nil
    }
    
    public var onlyFieldErrors: Self? {
        hasFieldErrors ? Self.init([], fieldErrors) : nil
    }
    
    public var generalized: Self {
        var all = generalErrors
        all.append(contentsOf: fieldErrors.values.flatMap({$0}))
        return Self.init(all, [:])
    }
    
    public var description: String {
        var all = generalErrors
        all.append(contentsOf: fieldErrors.values.flatMap({$0}))
        return all.joined(separator: "\n")
    }
    
    public func errorDescriptions(`for` field: PartialKeyPath<T>) -> [String] {
        fieldErrors[field] ?? []
    }
}


extension Errors: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
        
    public init(stringLiteral: String) {
        self.id = UUID()
        self.generalErrors = [stringLiteral]
        self.fieldErrors = [:]
    }
}

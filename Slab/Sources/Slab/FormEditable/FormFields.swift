import SwiftUI

fileprivate let minHeight = CGFloat(34)
fileprivate let errorColor = Color.init("ErrorColor")

public struct FormField_OptionalString<Model: FormEditable>: View {
    @Binding var model: String?
    @Binding var errors: Errors<Model>
    private var keyPath: KeyPath<Model, String?>
    
    public init(_ keyPath: KeyPath<Model, String?>, _ model: Binding<String?>, errors: Binding<Errors<Model>>) {
        self._model = model
        self._errors = errors
        self.keyPath = keyPath
    }
    
    public var body: some View {
        let conf = Model.textFieldConfiguration(forField: keyPath)
        
        VStack {
            HStack {
                Text(Model.name(forField: keyPath) ?? String(describing: keyPath))
                TextField(conf.placeholder ?? "", text: $model ?? "", onEditingChanged: { e in
                    guard e else { return }
                    errors.remove(for: keyPath)
                })
                .multilineTextAlignment(.trailing)
                .disableAutocorrection(conf.disableAutocorrection)
                .textContentType(conf.textContentType)
            }.frame(minHeight: minHeight)
            
            ForEach(errors.errorDescriptions(for: keyPath), id: \.self) { e in HStack {
                Text(e).font(.caption).foregroundColor(errorColor)
                    Spacer()
            }}
        }
    }
}

public struct FormField_String<Model: FormEditable>: View {
    @Binding var model: String
    @Binding var errors: Errors<Model>
    private var keyPath: KeyPath<Model, String>
    
    public init(_ keyPath: KeyPath<Model, String>, _ model: Binding<String>, errors: Binding<Errors<Model>>) {
        self._model = model
        self._errors = errors
        self.keyPath = keyPath
    }
    
    public var body: some View {
        let conf = Model.textFieldConfiguration(forField: keyPath)
        
        VStack {
            HStack {
                Text(Model.name(forField: keyPath) ?? String(describing: keyPath))
                TextField(conf.placeholder ?? "", text: $model, onEditingChanged: { e in
                    guard e else { return }
                    errors.remove(for: keyPath)
                })
                .multilineTextAlignment(.trailing)
                .disableAutocorrection(conf.disableAutocorrection)
                .textContentType(conf.textContentType)
            }.frame(minHeight: minHeight)
            
            ForEach(errors.errorDescriptions(for: keyPath), id: \.self) { e in HStack {
                Text(e).font(.caption).foregroundColor(errorColor)
                    Spacer()
            }}
        }
    }
}

public struct FormField_OptionalDate<Model: FormEditable>: View {
    @Binding var model: Date?
    @Binding var errors: Errors<Model>
    private var keyPath: KeyPath<Model, Date?>
    
    public init(_ keyPath: KeyPath<Model, Date?>, _ model: Binding<Date?>, errors: Binding<Errors<Model>>) {
        self._model = model
        self._errors = errors
        self.keyPath = keyPath
    }
    
    public var body: some View {
        VStack {
            DatePicker(Model.name(forField: keyPath) ?? String(describing: keyPath), selection: $model ?? Date(), displayedComponents: [.date])
                .frame(minHeight: minHeight)
            
            ForEach(errors.errorDescriptions(for: keyPath), id: \.self) { e in HStack {
                Text(e).font(.caption).foregroundColor(errorColor)
                    Spacer()
            }}
        }
    }
}

public struct FormField_Date<Model: FormEditable>: View {
    @Binding var model: Date
    @Binding var errors: Errors<Model>
    private var keyPath: KeyPath<Model, Date>
    
    public init(_ keyPath: KeyPath<Model, Date>, _ model: Binding<Date>, errors: Binding<Errors<Model>>) {
        self._model = model
        self._errors = errors
        self.keyPath = keyPath
    }
    
    public var body: some View {
        VStack {
            DatePicker(Model.name(forField: keyPath) ?? String(describing: keyPath), selection: $model, displayedComponents: [.date])
                .frame(minHeight: minHeight)
            
            ForEach(errors.errorDescriptions(for: keyPath), id: \.self) { e in HStack {
                Text(e).font(.caption).foregroundColor(errorColor)
                    Spacer()
            }}
        }
    }
}

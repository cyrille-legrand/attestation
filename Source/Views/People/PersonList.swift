import SwiftUI
import Slab

struct PersonList: View {
    @EnvironmentObject var database: Database
    @State private var isPresentingCreator: Bool = false
    
    var body: some View {
        list
        .navigationTitle("Personnes")
        .toolbar(content: {
            ToolbarItem(placement: .automatic) {
                Button(
                    action: { isPresentingCreator = true },
                    label: { Image(systemName: "plus") }
                )
            }
        })
        .sheet(isPresented: $isPresentingCreator, content: {
            PersonCreator(isPresented: $isPresentingCreator).environmentObject(database)
        })
    }
    
    var list: some View {
        Group {
            if database.people.isEmpty {
                Text("Utilisez le bouton + pour ajouter une personne.")
                    .foregroundColor(.secondary)
                
            }
            else {
                List {
                    ForEach(database.people.sorted(by: <)) { person in
                        NavigationLink(
                            destination: LazyView(
                                PersonEditor(editing: person).environmentObject(database)
                            ),
                            label: {
                                Text(person.fullName)
                            }
                        )
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
    }
    
    func deleteItems(at indices: IndexSet) {
        let allPeople = database.people.sorted(by: <)
        let toDelete = indices.map { allPeople[$0] }
        database.remove(toDelete)
    }
}


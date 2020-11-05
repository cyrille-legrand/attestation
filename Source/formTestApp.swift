import SwiftUI

@main
struct formTestApp: App {
    
    var database = Database.shared
    @State private var selectedTab = 0
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                
                NavigationView {
                    AttestationList().environmentObject(database)
                }
                .tag(1)
                .tabItem {
                    selectedTab == 1 ? Image(systemName: "checkmark.seal.fill") : Image(systemName: "checkmark.seal")
                    Text("Attestations")
                }
                
                // ---------------
                
                NavigationView {
                    PersonList().environmentObject(database)
                }
                .tag(0)
                .tabItem {
                    selectedTab == 0 ? Image(systemName: "person.2.fill") : Image(systemName: "person.2")
                    Text("Personnes")
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear(perform: {
                if database.people.isEmpty {
                    selectedTab = 0
                }
                else {
                    selectedTab = 1
                }
            })
        }
    }
}

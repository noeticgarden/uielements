
import SwiftUI

struct MainView: View {
    enum Example {
        case envelopment
    }
    
    @State var selected: Example?
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            NavigationStack {
                List(selection: $selected) {
                    NavigationLink("Envelopment", value: Example.envelopment)
                }
                .navigationTitle("Examples")
            }
            .toolbar(removing: .sidebarToggle)
        } detail: {
            switch selected {
            case .envelopment:
                EnvelopmentExample()
                
            case nil:
                Text("Select an example.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    MainView()
}

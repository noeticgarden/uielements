
import SwiftUI

struct MainView: View {
    enum Example: String {
        case envelopment
        case marks
    }
    
    @AppStorage("LastSelectedExample") var lastSelectedExample: String?
    @State var hasRestoredLastSelectedExample = false
    @State var selected: Example?
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            NavigationStack {
                List(selection: $selected) {
                    NavigationLink("Envelopment", value: Example.envelopment)
                    NavigationLink("Marks", value: Example.marks)
                }
                .navigationTitle("Examples")
            }
            .toolbar(removing: .sidebarToggle)
        } detail: {
            switch selected {
            case .envelopment:
                EnvelopmentExample()
                
            case .marks:
                MarksExample()
                
            case nil:
                Text("Select an example.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onChange(of: selected) { oldValue, newValue in
            if let newValue {
                self.lastSelectedExample = newValue.rawValue
            }
        }
        .onAppear {
            if !hasRestoredLastSelectedExample,
               let lastSelectedExample {
                self.selected = .init(rawValue: lastSelectedExample)
                hasRestoredLastSelectedExample = true
            }
        }
    }
}

#Preview {
    MainView()
}

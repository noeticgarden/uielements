
import SwiftUI
import Marks

struct MarksExample: View {
    @State var marks = Marks {
#if os(tvOS)
        IdentifiedMark(id: "TopLeft", mark: .point(.init(x: 30, y: 20, z: 0)))
        IdentifiedMark(id: "Middle", mark: .point(.init(x: 500, y: 400, z: 0)))
        IdentifiedMark(id: "BottomRight", mark: .point(.init(x: 800, y: 620, z: 0)))
#endif
    }

    var header: some View {
#if os(tvOS)
        Text("Sample Marks:")
#else
        Text("Hover on, click, drag, or touch the surface to show marks.")
#endif
    }
    
    @Namespace var me
    
    var body: some View {
        VStack {
            header
                .foregroundStyle(.secondary)
                .padding()
            
            MarksView(marks: marks)
                .contentShape(Rectangle())
                .allowsHitTesting(true)
                .experimental.marksContinuousHover(amongst: $marks)
#if os(tvOS)
                .focusable()
                .prefersDefaultFocus(in: me)
#else
                .experimental.marksDragGestures(amongst: $marks)
                .experimental.marksSpatialEvents(amongst: $marks)
#endif
        }
    }
}

#Preview {
    MarksExample()
}

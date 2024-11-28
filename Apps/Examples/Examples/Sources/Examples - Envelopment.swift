
import SwiftUI
import UIElements

struct EnvelopmentExample: View {
    @State var inspectorIsPresented = true
    @State var visibleFaces = {
        var set = Set(Envelopment.Placement.allCases)
        set.remove(.front)
        return set
    }()
    @State var showsConcentric = true
    @State var zeroDepthAdaptation = Envelopment.Adaptation.simulatesFrontView
    
    @State var depth: CGFloat = 200
    
    @ViewBuilder
    var displayedContent: some View {
        if showsConcentric {
            concentric
        } else {
            envelopment
        }
    }
    
    var concentric: some View {
        Concentric {
            envelopment
            Image(systemName: "checkmark.circle")
                .font(.system(size: 125))
        }
#if os(visionOS)
        .frame(maxDepth: depth)
#endif
    }
    
    var envelopment: some View {
        Envelopment {
            if visibleFaces.contains(.back) {
                EnvelopmentFace(placement: .back) {
                    FaceView(text: "Back", color: .blue)
                }
            }
            
            if visibleFaces.contains(.front) {
                EnvelopmentFace(placement: .front) {
                    FaceView(text: "Front", color: .purple)
                }
            }
            
            if visibleFaces.contains(.frontOutward) {
                EnvelopmentFace(placement: .frontOutward) {
                    FaceView(text: "Front (Outward)", color: .indigo)
                }
            }
            
            if visibleFaces.contains(.leading) {
                EnvelopmentFace(placement: .leading) {
                    FaceView(text: "Leading", color: .orange)
                }
            }
            
            if visibleFaces.contains(.top) {
                EnvelopmentFace(placement: .top) {
                    FaceView(text: "Top", color: .gray)
                }
            }
            
            if visibleFaces.contains(.trailing) {
                EnvelopmentFace(placement: .trailing) {
                    FaceView(text: "Trailing", color: .cyan)
                }
            }
            
            if visibleFaces.contains(.bottom) {
                EnvelopmentFace(placement: .bottom) {
                    FaceView(text: "Bottom", color: .black)
                }
            }
        }
        .envelopmentZeroDepthAdaptation(zeroDepthAdaptation)
#if os(visionOS)
        .frame(maxDepth: depth)
#endif
        .padding()
    }
    
    var body: some View {
        NavigationStack {
#if os(visionOS) || os(tvOS)
            HStack {
                displayedContent
                inspectorView
                    .contentMargins(.top, 30, for: .scrollContent)
                    .frame(maxWidth: 380)
            }
#else
            displayedContent
                .toolbar {
                    Toggle(isOn: $inspectorIsPresented) {
                        Label("Settings", systemImage: "info.circle")
                    }
                }
#endif
        }
#if !(os(visionOS) || os(tvOS))
        .inspector(isPresented: $inspectorIsPresented) {
            inspectorView
        }
#endif
    }
    
    func faceToggleBinding(_ placement: Envelopment.Placement) -> Binding<Bool> {
        Binding {
            visibleFaces.contains(placement)
        } set: { newValue in
            withAnimation {
                if newValue {
                    visibleFaces.insert(placement)
                } else {
                    visibleFaces.remove(placement)
                }
            }
        }
    }
    
    var inspectorView: some View {
        Form {
            Section {
#if os(visionOS)
                LabeledContent("Depth") {
                    Slider(value: $depth, in: 0...300)
                        .frame(maxWidth: 250)
                }
#else
                LabeledContent("Depth", value: "0")
#endif
                
                Picker("If Zero", selection: $zeroDepthAdaptation) {
                    Text("Show Back Face")
                        .tag(Envelopment.Adaptation.showsSingleFace(.back))
                    Text("Show Front Face")
                        .tag(Envelopment.Adaptation.showsSingleFace(.front))
                    Text("Show Front Outward Face")
                        .tag(Envelopment.Adaptation.showsSingleFace(.frontOutward))
                    Text("Show Leading Face")
                        .tag(Envelopment.Adaptation.showsSingleFace(.leading))
                    Text("Show Trailing Face")
                        .tag(Envelopment.Adaptation.showsSingleFace(.trailing))
                    Text("Show Top Face")
                        .tag(Envelopment.Adaptation.showsSingleFace(.top))
                    Text("Show Bottom Face")
                        .tag(Envelopment.Adaptation.showsSingleFace(.bottom))
                    Divider()
                    Text("Simulate Front View")
                        .tag(Envelopment.Adaptation.simulatesFrontView)
                }
            } footer: {
#if !os(visionOS)
                Text("Outside of visionOS, all views always have a depth of zero.")
#if os(macOS)
                    .font(.caption)
                    .foregroundStyle(.secondary)
#endif
#endif
            }
            
            Section("Faces") {
                Toggle("Back", isOn: faceToggleBinding(.back))
                Toggle("Trailing", isOn: faceToggleBinding(.trailing))
                Toggle("Front", isOn: faceToggleBinding(.front))
                Toggle("Front (Outward)", isOn: faceToggleBinding(.frontOutward))
                Toggle("Leading", isOn: faceToggleBinding(.leading))
                Toggle("Top", isOn: faceToggleBinding(.top))
                Toggle("Bottom", isOn: faceToggleBinding(.bottom))
            }
            
            Section {
                Toggle("Show Concentric Content", isOn: $showsConcentric.animation())
            }
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
}

struct FaceView: View {
    let text: LocalizedStringKey
    let color: Color
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .foregroundStyle(color.opacity(0.2))
                .border(color)
            
            Text(text)
                .foregroundStyle(.white)
                .padding(5)
                .padding([.leading, .trailing], 7)
                .background {
                    RoundedRectangle(cornerRadius: 100)
                        .foregroundStyle(color)
                }
                .padding(5)
            
        }
    }
}

#Preview {
    EnvelopmentExample()
}

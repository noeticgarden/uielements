
#if canImport(SwiftUI)
import SwiftUI
import Spatial

struct _SizeExfiltrator: ViewModifier {
    @State var exfiltrated = Exfiltrated()
    struct Exfiltrated: Equatable {
#if os(visionOS)
        var backPlaneFrame: Rect3D?
        var frontPlaneOrigin: Point3D?
#else
        var frame: CGRect?
#endif
    }
    
    let onSizeExfiltrated: (Size3D) -> Void
    
    func body(content: Content) -> some View {
#if os(visionOS)
        content
            .background {
                GeometryReader3D { geometry in
                    {
                        let frame = geometry.frame(in: .global)
                        Task { @MainActor in
                            self.exfiltrated.backPlaneFrame = frame
                        }
                        return Color.clear
                    }()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .overlay {
                GeometryReader3D { geometry in
                    {
                        let frame = geometry.frame(in: .global)
                        Task { @MainActor in
                            self.exfiltrated.frontPlaneOrigin = frame.origin
                        }
                        return Color.clear
                    }()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onChange(of: exfiltrated) { oldValue, newValue in
                guard let backPlaneFrame = newValue.backPlaneFrame,
                      let frontPlaneOrigin = newValue.frontPlaneOrigin else {
                    return
                }
                
                let result = Size3D(
                    width: backPlaneFrame.size.width,
                    height: backPlaneFrame.size.height,
                    depth: frontPlaneOrigin.z - backPlaneFrame.origin.z
                )
                self.onSizeExfiltrated(result)
            }
#else
        content
            .background {
                GeometryReader { geometry in
                    {
                        let frame = geometry.frame(in: .global)
                        Task { @MainActor in
                            self.exfiltrated.frame = frame
                        }
                        return Color.clear
                    }()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onChange(of: exfiltrated) { newValue in
                guard let frame = newValue.frame else {
                    return
                }
                
                self.onSizeExfiltrated(
                    Size3D(
                        width: frame.size.width,
                        height: frame.size.height,
                        depth: 0
                    )
                )
            }
#endif
    }
}

#if compiler(>=6) // Require Xcode 16's SDKs for previews.
@available(macOS 14, *)
@available(iOS 17, *)
@available(tvOS 17, *)
@available(watchOS 10, *)
@available(visionOS 1, *)
#Preview {
    @Previewable @State var size: Size3D?

#if os(visionOS)
    Sphere()
        .modifier(_SizeExfiltrator { newSize in
            size = newSize
        })
        .onChange(of: size, initial: true) { oldValue, newValue in
            print(String(describing: newValue))
        }
#else
    Text("visionOS is required for this preview.")
        .padding()
#endif
}

@available(macOS 14, *)
@available(iOS 17, *)
@available(tvOS 17, *)
@available(watchOS 10, *)
@available(visionOS 1, *)
#Preview {
    @Previewable @State var size: Size3D?
    
    RoundedRectangle(cornerRadius: 15)
        .frame(width: 520, height: 250)
        .foregroundStyle(.red)
        .padding()
        .modifier(_SizeExfiltrator { newSize in
            size = newSize
        })
        .onChange(of: size, initial: true) { oldValue, newValue in
            print(String(describing: newValue))
        }
}
#endif // compiler(>=6)

#endif

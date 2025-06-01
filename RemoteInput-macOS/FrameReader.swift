import SwiftUI

struct FrameReader: ViewModifier {
    @Binding var frame: CGRect
    let coordinateSpace: CoordinateSpace
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            frame = geometry.frame(in: coordinateSpace)
                        }
                        .onChange(of: geometry.frame(in: coordinateSpace)) { oldValue, newValue in
                            frame = newValue
                        }
                }
            )
    }
}

extension View {
    func frameReader(frame: Binding<CGRect>, coordinateSpace: CoordinateSpace) -> some View {
        modifier(FrameReader(frame: frame, coordinateSpace: coordinateSpace))
    }
}

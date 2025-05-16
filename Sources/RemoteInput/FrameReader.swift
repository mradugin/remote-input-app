import SwiftUI

struct FrameReader: ViewModifier {
    @Binding var frame: CGRect
    let coordinateSpace: CoordinateSpace
    
    func body(content: Content) -> some View {
        content
        .background {
            GeometryReader { geometryValue in
                let frame = geometryValue.frame(in: coordinateSpace)
                Color.clear
                .onAppear {
                    self.frame = frame
                }
                .onChange(of: frame) { newValue in
                    self.frame = newValue
                }
            }
        }
    }
}

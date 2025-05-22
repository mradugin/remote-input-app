import SwiftUI

struct TouchInputHandlerView: UIViewControllerRepresentable {
    let reportController: ReportController
    @Binding var selectedInputMode: ContentView.InputMode
    
    func makeUIViewController(context: Context) -> TouchInputHandler {
        TouchInputHandler(reportController: reportController)
    }
    
    func updateUIViewController(_ uiViewController: TouchInputHandler, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: TouchInputHandlerView
        
        init(_ parent: TouchInputHandlerView) {
            self.parent = parent
        }
    }
} 
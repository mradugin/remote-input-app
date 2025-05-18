import SwiftUI
import OSLog
#if os(iOS)
import UIKit
#endif

#if os(iOS)
class TouchInputHandler: UIViewController {
    private let reportController: ReportController
    private var lastTouchLocation: CGPoint?
    private var isDragging = false
    
    init(reportController: ReportController) {
        self.reportController = reportController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = true
        view.isMultipleTouchEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: view)
        lastTouchLocation = location
        isDragging = true
        
        // Simulate mouse down
        let report: [UInt8] = [1, 0, 0] // Left mouse button down
        reportController.reportMouseEvent(report)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let lastLocation = lastTouchLocation else { return }
        
        let location = touch.location(in: view)
        let deltaX = location.x - lastLocation.x
        let deltaY = location.y - lastLocation.y
        
        // Convert to Int8 range (-128 to 127)
        let deltaXInt8 = Int8(clamp(deltaX, min: -128, max: 127))
        let deltaYInt8 = Int8(clamp(deltaY, min: -128, max: 127))
        
        let report: [UInt8] = [
            isDragging ? 1 : 0, // Mouse button state
            UInt8(bitPattern: deltaXInt8),
            UInt8(bitPattern: deltaYInt8)
        ]
        reportController.reportMouseEvent(report)
        
        lastTouchLocation = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
        lastTouchLocation = nil
        
        // Simulate mouse up
        let report: [UInt8] = [0, 0, 0] // Mouse button up
        reportController.reportMouseEvent(report)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    private func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
        return Swift.max(min, Swift.min(max, value))
    }
}

extension ReportController {
    func reportMouseEvent(_ report: [UInt8]) {
        queueReport(.mouse(report))
    }
}
#endif 
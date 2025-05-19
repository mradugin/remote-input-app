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
        reportController.reportMouseButton(buttonMask: 1)
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
        
        reportController.reportMouseMovement(deltaX: deltaXInt8, deltaY: deltaYInt8, buttonMask: isDragging ? 1 : 0)
        lastTouchLocation = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
        lastTouchLocation = nil
        
        // Simulate mouse up
        reportController.reportMouseButton(buttonMask: 0)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    private func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
        return Swift.max(min, Swift.min(max, value))
    }
}

#endif 
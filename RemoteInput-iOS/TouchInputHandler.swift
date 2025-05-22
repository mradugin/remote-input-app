import SwiftUI
import OSLog

class TouchInputHandler: UIViewController {
    private let reportController: ReportController
    private var lastTouchLocation: CGPoint?
    private var isDragging = false
    private var touchStartTime: Date?
    private let clickThreshold: TimeInterval = 0.2
    private let dragDelayThreshold: TimeInterval = 0.2
    private var touchJustBegan = false
 
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

        lastTouchLocation = touch.location(in: view)
        isDragging = false
        touchStartTime = Date()
        touchJustBegan = true
        
        // Don't send initial mouse down - wait for move or end
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let startTime = touchStartTime,
              let lastLocation = lastTouchLocation else { return }
        
        let location = touch.location(in: view)
        let deltaX = location.x - lastLocation.x
        let deltaY = location.y - lastLocation.y
        
        if touchJustBegan {
            // Check if this is the first move after a delay
            let moveDelay = Date().timeIntervalSince(startTime)
            if moveDelay > dragDelayThreshold {
                isDragging = true
            }
            touchJustBegan = false
        }
        
        // Convert to Int8 range (-128 to 127)
        let deltaXInt8 = Int8(clamp(deltaX, min: -128, max: 127))
        let deltaYInt8 = Int8(clamp(deltaY, min: -128, max: 127))
        
        // Send movement with button state based on dragging
        reportController.reportMouseMovement(deltaX: deltaXInt8, deltaY: deltaYInt8, buttonMask: isDragging ? 1 : 0)
        lastTouchLocation = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let startTime = touchStartTime else { return }
        let touchDuration = Date().timeIntervalSince(startTime)
        
        if !isDragging && touchDuration < clickThreshold {
            // This was a short touch without movement - send a click
            reportController.reportMouseButton(buttonMask: 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { // 50ms delay
                self.reportController.reportMouseButton(buttonMask: 0)
            }
        } else {
            // This was a drag or long touch - just release the button
            reportController.reportMouseButton(buttonMask: 0)
        }
        
        // Reset state
        touchStartTime = nil
        lastTouchLocation = nil
        isDragging = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
    
    private func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
        return Swift.max(min, Swift.min(max, value))
    }
}

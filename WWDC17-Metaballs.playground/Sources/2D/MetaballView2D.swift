import UIKit

public class MetaballView2D: UIView { // TODO: Be able to configure colors
    public typealias DrawBlock = (_ view: MetaballView2D, _ context: CGContext) -> Void
    
    public let system: MetaballSystem2D = MetaballSystem2D()
    public var drawBlock: DrawBlock?
    
    // MARK: View lifecycle
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        // Set the size of the system
        system.width = Int(bounds.width)
        system.height = Int(bounds.height)
    }
    
    // MARK: Drawing
    override public func draw(_ rect: CGRect) {
        // Get the current context
        guard let context = UIGraphicsGetCurrentContext() else {
            print("Could not get context.")
            return
        }
        
        // Do the calculations required for everything else
        system.calculateSamples()
        system.calculateClassifications()
        
        // Draw the rest
        drawBlock?(self, context)
    }
    
    public func drawCircles(context: CGContext) {
        for ball in system.balls {
            context.strokeEllipse(in:
                CGRect(
                    x: ball.position.x - ball.radius, y: ball.position.y - ball.radius,
                    width: ball.radius * 2, height: ball.radius * 2
                )
            )
        }
    }
    
    public func drawValues(context: CGContext) {
//        ("Hello, world" as NSString).draw(at: <#T##CGPoint#>, withAttributes: <#T##[String : Any]?#>) // http://stackoverflow.com/questions/7251065/iphone-draw-white-text-on-black-view-using-cgcontext
    }
    
    public func drawGrid(context: CGContext) {
        // Calculate the size for each cell
        let width = bounds.width / CGFloat(system.width) / CGFloat(system.resolution)
        let height = bounds.height / CGFloat(system.height) / CGFloat(system.resolution)
        
        // Draw a square for each cell
        for (i, sample) in system.samples.enumerated() {
            let position = system.point(forIndex: i)
            if sample.aboveThreshold {
                context.fill(
                    CGRect(
                        x: position.x, y: position.y,
                        width: width, height: height
                    )
                )
            }
        }
    }
    
    public func drawPoints(context: CGContext) { // Just like the grid, but the points at every corner
        
    }
    
    public func drawCells(context: CGContext, interpolate: Bool) { // Draws the metaballs using marching squares
        let lines = system.calculateLines()
        for line in lines {
            context.strokeLineSegments(between: [line.a, line.b])
        }
    }
    
    // MARK: Interaction
    var touchStates = [UITouch: Int]() // [Touch: Ball index]
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            // Find the ball that was touched
            var ballIndex = -1
            for (i, ball) in system.balls.enumerated() {
                if sqrt(pow(ball.position.x - location.x, 2) + pow(ball.position.y - location.y, 2)) < ball.radius {
                    ballIndex = i
                    break
                }
            }
            
            // If no ball, create new ball
            if ballIndex == -1 {
                let ball = Metaball2D(position: location, radius: 15) // TODO: Use callback to create a ball
                system.balls.append(ball)
                ballIndex = system.balls.count - 1
            }
            
            if touch.tapCount >= 2 {
                // Delete the ball
                touchStates[touch] = nil
                system.balls.remove(at: ballIndex)
            } else {
                // Set the ball index being tapped
                touchStates[touch] = ballIndex
            }
        }
        
        setNeedsDisplay()
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if let ballIndex = touchStates[touch] {
                system.balls[ballIndex].position = location
            }
        }
        
        setNeedsDisplay()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchStates[touch] = nil
        }
        
        setNeedsDisplay()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchStates[touch] = nil
        }
        
        setNeedsDisplay()
    }
}

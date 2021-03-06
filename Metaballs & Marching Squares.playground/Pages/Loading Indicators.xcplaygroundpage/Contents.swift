/*:
 # Example: Loading Indicators
 
 Metaballs can be used for all sorts of fun demonstrations. For example, you can create really creative looking loading indicators, as seen below.
 
 Try swapping the loading styles and modifying properties to see the effect. To go even further, try writing your own; almost anything you make looks interesting.
 
 ---
 [◀ Marching Squares](@previous) • [Example: Fluid Simulation ▶](@next)
 */


import UIKit

// Defines types of loaders
enum LoadingStyle {
    case linear(count: Int, spacing: CGFloat), circular(count: Int, radius: CGFloat)
}

// The loading style used for the view
//let loadingStyle = LoadingStyle.linear(count: 3, spacing: 60)
let loadingStyle = LoadingStyle.circular(count: 3, radius: 40)

// Create a view
let view = MetaballView2D(frame: simulationSize)
view.drawBlock = { view, context in
    UIColor.independence.setFill()
    context.fill(view.bounds)
    
    UIColor.corsilk.setFill()
    view.drawCellsPath(context: context)
}

// Set up the system
let system = view.system
system.resolution = 1 / 4

// Create a controller for the loading indicator; we have to use a class
// because CADisplayLink uses a selector
class LoadingController {
    let system: MetaballSystem2D
    let style: LoadingStyle
    let speed: CFTimeInterval
    
    init(system: MetaballSystem2D, style: LoadingStyle, ballSize: CGFloat, speed: CFTimeInterval) {
        // Save the values
        self.system = system
        self.style = style
        self.speed = speed
        
        // Generate the balls
        let ballCount: Int
        switch style {
        case .linear(let count, _):
            ballCount = count + 1
        case .circular(let count, _):
            ballCount = count + 1
        }
        system.generateMetaballs(count: ballCount, minSize: ballSize, maxSize: ballSize)
        system.balls.last?.radius *= 0.75
        
        // Link into the render loop
        let displayLink = CADisplayLink(target: self, selector: #selector(step))
        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
        
    }
    
    @objc func step(link: CADisplayLink) {
        // Get the moving ball
        let movingBall = system.balls.last!
        
        // Get the center position
        let center = CGPoint(x: CGFloat(system.width) / 2, y: CGFloat(system.height) / 2)
        
        // Do positioning
        switch style {
        case .linear(let count, let spacing):
            let totalWidth = CGFloat(count - 1) * spacing
            
            // Place static balls
            for i in 0..<count {
                system.balls[i].position =
                    CGPoint(
                        x: CGFloat(i) * spacing + center.x - totalWidth / 2,
                        y: center.y
                    )
            }
            
            // Place the moving ball
            let offset = CGFloat(sin(link.timestamp * speed)) * (totalWidth / 2 + spacing)
            movingBall.position =
                CGPoint(
                    x: center.x + offset,
                    y: center.y
                )
        case .circular(let count, let radius):
            // Place static balls
            for i in 0..<count {
                var angle = CGFloat(i) / CGFloat(count) * CGFloat.pi * 2
                angle -= CGFloat.pi / 2 // Center the top ball
                system.balls[i].position =
                    CGPoint(
                        x: cos(angle) * radius + center.x,
                        y: sin(angle) * radius + center.y
                    )
            }
            
            // Place the moving ball
            movingBall.position =
                CGPoint(
                    x: center.x + CGFloat(cos(link.timestamp * speed)) * radius,
                    y: center.y + CGFloat(sin(link.timestamp * speed)) * radius
            )
        }
        
        // Re-render it
        view.setNeedsDisplay()
    }
}

// Set it up
let controller = LoadingController(
    system: system,
    style: loadingStyle,
    ballSize: 15,
    speed: 2.5
)

// Present the view
present(view: view)

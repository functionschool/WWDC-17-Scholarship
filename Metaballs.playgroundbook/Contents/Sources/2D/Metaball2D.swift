import Foundation
import CoreGraphics

public class Metaball2D {
    // Where the circle is
    var position: CGPoint
    
    // Radius of the circle
    var radius: CGFloat {
        didSet {
            // Save the size squared
            radius2 = radius * radius
        }
    }
    
    // Util for size ^ 2
    private(set) var radius2: CGFloat
    
    public init(position: CGPoint, radius: CGFloat) {
        self.position = position
        self.radius = radius
        self.radius2 = radius * radius
    }
}

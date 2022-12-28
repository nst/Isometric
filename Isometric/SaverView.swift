//
//  SaverView.swift
//  Isometric
//
//  Created by Nicolas Seriot on 17.10.21.
//

import ScreenSaver

// TODO: use ttls
// TODO: add random formulas
// TODO: use window dimensions

// MARK: - SaverView
final class SaverView: ScreenSaverView {

    var model = Model(X: 1, Y: 1, Z: 1, defaultValue: 0) // default
    
    // MARK: Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        //self.animationTimeInterval = 1 / 30.0
        
        setup()
    }
    
    func setup() {
        
        print(self.frame)
        
        if(self.frame.size.width <= 1.0) {
            return
        }
        
        let x_ = self.frame.size.width / CGFloat(self.model.DW) / 3.0 * 2.0
        let z_ = (self.frame.size.height - (CGFloat(x_) * 3.0 * CGFloat(self.model.DH) / 2.0)) / CGFloat(self.model.DH)

        self.model = Model(X: Int(x_), Y: Int(x_) * 2, Z: Int(z_), defaultValue: 0)

        let X = self.model.oids.X
        let Y = self.model.oids.Y
        let Z = self.model.oids.Z

        //        self.model.oids[0,0,0] = 1
        //        self.model.oids[0,1,0] = 1

        /*
        self.model.oids.fill(xx: (2,2), yy: (3,3), zz: (5,6), v: 1)
        
        self.model.oids.fill(xx:(1,2), yy:(1,2), zz:(5,6), v:0)
        self.model.oids.fill(xx:(4,5), yy:(1,2), zz:(5,6), v:0)
        self.model.oids.fill(xx:(1,2), yy:(4,5), zz:(5,6), v:0)
        self.model.oids.fill(xx:(4,5), yy:(4,5), zz:(5,6), v:0)

        self.model.oids.fill(xx:(0,2), yy:(1,2), zz:(1,2), v:0)
        self.model.oids.fill(xx:(0,2), yy:(1,2), zz:(4,5), v:0)
        self.model.oids.fill(xx:(0,2), yy:(4,5), zz:(1,2), v:0)
        self.model.oids.fill(xx:(0,2), yy:(4,5), zz:(4,5), v:0)

        self.model.oids.fill(xx:(1,2), yy:(0,2), zz:(1,2), v:0)
        self.model.oids.fill(xx:(1,2), yy:(0,2), zz:(4,5), v:0)
        self.model.oids.fill(xx:(4,5), yy:(0,2), zz:(1,2), v:0)
        self.model.oids.fill(xx:(4,5), yy:(0,2), zz:(4,5), v:0)
        */
        
        for x in 0...X-1 {
            let cosX = cos(Double(x))
            for y in 0...Y-1 {
                for z in 0...Z-1 {
                    if Int(cosX * Double(y)) % (z+1) == 0 {
                        self.model.oids[x,y,z] = 1
                    }
                }
            }
        }

    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }

    override func startAnimation() {
        super.startAnimation()
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    
    override func draw(_ rect: NSRect) {
        super.draw(rect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { abort() }
//        context.setAllowsAntialiasing(false)
//        context.setShouldAntialias(false)
        
        self.model.draw(context:context)
        
//        NSColor.red.set()
//
//        let bp = NSBezierPath()
//        bp.move(to: NSMakePoint(300, 300))
//        bp.line(to: NSMakePoint(350, 350))
//        bp.stroke()
//
//        let bp2 = NSBezierPath()
//        bp2.move(to: NSMakePoint(300, 300))
//        bp2.line(to: NSMakePoint(400, 300))
//        bp2.stroke()

    }

    override func animateOneFrame() {
        // update model
        
        let X = self.model.oids.X
        let Y = self.model.oids.Y
        let Z = self.model.oids.Z

        var x = 0
        var y = 0
        var z = 0

        // TODO: improve: add self.model.randomCubeWithValue(1)
        var visibleCubeWasFound = false
        while visibleCubeWasFound == false {
            x = Int.random(in: 0..<X)
            y = Int.random(in: 0..<Y)
            z = Int.random(in: 0..<Z)
            visibleCubeWasFound = self.model.vm[x,y,z] == 1
        }
        
        self.model.oids[x,y,z] = (self.model.oids[x,y,z] + 1) % 2
        
        let rect = self.model.drawingRect(x: x, y: y, z: z)
        //print("-- rect:", rect)

        let wideRect = NSMakeRect(rect.origin.x - 10, rect.origin.y - 10, rect.size.width + 20, rect.size.height + 20)
        //print("-- wideRect:", wideRect)
        
        self.setNeedsDisplay(wideRect)
        
//        self.needsDisplay = true
    }
}

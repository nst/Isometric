//
//  Model+Draw.swift
//  Isometric
//
//  Created by Nicolas Seriot on 17.10.21.
//

import Cocoa

extension Model {
        
    func drawCube(x: Int, y: Int, z: Int, nx: Bool, nx_: Bool, ny: Bool, ny_: Bool, nz: Bool, nz_: Bool, nxy_: Bool, nxz: Bool, nx_z_: Bool, nyz: Bool, ny_z_: Bool) {
        
        //print("drawCube", x, y, z)
    /*
      5
    2   6
      3      - DH
    1   7
      4
      | z_offset
    */
        
        let DW2 = DW / 2
        let DH2 = DH / 2

        let Y_MAX = self.oids.Y
        let Z_MAX = self.oids.Z
        
        let z_offset = DH * z
        
        let px = DW2 * (Y_MAX-1) + DW2*(x-y)
        let py = DH2*(x+y)
        //let p = NSMakePoint(CGFloat(px), CGFloat(py))
        
        guard let c = NSGraphicsContext.current?.cgContext else { return }
        
        c.saveGState()
        
        //print("-- translate", px, py)
        
        c.translateBy(x: CGFloat(px), y: CGFloat(py) + CGFloat(z_offset))
        
        let p1 = NSMakePoint(0.0, CGFloat(DH2))
        let p2 = NSMakePoint(0.0, CGFloat(DH2+DH))
        let p3 = NSMakePoint(CGFloat(DW2), CGFloat(DH))
        let p4 = NSMakePoint(CGFloat(DW2), 0.0)
        let p5 = NSMakePoint(CGFloat(DW2), CGFloat(2*DH))
        let p6 = NSMakePoint(CGFloat(DW), CGFloat(DH2+DH))
        let p7 = NSMakePoint(CGFloat(DW), CGFloat(DH2))

        var verticesR : [(CGPoint,CGPoint)] = []
        var verticesL : [(CGPoint,CGPoint)] = []
        var verticesT : [(CGPoint,CGPoint)] = []

        if (nx == false && nz == false) || (nx && nxz) {
            verticesT.append((p5, p6))
        }
        if (nx == false && ny_ == false) || (nx && nxy_) {
            verticesR.append((p6, p7))
        }
        if (ny == false && nz == false) || (ny && nyz) {
            verticesT.append((p5, p2))
        }
        if (nz_ == false && nx_ == false) || (nz_ && nx_z_) {
            verticesL.append((p1, p4))
        }
        if ny == false && nx_ == false {
            verticesL.append((p2, p1))
        }
        if nz_ == false && ny_ == false {
            verticesR.append((p4, p7))
        }
        if nx_ == false && ny_ == false {
            verticesL.append((p3, p4))
        }
        if nz == false && ny_ == false {
            verticesT.append((p3, p6))
        }
        if nz == false && nx_ == false {
            verticesT.append((p2, p3))
        }
        
        //print("verticesL:", verticesL)

        let z_ratio = 0.4 + CGFloat(z) * 0.6 / CGFloat(Z_MAX)
        
        let COLOR_TOP   = NSColor(calibratedRed: z_ratio, green: 0.5 * z_ratio, blue: 0.5 * z_ratio, alpha: 1.0)
        let COLOR_LEFT  = NSColor(calibratedRed: 0.6 * z_ratio, green: 0.0, blue: 0.0, alpha: 1.0)
        let COLOR_RIGHT = NSColor(calibratedRed: z_ratio, green: 0.0, blue: 0.0, alpha: 1.0)
        
        // right side
        if ny_ == false {
            drawSurface(context: c, points: [p3, p6, p7, p4], vertices: verticesR, fillColor: COLOR_RIGHT, strokeColor: NSColor.black)
        }

        // left side
        if nx_ == false {
            drawSurface(context: c, points: [p1, p2, p3, p4], vertices: verticesL, fillColor: COLOR_LEFT, strokeColor: NSColor.black)
        }

        // top face
        if nz == false {
            drawSurface(context: c, points: [p2, p5, p6, p3], vertices: verticesT, fillColor: COLOR_TOP, strokeColor: NSColor.black)
        }

        c.restoreGState()
    }
    
    func drawSurface(context: CGContext, points: [CGPoint], vertices: [(CGPoint, CGPoint)], fillColor: NSColor, strokeColor: NSColor) {
        
        context.saveGState()
        
        let pointsArray = NSPointArray.allocate(capacity: points.count)
        for (i, p) in points.enumerated() {
            pointsArray[i] = p
        }
        
        fillColor.set()
        let bp = NSBezierPath()
        bp.appendPoints(pointsArray, count: points.count)
        bp.fill()
        
        strokeColor.set()
        for (p1, p2) in vertices {
            NSBezierPath.strokeLine(from: p1, to: p2)
        }
        
        context.restoreGState()
    }
}

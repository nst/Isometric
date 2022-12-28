//
//  Model.swift
//  Isometric
//
//  Created by Nicolas Seriot on 17.10.21.
//

import Foundation
import CoreGraphics

struct Matrix3D<ElementType: Equatable> {
    
    let X: Int
    let Y: Int
    let Z: Int
    
    var grid: [ElementType]
    
    init(X: Int, Y: Int, Z: Int, defaultValue: ElementType) {
        self.X = X
        self.Y = Y
        self.Z = Z
        grid = Array(repeating: defaultValue, count: X * Y * Z)
    }
    
    func indexIsValidForRow(x: Int, y: Int, z: Int) -> Bool {
        return x >= 0 && x < X && y >= 0 && y < Y && z >= 0 && z < Z
    }
    
    subscript(x: Int, y: Int, z: Int) -> ElementType {
        get {
            assert(indexIsValidForRow(x:x, y:y, z:z), "Index out of range")
            return grid[(x*Y*Z) + (z*Y) + y]
        }
        set {
            assert(indexIsValidForRow(x:x, y:y, z:z), "Index out of range")
            grid[(x*Y*Z) + (z*Y) + y] = newValue
        }
    }
    
    mutating func fill(xx: (Int, Int), yy: (Int, Int), zz: (Int, Int), v: ElementType) {

        for x in xx.0...xx.1 {
            for y in yy.0...yy.1 {
                for z in zz.0...zz.1 {
                    self[x,y,z] = v
                }
            }
        }
    }
    
    func isNeighbour(x: Int, y: Int, z: Int, a: Int, b: Int, c: Int) -> Bool {
        
        if self.indexIsValidForRow(x: x+a, y: y+b, z: z+c) == false {
            return false
        }

        return self[x,y,z] == self[x+a,y+b,z+c]
    }
}

class Model: NSObject {

    var oids: Matrix3D<Int>
    var vm: Matrix3D<Int>
    
    let DW = 28
    let DH = 14
    
    init(X: Int, Y: Int, Z: Int, defaultValue: Int = 0) {
        let oids = Matrix3D(X: X, Y: Y, Z: Z, defaultValue: defaultValue)
        self.vm = Model.visibilityMatrix(m: oids)
        self.oids = oids
    }
    
    static func visibilityMatrix(m: Matrix3D<Int>) -> Matrix3D<Int> {
        
        let X = m.X
        let Y = m.Y
        let Z = m.Z
        
        var vm = Matrix3D(X: X, Y: Y, Z: Z, defaultValue: 0)
        
        for x in 0...X-1 {
            for y in 0...Y-1 {
                vm[x,y,Z-1] = 1
            }
        }

        for x in 0...X-1 {
            for z in 0...Z-1 {
                vm[x,0,z] = 1
            }
        }

        for y in 0...Y-1 {
            for z in 0...Z-1 {
                vm[0,y,z] = 1
            }
        }
        
        // iterate from user's standpoint

        for x in 0...X-1 {
            for y in 0...Y-1 {
                for z in (0...Z-1).reversed() {
                    
                    // if not visible
                    // no need to update visibility of "back" cube
                    // continue to the next cube
                    if vm[x,y,z] == 0 {
                        continue
                    }

                    // if vm is empty
                    // "back" cube becomes visible
                    if m[x,y,z] == 0 {
                        if vm.indexIsValidForRow(x: x+1, y: y+1, z: z-1) {
                            vm[x+1, y+1, z-1] = 1
                        }
                    }

                }
            }
        }
        
        return vm
    }
    
    func drawingRect(x: Int, y: Int, z: Int) -> NSRect {
        
        if self.oids.indexIsValidForRow(x: x, y: y, z: z) == false {
            return NSMakeRect(0, 0, 0, 0)
        }
        
        let DW = 28
        let DH = 14
        let DW2 = DW / 2
        let DH2 = DH / 2

        let Y_MAX = self.oids.Y
        //let Z_MAX = self.oids.Z
        
        let z_offset = DH * z
        
        let px = DW2 * (Y_MAX-1) + DW2*(x-y)
        let py = DH2*(x+y) + z_offset
        
        return NSMakeRect(CGFloat(px), CGFloat(py), CGFloat(DW), CGFloat(DH*2))
    }
    
    func draw(context: CGContext) {
        
        self.vm = Model.visibilityMatrix(m: self.oids)
        
        var drawCubesCount = 0
        
        for x in (0...self.oids.X-1).reversed() {
            for y in (0...self.oids.Y-1).reversed() {
                for z in 0...self.oids.Z-1 {
                    
                    if self.vm[x,y,z] == 0 || self.oids[x,y,z] == 0 {
                        continue
                    }
                                        
                    let nx  = self.oids.isNeighbour(x: x, y: y, z: z, a:  1, b: 0, c: 0)
                    let nx_ = self.oids.isNeighbour(x: x, y: y, z: z, a: -1, b: 0, c: 0)
                    let ny  = self.oids.isNeighbour(x: x, y: y, z: z, a:  0, b: 1, c: 0)
                    let ny_ = self.oids.isNeighbour(x: x, y: y, z: z, a:  0, b:-1, c: 0)
                    let nz  = self.oids.isNeighbour(x: x, y: y, z: z, a:  0, b: 0, c: 1)
                    let nz_ = self.oids.isNeighbour(x: x, y: y, z: z, a:  0, b: 0, c:-1)

                    let nxy_  = self.oids.indexIsValidForRow(x: x+1, y: y-1, z: z) && self.oids[x+1, y-1, z] == 1

                    let nxz   = self.oids.indexIsValidForRow(x: x+1, y: y, z: z+1) && self.oids[x+1, y, z+1] == 1
                    let nx_z_ = self.oids.indexIsValidForRow(x: x-1, y: y, z: z-1) && self.oids[x-1, y, z-1] == 1

                    let nyz = self.oids.indexIsValidForRow(x: x, y: y+1, z: z+1) && self.oids[x, y+1, z+1] == 1
                    let ny_z_ = self.oids.indexIsValidForRow(x: x, y: y-1, z: z-1) && self.oids[x, y-1, z-1] == 1
                    
                    drawCubesCount += 1
                    drawCube(x:x, y:y, z:z, nx:nx, nx_:nx_, ny:ny, ny_:ny_, nz:nz, nz_:nz_, nxy_:nxy_, nxz:nxz, nx_z_:nx_z_, nyz:nyz, ny_z_:ny_z_)
                }
            }
        }
        
        //print("drawCubesCount: \(drawCubesCount)")
        
    }
    
}

//
//  CustomCGVector.swift
//  TopDownRacer
//
//  Created by María Victoria Cavo on 26/4/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import SpriteKit

func + (vectorA: CGVector, vectorB: CGVector) -> CGVector {
    return CGVector(dx: vectorA.dx + vectorB.dx, dy: vectorA.dy + vectorB.dy)
}

func - (vectorA: CGVector, vectorB: CGVector) -> CGVector {
    return CGVector(dx: vectorA.dx - vectorB.dx, dy: vectorA.dy - vectorB.dy)
}

func pointProduct (vectorA: CGVector, vectorB: CGVector) -> CGFloat {
    return CGFloat(vectorA.dx * vectorB.dx + vectorA.dy * vectorB.dy)
}

func crossProduct (vectorA: CGVector, vectorB: CGVector) -> CGFloat {
    return CGFloat(vectorA.dx * vectorB.dy - vectorA.dy * vectorB.dx)
}

func / (vector: CGVector, scalar: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx / scalar, dy: vector.dy / scalar)
}

func distance (vectorA: CGVector, vectorB: CGVector) -> CGFloat {
    return (vectorA - vectorB).length()
}

func rotate (vector: CGVector, angle: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx * cos(angle) - vector.dy * sin(angle), dy: vector.dx * sin(angle) + vector.dy * cos(angle))
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGVector {
    func length() -> CGFloat {
        return sqrt(dx*dx + dy*dy)
    }
    
    func normalized() -> CGVector {
        return self / length()
    }
}

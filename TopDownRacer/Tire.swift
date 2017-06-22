//
//  Tire.swift
//  TopDownRacer
//
//  Created by María Victoria Cavo on 30/3/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import Foundation
import SpriteKit

class Tire : SKSpriteNode {
    
    private var fowardDirection : CGVector = CGVector(dx: 0, dy: 1)
    private var lateralDirection : CGVector = CGVector(dx: 1, dy: 0)
    
    public var traction : CGFloat = 1
    
    var maxForwardSpeed : CGFloat = 100  // 100;
    var maxBackwardSpeed : CGFloat = -20 // -20;
    var maxDriveForce : CGFloat = 150    // 150;
    
    let MAX_ANGLE_DEGREES : Double = 135.0
    let MIN_ANGLE_DEGREES : Double = 45.0
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 20))
        self.physicsBody?.categoryBitMask = PhysicsCategory.Tire
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Grass
        self.physicsBody?.collisionBitMask = PhysicsCategory.Border | PhysicsCategory.Water
        self.physicsBody?.mass = 20
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func getLateralVelocity() -> CGVector {
        let velocity : CGVector = self.physicsBody!.velocity
        let normal : CGVector = getLateralDirection().normalized()
        return CGVector(dx: normal.dx * pointProduct(vectorA: velocity, vectorB: normal), dy: normal.dy * pointProduct(vectorA: velocity, vectorB: normal))
    }
    
    public func getForwardVelocity() -> CGVector {
        let velocity : CGVector = self.physicsBody!.velocity
        let normal : CGVector = getFowardDirection().normalized()
        return CGVector(dx: normal.dx * pointProduct(vectorA: velocity, vectorB: normal), dy: normal.dy * pointProduct(vectorA: velocity, vectorB: normal))
    }
    
    public func getFowardDirection() -> CGVector {
        return rotate(vector: fowardDirection, angle: self.zRotation)
    }
    
    public func getLateralDirection() -> CGVector {
        return rotate(vector: lateralDirection, angle: self.zRotation)
    }
    
    public func updateFriction() {
        let const : CGFloat = self.physicsBody!.mass * (-1) * traction
        let lateralVelocity : CGVector = getLateralVelocity()
        let impulse : CGVector =  CGVector(dx: lateralVelocity.dx * const, dy: lateralVelocity.dy * const)
        self.physicsBody!.applyImpulse(impulse, at: self.position)
        self.physicsBody?.applyAngularImpulse(-0.1 * (self.physicsBody?.angularDamping)! * (self.physicsBody?.angularVelocity)!)
        let currentForwardNormal : CGVector = getForwardVelocity()
        let currentForwardSpeed : CGFloat = getLateralDirection().length()
        let dragForceMagnitude : CGFloat = -2 * currentForwardSpeed * traction
        self.physicsBody!.applyForce(CGVector(dx: currentForwardNormal.dx * dragForceMagnitude, dy: currentForwardNormal.dy * dragForceMagnitude), at: self.position)
        
    }
    
    public func initDirections(lateralDirection: CGVector, fowardDirection: CGVector) {
        self.fowardDirection = fowardDirection
        self.lateralDirection = lateralDirection
    }
    
    public func updateDrive(_ controlState : UInt32) {
        var desiredSpeed : CGFloat = 0
        switch (controlState & (TireDirections.Up|TireDirections.Down)) {
        case TireDirections.Up:
            desiredSpeed = maxForwardSpeed
        case TireDirections.Down:
            desiredSpeed = maxBackwardSpeed
        default:
            return
        }
        let currentForwardNormal : CGVector = getFowardDirection()
        let currentSpeed : CGFloat = pointProduct(vectorA: getForwardVelocity(), vectorB: currentForwardNormal)
        var force : CGFloat = 0
        
        if (desiredSpeed > currentSpeed) {
            force = maxDriveForce * 10
        } else if (desiredSpeed < currentSpeed) {
            force = -maxDriveForce * 10
        } else {
            return
        }
        self.physicsBody!.applyForce(CGVector( dx: currentForwardNormal.dx * force, dy: currentForwardNormal.dy * force), at: self.position)
    }
    
    public func updateTurn(_ controlState : UInt32, dt : CGFloat) {
        
        /*
         var desiredTorque : CGFloat = 0
        switch (controlState & (TireDirections.Left|TireDirections.Right)) {
        case TireDirections.Left:
            desiredTorque = 1 * traction
        case TireDirections.Right:
            desiredTorque = -1 * traction
        default:
            return
        }*/
        switch (controlState & (TireDirections.Left|TireDirections.Right)) {
        case TireDirections.Left:
            let rotation : CGFloat = self.zRotation + 20 * dt * CGFloat.pi / 180.0
            if ( rotation < CGFloat.pi / 4.0 ) {
                self.zRotation = rotation
            }
        case TireDirections.Right:
            let rotation : CGFloat = self.zRotation - 20 * dt * CGFloat.pi / 180.0
            if ( rotation > -CGFloat.pi / 4.0 ) {
                self.zRotation = rotation
            }
        default:
            return
        }
        
//        self.physicsBody!.applyTorque(desiredTorque)
    }
    
    
}

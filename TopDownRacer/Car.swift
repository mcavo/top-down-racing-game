//
//  Car.swift
//  TopDownRacingGame
//
//  Created by María Victoria Cavo on 8/5/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import Foundation
import SpriteKit

class Car : SKSpriteNode {

    var tireRU : Tire? = nil
    var tireLU : Tire? = nil
    var tireRD : Tire? = nil
    var tireLD : Tire? = nil

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.categoryBitMask = PhysicsCategory.Car
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Start
        self.physicsBody?.collisionBitMask = PhysicsCategory.Border | PhysicsCategory.Water
        self.physicsBody?.isDynamic = true
        self.physicsBody?.mass = 5
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateDrive(_ controlState : UInt32) {
        tireRU?.updateDrive(controlState)
        tireLU?.updateDrive(controlState)
    }
    
    func updateTurn(_ controlState : UInt32, dt : CGFloat) {
        tireRU?.updateTurn(controlState, dt: dt)
        tireLU?.updateTurn(controlState, dt: dt)
    }
    
    func updateFriction() {
        tireRU?.updateFriction()
        tireLU?.updateFriction()
        tireRD?.updateFriction()
        tireLD?.updateFriction()
    }

}

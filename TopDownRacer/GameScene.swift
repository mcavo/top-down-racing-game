//
//  GameScene.swift
//  TopDownRacer
//
//  Created by María Victoria Cavo on 30/3/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var controlState : UInt32 = 0

    public struct TireDirections {
        static let Left     : UInt32 = 0x1
        static let Right    : UInt32 = 0x2
        static let Up       : UInt32 = 0x4
        static let Down     : UInt32 = 0x8
    }
    
    private var directionButtonR : DirectionButton? = nil
    private var directionButtonL : DirectionButton? = nil
    private var directionButtonU : DirectionButton? = nil
    private var directionButtonD : DirectionButton? = nil
    
    let rotationAngle = M_PI / 90.0
    
    private var player : Tire? = nil

    var tire : Tire? = nil
    
    override func didMove(to view: SKView) {
        
        view.showsPhysics = true
        physicsWorld.contactDelegate = self
        
        backgroundColor = SKColor.darkGray
        physicsWorld.gravity = CGVector(dx:0, dy:0)

        addTire()
        addUI()
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        tire?.updateFriction()
        tire?.updateTurn(controlState: controlState)
        tire?.updateDrive(controlState: controlState)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            var location = touch.location(in: self)
            location = convert(location, to: self.camera!)
            if (directionButtonU?.contains(location))! {
                controlState |= TireDirections.Up
            }
            if (directionButtonD?.contains(location))! {
                controlState |= TireDirections.Down
            }
            if (directionButtonR?.contains(location))! {
                controlState |= TireDirections.Right
            }
            
            if (directionButtonL?.contains(location))! {
                controlState |= TireDirections.Left
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            var location = touch.location(in: self)
            location = convert(location, to: self.camera!)
            
            if (directionButtonU?.contains(location))! {
                controlState &= ~TireDirections.Up
            }
            if (directionButtonD?.contains(location))! {
                controlState &= ~TireDirections.Down
            }
            if (directionButtonR?.contains(location))! {
                controlState &= ~TireDirections.Right
            }
            
            if (directionButtonL?.contains(location))! {
                controlState &= ~TireDirections.Left
            }
        }
    }
    
    func addUI() {
        
        let camera = SKCameraNode()
        self.camera = camera
        addChild(camera)
        
        let constraint = SKConstraint.distance(SKRange(constantValue: 0), to: player!)
        camera.constraints = [ constraint ]
        
        directionButtonU = DirectionButton(texture: SKTexture(imageNamed: "right-circle-pink"), color: SKColor.clear, size: CGSize(width: 40, height: 40))
        directionButtonU!.zRotation = zRotation + CGFloat(M_PI / 2)
        directionButtonU!.position = convert(CGPoint(x: 0, y: -size.height/2 + directionButtonU!.size.height * 3), to: camera)
        
        camera.addChild(directionButtonU!)
        
        directionButtonD = DirectionButton(texture: SKTexture(imageNamed: "right-circle-pink"), color: SKColor.clear, size: CGSize(width: 40, height: 40))
        directionButtonD!.zRotation = zRotation + CGFloat(M_PI * 3 / 2)
        directionButtonD!.position = convert(CGPoint(x: 0, y: -size.height/2 + directionButtonD!.size.height), to: camera)
        
        camera.addChild(directionButtonD!)
        
        directionButtonR = DirectionButton(texture: SKTexture(imageNamed: "right-circle-pink"), color: SKColor.clear, size: CGSize(width: 40, height: 40))
        directionButtonR!.position = convert(CGPoint(x: size.width/2 - directionButtonR!.size.width , y: -size.height/2 + directionButtonD!.size.height * 2), to: camera)
        
        camera.addChild(directionButtonR!)
        
        directionButtonL = DirectionButton(texture: SKTexture(imageNamed: "right-circle-pink"), color: SKColor.clear, size: CGSize(width: 40, height: 40))
        directionButtonL!.zRotation = zRotation + CGFloat(M_PI)
        directionButtonL!.position.x = directionButtonL!.size.width
        directionButtonL!.position.y = directionButtonL!.size.height
        
        directionButtonL!.position = convert(CGPoint(x: -size.width/2 + directionButtonL!.size.width , y: -size.height/2 + directionButtonD!.size.height * 2), to: camera)
        
        camera.addChild(directionButtonL!)

    }
    
    func addTire() {
        tire = Tire(texture: nil,color: SKColor.black, size: CGSize(width: 6, height: 15))
        tire!.position.x = size.width / 2
        tire!.position.y = size.height / 2
        tire!.initDirections(lateralDirection: CGVector(dx:1,dy:0), fowardDirection: CGVector(dx:0, dy:1))
        tire!.name = "tire"
        player = tire
        addChild(tire!)
    }

}




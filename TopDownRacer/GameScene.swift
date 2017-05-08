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
    
    public struct PhysicsCategory {
        static let Tire     : UInt32 = 0x1
        static let Grass    : UInt32 = 0x2
        static let Borders  : UInt32 = 0x4
    }
    
    private var directionButtonR : DirectionButton? = nil
    private var directionButtonL : DirectionButton? = nil
    private var directionButtonU : DirectionButton? = nil
    private var directionButtonD : DirectionButton? = nil
    
    let rotationAngle = M_PI / 90.0
    
    let normalTraction : CGFloat = 1
    
    private var player : Tire? = nil

    var tire : Tire? = nil
    
    override func didMove(to view: SKView) {
        
        view.showsPhysics = true
        physicsWorld.contactDelegate = self
        
        backgroundColor = SKColor.darkGray
        physicsWorld.gravity = CGVector(dx:0, dy:0)

        addTire()
        addUI()
        addRaceTrack()
        
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if ((firstBody.categoryBitMask & PhysicsCategory.Tire != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Grass != 0)) {
            if let tire = firstBody.node as? Tire, let
                grass = secondBody.node as? Grass {
                tire.traction = grass.traction
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if ((firstBody.categoryBitMask & PhysicsCategory.Tire != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Grass != 0)) {
            if let tire = firstBody.node as? Tire {
                tire.traction = normalTraction
            }
        }
    }
    
    func addUI() {
        
        let camera = SKCameraNode()
        self.camera = camera
        addChild(camera)
        
        let constraint = SKConstraint.distance(SKRange(constantValue: 0), to: player!)
        camera.constraints = [ constraint ]
        
        directionButtonU = DirectionButton(texture: SKTexture(imageNamed: "right-circle-black"), color: SKColor.clear, size: CGSize(width: 40, height: 40))
        directionButtonU!.zRotation = zRotation + CGFloat(M_PI / 2)
        directionButtonU!.position = convert(CGPoint(x: 0, y: -size.height/2 + directionButtonU!.size.height * 3), to: camera)
        camera.addChild(directionButtonU!)
        
        directionButtonD = DirectionButton(texture: SKTexture(imageNamed: "right-circle-black"), color: SKColor.clear, size: CGSize(width: 40, height: 40))
        directionButtonD!.zRotation = zRotation + CGFloat(M_PI * 3 / 2)
        directionButtonD!.position = convert(CGPoint(x: 0, y: -size.height/2 + directionButtonD!.size.height), to: camera)
        
        camera.addChild(directionButtonD!)
        
        directionButtonR = DirectionButton(texture: SKTexture(imageNamed: "right-circle-black"), color: SKColor.clear, size: CGSize(width: 40, height: 40))
        directionButtonR!.position = convert(CGPoint(x: size.width/2 - directionButtonR!.size.width , y: -size.height/2 + directionButtonD!.size.height * 2), to: camera)
        
        camera.addChild(directionButtonR!)
        
        directionButtonL = DirectionButton(texture: SKTexture(imageNamed: "right-circle-black"), color: SKColor.clear, size: CGSize(width: 40, height: 40))
        directionButtonL!.zRotation = zRotation + CGFloat(M_PI)
        directionButtonL!.position.x = directionButtonL!.size.width
        directionButtonL!.position.y = directionButtonL!.size.height
        
        directionButtonL!.position = convert(CGPoint(x: -size.width/2 + directionButtonL!.size.width , y: -size.height/2 + directionButtonD!.size.height * 2), to: camera)
        
        camera.addChild(directionButtonL!)

    }
    
    func addTire() {
        tire = Tire(texture: nil,color: SKColor.black, size: CGSize(width: 10, height: 20))
        tire!.position.x = size.width / 2
        tire!.position.y = size.height / 2
        tire!.initDirections(lateralDirection: CGVector(dx:1,dy:0), fowardDirection: CGVector(dx:0, dy:1))
        tire!.name = "tire"
        tire!.traction = normalTraction
        tire!.physicsBody?.categoryBitMask = PhysicsCategory.Tire
        tire!.physicsBody?.contactTestBitMask = PhysicsCategory.Grass
        tire!.physicsBody?.collisionBitMask = 0
        player = tire
        addChild(tire!)
    }
    
    func addRaceTrack() {
        let grass = SKSpriteNode(imageNamed: "grass_tile")
        grass.zPosition = -1
        addChild(grass)
        let grassObj = Grass(texture: nil, color: UIColor.clear, size: grass.size)
        grassObj.position = grass.position
        grassObj.physicsBody = SKPhysicsBody(rectangleOf: grass.size)
        grassObj.physicsBody?.categoryBitMask = PhysicsCategory.Grass
        grassObj.physicsBody?.collisionBitMask = 0
        addChild(grassObj)
    }

}




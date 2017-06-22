//
//  GameScene.swift
//  TopDownRacer
//
//  Created by María Victoria Cavo on 30/3/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import SpriteKit
import GameplayKit

struct TireDirections {
    static let Left     : UInt32 = 0x01
    static let Right    : UInt32 = 0x02
    static let Up       : UInt32 = 0x04
    static let Down     : UInt32 = 0x08
}

struct PhysicsCategory {
    static let None     : UInt32 = 0x00
    static let Grass    : UInt32 = 0x01
    static let Start    : UInt32 = 0x02
    static let Border   : UInt32 = 0x04
    static let Water    : UInt32 = 0x08
    static let Tire     : UInt32 = 0x10
    static let Car      : UInt32 = 0x20
    static let All      : UInt32 = UInt32.max
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var controlState : UInt32 = 0
    
    private var directionButtonR : DirectionButton? = nil
    private var directionButtonL : DirectionButton? = nil
    private var directionButtonU : DirectionButton? = nil
    private var directionButtonD : DirectionButton? = nil
    
    private var timerLabel : SKLabelNode? = nil
    private var racesLabel : SKLabelNode? = nil
    private var timer : TimeInterval? = nil
    private var lastTime : TimeInterval = 0
    
    let normalTraction : CGFloat = 1

    var car : Car? = nil
    
    var playing : Bool = true
    var racing : Bool = false
    var races : Int = 0
    let MAX_RACES : Int = 3
    
    override func didMove(to view: SKView) {
        
        view.showsPhysics = true
        physicsWorld.contactDelegate = self
        
        backgroundColor = SKColor.darkGray
        physicsWorld.gravity = CGVector(dx:0, dy:0)

        addCar()
        addHUB()
        addRaceTrack()
        timer = TimeInterval(0)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if (playing) {
            if (timer!.isZero) {
                timer = currentTime
            }
            if (lastTime == 0) {
                lastTime = currentTime
            }
            car?.updateFriction()
            car?.updateDrive(controlState)
            car?.updateTurn(controlState, dt: CGFloat(currentTime - lastTime))
        
            let interval = currentTime - timer!
            let ti = NSInteger(interval)
            let seconds = ti % 60
            let minutes = (ti / 60) % 60
            timerLabel?.text = String(format:"%0.2d:%0.2d", minutes, seconds)
            lastTime = currentTime
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if (playing) {
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
            } else {
                car?.physicsBody?.isDynamic = true
                playing = true
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if (playing) {
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
        if ((firstBody.categoryBitMask & PhysicsCategory.Grass != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Tire != 0)) {
            if let grass = firstBody.node as? Grass, let
                tire = secondBody.node as? Tire {
                tire.traction = grass.traction
            }
        }
        if ((firstBody.categoryBitMask & PhysicsCategory.Start != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Car != 0)) {
            if(!racing) {
                racing = true
            } else {
                races += 1
                racesLabel?.text = String(format:"VUELTAS: %0.1d/%0.1d", races, MAX_RACES)
                if (races == MAX_RACES) {
                    playing = false
                    car?.physicsBody?.isDynamic = false
                }
            }
            print(races)
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
        if ((firstBody.categoryBitMask & PhysicsCategory.Grass != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Tire != 0)) {
            if let tire = secondBody.node as? Tire {
                tire.traction = normalTraction
            }
        }
    }
    
    func addHUB() {
        
        let camera = SKCameraNode()
        self.camera = camera
        addChild(camera)
        
        let constraint = SKConstraint.distance(SKRange(constantValue: 0), to: car!)
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
        
        timerLabel = SKLabelNode(fontNamed: "Helvetica")
        timerLabel!.fontSize = 14
        timerLabel!.fontColor = SKColor.white
        timerLabel?.text = String(format:"TIEMPO: %0.2d:%0.2d", 0, 0)
        timerLabel!.position.y = size.height/2 - 2 * timerLabel!.fontSize
        
        camera.addChild(timerLabel!)
        
        racesLabel = SKLabelNode(fontNamed: "Helvetica")
        racesLabel!.fontSize = 14
        racesLabel!.fontColor = SKColor.white
        racesLabel?.text = String(format:"VUELTAS: %0.1d/%0.1d", races, MAX_RACES)
        racesLabel!.position.y = size.height/2 - 5 * racesLabel!.fontSize
        
        camera.addChild(racesLabel!)

    }
    
    func addCar() {
        car = Car(texture: SKTexture(imageNamed: "pink_car"), color: UIColor.clear, size: CGSize(width:25, height:50))
        
        let tireRU : Tire = getTire(direction: CGVector(dx:-1,dy:0))
        tireRU.position.x = car!.position.x + car!.size.width / 2 - tireRU.size.width/2
        tireRU.position.y = car!.position.y + car!.size.height / 4
        car!.tireRU = tireRU
        
        let tireLU : Tire = getTire(direction: CGVector(dx:1,dy:0))
        tireLU.position.x = car!.position.x - car!.size.width / 2 + tireRU.size.width/2
        tireLU.position.y = car!.position.y + car!.size.height / 4
        car!.tireLU = tireLU
        
        let tireRD : Tire = getTire(direction: CGVector(dx:-1,dy:0))
        tireRD.position.x = car!.position.x + car!.size.width / 2 - tireRU.size.width/2
        tireRD.position.y = car!.position.y - car!.size.height / 4
        car!.tireRD = tireRD
        
        let tireLD : Tire = getTire(direction: CGVector(dx:1,dy:0))
        tireLD.position.x = car!.position.x - car!.size.width / 2 + tireRU.size.width/2
        tireLD.position.y = car!.position.y - car!.size.height / 4
        car!.tireLD = tireLD
        
        addChild(tireRU)
        addChild(tireLU)
        addChild(tireRD)
        addChild(tireLD)
        addChild(car!)
        
        let pinRU = SKPhysicsJointPin.joint(withBodyA: car!.physicsBody!, bodyB: tireRU.physicsBody!, anchor: tireRU.position)
        pinRU.shouldEnableLimits = true
        pinRU.upperAngleLimit = CGFloat.pi / 4.0
        pinRU.lowerAngleLimit = CGFloat.pi / -4.0
        pinRU.frictionTorque = 0.9
        physicsWorld.add(pinRU)
        let pinLU = SKPhysicsJointPin.joint(withBodyA: car!.physicsBody!, bodyB: tireLU.physicsBody!, anchor: tireLU.position)
        pinLU.shouldEnableLimits = true
        pinLU.upperAngleLimit = CGFloat.pi / 4.0
        pinLU.lowerAngleLimit = CGFloat.pi / -4.0
        pinLU.frictionTorque = 0.9
        physicsWorld.add(pinLU)
        
        let fixedLD = SKPhysicsJointFixed.joint(withBodyA: car!.physicsBody!, bodyB: tireLD.physicsBody!, anchor: tireLD.position)
        physicsWorld.add(fixedLD)
        let fixedRD = SKPhysicsJointFixed.joint(withBodyA: car!.physicsBody!, bodyB: tireRD.physicsBody!, anchor: tireRD.position)
        physicsWorld.add(fixedRD)
        
    }
    
    func getTire(direction: CGVector) -> Tire {
        let tire : Tire = Tire(texture: nil,color: SKColor.black, size: CGSize(width: 10, height: 20))
        tire.initDirections(lateralDirection: direction, fowardDirection: CGVector(dx:0, dy:1))
        tire.name = "tire"
        tire.traction = normalTraction
        return tire
    }
    
    func addRaceTrack() {
        //addCurvTile(angle: 0, position: CGPoint(x:0, y:0))
        
        addStart(angle: 0, position: CGPoint(x:0, y:120))
        
        addWaterTile("water_tile", angle : 0, position : CGPoint(x:-1500, y:1500))
        addWaterTile("water_tile_1", angle : 180, position : CGPoint(x:-1200, y:1500))
        addWaterTile("water_tile_1", angle : 180, position : CGPoint(x:-900, y:1500))
        addWaterTile("water_tile_1", angle : 180, position : CGPoint(x:-600, y:1500))
        addWaterTile("water_tile_1", angle : 180, position : CGPoint(x:-300, y:1500))
        addWaterTile("water_tile_1", angle : 180, position : CGPoint(x:0, y:1500))
        addWaterTile("water_tile", angle : 0, position : CGPoint(x:300, y:1500))
        
        addWaterTile("water_tile_1", angle : 270, position : CGPoint(x:-1500, y:1200))
        addCurvTile(angle: 180, position: CGPoint(x:-1200, y:1200))
        addRectTile(angle: 90, position: CGPoint(x:-900, y:1200))
        addRectTile(angle: 90, position: CGPoint(x:-600, y:1200))
        addCurvTile(angle: 90, position: CGPoint(x:-300, y:1200))
        addGrassTile(position: CGPoint(x:0, y:1200))
        addWaterTile("water_tile_1", angle : 90, position : CGPoint(x:300, y:1200))
        
        addWaterTile("water_tile_1", angle : 270, position : CGPoint(x:-1500, y:900))
        addRectTile(angle: 0, position: CGPoint(x:-1200, y:900))
        addWaterTile("water_tile_3", angle : 0, position : CGPoint(x:-900, y:900))
        addWaterTile("water_tile_2", angle : 270, position : CGPoint(x:-600, y:900))
        addCurvTile(angle: 270, position: CGPoint(x:-300, y:900))
        addCurvTile(angle: 90, position: CGPoint(x:0, y:900))
        addWaterTile("water_tile_1", angle : 90, position : CGPoint(x:300, y:900))
        
        addWaterTile("water_tile_1", angle : 270, position : CGPoint(x:-1500, y:600))
        addCurvTile(angle: 270, position: CGPoint(x:-1200, y:600))
        addCurvTile(angle: 90, position: CGPoint(x:-900, y:600))
        addWaterTile("water_tile_1", angle : 90, position : CGPoint(x:-600, y:600))
        addWaterTile("water_tile_2", angle : 270, position : CGPoint(x:-300, y:600))
        addRectTile(angle: 0, position: CGPoint(x:0, y:600))
        addWaterTile("water_tile_1", angle : 90, position : CGPoint(x:300, y:600))
        
        addWaterTile("water_tile", angle : 0, position : CGPoint(x:-1500, y:300))
        addWaterTile("water_tile_3", angle : 180, position : CGPoint(x:-1200, y:300))
        addRectTile(angle: 0, position: CGPoint(x:-900, y:300))
        addWaterTile("water_tile_1", angle : 90, position : CGPoint(x:-600, y:300))
        addWaterTile("water_tile_1", angle : 270, position : CGPoint(x:-300, y:300))
        addRectTile(angle: 0, position: CGPoint(x:0, y:300))
        addWaterTile("water_tile_1", angle : 90, position : CGPoint(x:300, y:300))
        
        addWaterTile("water_tile_1", angle : 270, position : CGPoint(x:-1500, y:0))
        addCurvTile(angle: 180, position: CGPoint(x:-1200, y:0))
        addCurvTile(angle: 0, position: CGPoint(x:-900, y:0))
        addWaterTile("water_tile_2", angle : 90, position : CGPoint(x:-600, y:0))
        addWaterTile("water_tile_2", angle : 180, position : CGPoint(x:-300, y:0))
        addRectTile(angle: 0, position: CGPoint(x:0, y:0))
        addWaterTile("water_tile_1", angle : 90, position : CGPoint(x:300, y:0))
        
        addWaterTile("water_tile_1", angle : 270, position : CGPoint(x:-1500, y:-300))
        addCurvTile(angle: 270, position: CGPoint(x:-1200, y:-300))
        addRectTile(angle: 90, position: CGPoint(x:-900, y:-300))
        addRectTile(angle: 90, position: CGPoint(x:-600, y:-300))
        addRectTile(angle: 90, position: CGPoint(x:-300, y:-300))
        addCurvTile(angle: 0, position: CGPoint(x:0, y:-300))
        addWaterTile("water_tile_1", angle : 90, position : CGPoint(x:300, y:-300))
        
        addWaterTile("water_tile", angle : 0, position : CGPoint(x:-1500, y:-600))
        addWaterTile("water_tile_1", angle : 0, position : CGPoint(x:-1200, y:-600))
        addWaterTile("water_tile_1", angle : 0, position : CGPoint(x:-900, y:-600))
        addWaterTile("water_tile_1", angle : 0, position : CGPoint(x:-600, y:-600))
        addWaterTile("water_tile_1", angle : 0, position : CGPoint(x:-300, y:-600))
        addWaterTile("water_tile_1", angle : 0, position : CGPoint(x:0, y:-600))
        addWaterTile("water_tile", angle : 0, position : CGPoint(x:300, y:-600))
        
    }
    
    func addRectTile(angle : CGFloat, position : CGPoint) {
        let rectTile = SKSpriteNode(imageNamed: "rect_tile")
        rectTile.position = position
        rectTile.zPosition = -1
        addChild(rectTile)
        let rectTileLeft = Grass(color: UIColor.clear, size: CGSize(width: rectTile.size.width/4, height: rectTile.size.height))
        rectTileLeft.position.x = -rectTile.size.width * 3 / 8
        rectTileLeft.position.y = 0
        let rectTileBodyLeft = SKPhysicsBody(rectangleOf: rectTileLeft.size)
        rectTileLeft.physicsBody = rectTileBodyLeft
        rectTileLeft.physicsBody!.isDynamic = false
        rectTileLeft.physicsBody!.categoryBitMask = PhysicsCategory.Grass
        rectTileLeft.physicsBody!.contactTestBitMask = PhysicsCategory.Tire
        rectTile.addChild(rectTileLeft)
        
        let rectTileRight = Grass(color: UIColor.clear, size: CGSize(width: rectTile.size.width/4, height: rectTile.size.height))
        rectTileRight.position.x = rectTile.size.width * 3 / 8
        rectTileRight.position.y = 0
        let rectTileBodyRight = SKPhysicsBody(rectangleOf: rectTileRight.size)
        rectTileRight.physicsBody = rectTileBodyRight
        rectTileRight.physicsBody!.isDynamic = false
        rectTileRight.physicsBody!.categoryBitMask = PhysicsCategory.Grass
        rectTileRight.physicsBody!.contactTestBitMask = PhysicsCategory.Tire
        rectTile.addChild(rectTileRight)
        rectTile.zRotation = angle * CGFloat.pi / 180.0
    }
    
    func addCurvTile(angle : CGFloat, position : CGPoint) {
        let curvTile = SKSpriteNode(imageNamed: "turn_tile")
        curvTile.position = position
        curvTile.zPosition = -1
        addChild(curvTile)
        
        let curvTileLeft = Grass(color: UIColor.clear, size: CGSize(width: curvTile.size.width/4, height: curvTile.size.height/4))
        curvTileLeft.position.x = -curvTileLeft.size.width * 3 / 2
        curvTileLeft.position.y = curvTileLeft.size.height * 3 / 2
        curvTileLeft.zPosition = 2
        let curvTileLeftPath = getTopLeftPath(tile: curvTileLeft)
        let curvTileBodyLeft = SKPhysicsBody(polygonFrom: curvTileLeftPath)
        curvTile.physicsBody = curvTileBodyLeft
        curvTile.physicsBody!.isDynamic = false
        curvTile.physicsBody!.categoryBitMask = PhysicsCategory.Grass
        curvTile.physicsBody!.contactTestBitMask = PhysicsCategory.Tire
        curvTile.addChild(curvTileLeft)
        
        curvTile.zRotation = angle * CGFloat.pi / 180.0
        
    }
    
    func  addStart(angle : CGFloat, position : CGPoint) {
        let tile = SKSpriteNode(imageNamed: "start_line")
        tile.position = position
        tile.zPosition = -0.5
        addChild(tile)
        
        let startLine = SKSpriteNode(color: UIColor.clear, size: tile.size)
        startLine.position = CGPoint.zero
        startLine.physicsBody = SKPhysicsBody(rectangleOf: tile.size)
        startLine.physicsBody!.isDynamic = false
        startLine.physicsBody!.categoryBitMask = PhysicsCategory.Start
        startLine.physicsBody!.contactTestBitMask = PhysicsCategory.Car
        tile.addChild(startLine)
    }
    
    func addGrassTile(position : CGPoint) {
        let tile = SKSpriteNode(imageNamed: "grass_tile")
        tile.position = position
        tile.zPosition = -1
        addChild(tile)
        
        let grassTile = Grass(color: UIColor.clear, size: tile.size)
        grassTile.position = CGPoint.zero
        grassTile.physicsBody = SKPhysicsBody(rectangleOf: tile.size)
        grassTile.physicsBody!.isDynamic = false
        grassTile.physicsBody!.categoryBitMask = PhysicsCategory.Grass
        grassTile.physicsBody!.contactTestBitMask = PhysicsCategory.Tire
        tile.addChild(grassTile)
    }
    
    func addWaterTile(_ tileName : String, angle : CGFloat, position : CGPoint) {
        let tile = SKSpriteNode(imageNamed: tileName)
        tile.position = position
        tile.zPosition = -1
        addChild(tile)
        
        let waterTile = SKSpriteNode(color: UIColor.clear, size: tile.size)
        waterTile.position = CGPoint.zero
        waterTile.physicsBody = SKPhysicsBody(rectangleOf: tile.size)
        waterTile.physicsBody!.isDynamic = false
        waterTile.physicsBody!.categoryBitMask = PhysicsCategory.Water
        tile.addChild(waterTile)
        
        tile.zRotation = angle * CGFloat.pi / 180.0
        
    }
    
    func getTopLeftPath(tile : Grass) -> CGPath {
        let path = CGMutablePath()
        let start : CGPoint = CGPoint(x: tile.position.x - tile.size.width/2 , y: tile.position.y + tile.size.height/2)
        path.move(to: start)
        path.addLine(to: CGPoint(x: start.x + tile.size.width, y: start.y))
        path.addLine(to: CGPoint(x: start.x + tile.size.width - 3, y: start.y - tile.size.height + 25))
        path.addLine(to: CGPoint(x: start.x + tile.size.width - 5, y: start.y - tile.size.height + 20))
        path.addLine(to: CGPoint(x: start.x + tile.size.width - 7, y: start.y - tile.size.height + 15))
        path.addLine(to: CGPoint(x: start.x + tile.size.width - 10, y: start.y - tile.size.height + 10))
        path.addLine(to: CGPoint(x: start.x + tile.size.width - 15, y: start.y - tile.size.height + 7))
        path.addLine(to: CGPoint(x: start.x + tile.size.width - 20, y: start.y - tile.size.height + 5))
        path.addLine(to: CGPoint(x: start.x + tile.size.width - 25, y: start.y - tile.size.height + 3))
        path.addLine(to: CGPoint(x: start.x, y: start.y - tile.size.height))
        path.addLine(to: start)
        path.closeSubpath()
        return path
    }
}




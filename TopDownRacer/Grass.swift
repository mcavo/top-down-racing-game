//
//  SpecialGround.swift
//  TopDownRacingGame
//
//  Created by María Victoria Cavo on 7/5/17.
//  Copyright © 2017 María Victoria Cavo. All rights reserved.
//

import Foundation
import SpriteKit

class Grass : SKSpriteNode {
    
    let traction : CGFloat = 1.5
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

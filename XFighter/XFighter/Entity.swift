//
//  Entity.swift
//  XFighter
//
//  Created by John Russel Usi on 10/30/15.
//  Copyright © 2015 CYS. All rights reserved.
//

import SpriteKit

class Entity: SKSpriteNode
{
    var direction = CGPointZero
    var health = 100.0
    var maxHealth = 100.0
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    init(position: CGPoint, texture: SKTexture)
    {
        super.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
        self.position = position
    }
    
    class func generateTexture() -> SKTexture?
    {
        return nil
    }
}

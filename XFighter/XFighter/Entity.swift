//
//  Entity.swift
//  XFighter
//
//  Created by John Russel Usi on 10/30/15.
//  Copyright © 2015 CYS. All rights reserved.
//

import SpriteKit

struct PhysicsCategory
{
    static var PlayerShip: UInt32 = 1
    static var EnemyShip: UInt32 = 2
    static var Bullet: UInt32 = 4
}

class Entity: SKSpriteNode
{
    var direction = CGPointZero
    
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
    
    func update(delta: NSTimeInterval) {
        // Overridden by subclasses
    }
    
    func collidedWith(body: SKPhysicsBody, contact: SKPhysicsContact) {
        // Overridden by subsclasses to implement actions to be carried out when an entity
        // collides with another entity e.g. PlayerShip or Bullet
    }
}

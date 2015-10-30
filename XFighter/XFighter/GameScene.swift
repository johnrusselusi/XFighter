//
//  GameScene.swift
//  XFighter
//
//  Created by John Russel Usi on 10/29/15.
//  Copyright (c) 2015 CYS. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene
{
    let shipNode = SKSpriteNode(imageNamed: "ship_01")
    let shipAnimation: SKAction
    var shipDestination: CGPoint = CGPointZero
    
    let playableRect: CGRect
    let hudHeight: CGFloat = 90
    
    let motionManager = CMMotionManager()
    
    override init(size: CGSize)
    {
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let maxAspectRatioWidth = size.height / maxAspectRatio
        let playableMargin = (size.width - maxAspectRatioWidth) / 2.0
        playableRect = CGRect(x: playableMargin, y: 0, width: size.width - playableMargin / 2, height: size.height)
        
        var textures: [SKTexture] = []
        
        for i in 1...3
        {
            textures.append(SKTexture(imageNamed: "ship_0\(i)"))
        }
        
        shipAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures(textures, timePerFrame: 0.1))
        motionManager.accelerometerUpdateInterval = 0.1
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(currentTime: NSTimeInterval)
    {
        boundsCheckShip()
        shipNode.runAction(SKAction.moveTo(shipDestination, duration: 1))
    }
    
    override func didMoveToView(view: SKView)
    {
        shipNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(shipNode)
        startShipAnimation()
        
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue())
        {
            data, error in
            
            let currentPosition = self.shipNode.position

            self.shipDestination.x = currentPosition.x + CGFloat(data!.acceleration.x * 10000)
            self.shipDestination.y = currentPosition.y + CGFloat(data!.acceleration.y * 1000 )
        }
        
        debugDrawPlayableArea()
    }
    
    func debugDrawPlayableArea()
    {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    func startShipAnimation()
    {
        shipNode.runAction(SKAction.repeatActionForever(shipAnimation))
    }
    
    func boundsCheckShip()
    {
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        
        if shipDestination.x <= bottomLeft.x
        {
            shipDestination.x = bottomLeft.x
        }
        
        if shipDestination.x >= topRight.x
        {
            shipDestination.x = topRight.x
        }
        
        if shipDestination.y <= bottomLeft.y
        {
            shipDestination.y = bottomLeft.y
        }
        
        if shipDestination.y >= topRight.y
        {
            shipDestination.y = topRight.y
        }
    }
}

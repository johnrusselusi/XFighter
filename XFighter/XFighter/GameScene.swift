//
//  GameScene.swift
//  XFighter
//
//  Created by John Russel Usi on 10/29/15.
//  Copyright (c) 2015 CYS. All rights reserved.
//

import SpriteKit

class GameScene: SKScene
{
    var lasUpdateTime : NSTimeInterval = 0
    var dt : NSTimeInterval = 0
    let backgroundMovePointsPerSec: CGFloat = 200.0
    
    var playerShip: PlayerShip!
    let shipAnimation: SKAction
    var shipDestination: CGPoint = CGPointZero
    
    let backgroundLayer = SKNode()
    
    let playableRect: CGRect
    let hudHeight: CGFloat = 90
    
    var deltaPoint = CGPointZero
    
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
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(currentTime: NSTimeInterval)
    {
        var newPoint: CGPoint = playerShip.position + deltaPoint
        
        newPoint.x.clamp(CGRectGetMinX(playableRect), CGRectGetMaxX(playableRect))
        newPoint.y.clamp(CGRectGetMinY(playableRect), CGRectGetMaxY(playableRect))
        
        playerShip.position = newPoint
        deltaPoint = CGPointZero
        
        if lasUpdateTime > 0
        {
            dt = currentTime - lasUpdateTime
        }
        else
        {
            dt = 0
        }
        
        lasUpdateTime = currentTime
        moveBackground()
    }
    
    override func didMoveToView(view: SKView)
    {
        backgroundLayer.zPosition = -1
        addChild(backgroundLayer)
        
        for i in 0...1
        {
            let background = backgroundNode()
            background.anchorPoint = CGPointZero
            background.position = CGPoint(x: 0, y: CGFloat(i) * background.size.height)
            background.name = "background"
            backgroundLayer.addChild(background)
        }

        playerShip = PlayerShip(entityPosition: CGPoint(x: size.width / 2, y: 100))
        addChild(playerShip)
        startShipAnimation()
    
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
    
    func moveBackground()
    {
        let backgroundVelocity = CGPoint(x: 0, y: -backgroundMovePointsPerSec)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        backgroundLayer.position += amountToMove
        
        backgroundLayer.enumerateChildNodesWithName("background")
            {
                node, _ in
                
                let background = node as! SKSpriteNode
                let backgroundScreenPos = self.backgroundLayer.convertPoint(background.position, toNode: self)
                
                if backgroundScreenPos.y <= -background.size.height
                {
                    background.position = CGPoint(x: background.position.x,
                                                  y: background.position.y + background.size.height * 2)
                }
        }
    }
    
    func backgroundNode() -> SKSpriteNode
    {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPointZero
        backgroundNode.name = "background"
        
        let background = SKSpriteNode(imageNamed: "background")
        background.anchorPoint = CGPointZero
        background.position = CGPointZero
        background.size = CGSize(width: size.width, height: size.height * 2)
        backgroundNode.addChild(background)
        
        backgroundNode.size = background.size
        
        return backgroundNode
    }
    
    func startShipAnimation()
    {
        playerShip.runAction(SKAction.repeatActionForever(shipAnimation))
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
    
    //MARK: UITouch Methods
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        deltaPoint = CGPointZero
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if let touch = touches.first as UITouch?
        {
            let currentPoint = touch.locationInNode(self)
            let previousPoint = touch.previousLocationInNode(self)
            
            deltaPoint = currentPoint - previousPoint
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        deltaPoint = CGPointZero
    }
}

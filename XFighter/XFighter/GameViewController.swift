//
//  GameViewController.swift
//  XFighter
//
//  Created by John Russel Usi on 10/29/15.
//  Copyright (c) 2015 CYS. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()

        let scene = GameScene(size:CGSize(width: 640, height: 1136))
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
            
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
            
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
            
        skView.presentScene(scene)
    }
}

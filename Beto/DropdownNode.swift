//
//  DropdownNode.swift
//  Beto
//
//  Created by Jem on 6/15/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import SpriteKit

class DropdownNode {
    fileprivate let layer: SKNode
    fileprivate var container: SKNode
    fileprivate let background: SKSpriteNode
    
    init(container: SKSpriteNode) {
        layer = SKNode()
        layer.setScale(Constant.ScaleFactor)
        
        self.container = container
        
        background = SKSpriteNode(color: UIColor.black, size: CGSize(width: ScreenSize.Width, height: ScreenSize.Height))
        background.alpha = 0.0
    }
    
    func createLayer() -> SKNode {
        // Run SKActions
        let fadeIn = SKAction.fadeAlpha(to: 0.6, duration: 0.3)
        background.run(fadeIn)
        
        let dropDown = SKAction.moveTo(y: 0, duration: 0.3)
        let compress = SKAction.scaleX(by: 1.02, y: 0.9, duration: 0.2)
        let actions = SKAction.sequence([dropDown, compress, compress.reversed()])
        container.run(actions)
     
        // Designate positions
        container.position = CGPoint(x: 0, y: ScreenSize.Height)
        
        layer.addChild(background)
        layer.addChild(container)
        
        return layer
    }
        
    func close() {
        let wait = SKAction.wait(forDuration: 0.5)
        
        let exitScreen = SKAction.moveTo(y: ScreenSize.Height, duration: 0.4)
        let vaultActions = SKAction.sequence([exitScreen, SKAction.removeFromParent()])
        container.run(vaultActions)
        
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.3)
        let backgroundActions = SKAction.sequence([fadeOut, SKAction.removeFromParent()])
        background.run(backgroundActions)
        
        let actions = SKAction.sequence([wait, SKAction.removeFromParent()])
        layer.run(actions)
    }
}


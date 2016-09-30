//
//  PowerUpVault.swift
//  Beto
//
//  Created by Jem on 8/11/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import SpriteKit

enum PowerUpKey: String {
    case lifeline
    case rewardBoost
    case reroll
    case extraDice
    case doublePayout
    case triplePayout
    
    static let allValues = [lifeline, rewardBoost, reroll, extraDice, doublePayout, triplePayout]
}

class PowerUpVault: DropdownNode {
    var activatePowerUpHandler: ((PowerUp) -> ())?
    
    init(activePowerUp: String) {
        let vault = SKSpriteNode(imageNamed: "powerUpVault")
        vault.position = CGPoint(x: 0, y: ScreenSize.Height)
        vault.size = CGSize(width: 304, height: 214)
        
        super.init(container: vault)
        
        let closeButton = ButtonNode(defaultButtonImage: "closeButton")
        closeButton.position = CGPoint(x: 140, y: 94)
        closeButton.size = CGSize(width: 44, height: 45)
        closeButton.action = close
        
        // Set up info overlay
        let infoOverlay = ButtonNode(defaultButtonImage: "overlay")
        infoOverlay.action = { infoOverlay.removeFromParent() }
        
        let infoSprite = SKSpriteNode(imageNamed: "powerUpsInfo")
        
        infoOverlay.addChild(infoSprite)
    
        let infoButton = ButtonNode(defaultButtonImage: "infoButton")
        infoButton.position = CGPoint(x: 120, y: -75)
        infoButton.action = {
            infoOverlay.alpha = 0.0
            
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            infoOverlay.run(fadeIn)
            
            vault.addChild(infoOverlay)
        }
        
        var buttonImage = "offButton"
        
        if GameData.autoLoadEnabled {
            buttonImage = "onButton"
        }
        
        let autoLoadButton = ButtonNode(defaultButtonImage: buttonImage, activeButtonImage: buttonImage)
        autoLoadButton.position = CGPoint(x: -110, y: -75)
        autoLoadButton.action = {
            GameData.toggleAutoLoad()
                    
            if GameData.autoLoadEnabled {
                autoLoadButton.changeTexture("onButton")
            } else {
                autoLoadButton.changeTexture("offButton")
            }
        }
        
        // Add nodes
        vault.addChild(closeButton)
        vault.addChild(autoLoadButton)
        vault.addChild(infoButton)
        
        var position = 0

        for key in PowerUpKey.allValues {
            var count = GameData.powerUps[key.rawValue]!
            
            if key.rawValue == activePowerUp {
                count -= 1
            }
            
            let button = PowerUp(name: key.rawValue, count: count)
            button.position = pointForPosition(position)
            button.activatePowerUpHandler = handleActivatePowerUp
            
            vault.addChild(button)
            
            position += 1
        }
    }
    
    func handleActivatePowerUp(_ powerUp: PowerUp) {
        close()
        activatePowerUpHandler!(powerUp)
    }
    
    func pointForPosition(_ position: Int) -> CGPoint {
        var column = 0
        var row = 0
        
        // Position squares based on a 2x3 grid
        if position <= 2 {
            column = position
        } else  {
            row = 1
            column = position - 3
        }
        
        let xPosition: CGFloat = 80
        let yPosition: CGFloat = 50
    
        let offsetX = -xPosition + (xPosition * CGFloat(column))
        let offsetY = 30 - (yPosition * CGFloat(row))
        
        return CGPoint(x: offsetX, y: offsetY)
    }
}

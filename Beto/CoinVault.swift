//
//  CoinVault.swift
//  Beto
//
//  Created by Jem on 3/5/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import SpriteKit

class CoinVault: DropdownNode {
    var changeDenominationHandler: (() -> ())?
    
    init() {
        var coins = [Coin]()
        
        let vault = SKSpriteNode(imageNamed: "coinVault")
        vault.position = CGPoint(x: 0, y: ScreenSize.Height)
        
        let closeButton = ButtonNode(defaultButtonImage: "closeButton")
        closeButton.position = CGPoint(x: 140, y: 95)
        
        let infoButton = ButtonNode(defaultButtonImage: "infoButton")
        infoButton.position = CGPoint(x: 120, y: -75)
        
        for (index, betValue) in Constant.Denominations.enumerated() {
            let coin = Coin(value: betValue, unlocked: index <= GameData.coinsUnlocked) 
            coin.size = CGSize(width: 38, height: 39)
            
            coins.append(coin)
        }
        
        super.init(container: vault)
        
        // Initialize info layer
        let infoSprite = SKSpriteNode(imageNamed: "coinVaultInfo")

        let infoOverlay = ButtonNode(defaultButtonImage: "overlay")
        infoOverlay.action = { infoOverlay.removeFromParent() }
        infoOverlay.addChild(infoSprite)
        
        // Add actions
        closeButton.action = close
        infoButton.action = {
            infoOverlay.alpha = 0.0
            
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            infoOverlay.run(fadeIn)
            
            vault.addChild(infoOverlay)
        }
        
        // Add nodes
        vault.addChild(closeButton)
        vault.addChild(infoButton)
        
        for coin in coins {
            let coinHolder = SKSpriteNode(imageNamed: "coinHolder")
            coinHolder.size = CGSize(width: 42, height: 42)
            coinHolder.position = pointForPosition(coins.index(of: coin)!)
            
            coin.coinSelectedHandler = handleCoinSelected
            coin.position = CGPoint(x: 1, y: -1)
            
            coinHolder.addChild(coin)
            vault.addChild(coinHolder)
        }
    }
        
    func handleCoinSelected(_ coin: Coin) {
        GameData.setDenomination(coin.value)
        GameData.save()
        
        changeDenominationHandler!()
        close()
    }
    
    func pointForPosition(_ position: Int) -> CGPoint {
        var column = 0
        var row = 0
        
        // Position coins based on a 2x4 grid
        if position <= 3 {
            column = position
        } else  {
            row = 1
            column = position - 4
        }

        let position: CGFloat = 50
        
        let offsetX = (-position * 1.5) + (position * CGFloat(column))
        let offsetY = (position / 2) - (position * CGFloat(row)) + 5
        
        return CGPoint(x: offsetX, y: offsetY)
    }
}

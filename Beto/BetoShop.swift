//
//  BetoShop.swift
//  Beto
//
//  Created by Jem on 9/28/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import SpriteKit

class BetoShop: DropdownNode {
    fileprivate let container: SKSpriteNode
    
        init() {
        container = SKSpriteNode(imageNamed: "betoShopBackground")
        container.position = CGPoint(x: 0, y: ScreenSize.Height)
        
        // Custom scale for iPhone 4 (Screen size: 320 x 480)
        if UIScreen.main.bounds.height == 480 {
            container.setScale(0.93)
        }
        
        super.init(container: container)
        
        let closeButton = ButtonNode(defaultButtonImage: "closeButton")
        closeButton.size = CGSize(width: 44, height: 45)
        closeButton.action = close
        closeButton.position = CGPoint(x: 140, y: 160)
        
        // Configure BuyDiceNodes
        let buyGold = BuyDiceNode(diceKey: .Gold, price: 50000)
        buyGold.position = pointForIndex(0)
        
        let buyPlatinum = BuyDiceNode(diceKey: .Platinum, price: 100000)
        buyPlatinum.position = pointForIndex(1)
        
        let buyDiamond = BuyDiceNode(diceKey: .Diamond, price: 500000)
        buyDiamond.position = pointForIndex(2)
        
        let buyRuby = BuyDiceNode(diceKey: .Ruby, price: 1000000)
        buyRuby.position = pointForIndex(3)
    
        container.addChild(closeButton)
        container.addChild(buyGold)
        container.addChild(buyPlatinum)
        container.addChild(buyDiamond)
        container.addChild(buyRuby)
    }
    
    func pointForIndex(_ index: Int) -> CGPoint {
        let offsetY = 90 - 60 * index
        
        return CGPoint(x: 0, y: offsetY)
    }
}

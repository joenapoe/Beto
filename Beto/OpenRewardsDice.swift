//
//  OpenRewardsDice.swift
//  Beto
//
//  Created by Jem on 8/20/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import SpriteKit

class OpenRewardsDice: DropdownNode {
    fileprivate let starCoinKey = "starCoin"
    fileprivate var claimButton: ButtonNode
    
    init(diceKey: RewardsDiceKey) {
        var rewardsCount = 3
        var claimedCount = 0
        
        switch diceKey {
        case .Bronze:
            GameData.incrementAchievement(.Bronze)
        case .Silver:
            GameData.incrementAchievement(.Silver)
        case .Gold:
            GameData.incrementAchievement(.Gold)
        case .Platinum:
            GameData.incrementAchievement(.Platinum)
            rewardsCount = 5
        case .Diamond:
            GameData.incrementAchievement(.Diamond)
            rewardsCount = 5
        case .Ruby:
            GameData.incrementAchievement(.Ruby)
            rewardsCount = 5
        }
        
        let container = SKSpriteNode()
        
        claimButton = ButtonNode(defaultButtonImage: "claimButton", activeButtonImage: "claimButton_active")
        claimButton.isHidden = true
        
        container.addChild(claimButton)
        
        super.init(container: container)
        
        // Add actions
        claimButton.action = close
        
        let imageName = diceKey.rawValue.lowercased() + "Reward_large"
        
        for pos in 0...rewardsCount-1 {
            let reward = generateReward(diceKey)
            
            if reward.key == starCoinKey {
                GameData.addStarCoins(reward.amount)
            } else {
                GameData.addPowerUpCount(reward.key, num: reward.amount)
            }
            
            let button = ButtonNode(defaultButtonImage: imageName)
            button.position = pointForPosition(pos)
            button.addWobbleAnimation()
            button.action = {
                let sprite = SKSpriteNode(imageNamed: reward.key)
                sprite.position = self.pointForPosition(pos)
                
                let label = SKLabelNode(text: "+\(reward.amount)")
                label.fontName = Constant.FontNameExtraBold
                label.fontSize = 18
                label.position = CGPoint(x: 10, y: -20)
                
                let labelShadow = label.createLabelShadow()
                
                sprite.addChild(labelShadow)
                sprite.addChild(label)
                container.addChild(sprite)
                
                button.removeAction(forKey: "wobble")
                button.action = {}
                button.removeFromParent()
                
                claimedCount += 1
                
                if claimedCount == rewardsCount {
                    self.claimButton.isHidden = false
                }
            }
            
            container.addChild(button)
        }
        
        GameData.save()
    }
    
    func generateReward(_ diceKey: RewardsDiceKey) -> (key: String, amount: Int) {
        var key = ""
        var amount = 0
        
        let rand = Int(arc4random_uniform(100)) + 1
                
        if rand <= 20 {
            key = PowerUpKey.lifeline.rawValue
        } else if rand <= 40 {
            key = PowerUpKey.rewardBoost.rawValue
        } else if rand <= 60 {
            key = PowerUpKey.extraDice.rawValue
        } else if rand <= 80 {
            key = PowerUpKey.doublePayout.rawValue
        } else if rand <= 90{
            key = PowerUpKey.triplePayout.rawValue
        } else {
            key = PowerUpKey.reroll.rawValue
        }
        
        switch diceKey {
        case .Bronze:
            amount = 1
        case .Silver:
            let randAmount = Int(arc4random_uniform(100)) + 1
            
            // 20/60/20 % chance to land 1/2/3
            if randAmount <= 20 {
                amount = 1
            } else if randAmount <= 80 {
                amount = 2
            } else {
                amount = 3
            }
        case .Gold:
            let randStar = Int(arc4random_uniform(100)) + 1
            
            // 5% chance to get a starCoin
            if randStar <= 5 {
                key = starCoinKey
                amount = 1
            } else {
                let randAmount = Int(arc4random_uniform(100)) + 1
                
                // 20/40/40 % chance to land 1/2/3
                if randAmount <= 20 {
                    amount = 1
                } else if randAmount <= 60 {
                    amount = 2
                } else {
                    amount = 3
                }
            }
        case .Platinum:
            let randStar = Int(arc4random_uniform(100)) + 1
            
            // 10% chance to get a starCoin
            if randStar <= 10 {
                key = starCoinKey
                amount = 1
            } else {
                let randAmount = Int(arc4random_uniform(100)) + 1
            
                // 10/60/30 % chance to land 1/2/3
                if randAmount <= 10 {
                    amount = 1
                } else if randAmount <= 70 {
                    amount = 2
                } else {
                    amount = 3
                }
            }
        case .Diamond:
            let randStar = Int(arc4random_uniform(100)) + 1
            
            // 20% chance to get a starCoin
            if randStar <= 20 {
                key = starCoinKey
                amount = 1
            } else {
                let randAmount = Int(arc4random_uniform(100)) + 1
                
                // 10/30/60 % chance to land 1/2/3
                if randAmount <= 10 {
                    amount = 1
                } else if randAmount <= 40 {
                    amount = 2
                } else {
                    amount = 3
                }
            }
        case .Ruby:
            let randStar = Int(arc4random_uniform(100)) + 1
            
            // 30% chance to get a starCoin
            if randStar <= 30 {
                key = starCoinKey
                amount = 1
            } else {
                amount = 3
            }
        }
        
        return(key, amount)
    }
    
    fileprivate func pointForPosition(_ position: Int) -> CGPoint {
        let xPosition: CGFloat = 60
        let yPosition: CGFloat = 80

        if position == 0 {
            return CGPoint(x: 0, y: yPosition)
        } else if position == 1 {
            return CGPoint(x: -xPosition, y: -yPosition)
        } else if position == 2 {
            return CGPoint(x: xPosition, y: -yPosition)
        } else if position == 3 {
            return CGPoint(x: -xPosition * 1.5, y: 0)
        } else if position == 4 {
            return CGPoint(x: xPosition * 1.5, y: 0)
        } else {
            return CGPoint(x: 0, y: 0) // Failsafe, should not execute
        }
    }
}

//
//  AchievementUnlocked.swift
//  Beto
//
//  Created by Jem on 5/27/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import SpriteKit

class AchievementUnlocked: DropdownNode {
    
    init(achievement: Achievement) {        
        let unlockedNode = SKSpriteNode(imageNamed: "achievementUnlocked")
        unlockedNode.size = CGSize(width: 304, height: 225)
        unlockedNode.position = CGPoint(x: 0, y: ScreenSize.Height)
        
        let claimButton = ButtonNode(defaultButtonImage: "claimButton", activeButtonImage: "claimButton_active")
        claimButton.size = CGSize(width: 110, height: 40)
        claimButton.position = CGPoint(x: 0, y: -80)

        let layer = SKNode()

        var title = achievement.displayName
        
        if achievement.level == 1 {
            title += " I"
        } else if achievement.level == 2 {
            title += " II"
        } else if achievement.level == 3 {
            title += " III"
        }
        
        let titleLabel = SKLabelNode(text: title.uppercased())
        titleLabel.fontName = Constant.FontNameExtraBold
        titleLabel.fontColor = UIColor.white
        titleLabel.fontSize = 14
        titleLabel.position = CGPoint(x: 0, y: 45)

        let titleShadow = titleLabel.createLabelShadow()

        let detailsText = achievement.requirements[achievement.level-1]

        let detailsLabel = SKLabelNode(text: detailsText)
        detailsLabel.fontName = Constant.FontName
        detailsLabel.fontColor = UIColor.darkGray
        detailsLabel.fontSize = 10
        detailsLabel.position = CGPoint(x: 0, y: 30)
        
        let rewardsLabel = SKLabelNode(text: "REWARDS")
        rewardsLabel.fontName = Constant.FontNameExtraBold
        rewardsLabel.fontColor = Constant.BetoGreen
        rewardsLabel.fontSize = 14
        rewardsLabel.position = CGPoint(x: 0, y: 10)

        let rewardsLabelShadow = rewardsLabel.createLabelShadow()

        let rewardsNode = SKNode()
        let rewards = achievement.rewards[achievement.level-1]
        
        // Display starCoin reward
        let starSprite = SKSpriteNode(imageNamed: "starCoin")
        starSprite.position = CGPoint(x: -50, y: -15)
        
        let starLabel = SKLabelNode(text: "x\(rewards.starCoins)")
        starLabel.fontName = Constant.FontName
        starLabel.fontColor = UIColor.darkGray
        starLabel.fontSize = 14
        starLabel.horizontalAlignmentMode = .left
        starLabel.position = CGPoint(x: 22, y: -5)
        
        starSprite.addChild(starLabel)
        rewardsNode.addChild(starSprite)
        
        // Display rewardsDice reward
        let diceSprite = SKSpriteNode(imageNamed: rewards.rewardsDice.rawValue.lowercased() + "Reward")
        diceSprite.position = CGPoint(x: 30, y: -15)
    
        let diceLabel = SKLabelNode(text: "x1")
        diceLabel.fontName = Constant.FontName
        diceLabel.fontColor = UIColor.darkGray
        diceLabel.fontSize = 14
        diceLabel.horizontalAlignmentMode = .left
        diceLabel.position = CGPoint(x: 20, y: -5)
        
        diceSprite.addChild(diceLabel)
        rewardsNode.addChild(diceSprite)
        
        // Add labels
        layer.addChild(titleShadow)
        layer.addChild(titleLabel)
        layer.addChild(detailsLabel)
        layer.addChild(rewardsLabelShadow)
        layer.addChild(rewardsLabel)
        layer.addChild(rewardsNode)
        
        super.init(container: unlockedNode)
        
        GameData.addStarCoins(rewards.starCoins)
        GameData.addRewardsDiceCount(rewards.rewardsDice.rawValue, num: 1)
        GameData.save()
        
        // Assign actions
        claimButton.action = close

        // Designate positions
        unlockedNode.position = CGPoint(x: 0, y: ScreenSize.Height)
        claimButton.position = CGPoint(x: 0, y: -80)

        // Add nodes
        unlockedNode.addChild(layer)
        unlockedNode.addChild(claimButton)
    }
}

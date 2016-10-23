//
//  RewardUnlocked.swift
//  Beto
//
//  Created by Jem on 8/28/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import SpriteKit

enum RewardType {
    case Chance
    case Gameplay
}

class RewardUnlocked: DropdownNode {
    
    init(rewardsDice: RewardsDice, rewardType: RewardType) {
        let container = SKSpriteNode(imageNamed: "rewardUnlocked")
        container.size = CGSize(width: 304, height: 225)
        container.position = CGPoint(x: 0, y: ScreenSize.Height)
        
        let claimButton = ButtonNode(defaultButtonImage: "claimButton", activeButtonImage: "claimButton_active")
        claimButton.size = CGSize(width: 110, height: 40)
        claimButton.position = CGPoint(x: 0, y: -80)
        
        var title = ""
        var detailsText = ""
        
        switch(rewardType) {
        case .Chance:
            title = "CONGRATULATIONS"
            detailsText = "You found a \(rewardsDice.key.rawValue) rewards dice!"
        case .Gameplay:
            title = "GAMEPLAY REWARD"
            detailsText = "Play \(GameData.gamesPlayed.formatStringFromNumber()) games"
        }
        
        let titleLabel = SKLabelNode(text: title)
        titleLabel.fontName = Constant.FontNameExtraBold
        titleLabel.fontSize = 14
        titleLabel.position = CGPoint(x: 0, y: 45)
        
        let titleShadow = titleLabel.createLabelShadow()
        
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
        
        rewardsDice.position = CGPoint(x: 0, y: -15)
        
        container.addChild(titleShadow)
        container.addChild(titleLabel)
        container.addChild(detailsLabel)
        container.addChild(rewardsLabelShadow)
        container.addChild(rewardsLabel)
        container.addChild(rewardsDice)
        container.addChild(claimButton)
        
        super.init(container: container)
        
        claimButton.action = close

    }
}

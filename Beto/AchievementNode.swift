//
//  AchievementNode.swift
//  Beto
//
//  Created by Jem on 5/20/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import SpriteKit

class AchievementNode: SKNode {
    
    init(achievement: Achievement) {
        super.init()
        
        let container = SKSpriteNode(imageNamed: "achievementBackground")
        container.size = CGSize(width: 276, height: 60)
                
        // Add level sprites
        for level in 1...3 {
            var imageName = "lockedLevel\(level)"
            
            if achievement.level >= level {
                imageName = "unlockedLevel\(level)"
            }
            
            let levelSprite = SKSpriteNode(imageNamed: imageName)
            levelSprite.position = pointForLevel(level)
            
            container.addChild(levelSprite)
        }
        
        // Add achievement details
        let details = SKNode()
        details.position = CGPoint(x: 50, y: 10)
        
        let titleLabel = SKLabelNode(text: achievement.displayName.uppercased())
        titleLabel.fontName = Constant.FontNameExtraBold
        titleLabel.fontColor = UIColor.white
        titleLabel.fontSize = 14

        // Requirements index. If at level 3, show level 2 requirement
        var index = achievement.level
        
        if index == 3 {
            index = 2
        }
        
        let requirementLabel = SKLabelNode(text: achievement.requirements[index])
        requirementLabel.fontName = Constant.FontName
        requirementLabel.fontColor = UIColor.darkGray
        requirementLabel.fontSize = 10
        requirementLabel.position = CGPoint(x: 0, y: -15)
        
        // Add progress bar or achievements completed label 
        if achievement.level == 3 {
            let completedLabel = SKLabelNode(text: "Achievement Completed")
            completedLabel.fontName = Constant.FontNameExtraBold
            completedLabel.fontColor = Constant.BetoGreen
            completedLabel.fontSize = 12
            completedLabel.position = CGPoint(x: 0, y: -30)
            
            let completedShadow = completedLabel.createLabelShadow()
            
            details.addChild(completedShadow)
            details.addChild(completedLabel)
            
        } else {
            let progressBar = SKSpriteNode(imageNamed: "progressBar")
            progressBar.size = CGSize(width: 120, height: 6)
            progressBar.position = CGPoint(x: 0, y: -25)
            
            let width = 120 * achievement.progress
            let offsetX = (width - 119.5) / 2
            
            let currentProgress = SKSpriteNode(imageNamed: "currentProgress")
            currentProgress.size = CGSize(width: width, height: 6)
            currentProgress.position = CGPoint(x: offsetX, y: 0)
            
            progressBar.addChild(currentProgress)
            details.addChild(progressBar)
        }
        
        let titleShadow = titleLabel.createLabelShadow()
        
        details.addChild(titleShadow)
        details.addChild(titleLabel)
        details.addChild(requirementLabel)
        
        container.addChild(details)
        
        addChild(container)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pointForLevel(_ level: Int) -> CGPoint {
        
        let offsetX = -145 + 32 * level
        
        return CGPoint(x: offsetX, y: 0)
    }
}

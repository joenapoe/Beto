//
//  AchievementsListNode.swift
//  Beto
//
//  Created by Jem on 4/8/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import SpriteKit

class AchievementsListNode: DropdownNode {
    fileprivate let container: SKSpriteNode
    fileprivate var achievementNodes: [AchievementNode]

    fileprivate var currentPage = 0
    fileprivate let perPageCount = 5
    
    init() {
        container = SKSpriteNode(imageNamed: "achievementsListBackground")
        container.size = CGSize(width: 303, height: 413)
        container.position = CGPoint(x: 0, y: ScreenSize.Height)
        
        // Custom scale for iPhone 4 (Screen size: 320 x 480)
        if UIScreen.main.bounds.height == 480 {
            container.setScale(0.93)
        }
        
        achievementNodes = []

        super.init(container: container)
        
        let closeButton = ButtonNode(defaultButtonImage: "closeButton")
        closeButton.size = CGSize(width: 44, height: 45)
        closeButton.action = close
        closeButton.position = CGPoint(x: 140, y: 190)
        
        let previousButton = ButtonNode(defaultButtonImage: "previousButton")
        previousButton.size = CGSize(width: 34, height: 35)
        previousButton.action = previousPage
        previousButton.position = CGPoint(x: -25, y: -180)
        
        let nextButton = ButtonNode(defaultButtonImage: "nextButton")
        nextButton.size = CGSize(width: 34, height: 35)
        nextButton.action = nextPage
        nextButton.position = CGPoint(x: 25, y: -180)
        
        createPage(currentPage)
        
        container.addChild(closeButton)
        container.addChild(previousButton)
        container.addChild(nextButton)
    }
    
    func createPage(_ pageNumber: Int) {
        for node in achievementNodes {
            node.removeFromParent()
        }
        
        achievementNodes = []
        
        for index in 0...perPageCount-1 {
            let position = index + (perPageCount * pageNumber)
            
            if position < Achievements.list.count {
                let node = AchievementNode(achievement: Achievements.list[position])
                node.position = pointForIndex(index)
                
                achievementNodes.append(node)
            }
        }
        
        for node in achievementNodes {
            container.addChild(node)
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
            createPage(currentPage)
        }
    }
    
    func nextPage() {
        var lastPage = Achievements.list.count / perPageCount
        
        if Achievements.list.count % perPageCount == 0 {
            lastPage -= 1
        }
        
        if currentPage < lastPage {
            currentPage += 1
            createPage(currentPage)
        }
    }
    
    func pointForIndex(_ index: Int) -> CGPoint {
        
        let offsetY = 121 - 60 * index
        
        return CGPoint(x: 0, y: offsetY)
    }
}

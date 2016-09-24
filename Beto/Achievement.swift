//
//  Achievement.swift
//  Beto
//
//  Created by Jem on 5/26/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

struct Reward {
    let starCoins: Int
    let rewardsDice: RewardsDiceKey
}

class Achievement {
    let name: String
    let displayName: String
    let requirementValues: [Int]
    let requirements: [String]
    let rewards: [Reward]
   
    var level: Int = 0
    var progress: Double = 0.0
    
    init(name: String, displayName: String, requirementValues: [Int], requirements: [String], rewards: [Reward]) {
        self.name = name
        self.displayName = displayName
        self.requirementValues = requirementValues
        self.requirements = requirements
        self.rewards = rewards
        
        startTrackingAchievement()
        calculateLevel()
        calculateProgress()
    }
    
    // Creates a new entry for achievementTracker in the plist for newly added achievements
    func startTrackingAchievement() {
        if GameData.achievementTracker.index(forKey: name) == nil {
            GameData.addNewAchievementTracker(name)
            GameData.save()
        }
    }
    
    func calculateLevel() {
        let value = GameData.achievementTracker[name]!
        
        if value >= requirementValues[2] {
            level = 3
        } else if value >= requirementValues[1] {
            level = 2
        } else if value >= requirementValues[0] {
            level = 1
        }
    }
    
    func calculateProgress() {
        if level == 3 {
            progress = 1.0
        } else {
            progress = Double(GameData.achievementTracker[name]!) / Double(requirementValues[level])
        }
    }
}

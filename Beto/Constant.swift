//
//  Constant.swift
//  Beto
//
//  Created by Jem on 2/24/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import SpriteKit

// Delete: Revisit Singleton Later
let GameData = GameDataManager()
let Audio = AudioManager()
let Achievements = AchievementsManager()

struct Constant {
    static let Denominations = [5, 10, 50, 100, 1000, 10000, 100000, 1000000]
    static let CoinUnlockedAt = [500, 1000, 5000, 10000, 100000, 1000000, 10000000]
    static let Margin: CGFloat = 10
    static let ScaleFactor: CGFloat = UIScreen.main.bounds.width / 320
    static let FontName = "Futura Medium"
    static let FontNameCondensed = "Futura-CondensedMedium"
    static let FontNameExtraBold = "Futura-CondensedExtraBold"
    
    static let BetoGreen = UIColor(red: 126/255, green: 211/255, blue: 33/255, alpha: 1)
}

struct ScreenSize {
    static let Size = UIScreen.main.bounds.size
    static let Width = UIScreen.main.bounds.width
    static let Height = UIScreen.main.bounds.height
}

enum Color: String {
    case Blue
    case Red
    case Green
    case Yellow
    case Cyan
    case Purple
    
    static let allValues = [Blue, Red, Green, Yellow, Cyan, Purple]
}


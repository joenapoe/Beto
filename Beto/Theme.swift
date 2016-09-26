//
//  Theme.swift
//  Beto
//
//  Created by Jem on 6/3/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import Foundation

enum ThemePrice: Int {
    case priceless = 99999
    case basic = 0
    case premium = 1
    case legendary = 100
}

class Theme {
    let name: String
    let background: String
    let board: String

    var unlocked: Bool
    var price: Int
 
    // Initializer for the current theme
    init(themeName: String, unlocked: Bool) {
        name = themeName
        
        background = "\(name.lowercased())Background"
        board = "\(name.lowercased())Board"
        
        self.unlocked = unlocked
        price = ThemePrice.priceless.rawValue
    }
    
    init(themeName: String) {
        name = themeName
        
        background = "\(name.lowercased())Background"
        board = "\(name.lowercased())Board"
        
        unlocked = GameData.unlockedThemes.contains(themeName)
        price = ThemePrice.priceless.rawValue
    }
    
    func setPrice(_ price: ThemePrice) {
        self.price = price.rawValue
    }
    
    func purchase() {
        unlocked = true
        GameData.subtractStarCoins(price)
        GameData.addPurchasedTheme(name)
        GameData.save()
    }
}

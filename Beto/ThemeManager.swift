//
//  ThemeManager.swift
//  Beto
//
//  Created by Jem on 6/3/16.
//  Copyright © 2016 redgarage. All rights reserved.
//

import Foundation

class ThemeManager {
    fileprivate(set) var themes = [Theme]()

    init() {
        let defaultTheme = Theme(themeName: "Default", tier: .free)
        themes.append(defaultTheme)
        
        let mango = Theme(themeName: "Mango", tier: .basic)
        themes.append(mango)
        
        let marine = Theme(themeName: "Marine", tier: .basic)
        themes.append(marine)

        let onyx = Theme(themeName: "Onyx", tier: .basic)
        themes.append(onyx)
        
        let peach = Theme(themeName: "Peach", tier: .basic)
        themes.append(peach)
        
        let sunset = Theme(themeName: "Sunset", tier: .basic)
        themes.append(sunset)
        
        let beach = Theme(themeName: "Beach", tier: .premium)
        themes.append(beach)
        
        let constellations = Theme(themeName: "Constellations", tier: .premium)
        themes.append(constellations)
        
        let strawberry = Theme(themeName: "Strawberry", tier: .premium)
        themes.append(strawberry)
        
        let candy = Theme(themeName: "Candy", tier: .ultimate)
        themes.append(candy)
        
        let clouds = Theme(themeName: "Clouds", tier: .ultimate)
        themes.append(clouds)
        
        let galaxy = Theme(themeName: "Galaxy", tier: .ultimate)
        themes.append(galaxy)
    }

    func getTheme(_ themeName: String) -> Theme {
        for theme in themes {
            if theme.name == themeName {
                return theme
            }
        }

        // Return default theme as failsafe. This could should never execute
        return themes[0]
    }
}

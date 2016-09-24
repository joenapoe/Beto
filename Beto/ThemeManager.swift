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
        let defaultTheme = Theme(themeName: "Default")
        themes.append(defaultTheme)
        
//        let blueTheme = Theme(themeName: "Aqua")
//        blueTheme.setPrice(.basic)
//        themes.append(blueTheme)
//        
//        let redTheme = Theme(themeName: "Red")
//        redTheme.setPrice(.basic)
//        themes.append(redTheme)
//        
//        let greenTheme = Theme(themeName: "Green")
//        greenTheme.setPrice(.basic)
//        themes.append(greenTheme)
//        
//        let purpleTheme = Theme(themeName: "Purple")
//        purpleTheme.setPrice(.basic)
//        themes.append(purpleTheme)
//        
//        let yellowTheme = Theme(themeName: "Yellow")
//        yellowTheme.setPrice(.premium)
//        themes.append(yellowTheme)
//        
//        let cyanTheme = Theme(themeName: "Cyan")
//        cyanTheme.setPrice(.premium)
//        themes.append(cyanTheme)
//        
//        let blackTheme = Theme(themeName: "Black")
//        blackTheme.setPrice(.premium)
//        themes.append(blackTheme)
//        
//        let azulTheme = Theme(themeName: "Azul")
//        azulTheme.setPrice(ThemePrice.legendary)
//        themes.append(azulTheme)
//        
//        let midnightTheme = Theme(themeName: "Midnight")
//        midnightTheme.setPrice(ThemePrice.legendary)
//        themes.append(midnightTheme)
        
        let aqua = Theme(themeName: "Aqua")
        aqua.setPrice(.basic)
        themes.append(aqua)
        
        let azure = Theme(themeName: "Azure")
        azure.setPrice(.basic)
        themes.append(azure)
        
        let beach = Theme(themeName: "Beach")
        beach.setPrice(.basic)
        themes.append(beach)
        
        let candy = Theme(themeName: "Candy")
        candy.setPrice(.basic)
        themes.append(candy)
        
        let mango = Theme(themeName: "Mango")
        mango.setPrice(.basic)
        themes.append(mango)
        
        let peach = Theme(themeName: "Peach")
        peach.setPrice(.basic)
        themes.append(peach)
        
        let sky = Theme(themeName: "Sky")
        sky.setPrice(.basic)
        themes.append(sky)
        
        let sunset = Theme(themeName: "Sunset")
        sunset.setPrice(.basic)
        themes.append(sunset)
        
        let constellations = Theme(themeName: "Constellations")
        constellations.setPrice(.premium)
        themes.append(constellations)
        
        let galaxy = Theme(themeName: "Galaxy")
        galaxy.setPrice(.premium)
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

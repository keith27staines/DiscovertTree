//
//  Theme.swift
//  DiscovertTree
//
//  Created by Keith Staines on 25/11/2023.
//  Credit: Theme colors from https://developer.apple.com/tutorials/app-dev-training/creating-a-card-view

import SwiftUI

enum Theme: String {
    case bubblegum
    case buttercup
    case poppy
    case seafoam
    case sky
    case tan
    case teal
    case yellow
    
    var accentColor: Color {
        .black
    }
    var mainColor: Color {
        Color(rawValue)
    }
}

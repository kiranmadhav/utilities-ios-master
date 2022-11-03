//
//  Language.swift
//  Utilities
//
//  Created by Chien, Arnold on 2/16/17.
//  Copyright © 2017 mhe. All rights reserved.
//

import Foundation

// ISO 639-1 raw values.
public enum Language: String {
    case english = "en"
    case spanish = "es"
    case german = "de"
    case french = "fr"
    case italian = "it"
    case danish = "da"
    case norwegian = "no"
    case finnish = "fi"
    case swedish = "sv"
    case polish = "pl"
    case russian = "ru"
    case arabic = "ar"
    case chinese = "zh"
    case japanese = "ja"
    case korean = "ko"
}

public enum Script: String {
    case latin = "Latn"
    case cyrillic = "Cyrl"
    case greek = "Grek"
    case japanese = "Jpan"
    case chinese = "Hans"
    case arabic = "Arab"
    case unknown = "Zyyy"
}

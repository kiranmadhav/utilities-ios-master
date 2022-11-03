//
//  AppInfo.swift
//  Utilities
//
//  Created by kurtu on 4/25/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import Foundation

open class AppInfo {
    public static var appName: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }

    public static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    public static var buildNumber: String? {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }
}

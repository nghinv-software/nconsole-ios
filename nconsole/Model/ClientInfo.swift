//
//  ClientInfo.swift
//  nconsole
//
//  Created by NghiNV on 12/04/2024.
//

import Foundation

public struct ClientInfo: Encodable {
    var id: String
    var name: String
    var platform: String
    var debug: Bool
    var isSimulator: Bool
    var version: String
    var buildVersion: String
    var model: String
    var manufacturer: String
    var os: String
    var osVersion: String
    var language: String
    var userAgent: String?
    var screenWidth: Double?
    var screenHeight: Double?
    var windowWidth: Double?
    var windowHeight: Double?
    var screenScale: Double?
    var windowScale: Double?
    var isPortrait: Bool?
    var isLandscape: Bool?
    var isDarkMode: Bool?
}

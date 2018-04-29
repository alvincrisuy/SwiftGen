//
// SwiftGenKit
// Copyright (c) 2017 SwiftGen
// MIT Licence
//

import Foundation
import Kanna

extension Storyboards {
  struct Scene {
    let sceneID: String
    let identifier: String
    let tag: String
    let customClass: String?
    let customModule: String?
    let segues: Set<Segue>
    let platform: Platform
  }
}

// MARK: - SwiftType

extension Storyboards.Scene: StoryboardsSwiftType {
  private static let tagTypeMap = [
    "avPlayerViewController": (type: "AVPlayerViewController", module: "AVKit"),
    "glkViewController": (type: "GLKViewController", module: "GLKit"),
    "pagecontroller": (type: "NSPageController", module: nil)
  ]

  var type: String {
    if let customClass = customClass {
      return customClass
    } else if let type = Storyboards.Scene.tagTypeMap[tag]?.type {
      return type
    } else {
      return "\(platform.prefix)\(tag.uppercasedFirst())"
    }
  }

  var module: String? {
    if let customModule = customModule {
      return customModule
    } else if let type = Storyboards.Scene.tagTypeMap[tag]?.module {
      return type
    } else if customClass == nil {
      return platform.module
    } else {
      return nil
    }
  }
}

// MARK: - XML

private enum XML {
  static let segueXPath = "//connections/segue"
  static let idAttribute = "id"
  static let customClassAttribute = "customClass"
  static let customModuleAttribute = "customModule"
  static let storyboardIdentifierAttribute = "storyboardIdentifier"
}

extension Storyboards.Scene {
  init(with object: Kanna.XMLElement, platform: Storyboards.Platform) {
    sceneID = object[XML.idAttribute] ?? ""
    identifier = object[XML.storyboardIdentifierAttribute] ?? ""
    tag = object.tagName ?? ""
    customClass = object[XML.customClassAttribute]
    customModule = object[XML.customModuleAttribute]
    segues = Set(object.xpath(XML.segueXPath).map {
      Storyboards.Segue(with: $0, platform: platform)
    })
    self.platform = platform
  }
}

// MARK: - Hashable

extension Storyboards.Scene: Equatable { }
func == (lhs: Storyboards.Scene, rhs: Storyboards.Scene) -> Bool {
  return lhs.sceneID == rhs.sceneID
}

extension Storyboards.Scene: Hashable {
  var hashValue: Int {
    return sceneID.hashValue
  }
}

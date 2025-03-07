//
//  HighlightTheme.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 28/11/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import OSLog

@available(*, deprecated)
public class HighlightTheme: Codable {

    var root: ThemeTrieElement

    var settings: [ThemeSetting]

    /// Logger
    static let logger = Logger(subsystem: "com.auroraeditor", category: "Highlight Theme")

    public init(settings: [ThemeSetting]) {
        self.settings = settings
        self.root = HighlightTheme.createTrie(settings: settings)
    }

    static func sortSettings(settings: [ThemeSetting]) -> [ThemeSetting] {
        var expanded = [ThemeSetting]()
        for setting in settings {
            for scope in setting.scopes {
                expanded.append(ThemeSetting(scope: scope,
                                             parentScopes: setting.parentScopes,
                                             attributes: setting.attributes,
                                             inSelectionAttributes: setting.inSelectionAttributes,
                                             outSelectionAttributes: setting.outSelectionAttributes))
            }
        }
        return expanded.sorted { (first, second) -> Bool in
            guard let firstScope = first.scopes.first,
                  let secondScope = second.scopes.first else {
                return false
            }

            if firstScope.scopeComponents.count != secondScope.scopeComponents.count {
                return firstScope.scopeComponents.count < secondScope.scopeComponents.count
            }
            return first.parentScopes.count < second.parentScopes.count
        }
    }

    static func createTrie(settings: [ThemeSetting]) -> ThemeTrieElement {
        var settings = sortSettings(settings: settings)
        let root = ThemeTrieElement(
            children: [:],
            attributes: [:],
            inSelectionAttributes: [:],
            outSelectionAttributes: [:],
            parentScopeElements: [:]
        )

        if settings.isEmpty {
            return root
        }

        if settings[0].scopes.first?.isEmpty ?? true {
            root.attributes = settings.removeFirst().attributes.reduce([:], {
                var res = $0
                res[$1.key] = $1
                return res
            })
            root.inSelectionAttributes = settings.removeFirst().inSelectionAttributes.reduce([:], {
                var res = $0
                res[$1.key] = $1
                return res
            })
            root.outSelectionAttributes = settings.removeFirst().outSelectionAttributes.reduce([:], {
                var res = $0
                res[$1.key] = $1
                return res
            })
        }

        for setting in settings {
            addSettingToTrie(root: root, setting: setting)
        }

        return root
    }

    static func addSettingToTrie(root: ThemeTrieElement, setting: ThemeSetting) {
        guard let first = setting.scopes.first else {
            return
        }

        var curr = root
        var prev: ThemeTrieElement?
        // TODO: Optimise to collapse
        for comp in first.scopeComponents {
            if let child = curr.children[String(comp)] {
                prev = curr
                curr = child
            } else {
                let new = ThemeTrieElement(
                    children: [:],
                    attributes: [:],
                    inSelectionAttributes: [:],
                    outSelectionAttributes: [:],
                    parentScopeElements: [:]
                )
                curr.children[String(comp)] = new
                prev = curr
                curr = new
            }
        }
        guard prev != nil else {
            self.logger.info("Error: prev is nil")
            return
        }
        curr.attributes = (prev?.attributes ?? [:])
        curr.inSelectionAttributes = (prev?.inSelectionAttributes ?? [:])
        curr.outSelectionAttributes = (prev?.outSelectionAttributes ?? [:])
        for attr in setting.attributes {
            curr.attributes[attr.key] = attr
        }
        for attr in setting.inSelectionAttributes {
            curr.inSelectionAttributes[attr.key] = attr
        }
        for attr in setting.outSelectionAttributes {
            curr.outSelectionAttributes[attr.key] = attr
        }

        if !setting.parentScopes.isEmpty {
            self.logger.warning("HighlightTheme parent scopes not implemented")
        }
    }

    public func allAttributes(forScopeName scopeName: ScopeName
    ) -> ([ThemeAttribute], [ThemeAttribute], [ThemeAttribute]) { // swiftlint:disable:this large_tuple
        var curr = root
        for comp in scopeName.components {
            if let child = curr.children[String(comp)] {
                curr = child
            } else {
                break
            }
        }
        return (Array(curr.attributes.values),
                Array(curr.inSelectionAttributes.values),
                Array(curr.outSelectionAttributes.values))
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let settings = try container.decode([ThemeSetting].self, forKey: .settings)
        self.init(settings: settings)
    }

    enum Keys: CodingKey {
        case settings
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(settings, forKey: .settings)
    }
}

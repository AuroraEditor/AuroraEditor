//
//  Spotlight.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 17/05/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI
import OSLog
import CoreSpotlight

class CoreSpotlight {
    @ObservedObject
    private var recentsStore: RecentProjectsStore = .shared

    private let logger = Logger(subsystem: "com.auroraeditor", category: "Spotlight")

    init() { }

    func update() {
        // Index new values
        let searchableItems = recentsStore.paths.map { recentItem in
            let attributeSet = CSSearchableItemAttributeSet(contentType: .item)
            attributeSet.title = recentItem.lastPathComponent
            attributeSet.contentDescription = recentItem
            attributeSet.artist = "Aurora Editor"
            attributeSet.keywords = [recentItem.lastPathComponent, "Aurora Editor"]

            attributeSet.relatedUniqueIdentifier = recentItem
            return CSSearchableItem(
                uniqueIdentifier: recentItem,
                domainIdentifier: "com.auroraeditor.projectItem",
                attributeSet: attributeSet
            )
        }

        let items = searchableItems.map { $0.attributeSet.title! }
        logger.debug("Sent \(searchableItems.count) recent projects to spotlight \(items)")

        // Send values to spotlight
        CSSearchableIndex.default().indexSearchableItems(searchableItems) { error in
            if let error = error {
                Log.error("\(error)")
            }
        }
    }

    func reset() {
        // Reset old values
        CSSearchableIndex.default().deleteSearchableItems(
            withDomainIdentifiers: ["com.auroraeditor.projectItem"]
        )
    }
}

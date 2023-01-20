//
//  RepositoryContainers&Items.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 18/8/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

// MARK: Repo Containers

/// `RepoContainer` is the superclass of ``RepoBranches``, ``RepoRecentLocations``, ``RepoTags``,
/// ``RepoStashedChanges``, ``RepoRemotes``, and ``RepoRemote``. Because in the OutlineView, each of these
/// are its own item, they each require their own class to distinguish between each other, however to save lines they
/// all share the same superclass. This superclass contains `contents`, which is an array of `Any` items.
/// Subclasses then add their own init functions, so that `contents` is filled with an array of the relevant class,
/// such as ``RepoBranch`` for ``RepoBranches``.
class RepoContainer {
    var contents: [Any]
    init(contents: [Any]) {
        self.contents = contents
    }
}

/// `RepoBranches` is the container class for ``RepoBranch``s
class RepoBranches: RepoContainer {
    var current: Int

    init(contents: [RepoBranch], current: Int = 0) {
        self.current = current
        super.init(contents: contents)
    }
}

/// `RepoRecentLocation` is the container class for ``RepoBranch``s which have been recently visited
/// Recent locations are the reason why we need container classes, because there is otherwise no way to distinguish
/// between ``RepoBranches`` and `RepoRecentLocation`, because they're both `[RepoBranch]` under the hood.
class RepoRecentLocations: RepoContainer {
    init(contents: [RepoBranch]) {
        super.init(contents: contents)
    }
}

/// `RepoTags` is the container class for ``RepoTag``s
class RepoTags: RepoContainer {
    init(contents: [RepoTag]) {
        super.init(contents: contents)
    }
}

/// `RepoStashedChanges` is the container class for ``RepoChange``s
class RepoStashedChanges: RepoContainer {
    init(contents: [RepoChange]) {
        super.init(contents: contents)
    }
}

/// `RepoRemotes` is the container class for ``RepoRemote``s
class RepoRemotes: RepoContainer {
    init(contents: [RepoRemote]) {
        super.init(contents: contents)
    }
}

/// `RepoRemote` is the container class for ``RepoBranch``s in the remote. This is another example
/// of why containers are needed, because this class too is a `[RepoBranch]` under the hood, much like
/// ``RepoBranches`` and ``RepoRecentLocations``.
class RepoRemote: RepoContainer {
    var name: String

    init(content: [RepoBranch], name: String) {
        self.name = name
        super.init(contents: content)
    }
}

// MARK: Repo items

/// Like ``RepoContainer``, this superclass allows code to be reduced by not having to check for every type
/// of item. This class has a `name` property, which is what determines the name displayed. The icon displayed
/// is determined by the subclass. In the future, if any features are to be implemented, all that one needs to do is
/// add the function/property to the subclass.
class RepoItem {
    var name: String

    init(name: String) {
        self.name = name
    }
}

/// `RepoBranch` is a subclass that represents git branches. ``RepoBranches``, ``RepoRecentLocations``
/// and ``RepoRemote`` are all wrapper classes for a `[RepoBranch]`.
class RepoBranch: RepoItem {}

/// `RepoTag` is a subclass that represents tags. I personally have never used tags before, but if they contain
/// additional information (like a colour or a category) then they can go into this subclass
class RepoTag: RepoItem {}

/// `RepoChange` is a subclass that represents stashed changes. I also have not used this before, but from the
/// name I think this includes a file name, which can easily go into the `name` property.
class RepoChange: RepoItem {}

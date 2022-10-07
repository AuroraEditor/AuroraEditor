//
//  Squash.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2022 Aurora Company. All rights reserved.
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// Squashes provided commits by calling interactive rebase.
///
/// Goal is to replay the commits in order from oldest to newest to reduce
/// conflicts with toSquash commits placed in the log at the location of the
/// squashOnto commit.
///
/// Example: A user's history from oldest to newest is A, B, C, D, E and they
/// want to squash A and E (toSquash) onto C. Our goal:  B, A-C-E, D. Thus,
/// maintaining that A came before C and E came after C, placed in history at the
/// the squashOnto of C.
///
/// Also means if the last 2 commits in history are A, B, whether user squashes A
/// onto B or B onto A. It will always perform based on log history, thus, B onto
/// A.
func squash() {}

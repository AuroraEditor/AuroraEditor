//
//  CodeLayoutManagerDelegate.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 18/9/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import AppKit

class CodeLayoutManagerDelegate: NSObject, NSLayoutManagerDelegate {

    func layoutManager(_ layoutManager: NSLayoutManager,
                       didCompleteLayoutFor textContainer: NSTextContainer?,
                       atEnd layoutFinishedFlag: Bool) {
        guard let layoutManager = layoutManager as? CodeLayoutManager else { return }

        if layoutFinishedFlag { layoutManager.gutterView?.layoutFinished() }
    }
}

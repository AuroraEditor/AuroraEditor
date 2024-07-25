//
//  Debouncer.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2024/07/21.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import Combine
import Foundation

class Debouncer {
    private var cancellable: AnyCancellable?

    func debounce(
        for timeInterval: TimeInterval,
        action: @escaping () -> Void
    ) {
        cancellable?.cancel()
        cancellable = Just(())
            .delay(
                for: .seconds(timeInterval),
                scheduler: RunLoop.main
            )
            .sink { _ in
                action()
            }
    }
}

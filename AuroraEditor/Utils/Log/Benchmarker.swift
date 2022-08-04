//
//  Benchmarker.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/08/04.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

class Benchmarker {
    typealias Result = (
        description: String?,
        average: Double,
        relativeStandardDeviation: Double
    )

    /**
     Measures the performance of code.

     - parameter description: The measure description.
     - parameter number:      The number of iterations.
     - parameter block:       The block to measure.

     - returns: The measure result.
     */
    func measure(_ description: String? = nil, iterations number: Int = 10, block: () -> Void) -> Result {
        precondition(number >= 1, "Iteration must be greater or equal to 1.")

        let durations = (0..<number).map { _ in duration { block() } }

        let average = self.average(durations)
        let standardDeviation = self.standardDeviation(average, durations: durations)
        let relativeStandardDeviation = standardDeviation * average * 100

        return (
            description: description,
            average: average,
            relativeStandardDeviation: relativeStandardDeviation
        )
    }

    private func duration(_ block: () -> Void) -> Double {
        let date = Date()

        block()

        return abs(date.timeIntervalSinceNow)
    }

    private func average(_ durations: [Double]) -> Double {
        return durations.reduce(0, +) / Double(durations.count)
    }

    private func standardDeviation(_ average: Double, durations: [Double]) -> Double {
        return durations.reduce(0) { sum, duration in
            return sum + pow(duration - average, 2)
        }
    }
}

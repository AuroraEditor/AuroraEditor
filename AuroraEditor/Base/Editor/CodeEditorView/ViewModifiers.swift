//
//  ViewModifers.swift
//  
//
//  Created by Manuel M T Chakravarty on 27/03/2021.
//
//  This file contains general purpose view modifiers.

import SwiftUI


// MARK: -
// MARK: Views with rounded corners on the left hand side.

fileprivate struct RectWithRoundedCornersOnTheLeft: Shape {
  let cornerRadius: CGFloat

  func path(in rect: CGRect) -> Path {
    var path = Path()

    let minXCorner = rect.minX + cornerRadius,
        minYCorner = rect.minY + cornerRadius,
        maxYCorner = rect.maxY - cornerRadius

    // We start in the top right corner and proceed clockwise
    path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.addLine(to: CGPoint(x: minXCorner, y: rect.maxY))

    path.addArc(center: CGPoint(x: minXCorner, y: maxYCorner),
                radius: cornerRadius,
                startAngle: Angle(degrees: 90),
                endAngle: Angle(degrees: 180),
                clockwise: false)

    path.addLine(to: CGPoint(x: rect.minX, y: minYCorner))

    path.addArc(center: CGPoint(x: minXCorner, y: minYCorner),
                radius: cornerRadius,
                startAngle: Angle(degrees: 90),
                endAngle: Angle(degrees: 0),
                clockwise: false)

    path.addLine(to: CGPoint(x: minXCorner, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
    return path
  }
}

extension View {

  /// Clip the view such that it has rounded corners on its left hand side.
  ///
  func roundedCornersOnTheLeft(cornerRadius: CGFloat = 5) -> some View {
    clipShape(RectWithRoundedCornersOnTheLeft(cornerRadius: cornerRadius))
  }
}


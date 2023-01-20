//
//  DockProgress.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 06/09/2022.
//
//  CREDIT: Modified from https://github.com/sindresorhus/DockProgress/
//

import SwiftUI
import Cocoa

extension NSApplication {
    func setDockProgress(progress: Double) {
        let dockTile = NSApplication.shared.dockTile
        guard let image = NSApplication.shared.applicationIconImage else { return }
        let imageView = NSImageView(image: image)
        dockTile.contentView = imageView
        // add the progress indicator to the dock tile view
        imageView.image = drawProgress(on: image, progress: progress)
        dockTile.display()
    }

    func removeDockProgress() {
        let dockTile = NSApplication.shared.dockTile
        guard let image = NSApplication.shared.applicationIconImage else { return }
        dockTile.contentView = NSImageView(image: image)
        dockTile.display()
    }

    private func drawProgress(on appIcon: NSImage, progress: Double) -> NSImage {
        NSImage(size: appIcon.size, flipped: false) { dstRect in
            NSGraphicsContext.current?.imageInterpolation = .high
            appIcon.draw(in: dstRect)

            guard let cgContext = NSGraphicsContext.current?.cgContext else { return false }

            let defaultInset: CGFloat = 6

            var rect = dstRect.insetBy(dx: defaultInset, dy: defaultInset)

            rect = rect.insetBy(dx: defaultInset, dy: defaultInset)

            let progressSquircle = ProgressSquircleShapeLayer(rect: rect)
            progressSquircle.strokeColor = NSColor.white.withAlphaComponent(0.5).cgColor
            progressSquircle.lineWidth = 5
            progressSquircle.progress = progress
            progressSquircle.render(in: cgContext)

            return true
        }
    }
}

/**
Convenience function for initializing an object and modifying its properties.
```
let label = with(NSTextField()) {
    $0.stringValue = "Foo"
    $0.textColor = .systemBlue
    view.addSubview($0)
}
```
*/

@discardableResult
private func with<T>(_ item: T, update: (inout T) throws -> Void) rethrows -> T {
    var this = item
    try update(&this)
    return this
}

private extension NSBezierPath {
    /**
    Create a path for a superellipse that fits inside the given rect.
    */
    static func superellipse(in rect: CGRect, cornerRadius: Double) -> Self {
        let minSide = min(rect.width, rect.height)
        let radius = min(cornerRadius, minSide / 2)

        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)

        // Top side (clockwise)
        let point1 = CGPoint(x: rect.minX + radius, y: rect.minY)
        let point2 = CGPoint(x: rect.maxX - radius, y: rect.minY)

        // Right side (clockwise)
        let point3 = CGPoint(x: rect.maxX, y: rect.minY + radius)
        let point4 = CGPoint(x: rect.maxX, y: rect.maxY - radius)

        // Bottom side (clockwise)
        let point5 = CGPoint(x: rect.maxX - radius, y: rect.maxY)
        let point6 = CGPoint(x: rect.minX + radius, y: rect.maxY)

        // Left side (clockwise)
        let point7 = CGPoint(x: rect.minX, y: rect.maxY - radius)
        let point8 = CGPoint(x: rect.minX, y: rect.minY + radius)

        let path = self.init()
        path.move(to: point1)
        path.addLine(to: point2)
        path.addCurve(to: point3, controlPoint1: topRight, controlPoint2: topRight)
        path.addLine(to: point4)
        path.addCurve(to: point5, controlPoint1: bottomRight, controlPoint2: bottomRight)
        path.addLine(to: point6)
        path.addCurve(to: point7, controlPoint1: bottomLeft, controlPoint2: bottomLeft)
        path.addLine(to: point8)
        path.addCurve(to: point1, controlPoint1: topLeft, controlPoint2: topLeft)

        return path
    }

    /**
    Create a path for a squircle that fits inside the given `rect`.
    - Precondition: The given `rect` must be square.
    */
    static func squircle(rect: CGRect) -> Self {
        assert(rect.width == rect.height)
        return superellipse(in: rect, cornerRadius: rect.width / 2)
    }
}

private final class ProgressSquircleShapeLayer: CAShapeLayer {
    convenience init(rect: CGRect) {
        self.init()
        fillColor = nil
        lineCap = .round
        position = .zero
        strokeEnd = 0

        let cgPath = NSBezierPath
            .squircle(rect: rect)
            .rotating(byRadians: .pi, centerPoint: rect.center)
            .reversed
            .cgPath

        path = cgPath
        bounds = cgPath.boundingBox
    }

    var progress: Double {
        get { strokeEnd }
        set {
            // Multiplying by `1.02` ensures that the start and end points meet at the end.
            // Needed because of the round line cap.
            strokeEnd = newValue * 1.02
        }
    }
}

private extension CGRect {
    var center: CGPoint {
        get { CGPoint(x: midX, y: midY) }
        set {
            origin = CGPoint(
                x: newValue.x - (size.width / 2),
                y: newValue.y - (size.height / 2)
            )
        }
    }
}

private extension NSBezierPath {
    /**
    UIKit polyfill.
    */
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)

        for index in 0..<elementCount {
            let type = element(at: index, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            @unknown default:
                assertionFailure("NSBezierPath received a new enum case. Please handle it.")
            }
        }

        return path
    }

    /**
    UIKit polyfill.
    */
    convenience init(roundedRect rect: CGRect, cornerRadius: CGFloat) {
        self.init(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    }

    /**
    UIKit polyfill.
    */
    func addLine(to point: CGPoint) {
        line(to: point)
    }

    /**
    UIKit polyfill.
    */
    func addCurve(to endPoint: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
        curve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }
}

private extension NSBezierPath {
    func copyPath() -> Self {
        (copy() as? Self)!
    }

    func rotationTransform(byRadians radians: Double, centerPoint point: CGPoint) -> AffineTransform {
        var transform = AffineTransform()
        transform.translate(x: point.x, y: point.y)
        transform.rotate(byRadians: radians)
        transform.translate(x: -point.x, y: -point.y)
        return transform
    }

    func rotating(byRadians radians: Double, centerPoint point: CGPoint) -> Self {
        let path = copyPath()

        guard radians != 0 else {
            return path
        }

        let transform = rotationTransform(byRadians: radians, centerPoint: point)
        path.transform(using: transform)
        return path
    }
}

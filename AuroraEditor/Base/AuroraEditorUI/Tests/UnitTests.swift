//
//  UnitTests.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 19.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

@testable import AuroraEditorUI
import Foundation
import SnapshotTesting
import SwiftUI
import XCTest

/// Aurora Editor UI unit tests.
final class AuroraEditorUIUnitTests: XCTestCase {

    // MARK: Help Button

    /// Tests the help button in light mode.
    func testHelpButtonLight() throws {
        let view = HelpButton(action: {})
        let hosting = NSHostingView(rootView: view)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 40, height: 40))
        hosting.appearance = .init(named: .aqua)
        assertSnapshot(matching: hosting, as: .image(size: .init(width: 40, height: 40)))
    }

    /// Tests the help button in dark mode.
    func testHelpButtonDark() throws {
        let view = HelpButton(action: {})
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 40, height: 40))
        assertSnapshot(matching: hosting, as: .image)
    }

    // MARK: Segmented Control

    /// Tests the segmented control in light mode.
    func testSegmentedControlLight() throws {
        let view = SegmentedControl(.constant(0), options: ["Opt1", "Opt2"])
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 100, height: 30))
        assertSnapshot(matching: hosting, as: .image)
    }

    /// Tests the segmented control in dark mode.
    func testSegmentedControlDark() throws {
        let view = SegmentedControl(.constant(0), options: ["Opt1", "Opt2"])
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 100, height: 30))
        assertSnapshot(matching: hosting, as: .image)
    }

    /// Tests the segmented control in light mode with prominent style.
    func testSegmentedControlProminentLight() throws {
        let view = SegmentedControl(.constant(0), options: ["Opt1", "Opt2"], prominent: true)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 100, height: 30))
        assertSnapshot(matching: hosting, as: .image)
    }

    /// Tests the segmented control in dark mode with prominent style.
    func testSegmentedControlProminentDark() throws {
        let view = SegmentedControl(.constant(0), options: ["Opt1", "Opt2"], prominent: true)
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 100, height: 30))
        assertSnapshot(matching: hosting, as: .image)
    }

    // MARK: FontPickerView

    /// Tests the font picker view in light mode.
    func testFontPickerViewLight() throws {
        let view = FontPicker("Font", name: .constant("SF-Mono"), size: .constant(13))
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 120, height: 30))
        assertSnapshot(matching: hosting, as: .image)
    }

    /// Tests the font picker view in dark mode.
    func testFontPickerViewDark() throws {
        let view = FontPicker("Font", name: .constant("SF-Mono"), size: .constant(13))
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 120, height: 30))
        assertSnapshot(matching: hosting, as: .image)
    }

    // MARK: EffectView

    /// Tests the effect view in light mode.
    func testEffectViewLight() throws {
        let view = EffectView()
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 20, height: 20))
        assertSnapshot(matching: hosting, as: .image)
    }

    /// Tests the effect view in dark mode.
    func testEffectViewDark() throws {
        let view = EffectView()
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 20, height: 20))
        assertSnapshot(matching: hosting, as: .image)
    }

    // MARK: ToolbarBranchPicker

    /// Tests the branch picker in light mode.
    func testBranchPickerLight() throws {
        let view = ToolbarBranchPicker(
            shellClient: .always(""),
            workspace: nil
        )
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .aqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 100, height: 50))
        assertSnapshot(matching: hosting, as: .image)
    }

    /// Tests the branch picker in dark mode.
    func testBranchPickerDark() throws {
        let view = ToolbarBranchPicker(
            shellClient: .always(""),
            workspace: nil
        )
        let hosting = NSHostingView(rootView: view)
        hosting.appearance = .init(named: .darkAqua)
        hosting.frame = CGRect(origin: .zero, size: .init(width: 100, height: 50))
        assertSnapshot(matching: hosting, as: .image)
    }
}

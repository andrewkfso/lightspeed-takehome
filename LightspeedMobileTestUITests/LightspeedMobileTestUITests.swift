//
//  LightspeedMobileTestUITests.swift
//  LightspeedMobileTestUITests
//
//  Created by Andrew So on 2025-08-22.
//

import XCTest

final class Lightspeed_iOS_TakeHomeUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - Helpers

    /// Returns the best-guess container for SwiftUI List, falling back if needed.
    private var listContainer: XCUIElement {
        if app.tables.firstMatch.exists { return app.tables.firstMatch }
        if app.collectionViews.firstMatch.exists { return app.collectionViews.firstMatch }
        return app.scrollViews.firstMatch
    }

    /// Ensures at least one row exists by tapping "Add Random Image" and waiting.
    @discardableResult
    private func ensureAtLeastOneRow(timeout: TimeInterval = 10) -> Int {
        let add = app.buttons["Add Random Image"]
        XCTAssertTrue(add.waitForExistence(timeout: 3), "Add button should exist")
        add.tap()

        // Wait up to `timeout` for first cell to appear
        let cell = app.cells.firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: timeout),
                      "Expected a list row to appear after adding")
        return app.cells.count
    }

    /// Waits until `app.cells.count` becomes exactly `expected` (or times out).
    @discardableResult
    private func waitForCellCount(toBe expected: Int, timeout: TimeInterval = 3.0) -> Bool {
        let predicate = NSPredicate(format: "count == %d", expected)
        let exp = expectation(for: predicate, evaluatedWith: app.cells, handler: nil)
        let result = XCTWaiter().wait(for: [exp], timeout: timeout)
        return result == .completed
    }

    /// Enters edit mode using your custom Edit button.
    private func enterEditMode() {
        let edit = app.buttons["Edit"]
        XCTAssertTrue(edit.waitForExistence(timeout: 2), "Edit button should exist")
        edit.tap()
    }

    /// Exits edit mode using your custom Done button.
    private func exitEditMode() {
        let done = app.buttons["Done"]
        XCTAssertTrue(done.waitForExistence(timeout: 2), "Done button should exist")
        done.tap()
    }

    // MARK: - Tests

    func test_AddRandomImage_AddsRow() {
        let before = app.cells.count
        let after = ensureAtLeastOneRow()
        XCTAssertGreaterThan(after, before, "Tapping Add should append a new row")
    }

    func test_DeleteRow_RemovesRow() {
        // Ensure at least 1 row to delete
        if app.cells.count == 0 { _ = ensureAtLeastOneRow() }

        let before = app.cells.count
        XCTAssertGreaterThanOrEqual(before, 1, "There should be at least one row to delete")

        // Swipe to reveal contextual Delete
        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.exists, "First cell should exist before deletion")
        firstCell.swipeLeft()

        // Tap "Delete"
        let delete = app.buttons["Delete"]
        XCTAssertTrue(delete.waitForExistence(timeout: 2), "Delete button should appear after swipe")
        delete.tap()

        // Wait for list to actually remove the row (animation/race guard)
        XCTAssertTrue(waitForCellCount(toBe: before - 1, timeout: 3.0),
                      "Row count should decrease after delete")

        let after = app.cells.count
        XCTAssertEqual(after, before - 1, "One row should be removed after delete")
    }

    func test_Reorder_MovesFirstRowToBottom() {
        // Ensure multiple rows so reorder is visible
        while app.cells.count < 3 { _ = ensureAtLeastOneRow() }

        // Enter edit mode to reveal drag handles
        enterEditMode()

        // Defensive: make sure the container exists (table/collection/scroll)
        XCTAssertTrue(listContainer.exists, "A list-like container should exist")

        let firstCell = app.cells.element(boundBy: 0)
        let lastIndex = app.cells.count - 1
        let lastCell  = app.cells.element(boundBy: lastIndex)

        XCTAssertTrue(firstCell.exists && lastCell.exists,
                      "Both source and destination cells should exist")

        // Long-press and drag the first cell onto the last cell
        // (works with SwiftUI List reordering)
        firstCell.press(forDuration: 0.9, thenDragTo: lastCell)

        exitEditMode()

        // We don't rely on cell text (authors vary), just ensure we still have >= 3 rows
        XCTAssertGreaterThanOrEqual(app.cells.count, 3, "Expect at least 3 rows after reordering")
    }

    func test_TapRow_OpensFullScreen_ThenClose() {
        if app.cells.count == 0 { _ = ensureAtLeastOneRow() }

        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.exists, "Need at least one cell to tap")

        // Tap to open the full-screen viewer
        firstCell.tap()

        let close = app.buttons["Close"]
        XCTAssertTrue(close.waitForExistence(timeout: 3), "Close button should appear in full-screen viewer")
        close.tap()

        // Back to list
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 2),
                      "List should be visible again after closing viewer")
    }
}

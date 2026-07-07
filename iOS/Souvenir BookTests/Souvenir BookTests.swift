import XCTest
@testable import SouvenirBook

@MainActor
final class SouvenirBookTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
    }

    func testSeedDataBelowFreeLimit() {
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testAddEntryIncreasesCount() {
        let before = store.entries.count
        store.add(Entry(itemName: "Test", tripTag: "Test2", price: 1, quantity: 2))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCanAddMoreWhenBelowLimit() {
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreAtLimit() {
        while store.entries.count < Store.freeLimit {
            store.add(Entry(itemName: "X", tripTag: "Y", price: 1, quantity: 1))
        }
        XCTAssertFalse(store.canAddMore)
    }

    func testDeleteEntryRemovesIt() {
        let entry = Entry(itemName: "Del", tripTag: "Me", price: 1, quantity: 1)
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testUpdateEntryChangesFields() {
        var entry = Entry(itemName: "Old", tripTag: "Old2", price: 1, quantity: 1)
        store.add(entry)
        entry.itemName = "New"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.itemName, "New")
    }

    func testDeleteAtOffsets() {
        store.add(Entry(itemName: "A", tripTag: "B", price: 1, quantity: 1))
        let before = store.entries.count
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, before - 1)
    }
}

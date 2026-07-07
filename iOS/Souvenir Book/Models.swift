import Foundation

struct Entry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var itemName: String
    var tripTag: String
    var price: Double
    var quantity: Double
    var date: Date = Date()
    var notes: String = ""
}

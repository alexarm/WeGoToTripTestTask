import Foundation

struct Tour: Codable {
    let title: String
    let description: String
    let steps: [Step]
}

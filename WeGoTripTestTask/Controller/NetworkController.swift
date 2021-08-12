import Foundation
import UIKit

class NetworkController {
    let requestUrl = "https://coffee-map-app.herokuapp.com/tours"
    static var tours = [Tour]()
    
    func fetchTours(completion: @escaping (Result<[Tour],  Error>) -> Void) {
        guard let url = URL(string: requestUrl) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data {
                do {
                    let toursInfo = try jsonDecoder.decode(Tours.self, from: data)
                    NetworkController.tours = toursInfo.tours
                    completion(.success(toursInfo.tours))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
}

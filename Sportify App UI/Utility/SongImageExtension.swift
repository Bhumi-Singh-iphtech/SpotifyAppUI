import UIKit

extension UIImageView {
    func load(urlString: String, completion: ((UIImage?) -> Void)? = nil) {
        guard let url = URL(string: urlString) else {
            completion?(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion?(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                self.image = image
                completion?(image)
            }
        }.resume()
    }
}

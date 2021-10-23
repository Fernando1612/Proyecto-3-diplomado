//
//  ViewController.swift
//  AsyncAwaitIntro
//
//  Created by Andy Ibanez on 6/12/21.
//

import UIKit

// MARK: - Definitions

struct ImageMetadata: Codable {
    let name: String
    let firstAppearance: String
    let year: Int
}

struct DetailedImage {
    let image: UIImage
    let metadata: ImageMetadata
}

enum ImageDownloadError: Error {
    case badImage
    case invalidMetadata
}

struct Character {
    let id: Int
    
    var metadata: ImageMetadata {
        get async throws {
            let metadata = try await downloadMetadata(for: id)
            return metadata
        }
    }
    
    var image: UIImage {
        get async throws {
            return try await downloadImage(imageNumber: id)
        }
    }
}

// MARK: - Functions


func downloadImageAndMetadata(
    imageNumber: Int,
    completionHandler: @escaping (_ image: DetailedImage?, _ error: Error?) -> Void
) {
    let imageUrl = "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part1/\(imageNumber).png"
    let metadataUrl = "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part1/\(imageNumber).json"
    let queue = OperationQueue()
    queue.addOperation {
        guard let imageUrl = URL(string: imageUrl), let metadataUrl = URL(string: metadataUrl) else{return}
        if let dataImage = try? Data(contentsOf: imageUrl),
           let mData = try? Data(contentsOf: metadataUrl){
            let image = UIImage(data: dataImage)
            let meta = try? JSONDecoder().decode(ImageMetadata.self, from: mData)
            
            let detailImage = DetailedImage(image: image!, metadata: meta!)
            completionHandler(detailImage,nil)
            }
        
        
    }
}

// MARK: - Main class

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var metadata: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @MainActor override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // MARK: METHOD 1 - Using Queues
 
        downloadImageAndMetadata(imageNumber: 1) { imageDetail, error in
            DispatchQueue.main.async{
                if let imageDetail = imageDetail {
                    self.imageView.image = imageDetail.image
                    self.metadata.text = "\(imageDetail.metadata.name) (\(imageDetail.metadata.firstAppearance) - \(imageDetail.metadata.year))"
                    print("Downloded success")
                }
            }
        }
        
        
    }
    
}

//
//  DetailViewController.swift
//  TwitterSearch
//
//  Created by Timur Saidov on 17.08.2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPost: UITextView!
    @IBOutlet weak var timerDetailLabel: UILabel!
    
    var name: String?
    var post: String?
    var imageUrl: String?
    
    var show: [Avatar]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.persistentContainer.viewContext {
            let fetchRequest: NSFetchRequest<Avatar> = Avatar.fetchRequest()
            do {
                show = try context.fetch(fetchRequest)
                guard let show = show else { return }
                for i in 0..<show.count {
                    print("Массив show, загруженный из CoreData: Число - \(show.count), элементы - \(show[i].show)")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        if show!.isEmpty {
            if let imageUrl = URL(string: imageUrl!) {
                URLSession.shared.dataTask(with: imageUrl) { (data, _, _) in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.userImage.image = image
                            self.userImage.layer.cornerRadius = 40
                            self.userImage.clipsToBounds = true
                            self.userImage.layer.borderWidth = 1
                            self.userImage.layer.borderColor = UIColor.gray.cgColor
                        }
                    }
                }.resume()
            }
        } else {
            userImage.image = nil
            userImage.layer.cornerRadius = 32.5
            userImage.clipsToBounds = true
            userImage.layer.borderWidth = 1
            userImage.layer.borderColor = UIColor.gray.cgColor
        }
        userName.text = name!
        userPost.text = post!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

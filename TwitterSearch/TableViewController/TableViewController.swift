//
//  TableViewController.swift
//  TwitterSearch
//
//  Created by Timur Saidov on 15.08.2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
     
     @IBOutlet weak var timerLabel: UIBarButtonItem!
     
     var show: [Avatar]? // Массив для того, чтобы отображать или скрывать картинки. Если картинки отображаются, то .count = 0, если картинки скрыты, то .count = 1.
     
     var posts: Response?
     var arrayOfPhoto: [String] = []
     var arrayOfName: [String] = []
     
     let loadingScreen = UIView()
     let activityIndicator = UIActivityIndicatorView()
     let loadingLabel = UILabel()
     
     var bool = false // Необходима для того, чтобы не отображать таблицу, пока идет загрузка данных с сервера.
     
     var timerUpdate = Timer() // Таймер до обновления. До вызова функции loadData().
     
     var timer = Timer() // Таймер счетчика в углу экрана, в timerLabel.
//     var seconds = 10
     var seconds: Int? // Тогда в методе func count(), необходимо извлекать значение self.seconds.
     let queue = DispatchQueue(label: "Queue", attributes: .concurrent)
     
     // Загрузка данных из CoreData.
     override func viewWillAppear(_ animated: Bool) {
          if let context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.persistentContainer.viewContext {
               let fetchRequest: NSFetchRequest<Avatar> = Avatar.fetchRequest()
               do {
                    show = try context.fetch(fetchRequest)
                    guard let show = show else { return } // Если show = nil, то в let show ничего не записывается.
                    for i in 0..<show.count {
                         print("Массив show, загруженный из CoreData: Число - \(show.count), элементы - \(show[i].show)")
                    }
                    self.tableView.reloadData()
               } catch {
                    print(error.localizedDescription)
               }
          }
     }
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
          navigationController?.navigationBar.prefersLargeTitles = true
          let attributes = [
               NSAttributedString.Key.foregroundColor: UIColor.white]
          navigationController?.navigationBar.largeTitleTextAttributes = attributes
          
//          self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.count), userInfo: nil, repeats: true)
//          RunLoop.current.add(self.timer, forMode: RunLoopMode.commonModes) // Method with a timer. UILabel/UIBarButtonItem is updating during scrolling UIScrollView. While UIScrollView is scrolling, the Timer is not updated because the run loops run in a different mode (RunLoopCommonModes, mode used for tracking events). The solution is adding timer to the RunLoopModes just after creation.
//               .current - a var, which returns the run loop for the current thread.
//               .add(timer: , forMode: ) - a func, which registers a given timer with a given input mode.
//               .RunLoopMode.commonModes - Objects added to a run loop using this value as the mode are monitored by all run loop modes that have been declared as a member of the set of “common" modes; see the description of CFRunLoopAddCommonMode(_:_:) for details.
          
          setLoadingScreen()
          loadData()
          self.timerUpdate = Timer.scheduledTimer(timeInterval: 12.75, target: self, selector: #selector(self.update), userInfo: nil, repeats: true) // Счетчик до обновления.
          RunLoop.current.add(self.timerUpdate, forMode: RunLoop.Mode.common)
          
          tableView.tableFooterView = UIView(frame: CGRect.zero)
     }
     
     override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
     }
     
     // MARK: - Table view data source
     
     override func numberOfSections(in tableView: UITableView) -> Int {
          return 1
     }
     
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          if bool {
               guard let posts = posts else { return 0 }
               return posts.response.items.count
          } else {
               return 0
          }
     }
     
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
          
          guard let posts = posts else { return cell }
          
          for i in 0..<posts.response.items.count {
               if posts.response.items[i].from_id < 0 {
                    for j in 0..<posts.response.groups.count {
                         var counterGroups = 0
                         if abs(posts.response.items[i].from_id) == posts.response.groups[j].id {
                              counterGroups = j
                              arrayOfPhoto.append(posts.response.groups[counterGroups].photo_50!)
                         }
                    }
               } else {
                    for j in 0..<posts.response.profiles.count {
                         var counterProfiles = 0
                         if posts.response.items[i].from_id == posts.response.profiles[j].id {
                              counterProfiles = j
                              arrayOfPhoto.append(posts.response.profiles[counterProfiles].photo_50!)
                         }
                    }
               }
          }
          
          guard let show = show else { return cell }
          
          if show.isEmpty {
               if let imageUrl = URL(string: arrayOfPhoto[indexPath.row]) {
                    URLSession.shared.dataTask(with: imageUrl) { (data, _, _) in // Обращаемся к нашей сессии и вызываем метод dataTask, который создает задачу на получение содержимого по указанному URL-адресу и проверяем можем ли по url получить данные в виде Data (т.е. если есть данные по этому url-адресу) и можем ли эти данные передать в качестве экземпляра класса UIImage в константу. Загрузка картинки в виде Data делается в фоновом потоке.
                         if let data = data, let image = UIImage(data: data) {
                              DispatchQueue.main.async {
                                   cell.userImage.image = image
                                   cell.userImage.layer.cornerRadius = 32.5
                                   cell.userImage.clipsToBounds = true
                                   cell.userImage.layer.borderWidth = 1
                                   cell.userImage.layer.borderColor = UIColor.gray.cgColor
                              }
                         }
                         }.resume()
               }
          } else {
               cell.userImage.image = nil
               cell.userImage.layer.cornerRadius = 32.5
               cell.userImage.clipsToBounds = true
               cell.userImage.layer.borderWidth = 1
               cell.userImage.layer.borderColor = UIColor.gray.cgColor
          }
          
          for i in 0..<posts.response.items.count {
               if posts.response.items[i].from_id < 0 {
                    for j in 0..<posts.response.groups.count {
                         var counterGroups = 0
                         if abs(posts.response.items[i].from_id) == posts.response.groups[j].id {
                              counterGroups = j
                              arrayOfName.append(posts.response.groups[counterGroups].name!)
                         }
                         
                    }
               } else {
                    for j in 0..<posts.response.profiles.count {
                         var counterProfiles = 0
                         if posts.response.items[i].from_id == posts.response.profiles[j].id {
                              counterProfiles = j
                              arrayOfName.append(posts.response.profiles[counterProfiles].first_name! + " " + posts.response.profiles[counterProfiles].last_name!)
                         }
                    }
               }
          }
          cell.userName.text = arrayOfName[indexPath.row]
          
          if posts.response.items[indexPath.row].text.count == 0 {
               cell.userTweet.text = "Post is not found."
          } else if posts.response.items[indexPath.row].text.count >= 29 {
               cell.userTweet.text = (posts.response.items[indexPath.row].text as NSString).substring(to: 29) + "..."
          } else {
               cell.userTweet.text = posts.response.items[indexPath.row].text
          }
          return cell
     }
     
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          tableView.deselectRow(at: indexPath, animated: true)
     }
     
     // Load data in the tableView.
     private func loadData() {
          let jsonUrlString1 = "https://api.vk.com/method/newsfeed.search?q=%22BMW%22&..."
          guard let url = URL(string: jsonUrlString1) else {
               let ac = UIAlertController(title: "Invalid URL", message: nil, preferredStyle: UIAlertController.Style.alert)
               let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
               ac.addAction(cancel)
               self.present(ac, animated: true, completion: nil)
               
               print("Error! Invalid URL!")
               return
          }
          
          URLSession.shared.dataTask(with: url) { (data, response, error)  in
               guard let data = data, let response = response else {
                    let ac = UIAlertController(title: "You are not connected to the Internet.", message: nil, preferredStyle: UIAlertController.Style.alert)
                    let connect = UIAlertAction(title: "Connect again", style: UIAlertAction.Style.default, handler: { (action) in
                         self.loadData()
                    })
                    ac.addAction(connect)
                    self.present(ac, animated: true, completion: nil)
                    
                    return
               }
               
               print(response)
//               print(String(data: data, encoding: .utf8) as Any)
               do {
                    self.posts = try JSONDecoder().decode(Response.self, from: data) // Загрузка одного экземпляра структуры Response: let posts = Response(response: Post(items: [Items], profiles: [Profiles], groups: [Groups])), то есть let posts = Response(response: ...) ~ {response: ...}. Использую тип Response, так как с сервера получаю словарь {response: {items: [...], profiles: [...], groups: [...]}}. А словарь идентичен экземпляру структуры.
                    print("Данные, полученные в виде JSON: \(self.posts!)")
                    
                    guard let post = self.posts else { return }
                    guard post.response.items.count != 0, post.response.profiles.count != 0, post.response.groups.count != 0 else {
                         let ac = UIAlertController(title: "No data. Error on server. Please, try again later", message: nil, preferredStyle: UIAlertController.Style.alert)
                         let connect = UIAlertAction(title: "Connect again", style: UIAlertAction.Style.default, handler: { (action) in
                              self.loadData()
                         })
                         ac.addAction(connect)
                         self.present(ac, animated: true, completion: nil)
                         
                         return
                    }
                    
                    self.arrayOfPhoto.removeAll()
                    self.arrayOfName.removeAll()
                    
                    DispatchQueue.main.async {
//                         DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
                         self.removeLoadingScreen()
                         self.bool = true
                         self.tableView.reloadData() // Отображение данных. Обновление таблицы.
                         self.seconds = 10 // Поскольку .reloadData() запускает перезагрузку таблицы, а не всего контроллера, то есть метод viewDidLoad не запускается, поэтому надо писать эту строчку, иначе счетчик будет уходить в минус.
                         self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.count), userInfo: nil, repeats: true) // Счетчик в углу экрана.
                         RunLoop.current.add(self.timer, forMode: RunLoop.Mode.common)
                    }
               } catch {
                    let ac = UIAlertController(title: "Invalid URL! Error serializing JSON", message: nil, preferredStyle: UIAlertController.Style.alert)
                    let connect = UIAlertAction(title: "Connect again", style: UIAlertAction.Style.default, handler: { (action) in
                         self.loadData()
                    })
                    ac.addAction(connect)
                    self.present(ac, animated: true, completion: nil)
                    
                    print("Error serializing JSON \(error)")
               }
          }.resume()
     }
     
     // Set the activity indicator into the main view.
     private func setLoadingScreen() {
          // Sets the view which contains the loading text and the activity indicator.
          let width: CGFloat = 120
          let height: CGFloat = 30
          let x = (tableView.frame.width / 2) - (width / 2)
          let y = (tableView.frame.height / 2) - (height / 2) - (navigationController?.navigationBar.frame.height)!
          loadingScreen.frame = CGRect(x: x, y: y, width: width, height: height)
          
          // Sets loading text.
          loadingLabel.isHidden = false
          loadingLabel.textColor = .gray
          loadingLabel.textAlignment = .center
          loadingLabel.text = "Loading..."
          loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
          
          // Sets activity indicator.
          activityIndicator.style = .gray
          activityIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
          activityIndicator.startAnimating()
          
          // Adds text and activity indicator to the view.
          loadingScreen.addSubview(activityIndicator)
          loadingScreen.addSubview(loadingLabel)
          
          tableView.addSubview(loadingScreen)
     }
     
     // Remove the activity indicator from the main view.
     private func removeLoadingScreen() {
          // Hides and stops the text and the activity indicator.
          activityIndicator.stopAnimating()
          activityIndicator.isHidden = true
          loadingLabel.isHidden = true
     }
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "detailSegue" {
               if let indexPath = tableView.indexPathForSelectedRow {
                    guard let dvc = segue.destination as? DetailViewController else { return }
                    guard let posts = posts else { return }
                    dvc.post = posts.response.items[indexPath.row].text
                    dvc.name = arrayOfName[indexPath.row]
                    dvc.imageUrl = arrayOfPhoto[indexPath.row]
               }
          }
     }
}

extension TableViewController {
     @objc func count() {
          self.seconds! -= 1 // self.seconds -= 1
          DispatchQueue.main.async {
               self.timerLabel.title = String(self.seconds!) // String(self.seconds)
          }
          if (self.seconds! == 0) { // (self.seconds == 0)
               DispatchQueue.main.async {
                    self.stopTimerLabel()
               }
          }
     }
     
     @objc func update() {
          stopTimerLabel()
          bool = false
          tableView.reloadData() // Отображение данных.
                                 // override func numberOfSections(in tableView: UITableView) -> Int
                                 // override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
                                 // override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
          setLoadingScreen()
          loadData()
     }
     
     private func stopTimerLabel() {
          self.timerLabel.title = ""
          self.timer.invalidate()
     }
}

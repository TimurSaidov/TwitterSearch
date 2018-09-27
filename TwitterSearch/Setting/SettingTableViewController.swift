//
//  SettingTableViewController.swift
//  TwitterSearch
//
//  Created by Timur Saidov on 21.08.2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit
import CoreData

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var settingSwitch: UISwitch!
    @IBOutlet weak var settingImage: UIImageView!
    
    var show: [Avatar]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = attributes
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.persistentContainer.viewContext {
            let fetchRequest: NSFetchRequest<Avatar> = Avatar.fetchRequest()
            do {
                show = try context.fetch(fetchRequest)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        settingImage.layer.cornerRadius = 20.0
        settingImage.clipsToBounds = true
        settingImage.layer.borderWidth = 1
        settingImage.layer.borderColor = UIColor.gray.cgColor
        
        guard let show = show else { return }
        if show.isEmpty {
            settingSwitch.setOn(true, animated: false)
        } else {
            settingSwitch.setOn(false, animated: false)
        }
        
        self.settingSwitch.addTarget(self, action: #selector(action(sender:)), for: .valueChanged)
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    // Метод при переключении Switch.
    @objc func action(sender: UISwitch) {
        if sender.isOn == true { // Switch ON.
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.persistentContainer.viewContext {
                
                // Обновление массива из CoreData.
                let fetchRequest: NSFetchRequest<Avatar> = Avatar.fetchRequest()
                do {
                    show = try context.fetch(fetchRequest)
                } catch {
                    print(error.localizedDescription)
                }
                guard let show = show else { return }
                let showDelete = show[show.count - 1]
                context.delete(showDelete)
                do {
                    try context.save()
                    print("Удаление получилось! Switch включен.")
                    print("Массив show, загруженный из CoreData: Число - \(show.count)") // Массив после удаление не обновляется, для этого необходимо его обновление.
                } catch let error as NSError {
                    print("Не удалось сохранить данные: \(error), \(error.userInfo)")
                }
                
                
            }
        } else { // Switch OFF.
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.coreDataStack.persistentContainer.viewContext {
                let newShow = Avatar(context: context)
                newShow.show = false
                guard let show = show else { return }
                do {
                    try context.save()
                    print("Сохранение удалось! Switch выключен.")
                    for i in 0..<show.count {
                        print("Массив show, загруженный из CoreData: Число - \(show.count), элементы - \(show[i].show)")
                    }
                } catch let error as NSError {
                    print("Не удалось сохранить данные: \(error), \(error.userInfo)")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

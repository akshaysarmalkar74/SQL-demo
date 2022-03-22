//
//  ViewController.swift
//  SQL-Demo
//
//  Created by Neosoft on 22/03/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var db = DBManager()
    var peoples = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // Get All Data
        fetchData()
    }

    @IBAction func addNewBtnTapped(_ sender: UIBarButtonItem) {
        // Display Alert with 2 textfields
        let alertVc = UIAlertController(title: "Add New Person", message: nil, preferredStyle: .alert)
        
        // Add TextFields
        alertVc.addTextField(configurationHandler: nil)
        alertVc.addTextField(configurationHandler: nil)
        
        // Customise TextField
        alertVc.textFields?[0].keyboardType = .numberPad
        alertVc.textFields?[0].placeholder = "Id"
        alertVc.textFields?[1].placeholder = "Name"
        
        let submitBtn = UIAlertAction(title: "Submit", style: .default) { [weak self]  _ in
            guard let id = Int(alertVc.textFields?[0].text ?? ""), let name = alertVc.textFields?[1].text else {
                print("Some Invalid data")
                return
            }
            
            self?.db.insert(id: id, name: name)
            self?.fetchData()
            self?.dismiss(animated: true, completion: nil)
        }
        
        alertVc.addAction(submitBtn)
        self.present(alertVc, animated: true, completion: nil)
    }
    
    func fetchData() {
        peoples = db.read()
        tableView.reloadData()
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peoples.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath) as! PersonCell
        let person = peoples[indexPath.row]
        
        // Configure Cell
        cell.idLabel.text = "\(person.id)"
        cell.nameLabel.text = person.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
            if let personId = self?.peoples[indexPath.row].id {
                self?.db.deleteByID(id: personId)
                self?.fetchData()
            } else {
                print("Some Error")
            }
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
}

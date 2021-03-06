//
//  CarsTableViewController.swift
//  Cars
//
//  Created by Usuário Convidado on 27/03/17.
//  Copyright © 2017 Usuário Convidado. All rights reserved.
//

import UIKit

class CarsTableViewController: UITableViewController {
    
    var dataSource: [Car] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadCars()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "edit" {
            let vc = segue.destination as! ViewController
            vc.car = dataSource[tableView.indexPathForSelectedRow!.row]
        }
    }
    
    func loadCars() {
        REST.loadCars { (cars: [Car]?) in
            if let cars = cars {
                // Existe
                self.dataSource = cars
                
                DispatchQueue.main.async {
                    self.tableView.reloadData() // cause it's async || ATENÇÃO!!!! não podemos alterar um elemento visual a nao ser na main thread
                }
            }
        }
    }

    // MARK: - Table view data source

    // Se não houver o método abaixo por default é 1
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let car = dataSource[indexPath.row]
        cell.textLabel?.text = car.name
        cell.detailTextLabel?.text = "\(car.price)"

        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let car = dataSource[indexPath.row]
            REST.deleteCar(car: car, onComplete: { (success: Bool) in
                DispatchQueue.main.async {
                    self.dataSource.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            })
        }
    }
}

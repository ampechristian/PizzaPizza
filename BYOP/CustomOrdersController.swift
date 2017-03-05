//
//  CustomOrdersController.swift
//  BYOP
//
//  Created by Ampe on 3/4/17.
//  Copyright © 2017 Ampe. All rights reserved.
//

import UIKit
import CoreData

class CustomOrdersController: UITableViewController {

    private let appDelegate = UIApplication.shared.delegate as! AppDelegate

    private var customOrders = [Pizza]() {
        didSet {
            tableView.reloadData()
        }
    }

    private func setUp() {
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        fetchCustomOrders()
    }

    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return customOrders.count
    }

    // Normally I Would Abstract The Cell Update To The UITableViewCell Class and simply pass batches of the model
    // Because we are working with single entries I decided against this pattern
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customordercell", for: indexPath) as! CustomOrdersCell
        let toppings = customOrders[indexPath.row].topping?.allObjects as! [Topping]
        let favorites = customOrders[indexPath.row].favorite
        var toppingString = [String]()
        for topping in toppings {
            toppingString.append(topping.name!)
        }
        cell.countLabel.text = "\(indexPath.row + 1)."
        cell.toppingsLabel?.text = toppingString.joined(separator: ", ")
        if favorites {
            cell.favoritedLabel?.text = "🍕"
        }
        else {
            cell.favoritedLabel?.text = ""
        }
        return cell
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateFavorite(indexPath: indexPath)
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updateFavorite(indexPath: indexPath)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        let context = appDelegate.persistentContainer.viewContext

        if editingStyle == .delete {
            let order = customOrders[indexPath.row]
            context.delete(order)
            do {
                try context.save()
                customOrders = try context.fetch(Pizza.fetchRequest())
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }

    // MARK: - Fetch From Core Data
    private func fetchCustomOrders() {
        let context = appDelegate.persistentContainer.viewContext
        do {
            customOrders = try context.fetch(Pizza.fetchRequest())
        } catch {
            print("Something Went Wrong")
        }
    }

    private func updateFavorite(indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CustomOrdersCell
        let order = customOrders[indexPath.row]
        let label = cell.favoritedLabel?.text
        if label == "" {
            cell.favoritedLabel?.text = "🍕"
            modifyData(data: order, value: true)
        }
        if label == "🍕" {
            cell.favoritedLabel?.text = ""
            modifyData(data: order, value: false)
        }
    }

    // MARK: - Update Core Data
    private func modifyData(data: Pizza, value: Bool) {
        let context = appDelegate.persistentContainer.viewContext
        data.favorite = value
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }


}

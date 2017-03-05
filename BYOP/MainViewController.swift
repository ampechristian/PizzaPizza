//
//  MainViewController.swift
//
//  Created by Ampe on 3/4/17.
//  Copyright © 2017 Ampe. All rights reserved.
//

// Go To Settings To Change The Number of Toppings In Chart

// Note: JSON Is Parsed & Data Manipulated On Each Launch & Not Persisted (I Would Normally Persist, But It Wasn't Stated To Do So)
// Note: I Manipulate Two Sets of Arrays
// First: The Assignmnet Asked To Sort For Most Common Topping Combo
// Second: I Did This More As A Fun Exercise; However, I Sorted By The Most Common Individual Toppings (More Usefully To Pizza Companies)
// --> This Result Was Used To Suggest Custom Toppings For Custom Orders

import UIKit
import SideMenu

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    // Restricting To Top 200 Toppings -> Can be changed in storyboard
    @IBOutlet weak var slider: UISlider!

    fileprivate var numOfItems = 20 {
        didSet {
            tableView.reloadData()
        }
    }

    private var top = [String]() {
        didSet {
            self.sort = hash(arr: top)
        }
    }

    private var common = [String]() {
        didSet {
            self.mostUsed = hash(arr: common)
        }
    }

    // Topping Combos
    fileprivate var sort = [(key: String, value: Int)]() {
        didSet {
            tableView.reloadData()
        }
    }

    // Individual Topping
    private var mostUsed = [(key: String, value: Int)]() {
        didSet {
            var arr = [String]()
            for a in mostUsed {
                let b = a.key
                arr.append(b)
            }
            Var.mostOften = arr
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSideMenu()
        readJson()
        tableView.estimatedRowHeight = 40.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    private func setupSideMenu() {
        SideMenuManager.menuPushStyle = .popWhenPossible
        SideMenuManager.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
    }

    // MARK: - Read JSON From File
    private func readJson() {
        do {
            if let file = Bundle.main.url(forResource: "Toppings", withExtension: "json") {
                var toppings = [String]()
                var ing = [String]()
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [[String: Any]] {
                    // Break Down Into Individual Dictionaries
                    for obj in object {
                        // Break Down Into Individual Arrays of Ingredients
                        if let topping = obj["toppings"] as? [String] {
                            // For Most Common Topping Combo: Sort Individual Arrays Alphabetically
                            let sortedArray = topping.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
                            // For Most Common Topping Combo: Turn Array of String Into a Single String
                            let string = sortedArray.joined(separator: ", ")
                            toppings.append(string)
                            // For Most Common Ingredient Used: (This Will Be Used For Suggestions On "Custom Orders")
                            // Take Each Sub Element and Append It To An Array of Strings (i.e. [[String]] -> [String]) reducing 2D array to 1D
                            for ingredient in topping {
                                ing.append(ingredient)
                            }
                        }
                    }
                    // Set Variables To Be Hashed
                    self.common = ing
                    self.top = toppings
                }
                else {
                    print("JSON is invalid")
                }
            }
            else {
                print("no file")
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }

    // Places Strings in a Hashtable & Counts Number of Occurences
    private func hash(arr: [String]) -> [(key: String, value: Int)] {
        var counts:[String:Int] = [:]
        for item in arr {
            counts[item] = (counts[item] ?? 0) + 1
        }
        // Call Dictionary Extension to Sort By Dictionary Value
        return counts.keysSortedByValue(isOrderedBefore: >)
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        numOfItems = Int(sender.value)
    }

}

// MARK: -  Data Source
extension MainViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numOfItems
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rankingcell", for: indexPath) as! RankingCell
        cell.countingLabel.text = "\(indexPath.row + 1)."
        cell.rankingLabel.text = "\(sort[indexPath.row].key)"
        cell.occurencesLabel.text = "\(sort[indexPath.row].value)"
        return cell
    }

}

extension Dictionary {

    func keysSortedByValue(isOrderedBefore:(Value, Value) -> Bool) -> [(key: Key, value: Value)] {
        return Array(self)
            .sorted() {
                let (_, lv) = $0
                let (_, rv) = $1
                return isOrderedBefore(lv, rv)
            }
            .map {
                let (k, v) = $0
                return (key: k, value: v)
        }
    }
}

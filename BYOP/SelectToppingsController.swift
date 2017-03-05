//
//  SelectToppingsController.swift
//  TutorStoryboard
//
//  Created by Ampe on 3/5/17.
//  Copyright © 2017 Ampe. All rights reserved.
//

import UIKit

class SelectToppingsController: UIViewController {

    private let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var selectedLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!

    var searchActive: Bool = false
    var passedSub: [String] = Var.mostOften
    var subjects: [String] = Var.mostOften
    var filtered: [String] = Var.mostOften
    var selected: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func configureCheckmarkForCell(cell: ToppingsCell, object: String) {
        let label: UILabel = cell.selectedLabel
        if (selected.contains(object)) {
            selectedLabel.text = selected.joined(separator: ", ")
            label.text = "√"
            label.backgroundColor = UIColor.red
            label.layer.borderWidth = 0
        }

        else {
            selectedLabel.text = selected.joined(separator: ", ")
            label.text = ""
            label.backgroundColor = UIColor.clear
            label.layer.borderWidth = 1
        }
    }

    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration, delay: TimeInterval(0), options: animationCurve, animations: { self.view.layoutIfNeeded() }, completion: nil)
        }
    }

    @IBAction func continueButtonPressed(_ sender: Any) {
        if !selected.isEmpty {
            writeToCoreData()
        }
        else {
            dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func cancelButtonPressed(_ sender: Any) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    private func writeToCoreData() {
        let context = appDelegate.persistentContainer.viewContext
        let pizza = Pizza(context: context)
        var array = [Topping]()
        for aTopping in selected {
            let topping = Topping(context: context)
            topping.name = aTopping
            array.append(topping)
        }
        pizza.favorite = false
        pizza.topping = NSSet(array: array)
        do {
            try context.save()
            searchBar.resignFirstResponder()
            dismiss(animated: true, completion: nil)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

}

extension SelectToppingsController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toppingscell", for: indexPath) as! ToppingsCell
        let string = filtered[indexPath.row]
        cell.subjectLabel!.text = string
        configureCheckmarkForCell(cell: cell, object: string)
        return cell
    }

}

extension SelectToppingsController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath) as! ToppingsCell
        let label: UILabel = cell.selectedLabel
        let string = filtered[indexPath.row]

        selected.append(string)
        selectedLabel.text = selected.joined(separator: ", ")

        label.text = "√"
        label.backgroundColor = UIColor.red
        label.layer.borderWidth = 0

    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        let cell = tableView.cellForRow(at: indexPath) as! ToppingsCell
        let label: UILabel = cell.selectedLabel
        let string = filtered[indexPath.row]

        selected = selected.filter{$0 != string}
        selectedLabel.text = selected.joined(separator: ", ")

        label.text = ""
        label.backgroundColor = UIColor.clear
        label.layer.borderWidth = 1

    }

}

extension SelectToppingsController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = searchText.isEmpty ? subjects : subjects.filter({(dataString: String) -> Bool in
            return dataString.range(of: searchText, options: .caseInsensitive) != nil
        })
        tableView.reloadData()
    }

}

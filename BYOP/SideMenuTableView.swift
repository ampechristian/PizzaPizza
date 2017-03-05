//
//  SideMenuTableView.swift
//  SideMenu
//
//  Created by Ampe on 3/4/17.
//  Copyright © 2017 Ampe. All rights reserved.
//

import Foundation
import SideMenu

class SideMenuTableView: UITableViewController {

    private let titles = [" ★    Popular Toppings", " ♥    My Toppings"]
    private let main = UIStoryboard(name: "Main", bundle: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menucell", for: indexPath) as! UITableViewVibrantCell
        cell.textLabel?.text = titles[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let jsonVC = main.instantiateViewController(withIdentifier: "json") as? MainViewController {
                show(jsonVC, sender: nil)
            }
        }
        if indexPath.row == 1 {
            if let customVC = main.instantiateViewController(withIdentifier: "customorders") as? CustomOrdersController {
                show(customVC, sender: nil)
            }
        }
    }
}

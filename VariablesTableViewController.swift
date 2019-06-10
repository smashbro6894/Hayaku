//
//  VariablesTableViewController.swift
//  Hayaku
//
//  Created by Patrick O'brien on 5/16/19.
//  Copyright © 2019 Patrick O'Brien. All rights reserved.
//

import UIKit

class VariablesTableViewController: UITableViewController {
    
    var leaderboardUrlString = "http://speedrun.com/api/v1/leaderboards/"
    var gameId: String?
    var categoryId : String?
    var variables = [Variable]()
    var variableURL: String?
    var keysForChoices = [[String]]()
    var choices = [[Choices]]()
    var game : Game?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Options"
        
        let leaderboardsBarButton = UIBarButtonItem(title: "Go!", style: .done, target: self, action: #selector(leaderboardsButtonPressed))
        self.navigationItem.rightBarButtonItem = leaderboardsBarButton
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        if let variableUrl = variableURL {
            guard let url = URL(string: variableUrl) else { return }
            
            let dataTask = URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                guard let data = data else { return }
                
                let variablesData = try? JSONDecoder().decode(VariablesResponse.self, from: data)
                DispatchQueue.main.async {
                    
                    if let variables = variablesData?.data {
                        self.variables = variables
                        for (index, variable) in variables.enumerated() {
                            if variable.isSubcategory == true {
                                
                                var choices = [Choices]()
                                var keys = [String]()
                                for key in variable.values.values.keys {
                                    
                                    keys.append("var-\(variable.id)=\(key)")
                                    choices.append(variable.values.values[key]!)
                                }
                                self.keysForChoices.append(keys)
                                self.choices.append(choices)
                            } else if variable.isSubcategory == false {
                                self.variables.remove(at: index)
                            }

                        }
                        self.tableView.reloadData()
                    }

                }
                
            }
            dataTask.resume()

        }

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if variables.count == 0 {
            return 1
        }
        return variables.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if variables.count == 0 {
            return 1
        }
        return variables[section].values.values.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        let cell = tableView.dequeueReusableCell(withIdentifier: "VariableCell", for: indexPath)
        if indexPath.row == 0 {
            cell.accessoryType = .checkmark
        }
        if variables.count == 0 {
            cell.textLabel?.text = "No options available! Press Go!"
            cell.accessoryType = .none

        } else {
            cell.textLabel?.text = choices[indexPath.section][indexPath.row].label

        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if variables.count == 0 {
            return "No options"
        }
        return variables[section].name
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if variables.count != 0 {
            if let tappedCell = tableView.cellForRow(at: indexPath) {
                let cells = tableView.visibleCells
                for cell in cells {
                    let cellIndexPath = tableView.indexPath(for: cell)
                    if cellIndexPath?.section == indexPath.section {
                        cell.accessoryType = .none
                    }
                    tappedCell.accessoryType = .checkmark
                }
                
            }
        }


    }
    
    
    @objc func leaderboardsButtonPressed() {
        let cells = tableView.visibleCells
        var runInformation = ""
        leaderboardUrlString += "\(gameId!)/category/\(categoryId!)?"
        
        for cell in cells {
            if cell.accessoryType == .checkmark {
                if let indexPath = tableView.indexPath(for: cell) {
                    runInformation += "| \(choices[indexPath.section][indexPath.row].label) |"
                    leaderboardUrlString += "\(keysForChoices[indexPath.section][indexPath.row])&"
                }
            }
        }
        leaderboardUrlString += "embed=players"
        
        
        let leaderboardsView = storyboard?.instantiateViewController(withIdentifier: "LeaderboardsView") as! LeaderboardsTableViewController
        leaderboardsView.leaderboardUrlString = leaderboardUrlString
        leaderboardsView.runInformation = runInformation
        print(leaderboardUrlString)
        leaderboardsView.game = self.game
        self.navigationController?.pushViewController(leaderboardsView, animated: true)
        leaderboardUrlString = "http://speedrun.com/api/v1/leaderboards/"

    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
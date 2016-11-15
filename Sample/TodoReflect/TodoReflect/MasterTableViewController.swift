//
//  MasterTableViewController.swift
//  TodoReflect
//
//  Created by Bruno Fernandes on 04/04/16.
//  Copyright © 2016 BFS. All rights reserved.
//


import UIKit

class MasterTableViewController: UITableViewController {
    
    let viewModel = ListViewModel()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        
        let item = viewModel.items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.amount

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.removePayback(indexPath.row)
            refresh()
        }
    }
    
    // MARK: - IBActions
    
    func refresh() {
        viewModel.refresh()
        tableView.reloadData()
    }
    
    // MARK: - Navigation 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DetailViewController
        if segue.identifier == "createSegue" {
            vc.viewModel = DetailViewModel(delegate: vc)
        }
        else if segue.identifier == "editSegue" {
            vc.viewModel = DetailViewModel(delegate: vc, index: tableView.indexPathForSelectedRow!.row)
        }
        
    }
    
}

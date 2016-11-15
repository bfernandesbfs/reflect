//
//  DetailViewController.swift
//  TodoReflect
//
//  Created by Bruno Fernandes on 04/04/16.
//  Copyright © 2016 BFS. All rights reserved.
//


import UIKit

class DetailViewController: UIViewController, DetailViewModelDelegate {
    
    var viewModel: DetailViewModel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = viewModel.title
        nameField.text = viewModel.name
        amountField.text = viewModel.amount
        nameField.becomeFirstResponder()
        
        nameField.addTarget(self, action: #selector(DetailViewController.nameChanged), for: UIControlEvents.editingChanged)
        amountField.addTarget(self, action: #selector(DetailViewController.ammountChanged), for: UIControlEvents.editingChanged)
    }
    
    func nameChanged() {
        viewModel.name = nameField.text!
        resultLabel.text = viewModel.infoText
    }
    
    func ammountChanged() {
        viewModel.amount = amountField.text!
        resultLabel.text = viewModel.infoText
    }
    
    
    // MARK: - AddViewModelDelegate
    
    func showInvalidName() {
        alert(message: "Invalid name")
        nameField.becomeFirstResponder()
    }
    
    func showInvalidAmount() {
        alert(message: "Invalid amount")
        amountField.becomeFirstResponder()
    }
    
    func dismissAddView() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func alert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    
    // MARK: - IBActions
    
    @IBAction func cancelPressed(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func donePressed(_ sender: AnyObject) {
        viewModel.handleDonePressed()
    }

}

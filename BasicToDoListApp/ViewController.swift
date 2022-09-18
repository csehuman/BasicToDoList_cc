//
//  ViewController.swift
//  BasicToDoListApp
//
//  Created by Paul Lee on 2022/09/18.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    
    var doneButton: UIBarButtonItem?
    
    var tasks = [Task]() {
        didSet {
            saveTasks()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapDoneButton))
        
        loadTasks()
    }
    
    @objc func tapDoneButton() {
        print("here")
        navigationItem.leftBarButtonItem = editButton
        tableView.setEditing(false, animated: true)
    }
    
    @IBAction func tapAddButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "할 일 등록", message: nil, preferredStyle: .alert)
        let addAction = UIAlertAction(title: "등록", style: .default) { [weak self] _ in
            guard let title = alert.textFields?[0].text else { return }
            let newTask = Task(title: title, done: false)
            self?.tasks.append(newTask)
            self?.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in
            textField.placeholder = "할 일을 입력해주세요."
        }
        
        present(alert, animated: true)
    }
    
    @IBAction func tapEditButton(_ sender: UIBarButtonItem) {
        guard !tasks.isEmpty else { return }
        navigationItem.leftBarButtonItem = doneButton
        tableView.setEditing(true, animated: true)
    }
    
    func loadTasks() {
        let userDefaults = UserDefaults.standard
        guard let tasksDict = userDefaults.object(forKey: "tasks") as? [[String: Any]] else { return }
        tasks = tasksDict.compactMap({
            guard let title = $0["title"] as? String else { return nil }
            guard let done = $0["done"] as? Bool else { return nil }
            return Task(title: title, done: done)
        })
    }
    
    func saveTasks() {
        let userDefaults = UserDefaults.standard
        let tasksDict = tasks.map {
            ["title": $0.title, "done": $0.done]
        }
        userDefaults.set(tasksDict, forKey: "tasks")
    }
}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let task = tasks[indexPath.row]
        
        cell.textLabel?.text = task.title
        cell.accessoryType = task.done ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var newTasks = tasks
        let task = newTasks[sourceIndexPath.row]
        newTasks.remove(at: sourceIndexPath.row)
        newTasks.insert(task, at: destinationIndexPath.row)
        tasks = newTasks
        
//        let task = tasks[sourceIndexPath.row]
//        tasks.remove(at: sourceIndexPath.row)
//        tasks.insert(task, at: destinationIndexPath.row)
    }
}


extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        if tasks.isEmpty {
            DispatchQueue.main.async {
                self.tapDoneButton()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = tasks[indexPath.row]
        task.done = !task.done
        tasks[indexPath.row] = task
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

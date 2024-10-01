//
//  ViewController.swift
//  TaskListApp
//
//  Created by Alexey Efimov on 11.02.2024.
//

import UIKit
import CoreData

final class TaskListViewController: UITableViewController {
    // MARK: - Private Properties
    private var taskList: [ToDoTask] = []
    private let cellID = "task"
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        fetchData()
    }
    
    // MARK: - Private Methods
    @objc private func addNewTask() {
        showAlert(withTitle: "New Task", andMessage: "What do you want to do?")
    }
    
    private func deleteTask(at indexPath: IndexPath) {
        let taskToRemove = taskList[indexPath.row]
        StorageManager.shared.persistentContainer.viewContext.delete(taskToRemove)
        
        taskList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        StorageManager.shared.saveContext()
    }
    
    private func fetchData() {
            let context = StorageManager.shared.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<ToDoTask> = ToDoTask.fetchRequest()
            
            do {
               taskList = try context.fetch(fetchRequest)
               tableView.reloadData()
            } catch {
                print("Failed to fetch data:", error)
            }
        }
    
    private func showAlert(
        withTitle title: String,
        andMessage message: String,
        task: ToDoTask? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(
            title: task == nil ? "Add" : "Update",
            style: .default
        ) { [weak self] _ in
            guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else {
                return
            }
            if let task = task {
                self?.update(task, withTitle: taskName)
            } else {
                self?.save(taskName)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "Task Name"
            textField.text = task?.title
        }
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        let storageManager = StorageManager.shared
        let task = ToDoTask(context: storageManager.persistentContainer.viewContext)
        task.title = taskName
        taskList.append(task)
        
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        storageManager.saveContext()
    }
    
    private func update(_ task: ToDoTask, withTitle newTitle: String) {
            task.title = newTitle
            if let index = taskList.firstIndex(of: task) {
                let indexPath = IndexPath(row: index, section: 0)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            StorageManager.shared.saveContext()
        }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        taskList.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let toDoTask = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = toDoTask.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let task = taskList[indexPath.row]
        showAlert(withTitle: "Update Task", andMessage: "What do you want to do?", task: task)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteTask(at: indexPath)
        }
    }
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.backgroundColor = .milkBlue
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
}


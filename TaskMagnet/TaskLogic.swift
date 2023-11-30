//
//  TaskLogic.swift
//  TaskMagnet
//
//  Created by Armin Halilovic on 28.11.2023.
//

import Foundation
import SwiftUI
import FirebaseFirestore

func addTask(_ task: Task, for userID: String) {
	let db = Firestore.firestore()
	var ref: DocumentReference? = nil
	ref = db.collection("users").document(userID).collection("tasks").addDocument(data: [
		"title": task.title,
		"isComplete": task.isComplete,
		"dueDate": task.dueDate ?? NSNull()
	]) { err in
		if let err = err {
			print("Error adding task: \(err)")
		} else {
			print("Task added with ID: \(ref!.documentID)")
		}
	}
}

func removeTask(_ taskID: String, for userID: String) {
	let db = Firestore.firestore()
	db.collection("users").document(userID).collection("tasks").document(taskID).delete() { err in
		if let err = err {
			print("Error removing task: \(err)")
		} else {
			print("Task successfully removed!")
		}
		
	}
}

func updateTask(_ task: Task, for userID: String) {
	guard let taskFirestoreID = task.firestoreID else { return }
	let db = Firestore.firestore()
	db.collection("users").document(userID).collection("tasks").document(taskFirestoreID).setData([
		"title": task.title,
		"isComplete": task.isComplete,
		"dueDate": task.dueDate ?? NSNull()
	]) { err in
		if let err = err {
			print("Error updating task: \(err)")
		} else {
			print("Task successfully updated!")
		}
	}
}


func toggleTaskCompleted(at index: Int, in tasks: inout [Task]) {
	tasks[index].isComplete.toggle()
	saveTasks(tasks)
}

func saveTasks(_ tasks: [Task]) {
	do {
		let encoded = try JSONEncoder().encode(tasks)
		UserDefaults.standard.set(encoded, forKey: "tasks")
	} catch {
		print("Error while saving tasks: \(error)")
	}
}

func loadTasks(for userID: String, completion: @escaping ([Task]) -> Void) {
	let db = Firestore.firestore()
	db.collection("users").document(userID).collection("tasks").getDocuments() { (querySnapshot, err) in
		var tasks: [Task] = []
		if let err = err {
			print("Error getting tasks: \(err)")
		} else {
			for document in querySnapshot!.documents {
				let data = document.data()
				let title = data["title"] as? String ?? ""
				let isComplete = data["isComplete"] as? Bool ?? false
				let firestoreID = document.documentID
				// Handle dueDate if necessary
				let task = Task(firestoreID: firestoreID, title: title, isComplete: isComplete, dueDate: nil)
				tasks.append(task)
			}
		}
		completion(tasks)
	}
}


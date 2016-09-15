//
//  ViewController.swift
//  DreamLister
//
//  Created by Mikko Hilpinen on 12.9.2016.
//  Copyright © 2016 Mikko Hilpinen. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate
{
	@IBOutlet weak var itemSegment: UISegmentedControl!
	@IBOutlet weak var itemTableView: UITableView!

	var controller: NSFetchedResultsController<Item>!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		itemTableView.delegate = self
		itemTableView.dataSource = self
		
		//generateTestData()
		//generateTestTypes()
		attemptFetch()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let cell = itemTableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
		configureCell(cell: cell, at: indexPath)
		return cell
	}
	
	private func configureCell(cell: ItemCell, at indexPath: IndexPath)
	{
		let item  = controller.object(at: indexPath)
		cell.configureCell(item: item)
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		if let sections = controller.sections
		{
			let sectionInfo = sections[section]
			return sectionInfo.numberOfObjects
		}
		else
		{
			return 0
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int
	{
		if let sections = controller.sections
		{
			return sections.count
		}
		
		return 0
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return 150 // ...
	}
	
	// These do not belong here, btw. This view handler is doing too much stuff
	
	func attemptFetch()
	{
		let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
		
		var sorter: NSSortDescriptor!
		
		// TODO: Using indices is not readable at all (tutorial though)
		switch (itemSegment.selectedSegmentIndex)
		{
		case 0: sorter = NSSortDescriptor(key: "created", ascending: false)
		case 1: sorter = NSSortDescriptor(key: "price", ascending: true)
		case 2: sorter = NSSortDescriptor(key: "title", ascending: true)
		default: sorter = NSSortDescriptor(key: "toItemType", ascending: true)
		}
		
		fetchRequest.sortDescriptors = [sorter]
		
		controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
		controller.delegate = self
		
		do
		{
			try controller.performFetch()
		}
		catch
		{
			print("\(error)")
		}
	}
	
	@IBAction func segmentChanged(_ sender: AnyObject)
	{
		attemptFetch()
		itemTableView.reloadData()
	}
	
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
	{
		itemTableView.beginUpdates()
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
	{
		itemTableView.endUpdates()
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		// This is not very safe? Displayed items should be managed outside the fetch results
		// since a new request may be done at any time?
		if let objects = controller.fetchedObjects, !objects.isEmpty
		{
			let item = objects[indexPath.row]
			performSegue(withIdentifier: "ItemDetailsVC", sender: item)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if segue.identifier == "ItemDetailsVC"
		{
			if let destination = segue.destination as? ItemDetailsVC
			{
				if let item = sender as? Item
				{
					destination.itemToEdit = item
				}
				else
				{
					destination.itemToEdit = nil
				}
			}
		}
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
	{
			switch (type)
			{
			case .insert:
				if let newIndexPath = newIndexPath
				{
					itemTableView.insertRows(at: [newIndexPath], with: .fade)
				}
			case .delete:
				if let indexPath = indexPath
				{
					itemTableView.deleteRows(at: [indexPath], with: .fade)
				}
			case .update:
				if let indexPath = indexPath
				{
					// Updates the cell at the index
					let cell = itemTableView.cellForRow(at: indexPath) as! ItemCell
					configureCell(cell: cell, at: indexPath)
				}
			case .move:
				if let indexPath = indexPath, let newIndexPath = newIndexPath
				{
					itemTableView.deleteRows(at: [indexPath], with: .fade)
					itemTableView.insertRows(at: [newIndexPath], with: .fade)
				}
		}
	}
	
	func generateTestData()
	{
		for i in 0...5
		{
			let item = Item(context: context)
			item.title = "Test title \(i)"
			item.price = 140000.0
			item.details = "Something very awesome. Especially in test conditions."
		}
		
		ad.saveContext()
	}
	
	func generateTestTypes()
	{
		let typeNames = ["Thing", "Act", "Habit", "Lesson", "Experience"]
		for typeName in typeNames
		{
			let itemType = ItemType(context: context)
			itemType.type = typeName
		}
		
		ad.saveContext()
	}
}


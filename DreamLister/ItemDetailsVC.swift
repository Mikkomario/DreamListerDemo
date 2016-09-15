//
//  ItemDetailsVC.swift
//  DreamLister
//
//  Created by Mikko Hilpinen on 13.9.2016.
//  Copyright © 2016 Mikko Hilpinen. All rights reserved.
//

import UIKit
import CoreData

class ItemDetailsVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	@IBOutlet weak var titleField: UITextField!
	@IBOutlet weak var priceField: UITextField!
	@IBOutlet weak var storeTypePicker: UIPickerView!
	@IBOutlet weak var detailsField: UITextView!
	@IBOutlet weak var tumbImageView: UIImageView!
	
	var stores = [Store]()
	var types = [ItemType]()
	var itemToEdit: Item?
	var imagePicker: UIImagePickerController!
	
    override func viewDidLoad()
	{
        super.viewDidLoad()

		if let topItem = self.navigationController?.navigationBar.topItem
		{
			topItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
		}
		
		//generateTestStores()
		
		storeTypePicker.dataSource = self
		storeTypePicker.delegate = self
		
		imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		
		getStores()
		getTypes() // WET WET
		
		if let item = itemToEdit
		{
			loadItemData(item)
		}
    }
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
	{
		if component == 0
		{
			return stores[row].name
		}
		else
		{
			return types[row].type
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
	{
		if component == 0
		{
			return stores.count
		}
		else
		{
			return types.count
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
	{
		// TODO: React somehow
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int
	{
		return 2
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
	{
		// Remember the magic key...
		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
		{
			tumbImageView.image = image
		}
		
		imagePicker.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func savePressed(_ sender: AnyObject)
	{
		var item: Item!
		
		if itemToEdit == nil
		{
			item = Item(context: context)
		}
		else
		{
			item = itemToEdit
		}
			
			
		// TODO: Add checks later
		if let title = titleField.text
		{
			item.title = title
		}
		if let price = priceField.text
		{
			item.price = (price as NSString).doubleValue
		}
		if let details = detailsField.text
		{
			item.details = details
		}
		
		// This is what happens when you use stupid connection names
		item.toStore = stores[storeTypePicker.selectedRow(inComponent: 0)]
		item.toItemType = types[storeTypePicker.selectedRow(inComponent: 1)]
		
		// Adds image to the item
		let picture = Image(context: context) // This should use existing images, however
		picture.image = tumbImageView.image
		item.toImage = picture
		
		ad.saveContext()
		
		// TODO: Some buble gum fix for a warning. Find out how to really do this
		_ = navigationController?.popViewController(animated: true)
		
	}
	
	@IBAction func deletePressed(_ sender: AnyObject)
	{
		if let item = itemToEdit
		{
			context.delete(item)
			ad.saveContext()
		}
		
		_ = navigationController?.popViewController(animated: true)
	}
	
	@IBAction func addImagePressed(_ sender: AnyObject)
	{
		present(imagePicker, animated: true, completion: nil)
	}
	
	private func loadItemData(_ item: Item)
	{
		titleField.text = item.title
		priceField.text = "\(item.price)"
		detailsField.text = item.details
		
		tumbImageView.image = item.toImage?.image as? UIImage
		
		if let store = item.toStore
		{
			// Finds the store with a matching name
			/*
			if let machingStore = stores.first(where: {$0.name == store.name})
			{
				// TODO: Do something with the matching store
			}*/
			
			// Finds the index of a matching store
			for matchingIndex in 0..<stores.count where stores[matchingIndex].name == store.name
			{
				storeTypePicker.selectRow(matchingIndex, inComponent: 0, animated: false)
				break
			}
		}
	}
	
	private func getStores()
	{
		let request: NSFetchRequest<Store> = Store.fetchRequest()
		do
		{
			stores = try context.fetch(request)
			storeTypePicker.reloadAllComponents()
		}
		catch
		{
			print(error)
		}
	}
	
	private func getTypes()
	{
		let request: NSFetchRequest<ItemType> = ItemType.fetchRequest()
		do
		{
			types = try context.fetch(request)
			storeTypePicker.reloadAllComponents()
		}
		catch
		{
			print(error)
		}
	}
	
	private func generateTestStores()
	{
		let storeNames = ["Verkkokauppa.com", "Humble Store", "Amazon", "Udemy"]
		for storeName in storeNames
		{
			let store = Store(context: context)
			store.name = storeName
		}
		
		ad.saveContext()
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

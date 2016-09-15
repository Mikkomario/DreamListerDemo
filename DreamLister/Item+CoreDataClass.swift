//
//  Item+CoreDataClass.swift
//  DreamLister
//
//  Created by Mikko Hilpinen on 12.9.2016.
//  Copyright © 2016 Mikko Hilpinen. All rights reserved.
//

import Foundation
import CoreData


public class Item: NSManagedObject
{
	public override func awakeFromInsert()
	{
		super.awakeFromInsert()
		
		// Sets creation time on insert
		self.created = NSDate()
	}
}

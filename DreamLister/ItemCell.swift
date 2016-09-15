//
//  ItemCell.swift
//  DreamLister
//
//  Created by Mikko Hilpinen on 12.9.2016.
//  Copyright © 2016 Mikko Hilpinen. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell
{
	@IBOutlet weak var thumbnailImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var typeLabel: UILabel!

	func configureCell(item: Item)
	{
		titleLabel.text = item.title
		priceLabel.text = "\(item.price) €"
		descriptionLabel.text = item.details
		thumbnailImageView.image = item.toImage?.image as? UIImage
		typeLabel.text =  item.toItemType?.type
	}
}

//
//  IAPDialogCell.swift
//  IAPKit
//
//  Copyright (c) 2018 Black Pixel.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit


class IAPDialogCell: UICollectionViewCell {
    
    // MARK: Static Properties
    
    static var identifier: String { return String(describing: self) }
    
    
    // MARK: Outlets
    
    @IBOutlet private weak var cellBackground: UIView!
    @IBOutlet private weak var cellBorder: UIView!
    @IBOutlet private weak var cellDescription: UILabel!
    @IBOutlet private weak var cellPrice: UILabel!
    @IBOutlet private weak var cellTitle: UILabel!
    @IBOutlet private weak var titleStackView: UIStackView!
    
    
    // MARK: Constraints

    @IBOutlet private weak var cellDescriptionTopToPriceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var descriptionBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleStackTopConstraint: NSLayoutConstraint!
    
    
    // MARK: Private Constants
    
    fileprivate static let descriptionToPricePaddingRegular = CGFloat(8)
    fileprivate static let descriptionToPricePaddingCompact = CGFloat(2)
    fileprivate static let descriptionBottomPaddingRegular = CGFloat(30.0)
    fileprivate static let descriptionBottomPaddingCompact = CGFloat(20.0)
    fileprivate static let iPhoneLandscapeCellSize = CGSize(width: 375, height: 172)
    fileprivate static let titleStackViewSpacingCompact = CGFloat(10.0)
    fileprivate static let titleStackViewSpacingRegular = CGFloat(12.0)
    fileprivate static let textSidePadding = CGFloat(25.0)
    fileprivate static let titleTopPaddingRegular = CGFloat(28.0)
    fileprivate static let titleTopPaddingCompact = CGFloat(20.0)
    
    
    // MARK: Public Computed Properties
    
    var selectedColor: IAPColor? {
        didSet {
            cellBorder.backgroundColor = selectedColor
        }
    }
    
    
    // MARK: Public Properties
    
    var selectedTitleColor: IAPColor?
    
    
    // MARK: Public Property Overrides
    
    override var isSelected: Bool {
        didSet {
            if !isSelected {
                cellBorder.alpha = 0
                cellTitle.textColor = .labelColor
                
            } else {
                cellBorder.alpha = 1
                
                let titleColor = selectedTitleColor ?? .baseColor
                cellTitle.textColor = titleColor
            }
        }
    }
    
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
}


// MARK: - Class

extension IAPDialogCell {
    
    class func registerNib(withCollectionView collection: UICollectionView) {
        let bundle = Bundle(identifier: "com.blackpixel.IAP-iOS")
        let nib = UINib(nibName: identifier, bundle: bundle)
        collection.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    class func size(forStoreProduct product: StoreProduct, collectionWidth width: CGFloat) -> CGSize {
        let showLandscapeCellSize = UIApplication.isLandscape() && !UIApplication.isIPad()
        let isCompact = UIApplication.shouldShowCompactView
        
        guard !showLandscapeCellSize else { return IAPDialogCell.iPhoneLandscapeCellSize }
        
        let gutter = isCompact ? IAPDialogViewController.gutterPaddingCompact : IAPDialogViewController.gutterPaddingRegular
        let cellWidth = width - (gutter * 2)
        
        let textSize = CGSize(width: cellWidth - (IAPDialogCell.textSidePadding * 2), height: CGFloat.greatestFiniteMagnitude)
        
        let title = NSAttributedString(string: product.skProduct.localizedTitle, attributes: [NSAttributedString.Key.font: UIFont.titleFont])
        let titleHeight = ceil(title.boundingRect(with: textSize, options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).height)
        
        let description = NSAttributedString(string: product.marketingMessage, attributes: [NSAttributedString.Key.font: UIFont.descriptionFont])
        let descriptionHeight = ceil(description.boundingRect(with: textSize, options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).height)
        
        guard isCompact else {
            let cellHeight = IAPDialogCell.titleTopPaddingRegular + titleHeight + IAPDialogCell.descriptionToPricePaddingRegular + descriptionHeight + IAPDialogCell.descriptionBottomPaddingRegular
            return CGSize(width: cellWidth, height: cellHeight)
        }
        
        let price = NSAttributedString(string: product.skProduct.price.stringValue, attributes: [NSAttributedString.Key.font: UIFont.priceFont])
        let priceHeight = ceil(price.boundingRect(with: textSize, options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).height)
        
        let cellHeight = IAPDialogCell.titleTopPaddingRegular + titleHeight + IAPDialogCell.titleStackViewSpacingCompact + priceHeight + IAPDialogCell.descriptionToPricePaddingCompact + descriptionHeight + IAPDialogCell.descriptionBottomPaddingCompact
        return CGSize(width: cellWidth, height: cellHeight)
    }
}


// MARK: - Layout

extension IAPDialogCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateUI()
    }
}


// MARK: - Private

private extension IAPDialogCell {
    
    func setup() {
        styleUI()
    }
    
    func styleUI() {
        backgroundColor = .clear
        clipsToBounds = false
        
        cellBorder.layer.cornerRadius = 14
        cellBorder.layer.masksToBounds = true
        cellBorder.alpha = 0.0
        
        cellBackground.backgroundColor = .white
        cellBackground.layer.cornerRadius = 10.0
        cellBackground.layer.borderColor = UIColor.unselectedColor.cgColor
        cellBackground.layer.borderWidth = 0.5
        cellBackground.layer.shadowColor = UIColor.shadowColor.cgColor
        cellBackground.layer.shadowRadius = 3
        cellBackground.layer.shadowOffset = CGSize(width: 0, height: 2)
        cellBackground.layer.shadowOpacity = 1
        
        cellTitle.font = .titleFont
        cellTitle.textColor = .labelColor
        
        cellPrice.font = .priceFont
        cellPrice.textColor = .labelColor
        
        cellDescription.font = .descriptionFont
        cellDescription.textColor = .labelColor
    }
    
    func updateUI() {
        
        if UIApplication.shouldShowCompactView {
            titleStackView.axis = .vertical
            titleStackView.spacing = IAPDialogCell.titleStackViewSpacingCompact
            titleStackTopConstraint.constant = IAPDialogCell.titleTopPaddingCompact
            
            cellDescriptionTopToPriceConstraint.constant = IAPDialogCell.descriptionToPricePaddingCompact
            descriptionBottomConstraint.constant = IAPDialogCell.descriptionBottomPaddingCompact
            
        } else {
            titleStackView.axis = .horizontal
            titleStackView.spacing = IAPDialogCell.titleStackViewSpacingRegular
            titleStackTopConstraint.constant = IAPDialogCell.titleTopPaddingRegular
            
            cellDescriptionTopToPriceConstraint.constant = IAPDialogCell.descriptionToPricePaddingRegular
            descriptionBottomConstraint.constant = IAPDialogCell.descriptionBottomPaddingRegular
        }
        
        layoutIfNeeded()
    }
}


// MARK: - Public

extension IAPDialogCell {
    
    final func configureCell(withProduct product: StoreProduct, selectedColor: IAPColor, selectedTitleColor: IAPColor) {
        self.selectedColor = selectedColor
        self.selectedTitleColor = selectedTitleColor

        cellTitle.text = product.marketingTitle
        cellDescription.text = product.marketingMessage

        // It's important that we let the StoreKit product dicate how
        // the currency should be displayed
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.skProduct.priceLocale
        let formattedString = formatter.string(from: product.skProduct.price)

        cellPrice.text = formattedString
    }
}


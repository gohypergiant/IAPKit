//
//  IAPDialogViewController.swift
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
import StoreKit

class IAPDialogViewController: IAPViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var buyNowButton: RoundedButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var closeLabelButton: UIButton!
    @IBOutlet weak var footerBackground: UIVisualEffectView!
    @IBOutlet weak var headerBackground: UIVisualEffectView!
    @IBOutlet weak var restoreButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // MARK: Constraints
    
    @IBOutlet weak var buyNowButtonBottomToRestoreConstraint: NSLayoutConstraint!
    @IBOutlet weak var buyNowButtonBottomToViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var restoreButtonBottomToViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var restoreButtonCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var restoreButtonTopToViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var restoreButtonTrailingConstraint: NSLayoutConstraint!
    
    
    // MARK: Private Properties
    
    private var currentProduct: StoreProduct?
    private let collectionViewLayout = UICollectionViewFlowLayout()
    private var accentColor: IAPColor?
    private var selectionColor: IAPColor?
    private var selectedIndex: IndexPath?
    
    
    // MARK: Public Properties
    
    var cancellationHandler: IAPCancellationHandler?
    
    
    // MARK: Public Computed Properties
    
    var products = [StoreProduct]() {
        didSet {
            collectionView.reloadData()
            UIView.animate(withDuration: 0.2) {
                self.activityView.alpha = 0.0
            }
        }
    }
    
    
    // MARK: Static Constants
    
    static let gutterPaddingRegular = CGFloat(60.0)
    static let gutterPaddingCompact = CGFloat(30.0)
    
    
    // MARK: Private Constants
    
    private let headerBackgroundHeightRegular = CGFloat(56)
    private let headerBackgroundHeightCompact = CGFloat(46)
    private let buyNowButtonTopPadding = CGFloat(40)
    
    
    // MARK: Factory
    
    static func make(accentColor: IAPColor, cancellationHandler: IAPCancellationHandler?) -> IAPDialogViewController {
        // The Storyboard is in the framework bundle
        let frameworkBundle = Bundle(for: IAPDialogViewController.self)
        let controller = UIStoryboard(name: "IAPDialog", bundle: frameworkBundle).instantiateInitialViewController() as! IAPDialogViewController
        controller.modalPresentationStyle = .formSheet
        controller.preferredContentSize = CGSize(width: 540, height: 620)
        controller.accentColor = accentColor
        controller.selectionColor = accentColor.withAlphaComponent(0.4)
        controller.cancellationHandler = cancellationHandler
        return controller
    }
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        setupViews()
        
        activityView.alpha = 1.0
        
        updateUI()
    }
}


// MARK: - Layout

extension IAPDialogViewController {
    
    final override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        updateUI()
        collectionView.setContentOffset(.zero, animated: false)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.closeLabelButton.alpha = 0.0
            self.closeButton.alpha = 0.0
            self.collectionView.alpha = 0.0
            self.view.layoutIfNeeded()
        }, completion: { (context) in
            self.updateUI()
            self.view.layoutIfNeeded()
            self.collectionView.selectItem(at: self.selectedIndex, animated: false, scrollPosition: .init(rawValue: 0))
            
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
                self.closeLabelButton.alpha = 1.0
                self.closeButton.alpha = 1.0
                self.collectionView.alpha = 1.0
            }, completion: nil)
        })
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateUI()
    }
}


// MARK: - Private

private extension IAPDialogViewController {
    
    func setDefaultConstraints() {
        restoreButtonTopToViewConstraint.isActive = false
        restoreButtonTrailingConstraint.isActive = false
        restoreButtonCenterXConstraint.isActive = true
        restoreButtonBottomToViewConstraint.isActive = true
        buyNowButtonBottomToViewConstraint.isActive = false
        buyNowButtonBottomToRestoreConstraint.isActive = true
    }
    
    func setupViews() {
        guard let accentColor = self.accentColor else { return }
        
        closeLabelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), for: .normal)
        closeLabelButton.sizeToFit()
        
        IAPDialogCell.registerNib(withCollectionView: collectionView)
        collectionView.clipsToBounds = false
        collectionViewLayout.scrollDirection = .vertical
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        // This needs to be set to true.  Otherwise
        // when a long press is triggered on a cell
        // all cells will be deselected.
        collectionView.allowsMultipleSelection = true
        
        buyNowButton.accentColor = accentColor
        buyNowButton.isEnabled = false
        
        restoreButton.setTitleColor(accentColor, for: .disabled)
        restoreButton.setTitleColor(accentColor, for: .normal)
        restoreButton.setTitle(NSLocalizedString("Restore Purchase", comment: "Title for button that restores previous purchases"), for: .normal)
        
        if let darkerColor = accentColor.darker(by: 0.2) {
            restoreButton.setTitleColor(darkerColor, for: .highlighted)
            restoreButton.setTitleColor(darkerColor, for: .selected)
        }
    }
    
    func showActivityView() {
        UIView.animate(withDuration: 0.2) {
            self.activityView.alpha = 1.0
        }
    }
    
    func updateUI() {

        // Compact Layouts
        if UIApplication.shouldShowCompactView {
            closeButton.isHidden = true
            closeLabelButton.isHidden = false
            
            if UIApplication.isIPad() == false, UIApplication.isLandscape() {
                headerBackground.isHidden = true
                headerHeightConstraint.constant = headerBackgroundHeightCompact
                
                footerBackground.isHidden = true
                
                collectionViewLayout.scrollDirection = .horizontal
                
                buyNowButtonBottomToRestoreConstraint.isActive = false
                buyNowButtonBottomToViewConstraint.isActive = true
                restoreButtonCenterXConstraint.isActive = false
                restoreButtonBottomToViewConstraint.isActive = false
                restoreButtonTopToViewConstraint.isActive = true
                restoreButtonTrailingConstraint.isActive = true
                
            } else {
                headerBackground.isHidden = false
                headerHeightConstraint.constant = headerBackgroundHeightCompact + view.safeAreaInsets.top
                
                footerBackground.isHidden = false
                
                collectionViewLayout.scrollDirection = .vertical
                
                setDefaultConstraints()
            }
            
            collectionViewLayout.invalidateLayout()
        }
        
        // Regular Layouts
        else {
            headerBackground.isHidden = false
            headerHeightConstraint.constant = headerBackgroundHeightRegular
            
            closeButton.isHidden = false
            closeLabelButton.isHidden = true
            
            setDefaultConstraints()
        }
    }
}


// MARK: - Actions

private extension IAPDialogViewController {
    
    @IBAction func buyNow() {
        showActivityView()
        guard let currentProduct = currentProduct  else { return }
        
        let payment = SKPayment(product: currentProduct.skProduct)
        SKPaymentQueue.default().add(payment)
    }
    
    @IBAction func restore() {
        showActivityView()
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    @IBAction func dismiss() {
        cancellationHandler?()
        cancellationHandler = nil
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - UICollectionViewDelegate

extension IAPDialogViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath
        currentProduct = products[indexPath.row]
        
        let storeProduct = products[indexPath.row]
        buyNowButton.setTitle(storeProduct.callToActionButtonText, for: .normal)
        buyNowButton.isEnabled = true
        
        collectionView.indexPathsForSelectedItems?.forEach({
            if $0 != indexPath {
                collectionView.deselectItem(at: $0, animated: true)
            }
        })
    }
}


// MARK: - UICollectionViewDataSource

extension IAPDialogViewController: UICollectionViewDataSource {

    final func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IAPDialogCell.identifier, for: indexPath) as! IAPDialogCell

        let product = products[indexPath.row]
        let selectedColor = self.selectionColor ?? .baseColor
        let selectedTitleColor = self.accentColor ?? .baseColor
        cell.configureCell(withProduct: product, selectedColor: selectedColor, selectedTitleColor: selectedTitleColor)
        
        return cell
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension IAPDialogViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let product = products[indexPath.row]
        
        return IAPDialogCell.size(forStoreProduct: product, collectionWidth: collectionView.frame.width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let isCompact = UIApplication.shouldShowCompactView
        let insetSides = isCompact ? IAPDialogViewController.gutterPaddingCompact : IAPDialogViewController.gutterPaddingRegular
        
        return UIEdgeInsets(top: 10, left: insetSides, bottom: 20, right: insetSides)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30.0
    }
}



//
//  DynamicGridLayout.swift
//  dynamicGridLayout
//
//  Created by Mikhail Kuzmin on 02/06/2019.
//  Copyright © 2019 Mikhail Kuzmin. All rights reserved.
//

import UIKit

class DynamicGridLayout: UICollectionViewLayout {

    weak var delegate: DynamicGridLayoutDelegate!

    // MARK: Items parameters
    let cellSpacing = CGFloat(2)
    var itemHeight = CGFloat(0)
    var itemWidth = CGFloat(0)
    
    // MARK: Page parameters
    var contentBounds = CGRect.zero
    var numberOfPages = 0
//    var groupWidth = CGFloat.zero
//    var groupHeight = CGFloat.zero
//    var groupTotalHorizontalSpacing = CGFloat.zero
//    var groupTotalVerticalSpacing = CGFloat.zero
    var groupWidth = 0.0
    var groupHeight = 0.0
    var groupTotalHorizontalSpacing = 0.0
    var groupTotalVerticalSpacing = 0.0
    var cellsPerSection = 0
    var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        cachedAttributes.removeAll()
        
        groupTotalHorizontalSpacing = Double(cellSpacing * CGFloat(delegate.cellsPerRow + 1))
        groupTotalVerticalSpacing = Double(cellSpacing * CGFloat(delegate.cellsPerColumn + 2))
        cellsPerSection = delegate.cellsPerRow * delegate.cellsPerColumn
        groupWidth = Double(collectionView.bounds.size.width)
        groupHeight = Double(collectionView.bounds.size.height)
        
        itemWidth = CGFloat((groupWidth - groupTotalHorizontalSpacing)) / CGFloat(delegate.cellsPerRow)
        itemHeight = itemWidth

        let itemsCount = collectionView.numberOfItems(inSection: 0)
        
        numberOfPages = itemsCount / cellsPerSection
        
        if itemsCount % cellsPerSection > 0 {
            numberOfPages += 1
        } else if itemsCount > 0 && itemsCount < cellsPerSection {
            numberOfPages += 1
        }
        
        var currentIndex = 0
        var lastFrame: CGRect = .zero
        
        let contentSize = CGSize(width: collectionView.bounds.size.width * CGFloat(numberOfPages),
                                       height: collectionView.bounds.size.height)
        
        contentBounds = CGRect(origin: .zero, size: contentSize)
        
        let columnHeight = itemHeight * CGFloat(delegate.cellsPerColumn) + cellSpacing * CGFloat(delegate.cellsPerColumn - 1)
        let verticalInsetSize = (CGFloat(groupHeight) - columnHeight) / 2

        func setUpFrame(rect: CGRect) {
            let cellFrame = rect
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: currentIndex, section: 0))
            attributes.frame = cellFrame
            cachedAttributes.append(attributes)
            contentBounds = contentBounds.union(lastFrame)
            currentIndex += 1
            lastFrame = cellFrame
        }

        var lastYPoint = CGFloat(0)
        var relativeXPoint = CGFloat(0)
        var pageShouldBeSwitched = false
        var currentPage = 0

        // index loop
        while currentIndex < itemsCount {
            if pageShouldBeSwitched {
                currentPage += 1
                lastYPoint = CGFloat(0)
                pageShouldBeSwitched = false
                relativeXPoint = collectionView.bounds.size.width * CGFloat(currentPage)
            }
            // column loop
            for row in 0..<Int(delegate.cellsPerColumn) {
                lastFrame = CGRect(x: relativeXPoint, y: 0.0, width: 0.0, height: 0.0)
                // row loops
                if row == 0 {
                    for _ in 0..<Int(delegate.cellsPerRow) {
                        guard currentIndex < itemsCount else { break }
                        
                        let frame = CGRect(x: lastFrame.maxX + cellSpacing,
                                           y: verticalInsetSize,
                                           width: itemWidth,
                                           height: itemHeight)

                        setUpFrame(rect: frame)
                        lastYPoint = frame.maxY
                    }
                } else {
                    for itemInRow in 0..<Int(delegate.cellsPerRow) {
                        guard currentIndex < itemsCount else { break }
                        
                        let frame = CGRect(x: lastFrame.maxX + cellSpacing,
                                           y: lastYPoint + cellSpacing,
                                           width: itemWidth,
                                           height: itemHeight)
                        setUpFrame(rect: frame)
                        if itemInRow == delegate.cellsPerRow - 1 && row == delegate.cellsPerColumn - 1 && currentPage < numberOfPages - 1 {
                            pageShouldBeSwitched = true
                        }
                    }
                    lastYPoint = lastFrame.maxY
                }
            }
        }
    }

    override var collectionViewContentSize: CGSize {
        return contentBounds.size
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }

    // MARK: LayoutAttributesForItem
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedAttributes
    }
}

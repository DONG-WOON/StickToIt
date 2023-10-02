//
//  ImageSelectionView.swift
//  StickToIt
//
//  Created by 서동운 on 10/2/23.
//

import UIKit

final class ImageSelectionView: UICollectionView {

    init() {
        super.init(
            frame: .zero,
            collectionViewLayout: Self.createLayout()
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageSelectionView {
    
    static func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex, environment) in

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1 / 3),
                heightDimension: .fractionalWidth(1 / 3)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(1 / 3)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: 3
            )
            
            group.interItemSpacing = .fixed(5.0)
            
            let section = NSCollectionLayoutSection(group: group)
            
            let spacing = 10.0
            let sectionInset = NSDirectionalEdgeInsets(
                top: spacing,
                leading: spacing,
                bottom: spacing,
                trailing: spacing
            )
            
            section.contentInsets = sectionInset
            
            return section
        }
        return layout
    }
}

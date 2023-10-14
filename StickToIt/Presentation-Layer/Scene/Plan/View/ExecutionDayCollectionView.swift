//
//  ExecutionDayCollectionView.swift
//  StickToIt
//
//  Created by 서동운 on 10/14/23.
//

import UIKit

final class ExecutionDayCollectionView: UICollectionView {
    
    init() {
        super.init(
            frame: .zero,
            collectionViewLayout: Self.createLayout()
        )
        
        self.backgroundColor = .clear
        self.isScrollEnabled = false
        self.allowsMultipleSelection = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func enableAllCell() {
        let cells = Week.allCases.map {
            return cellForItem(at: IndexPath(item: $0.rawValue - 1, section: 0))
        }
        cells.forEach { $0?.isUserInteractionEnabled = true }
    }
    
    func disable(indexAtCell weeks: [Int]) {
        let enableCells = weeks.map {
            return cellForItem(
                at: IndexPath(
                    item: $0 - 1,
                    section: 0)
            ) as? ExecutionDayCollectionViewCell
            
        }
        
        enableCells.forEach {
            $0?.isUserInteractionEnabled = true
        }
        
        
        let disableCells = Set(1...7)
            .subtracting(Set(weeks))
            .map {
                return cellForItem(
                    at: IndexPath(
                        item: $0 - 1,
                        section: 0)
                ) as? ExecutionDayCollectionViewCell
            }
        disableCells.forEach {
            $0?.isUserInteractionEnabled = false
        }
    }
}

final class ExecutionDayCollectionViewCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        willSet {
            select(newValue)
        }
    }
    
    override var isUserInteractionEnabled: Bool {
        willSet {
            enable(newValue)
        }
    }
    
    let label: UILabel = {
        let view = UILabel()
        view.textColor = .label
        view.textAlignment = .center
        view.backgroundColor = .clear
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.label.text = nil
    }
    
    private func select(_ isSelected: Bool) {
        if isSelected {
            contentView.backgroundColor = .systemIndigo.withAlphaComponent(0.6)
            label.textColor = .white
        } else {
            contentView.backgroundColor = .clear
            label.textColor = .label
        }
    }
    
    private func enable(_ isEnabled: Bool) {
        if isEnabled {
            contentView.backgroundColor = . clear
            label.textColor = .label
        } else {
            contentView.backgroundColor = .lightGray
            label.textColor = .white
        }
    }
}

extension ExecutionDayCollectionViewCell: BaseViewConfigurable {
    func configureViews() {
        contentView.addSubview(label)
        
        contentView.bordered(borderWidth: 0.5, borderColor: .systemIndigo)
    }
    
    func setConstraints() {
        label.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
    }
}
extension ExecutionDayCollectionView {
    
    static func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex, environment) in
            
            let spacing = 1.0
            
            let edgeInset = NSDirectionalEdgeInsets(
                top: spacing,
                leading: spacing,
                bottom: spacing,
                trailing: spacing
            )
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1 / 7),
                heightDimension: .fractionalHeight(1.0)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = edgeInset
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            
            if #available(iOS 16.0, *) {
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    repeatingSubitem: item,
                    count: 7
                )
                
                group.interItemSpacing = .fixed(spacing)
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.contentInsets = edgeInset
                
                return section
            } else {
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitem: item,
                    count: 7
                )
                
                group.interItemSpacing = .fixed(spacing)
                
                let section = NSCollectionLayoutSection(group: group)
                
                section.contentInsets = edgeInset
                
                return section
            }
        }
        return layout
    }
}

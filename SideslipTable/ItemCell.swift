//
//  ItemCell.swift
//  SideslipTable
//
//  Created by Tory on 2021/4/28.
//

import UIKit

class ItemCell: UICollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUi()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupTitle(_ title: String) {
        self.titleLabel.text = title
    }
    
    private func setupUi() {
        self.contentView.backgroundColor = randomRGB()
        self.contentView.addSubview(self.titleLabel)
    }
    
    override func layoutSubviews() {
        self.titleLabel.frame = self.contentView.bounds
    }
    
}

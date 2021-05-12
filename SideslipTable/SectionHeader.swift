//
//  SectionHeader.swift
//  SideslipTable
//
//  Created by Tory on 2021/4/28.
//

import UIKit

class SectionHeader: UICollectionReusableView {
    
    static var headerId = "SectionHeaderId"
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
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
        self.backgroundColor = .white
        self.addSubview(self.titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.frame = self.bounds
    }
}

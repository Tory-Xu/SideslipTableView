//
//  ViewController.swift
//  SideslipTable
//
//  Created by Tory on 2021/4/24.
//

import UIKit

class ViewController: UIViewController {

    public static var cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        

        let slipTableView = SideslipTableView(frame: self.view.bounds, style: .plain)
        slipTableView.backgroundColor = .blue
        slipTableView.dataSource = self
        slipTableView.delegate = self
        self.view.addSubview(slipTableView)
        
        slipTableView.registerCell = { () -> (cellClass: AnyClass?, identifier: String) in
            return (ItemCell.self, ViewController.cellId)
        }
        slipTableView.registerSupplementaryView = { ()-> (cellClass: AnyClass?, kind: String, identifier: String) in
            return (SectionHeader.self, UICollectionView.elementKindSectionHeader, SectionHeader.headerId)
        }
//        slipTableView.reloadData()
    }


}

extension ViewController: SideslipTableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int, indexPathForTableView: IndexPath) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, indexPathForTableView: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ViewController.cellId, for: indexPath)
        if let itemCell = cell as? ItemCell {
            itemCell.setupTitle("\(indexPathForTableView) - \(indexPath)")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath, indexPathForTableView: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.headerId, for: indexPath) as? SectionHeader else {
            fatalError("获取视图失败")
        }
        
        header.setupTitle("--header \(indexPathForTableView.row)")
        return header
    }
}

extension ViewController: SideslipTableViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, indexPathForTableView: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int, indexPathForTableView: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 80)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

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
        self.titleLabel.frame = self.bounds
    }
}

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


func randomRGB() -> UIColor {
    return UIColor.init(red: CGFloat(arc4random()%256)/255.0, green: CGFloat(arc4random()%256)/255.0, blue: CGFloat(arc4random()%256)/255.0, alpha: 1)
}

//
//  SideslipTableView.swift
//  SideslipTable
//
//  Created by Tory on 2021/4/24.
//

import UIKit

public enum SideCellType {
    case slipCell(_ config: ((_ cell: SideslipCell)->Void)? = nil)
    case customSlipCell(_ cell: SideslipCell)
    case customCell(_ cell: UITableViewCell)
}

public protocol SideslipTableViewDataSource: NSObjectProtocol {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    
    func numberOfSections(in tableView: UITableView) -> Int // Default is 1 if not implemented
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> SideCellType
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int,
                        indexPathForTableView: IndexPath) -> Int
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath,
                        indexPathForTableView: IndexPath) -> UICollectionViewCell
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath,
                        indexPathForTableView: IndexPath) -> UICollectionReusableView
}

extension SideslipTableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> SideCellType { return .slipCell() }
}

@objc public protocol SideslipTableViewDelegate: NSObjectProtocol {

    @objc optional func tableView(_ tableView: UITableView,
                                  heightForRowAt indexPath: IndexPath) -> CGFloat

    @objc optional func tableView(_ tableView: UITableView,
                                  heightForHeaderInSection section: Int) -> CGFloat
    
    @objc optional func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    
    @objc optional  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath,
                        indexPathForTableView: IndexPath) -> CGSize
    
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       insetForSectionAt section: Int,
                                       indexPathForTableView: IndexPath) -> UIEdgeInsets
    
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       minimumLineSpacingForSectionAt section: Int,
                                       indexPathForTableView: IndexPath) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       minimumInteritemSpacingForSectionAt section: Int,
                                       indexPathForTableView: IndexPath) -> CGFloat
    
    @objc optional func collectionView(_ collectionView: UICollectionView,
                                       layout collectionViewLayout: UICollectionViewLayout,
                                       referenceSizeForHeaderInSection section: Int,
                                       indexPathForTableView: IndexPath) -> CGSize
}

class SideslipTableView: UIView {
    
    public weak var dataSource: SideslipTableViewDataSource?
    public weak var delegate: SideslipTableViewDelegate?
    
    typealias RegisterCell = ()-> (cellClass: AnyClass?, identifier: String)
    public var registerCell: RegisterCell?
    typealias RegisterSupplementaryView = ()-> (cellClass: AnyClass?, kind: String, identifier: String)
    public var registerSupplementaryView: RegisterSupplementaryView?
    
    private let tableView: UITableView
    
    private var horizontalContentOffset: CGPoint = CGPoint.zero
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame, style: .plain)
    }
    
    init(frame: CGRect, style: UITableView.Style) {
        self.tableView = UITableView(frame: .zero, style: style)
        super.init(frame: frame)
        self.setupUi()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reloadData() {
        self.tableView.reloadData()
    }
    
    public func reloadHorizontalRow(row: Int) {
        self.tableView.visibleCells.forEach { (cell) in
            guard let sideslipCell = cell as? SideslipCell else {
                return
            }
            
            sideslipCell.collectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
        }
    }
    
    public func reloadHorizontalRows(rows: [Int]) {
        var indexPaths = [IndexPath]()
        rows.forEach { (row) in
            indexPaths.append(IndexPath(row: row, section: 0))
        }
        
        self.tableView.visibleCells.forEach { (cell) in
            guard let sideslipCell = cell as? SideslipCell else {
                return
            }
            
            sideslipCell.collectionView.reloadItems(at: indexPaths)
        }
    }
    
    private func setupUi() {
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        self.tableView.tableFooterView = UIView()
        if #available(iOS 11, *) {
            self.tableView.sectionHeaderHeight = 0
            self.tableView.sectionFooterHeight = 0
            self.tableView.estimatedSectionHeaderHeight = 0
        }
        self.addSubview(self.tableView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView.frame = self.bounds
    }
    
}

// MARK: SideslipTableView
extension SideslipTableView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? SideslipCollectionView {
            self.horizontalContentOffset = collectionView.contentOffset
            self.tableView.indexPathsForVisibleRows?.forEach { (indexPath: IndexPath) in
                guard indexPath != collectionView.indexPathForAssociateCell else  {
                    return
                }
                guard let cell = self.tableView.cellForRow(at: indexPath) as? SideslipCell else {
                    return
                }
                
                cell.collectionView.contentOffset = collectionView.contentOffset
            }
        }
    }
}

// MARK: UITableViewDataSource
extension SideslipTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.tableView(tableView, numberOfRowsInSection: section) ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource?.numberOfSections(in: tableView) ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cellType = self.dataSource?.tableView(tableView, cellForRowAt: indexPath) else {
            fatalError("必须实现数据源")
        }
        
        var slipCell: SideslipCell
        switch cellType {
        case let .slipCell(config):
            slipCell = SideslipCell.slipCell(tableView: tableView)
            config?(slipCell)
        case let .customSlipCell(cell):
            slipCell = cell
        case let .customCell(cell):
            return cell
        }
        
        slipCell.collectionView.contentOffset = self.horizontalContentOffset
        slipCell.collectionView.indexPathForAssociateCell = indexPath
        if slipCell.beReused {
            slipCell.collectionView.reloadData()
        } else {
            slipCell.collectionView.delegate = self
            slipCell.collectionView.dataSource = self
            
            if let (cellClass, identifier) = self.registerCell?() {
                slipCell.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
            }
            if let (cellClass, kind, identifier) = self.registerSupplementaryView?() {
                slipCell.collectionView.register(cellClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
            }
        }
        return slipCell
    }
    
}

// MARK: UITableViewDelegate
extension SideslipTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.delegate?.tableView?(tableView, heightForRowAt: indexPath) ?? 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.delegate?.tableView?(tableView, heightForHeaderInSection: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.delegate?.tableView?(tableView, viewForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
}

// MARK: UICollectionViewDataSource
extension SideslipTableView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let indexPathForAssociateCell = (collectionView as! SideslipCollectionView).indexPathForAssociateCell!
        return self.dataSource?.collectionView(collectionView,
                                               numberOfItemsInSection: section,
                                               indexPathForTableView: indexPathForAssociateCell) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let indexPathForAssociateCell = (collectionView as! SideslipCollectionView).indexPathForAssociateCell!
        return self.dataSource!.collectionView(collectionView,
                                               cellForItemAt: indexPath,
                                               indexPathForTableView: indexPathForAssociateCell)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let indexPathForAssociateCell = (collectionView as! SideslipCollectionView).indexPathForAssociateCell!
        return self.dataSource!.collectionView(collectionView,
                                               viewForSupplementaryElementOfKind: kind,
                                               at: indexPath,
                                               indexPathForTableView: indexPathForAssociateCell)
    }

}

// MARK: UICollectionViewDelegate
extension SideslipTableView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let indexPathForAssociateCell = (collectionView as! SideslipCollectionView).indexPathForAssociateCell!
        return self.delegate?.collectionView(collectionView,
                                             layout: collectionViewLayout,
                                             sizeForItemAt: indexPath,
                                             indexPathForTableView: indexPathForAssociateCell) ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let indexPathForAssociateCell = (collectionView as! SideslipCollectionView).indexPathForAssociateCell!
        return self.delegate?.collectionView?(collectionView,
                                      layout: collectionViewLayout,
                                      insetForSectionAt: section,
                                      indexPathForTableView: indexPathForAssociateCell) ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let indexPathForAssociateCell = (collectionView as! SideslipCollectionView).indexPathForAssociateCell!
        return self.delegate?.collectionView?(collectionView,
                                      layout: collectionViewLayout,
                                      minimumLineSpacingForSectionAt: section,
                                      indexPathForTableView: indexPathForAssociateCell) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let indexPathForAssociateCell = (collectionView as! SideslipCollectionView).indexPathForAssociateCell!
        return self.delegate?.collectionView?(collectionView,
                                      layout: collectionViewLayout,
                                      minimumInteritemSpacingForSectionAt: section,
                                      indexPathForTableView: indexPathForAssociateCell) ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPathForAssociateCell = (collectionView as! SideslipCollectionView).indexPathForAssociateCell!
        return self.delegate?.collectionView?(collectionView,
                                      layout: collectionViewLayout,
                                      referenceSizeForHeaderInSection: section,
                                      indexPathForTableView: indexPathForAssociateCell) ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        debugPrint("collectionView did click at indexPath: \(indexPath)")
    }
}

// MARK: SideslipCell

public class SideslipCell: UITableViewCell {
    
    /// 滑动区域四周间距
    public var slipContentInsets: UIEdgeInsets = .zero
    
    lazy public var collectionView: SideslipCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionHeadersPinToVisibleBounds = true
        
        let collectionView = SideslipCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    public var beReused = false
    
    public class func slipCell(tableView: UITableView, reuseId: String = "SideslipCellId") -> SideslipCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) as? SideslipCell {
            cell.beReused = true
            return cell
        }

        let cell = SideslipCell(style: .default, reuseIdentifier: reuseId)
        return cell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUi()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUi() {
        // !!!: 未设置颜色，会导致 collectionView 无法接受到事件，导致无法侧滑
        self.contentView.backgroundColor = .white
        self.addSubview(self.collectionView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let width = self.bounds.width - self.slipContentInsets.left - self.slipContentInsets.right
        let height = self.bounds.height - self.slipContentInsets.top - self.slipContentInsets.bottom
        self.collectionView.frame = CGRect(x: self.slipContentInsets.left,
                                           y: self.slipContentInsets.top,
                                           width: width,
                                           height: height)
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let response = super.hitTest(point, with: event)
        debugPrint("hit test responder is: \(String(describing: response))")
        if response == nil {
             return self.collectionView
        } else {
            return response
        }
    }

}

public class SideslipCollectionView: UICollectionView {
    var indexPathForAssociateCell: IndexPath?
}


//
//  ViewController.swift
//  SideslipTable
//
//  Created by Tory on 2021/4/24.
//

import UIKit

class ViewController: UIViewController {

    public static var cellId = "cellId"
    
    lazy var slipTableView: SideslipTableView = {
        let y: CGFloat = 200
        let frame = CGRect(x: 0, y: y,
                           width: self.view.frame.width,
                           height: self.view.frame.height - y)
        let slipTableView = SideslipTableView(frame: frame,
                                              style: .plain)
        slipTableView.backgroundColor = .blue
        slipTableView.dataSource = self
        slipTableView.delegate = self
        slipTableView.registerCell = { () -> (cellClass: AnyClass?, identifier: String) in
            return (ItemCell.self, ViewController.cellId)
        }
        slipTableView.registerSupplementaryView = { ()-> (cellClass: AnyClass?, kind: String, identifier: String) in
            return (SectionHeader.self, UICollectionView.elementKindSectionHeader, SectionHeader.headerId)
        }
        return slipTableView
    }()
    
    @IBOutlet var menuView: UIView!
    
    @IBOutlet weak var refreshColTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.


        self.view.addSubview(self.slipTableView)
    }
    
    
    // swift 注意：@objc 不能少
    @objc func injected() {
        self.slipTableView.reloadData()
    }
    
    @IBAction func reload(_ sender: Any) {
        self.slipTableView.reloadData()
    }
    
    @IBAction func refreshCol(_ sender: Any) {
        let col = Int(self.refreshColTextField.text ?? "2")!
        self.slipTableView.reloadHorizontalRow(row: col)
    }
    
    @IBAction func refreshCols(_ sender: Any) {
        self.slipTableView.reloadHorizontalRows(rows: [0, 2, 4])
    }
    
    
}

extension ViewController: SideslipTableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    fileprivate func customCell(_ tableView: UITableView, _ indexPath: IndexPath) -> SideCellType {
        let customCellId = "customCellId"
        var cell: UITableViewCell
        if let reusableCell = tableView.dequeueReusableCell(withIdentifier: customCellId) {
            cell = reusableCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: customCellId)
        }
        cell.backgroundColor = .gray
        cell.textLabel?.text = "custom cell: \(indexPath.section) - \(indexPath.row)"
        cell.textLabel?.textColor = .red
        return .customCell(cell)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> SideCellType {
        
        let result = indexPath.row % 3
        
        switch result {
        case 0:
            return .slipCell()
        case 1:
            let cell = CustomSlieslipCell.slipCell(tableView: tableView)
            return .customSlipCell(cell)
        default:
            return customCell(tableView, indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int, indexPathForTableView: IndexPath) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, indexPathForTableView: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ViewController.cellId, for: indexPath)
        if let itemCell = cell as? ItemCell {
            let title = "\(indexPathForTableView) - \(indexPath)"
            debugPrint(title)
            itemCell.setupTitle(title)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath, indexPathForTableView: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.headerId, for: indexPath) as? SectionHeader else {
            fatalError("获取视图失败")
        }
        
        let title = "--header \(indexPathForTableView.row)"
        debugPrint(title)
        header.setupTitle(title)
        return header
    }
}

extension ViewController: SideslipTableViewDelegate {
    static var rowHeight: CGFloat = 80
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        debugPrint("tableView did click at indexPath: \(indexPath)")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, indexPathForTableView: IndexPath) -> CGSize {
        return CGSize(width: 100, height: ViewController.rowHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int, indexPathForTableView: IndexPath) -> CGSize {
        return CGSize(width: 100, height: ViewController.rowHeight)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ViewController.rowHeight
    }
}

func randomRGB() -> UIColor {
    return UIColor.init(red: CGFloat(arc4random()%256)/255.0,
                        green: CGFloat(arc4random()%256)/255.0,
                        blue: CGFloat(arc4random()%256)/255.0,
                        alpha: 1)
}


class CustomSlieslipCell: SideslipCell {
    
    private static var reloadButtonSize = CGSize(width: 100, height: 44)
    
    lazy var reloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("reload", for: .normal)
        button.addTarget(self, action: #selector(reloadView), for: .touchUpInside)
        button.backgroundColor = .red
        return button
    }()
    
    override public class func slipCell(tableView: UITableView, reuseId: String = "CustomSlieslipCellId") -> CustomSlieslipCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) as? CustomSlieslipCell {
            cell.beReused = true
            return cell
        }

        let cell = CustomSlieslipCell(style: .default, reuseIdentifier: reuseId)
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
        self.slipContentInsets = UIEdgeInsets(top: 0, left: 10, bottom: CustomSlieslipCell.reloadButtonSize.height, right: 0)
        
        self.contentView.addSubview(self.reloadButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.reloadButton.center = CGPoint(x: self.center.x,
                                           y: self.bounds.height - CustomSlieslipCell.reloadButtonSize.height / 2)
        self.reloadButton.frame.size = CustomSlieslipCell.reloadButtonSize
    }
    
    @objc func reloadView() {
        self.collectionView.reloadData()
    }
    
}

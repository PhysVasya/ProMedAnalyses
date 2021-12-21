//
//  TableForData.swift
//  getCRPfromProMed
//
//  Created by Vasiliy Andreyev on 14.12.2021.
//

import UIKit

protocol TableForDataDelegate {
    func viewDidScroll(to position: CGFloat)
}

class ResultsViewController: UIViewController, TableForDataDelegate {
    
    var infoForRow = [String]()
    var headerForSection = [String]()
    var headerForCollectionView = [String]()
    
    let maximumHeight : CGFloat = 250
    let minimumHeight : CGFloat = 50
    var previousScrollOffset : CGFloat = 0
    
    @IBOutlet var header : UIView!
    @IBOutlet var tableView : UITableView!
    @IBOutlet weak var headerViewHeight : NSLayoutConstraint!
    
    var myLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        tableView.register(UINib(nibName: "tableCell", bundle: nil), forCellReuseIdentifier: "tableCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.zPosition = 1
        view.addSubview(tableView)
        
        header = UIView(frame: CGRect(x: 0, y: 140, width: view.frame.width, height: 50))
        header.backgroundColor = .blue
        header.layer.zPosition = 200
        view.addSubview(header)
        view.bringSubviewToFront(header)
        
        myLabel = UILabel(frame: CGRect(x: 0, y: 0, width: header.frame.width, height: header.frame.height))
        myLabel.text = "YOUR MOMA GaY"
        myLabel.textColor = .white
        myLabel.textAlignment = .center
        header.isHidden = false
        header.addSubview(myLabel)
    }
    
    func viewDidScroll (to position: CGFloat) {
        for cell in tableView.visibleCells as! [ReusableCellForResultsTableView] {
            cell.collectionView.contentOffset.x = position
        }
    }
}




// MARK: - Table view data source

extension ResultsViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerForSection[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! ReusableCellForResultsTableView
        cell.scrollDelegate = self
        
        if indexPath.row == 0 {
            cell.textStrings = headerForCollectionView
            return cell
        } else {
            cell.textStrings = infoForRow
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        print(header.constraints)
        //        let headerCell = tableView.cellForRow(at: IndexPath(row:0, section: 0))
        //        guard headerCell == nil || (headerCell!.frame.origin.y < tableView.contentOffset.y + headerCell!.frame.height/2) else {
        //            header?.isHidden = true
        //            return
        //
        //        }
        //
        //        guard let hdr = header else {
        //            return
        //        }
        //        hdr.isHidden = false
        //        hdr.frame = CGRect(x: 0, y: tableView.contentOffset.y, width: hdr.frame.size.width, height: hdr.frame.size.height)
        //
        //        if !tableView.subviews.contains(hdr) {
        //            tableView.addSubview(hdr)
        //        }
        //
        //        tableView.bringSubviewToFront(hdr)
    }
    
}




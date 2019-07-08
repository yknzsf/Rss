//
//  ViewController.swift
//  Rss
//
//  Created by zsf on 2019/7/7.
//

import UIKit
import Alamofire
import SwiftyXMLParser
import CHTCollectionViewWaterfallLayout
import SnapKit
import Kingfisher
import JXPhotoBrowser

class ViewController: UIViewController {
    
    var items: Array<RssNews> = Array<RssNews>();
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews();
        addConstraints();
        self.loadData();
    }
    
    func addSubviews() {
        self.view.addSubview(self.collectionView);
    }
    
    func addConstraints() {
        self.collectionView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view.snp.left);
            make.right.equalTo(self.view.snp.right);
            make.top.equalTo(self.view.snp.top);
            make.bottom.equalTo(self.view.snp.bottom);
        }
    }
    
    // MARK: -lazy
    lazy var collectionView: UICollectionView = {
        let layout = CHTCollectionViewWaterfallLayout();
        layout.columnCount = 2;
        let v = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout);
        v.delegate = self;
        v.dataSource = self;
        v.backgroundColor = UIColor.white;
        v.register(RssNewsListCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(RssNewsListCollectionViewCell.self));
        return v;
    }();
    
}

extension ViewController {
    
    // 从网络下载数据
    func loadData() {
        let urlStr = "https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss";
        Alamofire.request(urlStr, method: .get).responseData { [weak self](response) in
            let xml = XML.parse(response.result.value!)
            let channel = xml["rss"]["channel"]
            let items = channel["item"]
            var array:[RssNews] = []
            for item in items {
                let model: RssNews = RssNews()
                model.title = item["title"].text
                model.thumb = item["enclosure"].attributes["url"]
                model.description = item["description"].text
                array.append(model)
            }
            self?.items.append(contentsOf: array);
            self?.collectionView.reloadData();
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource , CHTCollectionViewDelegateWaterfallLayout{
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAt indexPath: IndexPath!) -> CGSize {
        let model = self.items[indexPath.row];
        if __CGSizeEqualToSize(model.imageSize, CGSize.zero) == false {
            return model.imageSize;
        }
        
        return CGSize(width: 150, height: 150);
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(RssNewsListCollectionViewCell.self), for: indexPath) as? RssNewsListCollectionViewCell;
        cell?.backgroundColor = UIColor.white;
        let model = self.items[indexPath.row];
        let url = URL(string: model.thumb ?? "")
        cell?.imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "loading"),//占位图
            options: [
            ])
        {
            result in
            switch result {
            case .success(let value):
                model.imageSize = value.image.size;
                self.collectionView.reloadItems(at: [indexPath]);
            case .failure(let error):
                print(error);
            }
        }
        
        return cell!;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let loader = JXKingfisherLoader()
        
        let dataSource = JXNetworkingDataSource(photoLoader: loader, numberOfItems: { () -> Int in
            return self.items.count
        }, placeholder: { (at) -> UIImage? in
            return UIImage(named: "loading")
        }) { (index) -> String? in
            let model = self.items[index];
            return model.thumb ?? "";
        }
        
        // 视图代理，实现了光点型页码指示器
        let delegate = JXDefaultPageControlDelegate()
        
        // 转场动画
        let trans = JXPhotoBrowserZoomTransitioning { (browser, index, view) -> UIView? in
            let indexPath = IndexPath(item: index, section: 0)
            let cell = collectionView.cellForItem(at: indexPath) as? RssNewsListCollectionViewCell
            return cell?.imageView
        }
        
        JXPhotoBrowser(dataSource: dataSource, delegate: delegate, transDelegate: trans)
            .show(pageIndex: indexPath.item)
    }
}

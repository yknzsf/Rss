//
//  RssNewsListCollectionViewCell.swift
//  Rss
//
//  Created by zsf on 2019/7/7.
//

import UIKit

class RssNewsListCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.contentView.addSubview(self.imageView);
        self.imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView.snp.edges);
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI初始化

    lazy var imageView: UIImageView = {
        let i = UIImageView();
        i.contentMode = .scaleAspectFit;
        return i;
    }();
}

//
//  XibView.swift
//  SeatGeek
//
//  Created by Andriy Kupich on 5/6/19.
//  Copyright © 2019 Andriy Kupich. All rights reserved.
//

import UIKit

class XibView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    func load() {
        guard let view = Bundle(for: XibView.self)
            .loadNibNamed(type(of: self).identifier, owner: self, options: nil)?
            .first as? UIView else { return }
        addSubview(view)
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

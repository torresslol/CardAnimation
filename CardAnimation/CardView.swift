//
//  CardView.swift
//  CardAnimation
//
//  Created by yy on 2024/12/24.
//

import UIKit

class CardView: UIView {
    // MARK: - UI Components
    private let frontImageView: UIImageView
    private let backImageView: UIImageView
    
    // MARK: - Properties
    var isFlipped: Bool = false
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        frontImageView = UIImageView(frame: .zero)
        backImageView = UIImageView(frame: .zero)
        
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        // Setup container view
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        // Setup back image view (lucky image)
        backImageView.contentMode = .scaleAspectFill
        backImageView.image = UIImage(named: "lucky")
        backImageView.frame = bounds
        addSubview(backImageView)
        
        // Setup front image view (girl image)
        frontImageView.contentMode = .scaleAspectFill
        frontImageView.image = UIImage(named: "girl")
        frontImageView.frame = bounds
        frontImageView.isHidden = true
        addSubview(frontImageView)
        
        // Add shadow and border if needed
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.2
    }
    
    // MARK: - Public Methods
    
    /// Flips the card with animation
    func flip() {
        UIView.transition(with: self,
                         duration: 0.3,
                         options: .transitionFlipFromLeft,
                         animations: {
            self.frontImageView.isHidden = !self.frontImageView.isHidden
            self.backImageView.isHidden = !self.backImageView.isHidden
            self.isFlipped = !self.isFlipped
        })
    }
}


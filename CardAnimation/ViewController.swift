//
//  ViewController.swift
//  CardAnimation
//
//  Created by yy on 2024/12/24.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Properties
    
    /// Enum to track the current state of the card game
    private enum GameState {
        case initial      // Initial state when view is loaded
        case unfolded    // Cards are unfolded in fan pattern
        case selected    // A card is selected and moved to center
        case revealed    // Selected card is flipped and shown
    }
    
    private var currentState: GameState = .initial
    private var cardViews: [CardView] = []
    private let cardCount = 5
    private let cardSize = CGSize(width: 100, height: 150)
    private var selectedCardIndex: Int?
    
    private lazy var matchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Match", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.isEnabled = false
        button
            .addTarget(
                self,
                action: #selector(matchButtonTapped),
                for: .touchUpInside
            )
        return button
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        setupMatchButton()
        setupCardViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if currentState == .initial {
            unfoldCards()
        }
    }
    
    // MARK: - Setup Methods
        
    /// Sets up the match button with proper positioning and styling
    private func setupMatchButton() {
        // Calculate button position
        let buttonFrame = CGRect(
            x: (view.bounds.width - 100) / 2,
            y: view.bounds.height - 200,
            width: 100,
            height: 50
        )
            
        matchButton.frame = buttonFrame
        view.addSubview(matchButton)
    }
        
    /// Creates and sets up all card views
    private func setupCardViews() {
        // Calculate initial center position for cards
        let centerX = view.bounds.width / 2
        let centerY = view.bounds.height / 2 + 100
        let centerPoint = CGPoint(x: centerX, y: centerY)
            
        // Create card views
        for _ in 0..<cardCount {
            let cardView = CardView(
                frame: CGRect(origin: .zero, size: cardSize)
            )
            cardView.center = centerPoint
            cardView.isHidden = true // Initially hidden
            view.addSubview(cardView)
            cardViews.append(cardView)
        }
    }
    
    // MARK: - Button Actions
    
    @objc private func matchButtonTapped() {
        switch currentState {
        case .initial:
            // Should never happen as button is disabled in initial state
            break
            
        case .unfolded:
            // Normal flow: select and reveal a card
            selectAndRevealCard()
            
        case .selected:
            // Should never happen as button is disabled during selection animation
            break
            
        case .revealed:
            // Reset the game to unfolded state before starting new selection
            resetToUnfolded { [weak self] in
                self?.selectAndRevealCard()
            }
        }
    }
    
    // MARK: - Card Animation Methods
    
    /// Unfolds cards in fan pattern
    private func unfoldCards() {
        let angleIncrement = Double.pi / 8
        let startY = view.bounds.height / 2 + 100
        let centerPoint = CGPoint(x: view.bounds.width / 2, y: startY)
        
        for (index, cardView) in cardViews.enumerated() {
            cardView.isHidden = false
            cardView.center = centerPoint
            
            let angle = angleIncrement * Double(index) - angleIncrement * Double(
                cardCount - 1
            ) / 2
            let translationX = CGFloat(150 * sin(angle))
            let translationY = CGFloat(150 * cos(angle))
            
            let transform = CGAffineTransform(
                translationX: translationX,
                y: -translationY
            )
                .rotated(by: CGFloat(angle))
            
            UIView.animate(withDuration: 0.3,
                           delay: Double(index) * 0.1,
                           options: [],
                           animations: {
                cardView.transform = transform
            }, completion: { _ in
                if index == self.cardViews.count - 1 {
                    self.currentState = .unfolded
                    self.matchButton.isEnabled = true
                }
            })
        }
    }
    
    /// Resets the game to unfolded state and executes completion handler
    private func resetToUnfolded(completion: (() -> Void)? = nil) {
        guard let selectedIndex = selectedCardIndex,
              selectedIndex < cardViews.count else {
            completion?()
            return
        }
        
        matchButton.isEnabled = false
        let selectedCard = cardViews[selectedIndex]
        
        // First flip back if needed
        if selectedCard.isFlipped {
            selectedCard.flip()
        }
        
        // Calculate final position in fan pattern
        let angleIncrement = Double.pi / 8
        let angle = angleIncrement * Double(selectedIndex) - angleIncrement * Double(
            cardCount - 1
        ) / 2
        let translationX = CGFloat(150 * sin(angle))
        let translationY = CGFloat(150 * cos(angle))
        let finalTransform = CGAffineTransform(
            translationX: translationX,
            y: -translationY
        )
            .rotated(by: CGFloat(angle))
        
        UIView.animate(withDuration: 0.3, animations: {
            selectedCard.transform = finalTransform
            selectedCard.center = CGPoint(x: self.view.bounds.width / 2,
                                          y: self.view.bounds.height / 2 + 100)
        }) { _ in
            self.selectedCardIndex = nil
            self.currentState = .unfolded
            self.matchButton.isEnabled = true
            completion?()
        }
    }
    
    /// Selects and reveals center card
    private func selectAndRevealCard() {
        matchButton.isEnabled = false
        currentState = .selected
        
        let centerIndex = cardCount / 2
        selectedCardIndex = centerIndex
        let centerCard = cardViews[centerIndex]
        view.bringSubviewToFront(centerCard)
        
        // Move to position A (slightly up)
        UIView.animate(withDuration: 0.5, animations: {
            centerCard.transform = centerCard.transform
                .translatedBy(x: 0, y: -50)
        }) { [weak self] _ in
            // Move to position B (center and scale)
            UIView.animate(withDuration: 0.3, animations: {
                centerCard.center = self?.view.center ?? .zero
                centerCard.transform = CGAffineTransform(scaleX: 2.2, y: 2.2)
            }) { [weak self] _ in
                // Flip the card
                centerCard.flip()
                self?.currentState = .revealed
                self?.matchButton.isEnabled = true
            }
        }
    }
}


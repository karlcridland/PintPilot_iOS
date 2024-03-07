//
//  UIViewController.swift
//  pint pilot
//
//  Created by Karl Cridland on 03/12/2020.
//

import Foundation
import UIKit

extension UIViewController {
    func addChildViewControllerWithView(_ childViewController: UIViewController, toView view: UIView? = nil) {
        let view: UIView = view ?? self.view

        childViewController.removeFromParent()
        childViewController.willMove(toParent: self)
        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}


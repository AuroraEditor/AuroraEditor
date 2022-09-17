//
//  UIHostingView.swift
//  
//
//  Created by Manuel M T Chakravarty on 04/05/2021.
//

import SwiftUI

#if os(iOS)

class UIHostingView<Content: View>: UIView {
  private let hostingViewController: UIHostingController<Content>

  var rootView: Content {
    get { hostingViewController.rootView }
    set { hostingViewController.rootView = newValue }
  }

  init(rootView: Content) {
    hostingViewController = UIHostingController(rootView: rootView)
    super.init(frame: .zero)

    hostingViewController.view?.translatesAutoresizingMaskIntoConstraints = false
    addSubview(hostingViewController.view)
    if let view = hostingViewController.view {

      view.backgroundColor = .clear
      view.isOpaque        = false
      addSubview(view)
      let constraints = [
        view.topAnchor.constraint(equalTo: self.topAnchor),
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        view.leftAnchor.constraint(equalTo: self.leftAnchor),
        view.rightAnchor.constraint(equalTo: self.rightAnchor)
      ]
      NSLayoutConstraint.activate(constraints)

    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    hostingViewController.sizeThatFits(in: size)
  }
}

#endif

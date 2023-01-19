//  Created by Marcel Derks on 04.10.19.
//  Copyright © 2019 kmb. All rights reserved.
//

import UIKit
import WebKit

class DemoBug: UIViewController {

    let buttonOpenWebView = UIButton(type: .custom)
    let buttonForceBug = UIButton(type: .custom)
    
    let demoLabel = UILabel()
    let descriptionLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        let stackView = UIStackView()
        view.addSubview(descriptionLabel)
        descriptionLabel.pinLeft(to: view, inset: 8.0)
        descriptionLabel.pinTop(to: view, inset: 32.0, respectSafeArea: true)
        descriptionLabel.pinRight(to: view, inset: -8.0)
        
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 16.0
        stackView.addArrangedSubview(buttonOpenWebView)
        stackView.addArrangedSubview(buttonForceBug)
        stackView.addArrangedSubview(demoLabel)
        stackView.pinTopToBottom(of: descriptionLabel, inset: 16.0)
        stackView.pinLeft(to: view, inset: 0.0)
        stackView.pinRight(to: view, inset: 0.0)
        
        buttonOpenWebView.setTitle("Open Web View modal", for: .normal)
        buttonForceBug.setTitle("Force NSAttributeBug", for: .normal)
        
        buttonOpenWebView.addTarget(self, action: #selector(openWebViewTapped), for: .touchUpInside)
        buttonForceBug.addTarget(self, action: #selector(forceBugTapped), for: .touchUpInside)
        
        let descFont: UIFont = .systemFont(ofSize: 16.0)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = descFont
        descriptionLabel.textColor = .white
        descriptionLabel.text = """
        This code isolates a bug that happens in combination of the use of NSAttributedString
        and a WKWebView. To reproduce, first open the WebView by tapping the first button.
        Is shows a demo of MediaRecorder embedded in a web page. It should ask for a permission and after that
        has been given, you can record and play audio with no problems.
        
        So far so good.
        
        Now tap the second button, which will create a NSAttributedString with docytpe = html.
        
        From that point on, when you open the webview again, it will crash at the moment, the MediaRecorder
        on that webview is started.
        """
    }
    
    @objc func openWebViewTapped(sender: UIButton) {
        let webView = WebViewController()
        webView.modalPresentationStyle = .fullScreen
        self.present(webView, animated: true)
    }
    
    @objc func forceBugTapped(sender: UIButton) {
        let htmlAttributedText = "<b>This is NSAttributedString html document type</b>".convertHtmlToNSAttributedString
        demoLabel.attributedText = htmlAttributedText
        demoLabel.textColor = .white
    }
}

class WebViewController: UIViewController {
    
    let webView = WKWebView()
    let closeButton = UIButton(type: .close)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        view.backgroundColor = UIColor.black
        view.addSubview(closeButton)
        
        closeButton.pinTop(to: view, inset: 0.0, respectSafeArea: true)
        closeButton.pinLeft(to: view, inset: 8.0, respectSafeArea: true)
        closeButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        
        webView.pinEdges(to: view)
        webView.configuration.allowsInlineMediaPlayback = true
        if let url = URL(string: "https://addpipe.com/simple-web-audio-recorder-demo/") {
            webView.load(URLRequest(url: url))
        }
    }
    
    @objc func dismissViewController(sender: Any) {
        dismiss(animated: true)
    }
}

extension String {
    public var convertHtmlToNSAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue,
                ], documentAttributes: nil)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}


// MARK: Just some Constraints helpers . From here not important for the bug

extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0

        return String(format: "#%06x", rgb)
    }
}

extension UIView {
    
    func pinEdges(to targetView: UIView, inset: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: targetView.leadingAnchor, constant: inset),
            trailingAnchor.constraint(equalTo: targetView.trailingAnchor, constant: -inset),
            topAnchor.constraint(equalTo: targetView.topAnchor, constant: inset),
            bottomAnchor.constraint(equalTo: targetView.bottomAnchor, constant: -inset),
        ])
    }

    @discardableResult
    func pinBottom(to targetView: UIView, inset: CGFloat, respectSafeArea: Bool = false) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint
        
        if respectSafeArea {
            constraint = bottomAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.bottomAnchor, constant: inset)
        } else {
            constraint = bottomAnchor.constraint(equalTo: targetView.bottomAnchor, constant: inset)
        }
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func pinTop(to targetView: UIView, inset: CGFloat, respectSafeArea: Bool = false) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint
        
        if respectSafeArea {
            constraint = topAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.topAnchor, constant: inset)
        } else {
            constraint = topAnchor.constraint(equalTo: targetView.topAnchor, constant: inset)
        }
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func pinLeft(to targetView: UIView, inset: CGFloat, respectSafeArea: Bool = false) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint
        if respectSafeArea {
            constraint = leftAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.leftAnchor, constant: inset)
        } else {
            constraint = leftAnchor.constraint(equalTo: targetView.leftAnchor, constant: inset)
        }
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func pinRight(to targetView: UIView, inset: CGFloat, respectSafeArea: Bool = false) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        var constraint: NSLayoutConstraint
        if respectSafeArea {
            constraint = rightAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.rightAnchor, constant: inset)
        } else {
            constraint = rightAnchor.constraint(equalTo: targetView.rightAnchor, constant: inset)
        }
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func pinTopToBottom(of targetView: UIView, inset: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false

        let constraint = topAnchor.constraint(equalTo: targetView.bottomAnchor, constant: inset)
        constraint.isActive = true
        return constraint
    }

    func center(in targetView: UIView) {
        self.constraint(.centerX, to: targetView)
        self.constraint(.centerY, to: targetView)
    }
    
    /// Adds one or more constraints for the same attribute between the caller view and a target item.
    func constraint(
        _ attributes: NSLayoutConstraint.Attribute...,
        to targetItem: Any?,
        multiplier: CGFloat = 1,
        constant: CGFloat = 0
    ) {
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
        for attribute in attributes {
            if let targetItem = targetItem {
                NSLayoutConstraint(
                    item: self, attribute: attribute, relatedBy: .equal, toItem: targetItem, attribute: attribute, multiplier: multiplier,
                    constant: constant
                ).isActive = true
            } else {
                NSLayoutConstraint(
                    item: self, attribute: attribute, relatedBy: .equal, toItem: targetItem, attribute: .notAnAttribute, multiplier: multiplier,
                    constant: constant
                ).isActive = true
            }
        }
    }
    
    func centerVertical(in targetView: UIView, constant: CGFloat = 0) {
        self.constraint(.centerY, to: targetView, constant: constant)
    }
}

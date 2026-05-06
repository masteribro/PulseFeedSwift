//
//  PDFPageViewer.swift
//  PulseFeed
//
//  Created by Ibrahim Mohammed on 05/03/2026.
//

import SwiftUI
import PDFKit
import QuickLook

struct PDFPageViewer: UIViewControllerRepresentable {
    let documentURL: URL
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let pdfViewController = PDFPageViewController(documentURL: documentURL, isPresented: $isPresented)
        let navigationController = UINavigationController(rootViewController: pdfViewController)
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController.navigationBar.barStyle = .black
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

class PDFPageViewController: UIViewController {
    private let documentURL: URL
    @Binding private var isPresented: Bool
    
    private var pdfDocument: PDFDocument?
    private var pageControllers: [UIViewController] = []
    private var currentPageIndex = 0
    private var totalPages = 0
    
    private lazy var pageViewController: UIPageViewController = {
        let pvc = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [UIPageViewController.OptionsKey.interPageSpacing: 20]
        )
        pvc.dataSource = self
        pvc.delegate = self
        pvc.view.backgroundColor = .black
        return pvc
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPageIndicatorTintColor = .white
        control.pageIndicatorTintColor = .gray
        control.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        control.layer.cornerRadius = 15
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    init(documentURL: URL, isPresented: Binding<Bool>) {
        self.documentURL = documentURL
        self._isPresented = isPresented
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPDF()
        setupUI()
    }
    
    private func setupPDF() {
        pdfDocument = PDFDocument(url: documentURL)
        totalPages = pdfDocument?.pageCount ?? 0
        
        for i in 0..<totalPages {
            if let page = pdfDocument?.page(at: i) {
                let pageVC = PDFSinglePageViewController(page: page, pageIndex: i)
                pageControllers.append(pageVC)
            }
        }
        
        if let firstPage = pageControllers.first as? PDFSinglePageViewController {
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: false)
            currentPageIndex = 0
            pageControl.currentPage = 0
            pageControl.numberOfPages = totalPages
            firstPage.delegate = self
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.frame = view.bounds
        pageViewController.didMove(toParent: self)
        
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 30),
            pageControl.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
    }
    
    @objc private func closeTapped() {
        isPresented = false
        dismiss(animated: true)
    }
    
    func goToPage(index: Int) {
        guard index >= 0 && index < pageControllers.count else { return }
        
        let direction: UIPageViewController.NavigationDirection = index > currentPageIndex ? .forward : .reverse
        currentPageIndex = index
        
        if let pageVC = pageControllers[index] as? PDFSinglePageViewController {
            pageVC.delegate = self
            pageViewController.setViewControllers([pageVC], direction: direction, animated: true)
            pageControl.currentPage = index
        }
    }
}

extension PDFPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? PDFSinglePageViewController else { return nil }
        let index = currentVC.pageIndex
        return index > 0 ? pageControllers[index - 1] : nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? PDFSinglePageViewController else { return nil }
        let index = currentVC.pageIndex
        return index < pageControllers.count - 1 ? pageControllers[index + 1] : nil
    }
}

extension PDFPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let visibleVC = pageViewController.viewControllers?.first as? PDFSinglePageViewController {
            currentPageIndex = visibleVC.pageIndex
            pageControl.currentPage = currentPageIndex
        }
    }
}

extension PDFPageViewController: PDFSinglePageViewControllerDelegate {
    func pageTapped() {
        let isHidden = closeButton.isHidden
        closeButton.isHidden = !isHidden
        pageControl.isHidden = !isHidden
    }
}

protocol PDFSinglePageViewControllerDelegate: AnyObject {
    func pageTapped()
}

class PDFSinglePageViewController: UIViewController {
    let page: PDFPage
    let pageIndex: Int
    weak var delegate: PDFSinglePageViewControllerDelegate?
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.minimumZoomScale = 1.0
        sv.maximumZoomScale = 3.0
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.backgroundColor = .black
        return sv
    }()
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .black
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    init(page: PDFPage, pageIndex: Int) {
        self.page = page
        self.pageIndex = pageIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        renderPage()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupViews() {
        view.backgroundColor = .black
        
        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scrollView)
        
        scrollView.addSubview(imageView)
    }
    
    private func renderPage() {
        let pageBounds = page.bounds(for: .mediaBox)
        let scale = min(view.bounds.width / pageBounds.width, view.bounds.height / pageBounds.height) * 0.9
        
        let renderSize = CGSize(width: pageBounds.width * scale, height: pageBounds.height * scale)
        let image = page.thumbnail(of: renderSize, for: .mediaBox)
        
        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = image
            self?.imageView.frame = CGRect(origin: .zero, size: renderSize)
            self?.scrollView.contentSize = renderSize
            
            let xOffset = max(0, (self?.scrollView.bounds.width ?? 0) - renderSize.width) / 2
            let yOffset = max(0, (self?.scrollView.bounds.height ?? 0) - renderSize.height) / 2
            self?.scrollView.contentInset = UIEdgeInsets(top: yOffset, left: xOffset, bottom: yOffset, right: xOffset)
        }
    }
    
    @objc private func handleTap() {
        delegate?.pageTapped()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let image = imageView.image {
            let renderSize = image.size
            let xOffset = max(0, scrollView.bounds.width - renderSize.width) / 2
            let yOffset = max(0, scrollView.bounds.height - renderSize.height) / 2
            scrollView.contentInset = UIEdgeInsets(top: yOffset, left: xOffset, bottom: yOffset, right: xOffset)
        }
    }
}

extension PDFSinglePageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let xOffset = max(0, scrollView.bounds.width - scrollView.contentSize.width) / 2
        let yOffset = max(0, scrollView.bounds.height - scrollView.contentSize.height) / 2
        scrollView.contentInset = UIEdgeInsets(top: yOffset, left: xOffset, bottom: yOffset, right: xOffset)
    }
}

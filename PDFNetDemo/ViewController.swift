//
//  ViewController.swift
//  PDFNetDemo
//
//  Created by Ajinkya Paranjape on 17/06/19.
//  Copyright © 2019 Mobiuso. All rights reserved.
//

import UIKit
import PDFNet
import Tools

class ViewController: UIViewController, PTDocumentViewControllerDelegate, PTAnnotationToolbarDelegate {

    // Create a PTDocumentViewController
    let documentController = PTDocumentViewController()
    var isSelected = false
    
    @IBOutlet weak var buttonAnnotation: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.addChild(documentController)
        self.view.addSubview(documentController.view)
        // The PTDocumentViewController must be in a navigation controller before a document can be opened
        //let navigationController = UINavigationController(rootViewController: documentController)
        
        //  Assign Delegates
        documentController.delegate = self
        documentController.annotationToolbar.delegate = self
        
        //  Initialize PDFDoc object
        let pdfDoc = documentController.pdfViewCtrl.getDoc()
        if pdfDoc != nil {
            print("PDF Doc Found")
        }
        print("PDF Document: \(String(describing: documentController.pdfViewCtrl.getDoc()))")
        
        //deleteAllAnnotations(pdfViewCtrl: pdfViewController)
        
        // Open an existing local file URL.
        if let fileURL = Bundle.main.url(forResource: "test", withExtension: "pdf") {
            print("File Found!")
            documentController.openDocument(with: fileURL)
            
            // Show navigation (and document) controller.
            //self.present(navigationController, animated: true, completion: nil)
            
        } else {
            print("Error Occured")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //super.viewWillDisappear(true)
        if (self.isMovingFromParent || self.isBeingDismissed) {
            //  Handle Back Button Action
            deleteAllAnnotations(pdfViewCtrl: documentController.pdfViewCtrl)
        }
        
    }

    @IBAction func buttonAnnotationTapped(_ sender: UIBarButtonItem) {
        isSelected = !isSelected
        if (isSelected) {
            documentController.isAnnotationToolbarHidden = false
            
        } else {
            documentController.isAnnotationToolbarHidden = true
            
        }
    }
    
    //  MARK: -  PTDocumentController Delegate Methods
    func documentViewControllerDidOpenDocument(_ documentViewController: PTDocumentViewController) {
        print("Document Opened Successfully!")
    }
    
    func documentViewController(_ documentViewController: PTDocumentViewController, didFailToOpenDocumentWithError error: Error) {
        print("Document Failed To Open...Error!")
    }
    
    //  MARK: - PTAnnotationToolbar Delegate Methods
    func annotationToolbarDidCancel(_ annotationToolbar: PTAnnotationToolbar) {
        // Hide annotation toolbar when cancelled.
        documentController.isAnnotationToolbarHidden = true
        isSelected = false
        
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        // The annotation toolbar is usually positioned at the top of its superview.
        return .top;
    }
    
    func toolShouldGoBack(toPan annotationToolbar: PTAnnotationToolbar) -> Bool {
        return false
    }
    
    func deleteAllAnnotations(pdfViewCtrl: PTPDFViewCtrl) {
        var shouldUnlock = false
        do {
            pdfViewCtrl.docLock(true)
            shouldUnlock = true
            let itr = pdfViewCtrl.getPageCount()
            var count: Int32 = 0
            while (count < itr) {
                if let currentPage = pdfViewCtrl.getDoc()?.getPage(UInt32(count+1)) {
                    let page: PTPage = currentPage
                    var annotCount = page.getNumAnnots()
                    while (annotCount > 0) {
                        page.annotRemove(with: 0)
                        annotCount = page.getNumAnnots()
                    }
                    //pdfViewCtrl.update(true)
                }
                count += 1
            }
            pdfViewCtrl.update(true)
        }
        
        if (shouldUnlock) {
            pdfViewCtrl.docUnlock()
            
        }
    }
    
}


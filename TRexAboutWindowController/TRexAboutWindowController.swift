//
//  TRexAboutWindowController.swift
//  T-Rex
//
//  Created by David Ehlen on 24.07.15.
//  Copyright © 2015 David Ehlen. All rights reserved.
//

import Cocoa

open class TRexAboutWindowController : NSWindowController {
    open var appName : String = ""
    open var appVersion : String = ""
    open var appVersionExtended : String = ""
    open var appVersionExtendedColor : NSColor = NSColor.lightGray
    open var appCopyright : NSAttributedString
    open var appCredits : NSAttributedString?
    open var appEULA : NSAttributedString?
    open var appCreditsURL : URL?
    open var appEULAURL : URL?
    open var appURL : URL?
    open var textShown : NSAttributedString
    open var windowState : Int = 0
    open var windowShouldHaveShadow: Bool = true
    
    @IBOutlet var infoView: NSView!
    @IBOutlet var textField: NSTextView!
    @IBOutlet var visitWebsiteButton: NSButton!
    @IBOutlet var EULAButton: NSButton!
    @IBOutlet var creditsButton: NSButton!
    @IBOutlet var versionLabel: NSTextField!
    @IBOutlet weak var extendedVersionLabel: NSTextField!
    
    override init(window: NSWindow?) {
        appCopyright = NSAttributedString()
        textShown = NSAttributedString()
        super.init(window: window)
    }
    
    required public init?(coder: NSCoder) {
        appCopyright = NSAttributedString()
        textShown = NSAttributedString()
        super.init(coder: coder)
    }
    
    override open func windowDidLoad() {
        super.windowDidLoad()
        windowState = 0
        infoView.wantsLayer = true
        infoView.layer!.cornerRadius = 10.0
        infoView.layer!.backgroundColor = NSColor.white.cgColor
        window?.backgroundColor = NSColor.white
        window?.hasShadow = windowShouldHaveShadow
        
        if appName.characters.count <= 0 {
            appName = valueFromInfoDict("CFBundleName")
        }
        
        if appVersion.characters.count <= 0 {
            let version = valueFromInfoDict("CFBundleVersion")
            let shortVersion = valueFromInfoDict("CFBundleShortVersionString")
            appVersion = String(format: NSLocalizedString("Version %@ (Build %@)", comment: "Version %@ (Build %@), displayed in the about window"), shortVersion, version)
            versionLabel.stringValue = appVersion
        }

        extendedVersionLabel.stringValue = appVersionExtended
        extendedVersionLabel.textColor = appVersionExtendedColor
        
        if appCopyright.string.characters.count <= 0 {
            if floor(NSAppKitVersionNumber) <= Double(NSAppKitVersionNumber10_9) {
                let font:NSFont? = NSFont(name: "HelveticaNeue", size: 11.0)
                let color:NSColor? = NSColor.lightGray
                let attribs:[String:AnyObject] = [NSForegroundColorAttributeName:color!,
                                                  NSFontAttributeName:font!]
                appCopyright = NSAttributedString(string: valueFromInfoDict("NSHumanReadableCopyright"), attributes:attribs)
            }
            else {
                let font:NSFont? = NSFont(name: "HelveticaNeue", size: 11.0)
                let color:NSColor? = NSColor.tertiaryLabelColor
                let attribs:[String:AnyObject] = [NSForegroundColorAttributeName:color!,
                                                  NSFontAttributeName:font!]
                appCopyright = NSAttributedString(string: valueFromInfoDict("NSHumanReadableCopyright"), attributes:attribs)
            }
        }
        
        if appCredits == nil {
            if let creditsRTF = Bundle.main.path(forResource: "Credits", ofType: "rtf") {
                appCredits = NSAttributedString(path: creditsRTF, documentAttributes: nil)!
            }
            else {
                if appCreditsURL == nil {
                    creditsButton.isHidden = true
                }
            }
        }

        if appEULA == nil {
            if let eulaRTF = Bundle.main.path(forResource: "EULA", ofType: "rtf") {
                appEULA = NSAttributedString(path: eulaRTF, documentAttributes: nil)!
            }
            else {
                if appEULAURL == nil {
                    EULAButton.isHidden = true
                }
            }
        }
        
        textField.textStorage!.setAttributedString(appCopyright)
        creditsButton.title = NSLocalizedString("Credits", comment: "Caption of the 'Acknowledgments' button in the about window")
        EULAButton.title = NSLocalizedString("EULA", comment: "Caption of the 'License Agreement' button in the about window")
    }
    
    @IBAction func visitWebsite(_ sender: AnyObject) {
        guard let url = appURL else { return }
        
        NSWorkspace.shared().open(url)
    }
    
    @IBAction func showCredits(_ sender: AnyObject) {
        if let appCredits = appCredits {
            if windowState != 1 {
                let amountToIncreaseHeight:CGFloat  = 100
                var oldFrame:NSRect = window!.frame
                oldFrame.size.height += amountToIncreaseHeight
                oldFrame.origin.y -= amountToIncreaseHeight
                window!.setFrame(oldFrame,display:true, animate:true)
                windowState = 1
            }
            textField.textStorage!.setAttributedString(appCredits)
        }
        else {
            if let appCreditsURL = appCreditsURL {
                NSWorkspace.shared().open(appCreditsURL)
            }
        }
    }
    
    @IBAction func showEULA(_ sender: AnyObject) {
        if let appEULA = appEULA {
            if windowState != 1 {
                let amountToIncreaseHeight:CGFloat  = 100
                var oldFrame:NSRect = window!.frame
                oldFrame.size.height += amountToIncreaseHeight
                oldFrame.origin.y -= amountToIncreaseHeight
                window!.setFrame(oldFrame,display:true, animate:true)
                windowState = 1
            }
            textField.textStorage!.setAttributedString(appEULA)
        }
        else {
            if let appEULAURL = appEULAURL {
                NSWorkspace.shared().open(appEULAURL)
            }
        }
    }
    
    @IBAction func showCopyright(_ sender: AnyObject) {
        if windowState != 0 {
            let amountToIncreaseHeight:CGFloat  = -100
            var oldFrame:NSRect = window!.frame
            oldFrame.size.height += amountToIncreaseHeight
            oldFrame.origin.y -= amountToIncreaseHeight
            window!.setFrame(oldFrame,display:true, animate:true)
            windowState = 0
        }
        
        textField.textStorage!.setAttributedString(appCopyright)
    }
    
    open func windowShouldClose(_ sender: AnyObject) -> Bool {
        showCopyright(sender)
        return true
    }
    
    override open func showWindow(_ sender: Any?) {
        super.showWindow(sender)
    }
    
    //Private
    fileprivate func valueFromInfoDict(_ string:String) -> String {
        let dictionary = Bundle.main.infoDictionary!
        let result = dictionary[string] as! String
        return result
    }
}

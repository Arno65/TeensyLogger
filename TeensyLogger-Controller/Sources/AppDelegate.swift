//
//  AppDelegate.swift
//
//    ----------------------------------------------------------------------------------------------------
//      This project was started with XCode 13.4 on june 2022.
//      The main language was Swift 5.0
//      This code uses the ORSSerialPort Framework, and the Objective-C source code (2014) is used.
//      A part of the 'fft.swift' was created by Christopher Helf on 17.08.15.
//    ----------------------------------------------------------------------------------------------------
//
//  From... ORSSerialPortSwiftDemo
//
//  Created by Andrew Madsen on 10/31/14.
//  Copyright (c) 2014 Open Reel Software. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a
//	copy of this software and associated documentation files (the
//	"Software"), to deal in the Software without restriction, including
//	without limitation the rights to use, copy, modify, merge, publish,
//	distribute, sublicense, and/or sell copies of the Software, and to
//	permit persons to whom the Software is furnished to do so, subject to
//	the following conditions:
//	
//	The above copyright notice and this permission notice shall be included
//	in all copies or substantial portions of the Software.
//	
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// (cl)  Spring, Summer, Autumn 2022  by Arno Jacobs
//
// See 'SerialPortController.swift' for version information.
//

import Cocoa

// Reading the mouse position can only be done in AppDelegate.swift but is needed in SerialPortController.swift
// These to global variables are use to store the mouse position on the main window.
var mousePositionX:Int  = -1
var mousePositionY:Int  = -1

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    // Needed for mouse pointer location on the main window
    var location: NSPoint { window.mouseLocationOutsideOfEventStream }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
            // Mouse position on this active view (window)
            mousePositionX = Int(self.location.x)       // Scaling will be done in 'SerialPortController.swift'
            mousePositionY = Int(self.location.y)       // after a mouse click on the canvas
            return $0
        }
    }
}



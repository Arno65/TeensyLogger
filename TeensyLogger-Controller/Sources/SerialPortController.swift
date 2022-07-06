//
//  SerialPortController.swift
//
//  Based on code from... ORSSerialPortSwiftDemo
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
// (cl)  Spring, Summer 2022  by Arno Jacobs
//
//  version 1.0a    2022-06-09      Stripped the ORSSerialPortSwiftDemo to the minimum
//                                  You still need to select the serial port manually :-(
//                                  The rest is 0K - for so far
//  version 1.0b    2022-06-10      Can access port directly via code - no menu needed - so point 1 from W.T.D.
//                                  Sending serial was easy but reading was harder - is working 0K now.
//                                  Set correct font for TextView is working 0K now.
//  version 1.0c    2022-06-16      Serial I/O 0K for now, working on graphics - standard time scaled plot is working 0K
//                                  (x,y) plot only for channels 1 and 2 -- there are some dummy data sets
//                                  Added averge of 5 ('hard coded 5') consecutive data points
//  version 1.0d    2022-06-17      Added multiple (x,y) plots and sample & division time labels
//  version 1.1a    2022-06-20      De extra hardware between the 8 inputs and the Teensy 4.0 board had a flaw.
//                                  The 1V65 'centre' Voltage part introduced a lot o noise on all 8 attenuators.
//                                  Did fix that issue.
//                                  Recalibrated the Teensy Logger for -10V00, 0V0 and +10V00 and
//                                  changed calibration data in this code
//  version 1.2a    2022-06-21      Changed the Teensy code a bit so command 'dump' can be done automatically
//                                  And if the list has all it's data the plot will start automatically.
//  version 1.2b    2022-06-23      Added short-keys and menu items
//                                  Started 'save' & 'open' of settings and data -- NO conversion yet...
//                                  Planning 'save' data ready for GnuPLot
//  version 1.4a    2022-06-24      Added a "current setup and data set" save to a JSON formatted file
//                                  Reshaped the x and y axis for different plot types
//  version 1.4c    2022-06-25      Added a "setup and data set" load from a JSON formatted file
//                                  Refactor - more functional - 'initCanvas'
//                                  Added sample frequency - request from Rob Jansen ;-)
//  version 1.5a    2022-06-27      The source code for ORSSerialPort is added
//                                  The mouse click info on the oscilloscope canvas is working for
//                                  time based- and (x,y)-plots
//  version 1.5b    2022-06-28      Serial IO error - debug for fail connection
//                                  Working on Help window - does not go at all, for what I want.
//  version 1.5c    2022-06-29      Refactoring the helper information - rich text over the oscilloscope canvas
//                                  First version to be pushed to my GitHub page (Arno65)
//  version 1.5s    2022-06-30      First draft for stream mode - (x,y) plot for first 2 channels ONLY
//  version 1.5t    2022-07-01      Refactor graphical part - plot constants' go global  to speed up stream mode.
//  version 1.5u    2022-07-06      (Automatic) Match oversampling degree with a maximum of sample speed, a range check
//
//
//  W.T.D.
//     ~1.      Automatic selection of the correct TeensyLogger port - select one time, use many times.
//                  Can't do this safely. The USB port has a different name on each different Mac.
//                  The current Pop Up Button is working good enough.
//     !2.      Automatic initialisation of the TeensyLogger
//                  Can work with open & save setup and data options.
//                  I once thought ~ Will not work. Rethink this requirment.
//     ~2.II.   JSON formatted save files - open and save are working -- open recent will not do for the time being...
//     ~3.      Simple square shaped plot (X,Y) in the range -10...+10V for both axis.
//                  0K. Done. For all even number selected inputs.
//                  So one (x,y)-plot if 2 inputs are selected and four (x,y)-plots if 8 inputs are selected.
//     ~3.II.   Reshape the scale for timed plot. Move the y-axis to the left.
//     ~4.      More text info on main window. Like 1 V/div with (x,y)-plot.
//     !5.      Zoomed view of plot. Example: (x,y) plot in a range [0V..5V], zoom to this range. Or just one quadrant
//              Will not do that in the near future (but is possible)
//     ~6.      Hint info with mouse click on oscilloscope view. Click a point on the view and show it's corresponding values.
//              There is time and Voltage info from a mouse click on the oscilloscope canvas.
//     .7.      Refactor to clean code - delete all dummy's and unnecessary doubles
//              The crosses on the plots can be more compact as functions.
// -->  8.      Spectrum analysis and other mathematical tricks. (Derivative of the line on a point.)
//              This can be done with other apps. Using the JSON as input for analysis.
//     ~9.      The serial I/O code (ORSSerialPort) needs recompilation for release version.
//              A previous version had de Framework compiled for Intel only.
//              Now the source code is integrated and the project can be compiled for Intel and Apple M1
//     ~10.     A functioning HELP window.
//     .11.     Implement a 'stream mode' on the TeensyLogger. After that add that functionality to this app.
//              Only done for (x,y)-plot  -  yet
// -->  12.     Export data to *.csv (for spreadsheets) and a formatted version for GnuPlot.
//              (Like nr.8) This can be done with other apps. Using the JSON as input for conversion.
// -->  13.     Optional zoom in with time based plot on time scale - BUT HOW? - as... from -3 Volt ... + 5.5 Volt ???
// -->  14.     Optional zoom in with (x,y) plot on quadrant - just make a dropdown for [All @ 10 Volt, All @ 5 Volt, Q1, Q2, Q3, Q4]
// -->  15.     Optional inversion of X-axis and/or Y-axis (to skip the use of inverters on the A.C.)
// -->  16.     Optional Z-axis, 2D plot with (line/point) intensity for the Z-axis.
//
/*
        Most of the user I/O options can be accessed by key equivalents (hotkeys.)
 
        All those options are combinations of the command key (⌘) and a (shift-less) standar keyboard character.

         (⌘A)       status                  (TL)
         (⌘B)       baud rate               (TL)
         (⌘C)       (dis)connect            (TL)
         (⌘D)       plot (term. data)       (TL)
         (⌘E)       send (manual command)   (TL)
         (⌘G)       oversampling            (init TL)
         (⌘H)       hide app.               (main menu)
         (⌘I)       initialize              (TL)
         (⌘L)       clear                   (terminal)
         (⌘M)       minimize                (main menu)
         (⌘O)       open                    (main menu)
         (⌘P)       select serial port      (TL)
         (⌘Q)       quit                    (main menu)
         (⌘R)       init & start            (TL)
         (⌘S)       save                    (main menu)
         (⌘X)       plot (style)            (oscilloscope view)
         (⌘?)       help                    (main menu)
         (⌘=)       start                   (TL)
         (⌘-)       stop                    (TL)
         (⌘.)       stream                  (TL)
         (⌘1)       channels                (TL)

*/
/*
    Info from the TeensyLogger

        Teensy 4.0 data recorder 1.2s   - - - - - - - - - - -
        ?               Show this help
        arm             Arm recorder, start by trigger or command
        channels=x      Set number of channels to x [1..8]
        dump            Display raw samples on multiple lines
        interval=x      Set the sampling interval to x microseconds
        ms=x            Set the number of samples (max. 24576)
        oversampling=x  Set degree of oversampling as 2**x
        stream          Start continuous data acquisition & display
        start           Start data acqusition (first arm system)
        status          Show the current status information
        stop            Stop a running/continuous data acquisition
*/

import Cocoa
import ORSSerial

// Outside the SerialPortController-class
// In the function "sendCommand" this constant is used as a default value
let standardSleepTime: UInt32 = 101     // This is just a bit more than the timeout set
                                        // in the Teensy 4.0 module for serial I/O
let maxChannels = 8


class SerialPortController: NSObject, NSApplicationDelegate, ORSSerialPortDelegate {

	@objc let serialPortManager = ORSSerialPortManager.shared()         // usbmodem101899901
	@objc let availableBaudRates = [115200,57600,9600,1200]
    
    @objc dynamic var serialPort: ORSSerialPort? {
		didSet {
			oldValue?.close()
			oldValue?.delegate = nil
            serialPort?.delegate = self
            serialPort?.baudRate = 115200
            serialPort?.parity = .none
            serialPort?.numberOfStopBits = 1
		}
	}
	
    
	@IBOutlet weak var openCloseButton: NSButton!
    @IBOutlet weak var sendTextField: NSTextField!
    @IBOutlet weak var sendButton: NSButton!
    @IBOutlet var baudRateSelector: NSPopUpButton!
    @IBOutlet var receivedDataTextView: NSTextView!

    @IBOutlet weak var numberOfChannels: NSPopUpButton!
    @IBOutlet weak var intervalTime: NSTextField!
    @IBOutlet weak var numberOfSamples: NSTextField!
    @IBOutlet weak var degreeOfOversampling: NSPopUpButton!
    
    @IBOutlet weak var plotStyle: NSPopUpButton!
    
    @IBOutlet weak var serialPortLabel: NSTextField!
    @IBOutlet weak var baudRateLabel: NSTextField!
    
    @IBOutlet weak var statusTeensyLogger: NSTextField!
    @IBOutlet weak var mouseClickSample: NSTextField!
    @IBOutlet var helpRichText: NSTextView!
    @IBOutlet weak var helpRichTextScroller: NSScroller!
    
    @IBOutlet weak var sampleFrequency: NSTextField!
    @IBOutlet weak var sampleTime: NSTextField!
    @IBOutlet weak var sampleTimeUnit: NSTextField!
    @IBOutlet weak var divisionTime: NSTextField!
    @IBOutlet weak var divisionTimeUnit: NSTextField!
    @IBOutlet weak var divisionTimeLabel: NSTextField!
    @IBOutlet weak var divisionYaxis: NSTextField!
    
    @IBOutlet weak var changePort: NSPopUpButton!
    @IBOutlet weak var changeBaudRate: NSPopUpButton!
    
    @IBOutlet weak var canvas: NSImageView!
    
    // Get current application version - for JSON output
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

    var checkSelectedOpen   = false
    var checkArmed          = false
    
    let tlReady     = "The TeensyLogger is ready for use"
    let tlNOTReady  = "The TeensyLogger is NOT connected"
    let sConnect    = "connect"
    let sDisconnect = "disconnect"
   
    // Teensy Logger commands
    let tl_channels = "channels"
    let tl_oversmpl = "oversampling"
    let tl_interval = "interval"
    let tl_samples  = "ms"
    let tl_arm      = "arm"
    let tl_start    = "start"
    let tl_stop     = "stop"
    let tl_dump     = "dump"
    let tl_status   = "status"
    let tl_stream   = "stream"
    let sEq         = "="
    
    // JSON helper strings
    let json_channels   = "channelsIndex"
    let json_oversmpl   = "oversamplingIndex"
    let json_interval   = "intervalValue"
    let json_samples    = "samplesValue"
    let json_plotStIx   = "plotstyleIndex"

    // Data -> action helper codes
    let EoDDC       = "!$ "     // End of Data Dump characters
    let SASC        = "~$ "     // Sampling automatic stopped... characters

    var needsInit               = true
    let availableChannels       = ["1","2","3","4","5","6","7","8"]
    let availableOversampling   = ["0","1","2","3","4"]
    let availablePlotStyles     = ["time","time [avg.]","(x,y)","(x,y) [avg.]"]
    let initialOSS              = "3"
    
    // These are the calibrated values for -10V0, 0V0 and +10V0
    // In my case the eight channels of the TeensyLogger calibrated to the same values
    let calibratedMinus10V0 = [200,200,201,200,201,200,201,200]
    let calibrated0V0       = [510,511,511,509,512,512,512,511]
    let calibratedPlus10V0  = [821,822,821,821,821,821,821,821]
    let maxDepth    = 24576     // Maximum of samples per run - this number is bound by the amount of RAM on the Teensy 4.X
    let zeroVolt    = 0
    let oneVolt     = 1
//    let twoVolt     = 2
    let fiveVolt    = 5
    let tenVolt     = 10
    let twelveVolt  = 12

    // Time scale help
    let sSeconds        = "s."
    let sMilliseconds   = "ms."
    let sMicroseconds   = "µs."
    let sNanoseconds    = "ns."
    
    // Line feed character
    let sLF = "\n"

    /*
     New calibation data - data created with better TL hardware on 2022-06-20:

     Analog input port                                A0  A1  A2  A3  A4  A5  A6  A7
     Data from: TL-Avg-2/Avg0V0-run-1.txt           [509,511,511,508,512,512,512,511]
     Data from: TL-Avg-2/Avg0V0-run-2.txt           [511,511,512,509,513,512,512,511]
     Data from: TL-Avg-2/Avg0V0-run-3.txt           [510,511,511,509,512,512,512,511]   Check
     Data from: TL-Avg-2/Avg0V0-run-4.txt           [509,511,511,508,512,512,512,511]
     Data from: TL-Avg-2/Avg9V995.txt               [821,822,821,821,821,821,821,821]   Check
     Data from: TL-Avg-2/AvgMinus9V995.txt          [200,200,201,200,201,200,201,200]   Check
     */
    
    var plotPoints:[[Int]] = [] // Now an empty list for all plot points for all 8 channels.
    
    var streamPoints:[Int]  = []
    var streamMode:Bool     = false
    var streamStart:Bool    = true
    let streamEndString     = "$$ Streaming stopped."
    let streamPath          = NSBezierPath()
    
    var image = NSImage()
    
    let avgSamples = 10     // At this point the average value is taken over ten (10) consecutive data points
    
    let bgColour    = NSColor(red: 0.0, green: 0.10, blue: 0.05, alpha: 1.0)
    let pointColour = NSColor(red: 0.9, green: 0.20, blue: 0.15, alpha: 1.0)
    let gridColour  = NSColor(red: 0.0, green: 0.80, blue: 0.15, alpha: 1.0)

    let channelColours   = [ NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),          // colour for channel 1 plot
                             NSColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0),          // and        channel 2...
                             NSColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),
                             NSColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),          // and...
                             NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
                             NSColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),          //           channel 6...
                             NSColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0),
                             NSColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0) ]         // and   for channel 8

    
    // Get some graphical sizes
    var px:CGFloat  = 0
    var py:CGFloat  = 0
    let oX:Int      = 20         // the origin starting point of the canvas on the main window is (20,20)
    let oY:Int      = 20         // I'm not able to retrieve these numbers via code.
    var x0:Int      = 0
    var y0:Int      = 0
    var V1:Int      = 0
    var canvas_size = NSMakeSize(0,0)
    var correctionFactorPlus  = Array(repeating: Float(0), count: maxChannels)
    var correctionFactorMinus = Array(repeating: Float(0), count: maxChannels)
    let milli2micro:Double  = 1e3
    let unit2micro:Double   = 1e6

    
    func initValues() {
        // First some graphical 'constants'
        px = canvas.visibleRect.width       // Get the canvas size
        py = canvas.visibleRect.height
        x0 = Int(px / 2)                    // Centre (x,y) point
        y0 = Int(py / 2)
        V1 = Int(px / 24)                   // There are 24 divisions per axis on the canvas
        canvas_size = NSMakeSize(px,py)

        for ci in 0...maxChannels-1 {
            correctionFactorPlus[ci]  = Float (tenVolt*V1) / Float (calibratedPlus10V0[ci] - calibrated0V0[ci])
            correctionFactorMinus[ci] = Float (tenVolt*V1) / Float (calibrated0V0[ci] - calibratedMinus10V0[ci])
        }

        // First time init code...
        if needsInit {
            numberOfChannels.removeAllItems()
            numberOfChannels.addItems(withTitles: availableChannels)
            
            degreeOfOversampling.removeAllItems()
            degreeOfOversampling.addItems(withTitles: availableOversampling)
            degreeOfOversampling.setTitle(initialOSS)
            
            plotStyle.removeAllItems()
            plotStyle.addItems(withTitles: availablePlotStyles)
                
            // Hide the (ugly) scroll bar on the help screen
            helpRichTextScroller.isHidden = true
            
            needsInit = false
        }
        
        streamMode = false
        updateSampleAndDivisionTime()
        mouseClickSample.stringValue = "..."
    }
    
    
    func cleanTextView() {
        // If the string is completely cleared with a "" than the font changes. Ugh...
        receivedDataTextView.textStorage?.mutableString.setString(sLF);
        receivedDataTextView.needsDisplay = true
        initValues()
        showCanvas()
    }
    

    func sendCommand (send sendString: String, sleep st: UInt32 = standardSleepTime) {
        if checkSelectedOpen {
            if let sendCMD = sendString.data(using: String.Encoding.utf8) {
                self.serialPort!.send(sendCMD)
                usleep(1000*st)
            }
        }
    }
    
    
    // Now test for a sequence
    @IBAction func armTL(_ sender: Any) {
        streamMode = false
        updateSampleAndDivisionTime()
        // Read from window...
        // Channels, interval, number of samples and oversampling
        // Send the commands with the set values
        // As an extra, show current status of the TeensyLogger in the terminal window
        // And ARM
        let nch     = Int(availableChannels[numberOfChannels.indexOfSelectedItem]) ?? 1
        var itime   = Int(intervalTime.stringValue) ?? 0        // And check for correct int value in range
        if itime < 0 { itime = 0 }
        intervalTime.stringValue = String(itime)
        var nsm     = Int(numberOfSamples.stringValue) ?? 0     // Check for correct int vallue in range
        if nsm < 0 || nsm > maxDepth { nsm = 0 }                   // Check for range in the TeensyLogger Teensy 4.0 code
        numberOfSamples.stringValue = String(nsm)
        let dovs    = Int(availableOversampling[degreeOfOversampling.indexOfSelectedItem]) ?? 4
        
        // Only arm for useful or workable values
        if itime > 0 && nsm > 0 {
            let snch    = tl_channels + sEq +   String(nch)
            let sitime  = tl_interval + sEq +   String(itime)
            let sms     = tl_samples + sEq +    String(nsm)
            let sdovs   = tl_oversmpl + sEq +   String(dovs)
            
            sendCommand(send: snch)
            sendCommand(send: sitime)
            sendCommand(send: sms)
            sendCommand(send: sdovs)
            sendCommand(send: tl_status)
            sendCommand(send: tl_arm)
        }
    }
    
    
    @IBAction func startTL(_ sender: Any) {
        streamMode = false
        sendCommand(send: tl_start)
        showCanvas()
    }
    
    
    @IBAction func initializeAndStart(_ sender: Any) {
        streamMode = false
        armTL(self)
        startTL(self)
    }
    
    
    @IBAction func stopTL(_ sender: Any) {
        streamMode = false
        sendCommand(send: tl_stop)
        showCanvas()
    }
    

    @IBAction func plotStreamTL(_ sender: Any) {
        showDataPlot()
    }
    
    
    @IBAction func statusTL(_ sender: Any) {
        updateSampleAndDivisionTime()
        sendCommand(send: tl_status)
    }
    
    
    @IBAction func streamModeTL(_ sender: Any) {
        // Don't forget to initialize and arm the TeensyLogger
        cleanTextView()
        initCanvas()
        streamMode  = true
        streamStart = true
        image.lockFocus()
        sendCommand(send: tl_stream, sleep: 200)
    }
    

    func dumpTL() {
        cleanTextView()
        sendCommand(send: tl_dump)
        showDataPlot()
    }
    
    
    func updateSampleAndDivisionTime() {
        let iIT0    = Int(intervalTime.stringValue) ?? 0
        let iNS     = Int(numberOfSamples.stringValue) ?? 0
        let ixDOS   = Int(availableOversampling[degreeOfOversampling.indexOfSelectedItem]) ?? 0
        var st:Float = 0.0
        var dt:Float = 0.0
        var hsss = sSeconds
        var hdss = sSeconds
                
        // First check & change the relation between the degree of oversampling and the sample interval time.
        // While testing my system it showed that there is a minimal sample interval time or maximum sample speed
        // depending on the chosen degree of oversampling. This dependence is shown in the next table.
        //
        // Oversampling         minimal sample interval time
        //      4                   60 µs.
        //      3                   30 µs.
        //      2                   20 µs.
        //      1                   16 µs.
        //      0                    4 µs.
        
        // Keep the selected oversampling degree and match to a minimal interval time
        let msit:[Int] = [4,16,20,30,60]
        let iIT = max( iIT0, msit[ixDOS] )
        let tus = iIT * iNS

        // Change interval time on view if needed...
        if (iIT != iIT0) { intervalTime.stringValue = String(iIT) }
        
        // seconds?
        if tus >= 1000000 {
            st = Float(tus) / 1000000
            dt = st / 20
            if (dt < 1.0) {
                dt *= 1000
                hdss = sMilliseconds
            }
        } else {
            // milliseconds?
            if tus >= 1000 {
                st = Float(tus) / 1000
                hsss = sMilliseconds
                hdss = sMilliseconds
                dt = st / 20
                if (dt < 1.0) {
                    dt *= 1000
                    hdss = sMicroseconds
                }
            } else {
            // microseconds
                st = Float(tus)
                hsss = sMicroseconds
                hdss = sMicroseconds
                dt = st / 20
                if (dt < 1.0) {
                    dt *= 1000
                    hdss = sNanoseconds // nano seconds ???
                }
            }
        }
        
        // Calculate sample frequency in Hz.
        let sf: Double = unit2micro / Double(iIT)
        if sf >= 10     { sampleFrequency.stringValue = String(format: "%.1f", sf) }
        else
            if sf >= 1  { sampleFrequency.stringValue = String(format: "%.2f", sf) }
            else        { sampleFrequency.stringValue = String(format: "%.4f", sf) }

        sampleTime.stringValue          = String(format: "%.4f", st)
        sampleTimeUnit.stringValue      = hsss
        divisionTime.stringValue        = String(format: "%.4f", dt)
        divisionTimeUnit.stringValue    = hdss

        mouseClickSample.stringValue = "..."
    }

    
    
    @IBAction func changeOversampling(_ sender: Any) {
        updateSampleAndDivisionTime()
    }
    
    @IBAction func changeSampleInterval(_ sender: Any) {
        updateSampleAndDivisionTime()
    }
    

    @IBAction func changeNumberOfSamples(_ sender: Any) {
        updateSampleAndDivisionTime()
    }
    
    
    func serialPort(_ poort: ORSSerialPort, didReceive data: Data) {
        if let hData = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            let newLines = String(hData)
            let lines = newLines.split(whereSeparator: \.isNewline)

            if !lines.isEmpty {
                if (lines[0] == streamEndString) {
                    streamMode = false
                }
                if streamMode {
                    let spoints = lines[0].split(whereSeparator: \.isPunctuation)
                    if spoints.endIndex > 1 {
                        image.lockFocus()
                        channelColours[0].set()
                        // get raw data and transform to (x,y) plot data
                        let strX = Int(spoints[0]) ?? 0
                        let strY = Int(spoints[1]) ?? 0
                        var xpos = Float(strX - calibrated0V0[0])
                        var ypos = Float(strY - calibrated0V0[1])
                        if xpos < 0 {
                            xpos *= correctionFactorMinus[0]
                        } else {
                            xpos *= correctionFactorPlus[0]
                        }
                        if ypos < 0 {
                            ypos *= correctionFactorMinus[1]
                        } else {
                            ypos *= correctionFactorPlus[1]
                        }
                        
                        if streamStart {                        // Only plot stream in (x,y) with first two channels.
                            streamStart = false
                            streamPath.removeAllPoints()        // start with NO points... and MOVE to starting point
                            streamPath.move(to: NSPoint( x: x0 + Int(xpos), y: y0 + Int(ypos) ))
                        } else {
                            streamPath.line(to: NSPoint( x: x0 + Int(xpos), y: y0 + Int(ypos) ))
                        }
                        streamPath.stroke()
                        image.unlockFocus()
                        canvas.needsDisplay = true
                    }
                }
            }
            
            receivedDataTextView.textStorage?.mutableString.append(newLines)
            receivedDataTextView.scrollToEndOfDocument(self)
            receivedDataTextView.needsDisplay = true
            
            let lc = lines.endIndex - 1
            if (lc>0) {
                if (lines[lc] == SASC) {
                    dumpTL()
                } else
                    if (lines[lc] == EoDDC) {
                        showDataPlot()
                    }
            }
        }
    }

    
	@IBAction func send(_: Any) {
        if checkSelectedOpen {
            let sendString = self.sendTextField.stringValue
            if let sendData = sendString.data(using: String.Encoding.utf8) {
                self.serialPort?.send(sendData)
            }
        }
	}
	
    
	@IBAction func returnPressedInTextField(_ sender: Any) {
//		sendButton.performClick(sender)
        send(self)
        mouseClickSample.stringValue = "..."
	}
	
    
    // This is probably the first thing a user will do
    // Start the nessesary software initializations
    @IBAction func changeSerialPort(_ sender: Any) {
        initValues()
    }
    
    
    
	@IBAction func openOrClosePort(_ sender: Any) {
        updateSampleAndDivisionTime()

        // Serial IO Error helper
        if openCloseButton.title == sConnect && openCloseButton.isEnabled && !changePort.isEnabled {
            changePort.isEnabled = true
            changeBaudRate.isEnabled = true
            serialPortLabel.isEnabled = true
            baudRateLabel.isEnabled = true
        } else {
            if let port = self.serialPort {
                if (port.isOpen) {
                    port.close()
                    sendTextField.isEnabled     = false
                    sendButton.isEnabled        = false
                    self.statusTeensyLogger.stringValue = tlNOTReady
                    checkSelectedOpen = false
                    serialPortLabel.isEnabled = true
                    baudRateLabel.isEnabled = true
                    changePort.isEnabled = true
                    changeBaudRate.isEnabled = true
                } else {
                    port.open()
                    cleanTextView()
                    initCanvas()
                    sendTextField.isEnabled     = true
                    sendButton.isEnabled        = true
                    self.statusTeensyLogger.stringValue = tlReady
                    checkSelectedOpen = true
                    changePort.isEnabled = false
                    changeBaudRate.isEnabled = false
                    mouseClickSample.stringValue = "..."
                    serialPortLabel.isEnabled = false
                    baudRateLabel.isEnabled = false
                }
            }
        }
    }
	
    
	@IBAction func clear(_ sender: Any) {
        cleanTextView()
	}
	
    
	// MARK: - ORSSerialPortDelegate
	func serialPortWasOpened(_ serialPort: ORSSerialPort) {
		openCloseButton.title = sDisconnect
	}
	
    
	func serialPortWasClosed(_ serialPort: ORSSerialPort) {
		openCloseButton.title = sConnect
        serialPortLabel.isEnabled = true
        baudRateLabel.isEnabled = true
        changePort.isEnabled = true
        changeBaudRate.isEnabled = true
	}
	
    
	func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        self.serialPort = nil
		openCloseButton.title = sConnect
        openCloseButton.isEnabled = false
        checkSelectedOpen = false
        changePort.isEnabled = true
        changeBaudRate.isEnabled = true
        serialPortLabel.isEnabled = true
        baudRateLabel.isEnabled = true
	}
	
    
	func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        infoView(title: "Serial port fail!", message: "SerialPort \(serialPort) encountered an error: \(error)")
        changePort.isEnabled = true
        changeBaudRate.isEnabled = true
        serialPortLabel.isEnabled = true
        baudRateLabel.isEnabled = true
    }

    
    
    func matchChannelsWithPlotStyle() {
        // Match channels with selected plot style
        let nch  = Int(availableChannels[numberOfChannels.indexOfSelectedItem]) ?? 1
        var psix = plotStyle.indexOfSelectedItem
        
        if (nch%2==1 && psix>=2) { psix -= 2 }
        if psix >= 2{
            divisionTime.isHidden       = true
            divisionTimeUnit.isHidden   = true
            divisionTimeLabel.isHidden  = true
            divisionYaxis.stringValue   = "(x,y):  1 V/div."
        } else
        {
            divisionTime.isHidden       = false
            divisionTimeUnit.isHidden   = false
            divisionTimeLabel.isHidden  = false
            divisionYaxis.stringValue   = "y-axis: 1 V/div."
        }
        
        plotStyle.selectItem(at: psix)
    }
    
    
    // There could be need to change the plot style.
    @IBAction func changeChannels(_ sender: Any) {
        matchChannelsWithPlotStyle()
        updateSampleAndDivisionTime()
        mouseClickSample.stringValue = "..."
    }
    
    
    // The retrieved data is stored globaly in 'plotPoints[[Int]]'
    func retrieveData() {
        var hl:[Int] = []
        var ixc = 0
            
        let tss = self.receivedDataTextView.textStorage!.string
        let lines = tss.split(whereSeparator: \.isNewline)      // This will split on new line and skip the empty lines.
        let lc = lines.endIndex - 2
            
        // Make sure the canvas is visible (not hidden) - we want to see the oscilloscope canvas
        showCanvas()
        
        plotPoints.removeAll()  // Be sure to start with an empty list
        
        if lc > 0 { // We need input line . . .
            for c in 1...lc {
                let channelValues = lines[c].split(whereSeparator: \.isPunctuation)
                let chc = channelValues.endIndex - 1
                if chc > ixc { ixc = chc }
                hl = []
                for cc in 0...chc {
                    let hi = Int(channelValues[cc]) ?? 0
                    if (hi>0) { hl.append(hi) }
                }
                // Only append the sublists that have the correct amount of data (by that the correct data)
                if hl.endIndex - 1 == ixc && hl != [0]  { plotPoints.append(hl) }
            }
            if (plotPoints.endIndex > 2) {
                numberOfSamples.stringValue = String(plotPoints.endIndex)
            }
            
            let psix = plotStyle.indexOfSelectedItem
            if (psix==1 || psix==3) && plotPoints.endIndex >= (2*avgSamples) {
                // Now calculate the average value per 'avgSamples' plotPoints
                // A line needs at least 2 points, so 2*'avgSamples' plotPoints for a useful average calculation
            
                let chh = plotPoints[0].endIndex
                var avgHelperPoints:[[Int]] = []
                var hsum = Array(repeating: 0, count: chh)
                var apc = 0
                for ppl in plotPoints {
                    for clp in 0...ppl.endIndex-1 {
                        hsum[clp] += ppl[clp]
                    }
                    apc += 1
                    if apc >= avgSamples {
                        for hc in 0...ppl.endIndex-1 {
                            hsum[hc] = Int(0.5+Float(hsum[hc])/Float(avgSamples))
                        }
                        avgHelperPoints.append(hsum)
                        hsum = Array(repeating: 0, count: chh)
                        apc=0
                    }
                }
                plotPoints.removeAll()
                plotPoints = avgHelperPoints
            }
            // Button [stop] can be pressed before all points acquired by the TeensyLogger
            // If there is an early 'stop' ->   Update the number of plot points
            //                                  Update the view
            updateSampleAndDivisionTime()
        }
    }
    
    
    @IBAction func changePlotStyle(_ sender: Any) {
        mouseClickSample.stringValue = "..."
        matchChannelsWithPlotStyle()
        showDataPlot()
    }
    
    
    // Open and load data from disk - or - save data to disk // ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
    //
    func infoView(title ttl: String, message msg: String) {
        let info = NSAlert()
        info.icon = NSImage(named: "Atention")
        info.messageText = ttl
        info.informativeText = msg
        info.alertStyle = .informational
        info.addButton(withTitle: "0K.")
        info.runModal()
    }
    
    
    // Get a single Int value
    func getJSONInt(title ttl: String, json jsonData: String) -> Int {
        var hs: String = ""
        let fts = "\"" + ttl + "\":"
        // find title in json string and pick the number related to the title
        if (jsonData.contains(fts)) {
            hs = String(jsonData)
            let startIndex = hs.range(of: fts)
            hs = String(hs[(startIndex?.upperBound...)!])
            let endIndex = hs.range(of: ",")
            hs = String(hs[..<(endIndex?.lowerBound)!])
            // Now only take decimal digits
            let hhs = hs
            hs = ""
            for c in hhs { if c >= "0" && c <= "9" { hs += String(c) }}
        }
        return (Int(hs) ?? -1)
    }
    
    // Get a list of Int values
    func getJSONIntList(title ttl: String, json jsonData: String) -> [Int] {
        var ilst: [Int] = []
        let fts = "\"" + ttl + "\":"
        // find title in json string and pick the number related to the title
        if (jsonData.contains(fts)) {
            var hs = String(jsonData)
            let startIndex1 = hs.range(of: fts)
            hs = String(hs[(startIndex1?.upperBound...)!])
            let startIndex2 = hs.range(of: "[")
            hs = String(hs[(startIndex2?.upperBound...)!])
            let endIndex = hs.range(of: "]")
            hs = String(hs[..<(endIndex?.lowerBound)!])

            // Now only take decimal digits, or newline
            let hhs = hs
            hs = ""
            for c in hhs { if (c >= "0" && c <= "9") || c=="\n" { hs += String(c) }}

            let nl = hs.split(whereSeparator: \.isNewline)
            for ns in nl {
                let n = Int(ns) ?? 0
                ilst.append(n)
            }
        }
        return ilst
    }
    
    
    @IBAction func openDataFile(_ sender: Any) {
        // Always . . . a 'clean' start
        initValues()
        
        let loadFile = NSOpenPanel()
        loadFile.message = "Load a configuration and a retreived data set file"
        let lfc = loadFile.runModal()
        if lfc.rawValue == NSApplication.ModalResponse.OK.rawValue {
            // Open recent ...
            loadData(url: loadFile.url!)
        }
    }
    
 
    func loadData(url filename: URL) {
        // Open File dialog view for 'load'
        // If filename then load
        // Parse JSON or XML
        // Set view with new configuration data
        // Set TextView with new data set incl. '!$ ' part. This will start the showDataPlot() function
                
        // Try the load...
        do {
                //  loadData: NSString
            let loadFile = try NSString(contentsOfFile: filename.relativePath, encoding: String.Encoding.utf8.rawValue)
            let initJSON = String(loadFile)
            
            // Get JSON data like: the function will always return a string?
            // let ci = getJSON(title: "channelsIndex", json: initJSON)
            // ---> "3"
            // update the "number of channels"
            //
            // let samples = getJSON(title: "s101", json: initJSON)
            // ---> "563,562,562,563,562,562,563,562"
            // Add these to the terminal view and after all are added start the plot
            
            let json_chix = getJSONInt(title: json_channels, json: initJSON)
            let json_osix = getJSONInt(title: json_oversmpl, json: initJSON)
            let json_ivix = getJSONInt(title: json_interval, json: initJSON)
            let json_spix = getJSONInt(title: json_samples,  json: initJSON)
            let json_plix = getJSONInt(title: json_plotStIx, json: initJSON)

            if json_chix >= 0   { numberOfChannels.title          = String(json_chix+1) }
            if json_osix >= 0   { degreeOfOversampling.title      = String(json_osix)   }
            if json_ivix >= 0   { intervalTime.stringValue        = String(json_ivix)   }
            if json_spix >= 0   { numberOfSamples.stringValue     = String(json_spix)   }
            if json_plix >= 0   { plotStyle.title                 = String(availablePlotStyles[json_plix])  }
            
            if json_spix >= 0 {
                cleanTextView()
                receivedDataTextView.textStorage?.mutableString.append("\(json_spix) samples\n")
                for s in 1...json_spix {
                    var hs = "s" + String(s)
                    let json_samples = getJSONIntList(title: hs, json: initJSON)
                    hs = ""
                    let c = json_samples.endIndex
                    if c > 1 {
                        for cc in 0...c-2 {
                            hs += "\(json_samples[cc]),"
                        }
                    }
                    if c > 0 { hs += "\(json_samples[c-1])\n" }
                    receivedDataTextView.textStorage?.mutableString.append(hs)
                }
                receivedDataTextView.textStorage?.mutableString.append("\n!$\n")
                receivedDataTextView.scrollToEndOfDocument(self)
                receivedDataTextView.needsDisplay = true
            }
        
            showDataPlot()
        }   catch
            {
                infoView(title: "Load failed!", message: "Unable to load configuration and data set.")
            }
    }
    
    
    @IBAction func saveDataToFile(_ sender: Any) {
        let saveFile = NSSavePanel()
        saveFile.message = "Save a configuration and a retreived data set file"
        let sfc = saveFile.runModal()
        if sfc.rawValue == NSApplication.ModalResponse.OK.rawValue {
            saveData(url: saveFile.url!)
        }
    }
    
    
    func currentStateAndDataSetToJSON() -> String {
        var rsJSON: String = ""
        
        // Current date and time
        // get the current date and time
        let dateNOW = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let sDateNow = formatter.string(from: dateNOW)
        
        var dataSetJSON: String = ""
        let ht4     = "    "            // Tabs as spaces...
        let ht12    = "            "
        let ht14    = "              "

        let initJSON =  ht4 + "\"name\": \"TeensyLogger setup file\",\n    \"version\": \"" + appVersion! +
                        "\",\n    \"data date\": \"" + sDateNow + "\"\n"
        
        let chJSON = ht4 + "\"" + json_channels + "\": " + String(numberOfChannels.indexOfSelectedItem) + ",\n"
        let osJSON = ht4 + "\"" + json_oversmpl + "\": " + String(degreeOfOversampling.indexOfSelectedItem) + ",\n"
        let ivJSON = ht4 + "\"" + json_interval + "\": " + intervalTime.stringValue + ",\n"
        let spJSON = ht4 + "\"" + json_samples  + "\": " + numberOfSamples.stringValue + ",\n"
        let psJSON = ht4 + "\"" + json_plotStIx + "\": " + String(plotStyle.indexOfSelectedItem) + "\n"

        let ppr     = plotPoints.endIndex
        let ppc     = plotPoints[0].endIndex
        for s in 0...ppr-1 {
            dataSetJSON += ht4 + "\"s" + String(s+1) + "\":\n" + ht12 + "[\n"
            for c in 0...ppc-1 {
                dataSetJSON += ht14 + String(plotPoints[s][c] )
                if c < ppc-1 {
                    dataSetJSON += ",\n"
                } else {
                    dataSetJSON += "\n" + ht12 + "]"
                }
            }
            if s < ppr-1 {
                    dataSetJSON += ","
            }
            dataSetJSON += "\n"
        }
            
        rsJSON =    "[\n  {\n" + initJSON + "  },\n  {\n" +
                    chJSON + osJSON + ivJSON + spJSON + psJSON +
                    "  },\n  {\n" + dataSetJSON + "  }\n]\n"
        
        return rsJSON
    }
    
    
    func saveData(url filename: URL) {
        // Get retreived data if there is any - otherwise ~break
        // Get configuration / setup data
        // Convert to JSON or XML
        // Open File dialog view for 'save'
        // If filename then save

        // get current data set to 'plotPoints' (global array)
        retrieveData()

        // Is there data to be stored?
        if plotPoints.endIndex > 1 {
            let dataString = currentStateAndDataSetToJSON()

            // Try the save...
            do  {
                    try
                        dataString.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                }   catch
                        {
                            infoView(title: "Save failed!", message: "Unable to save configuration and data set.")
                }
        } else {
            infoView(title: "Did not save current state!", message: "There is no acquired data in the current data set.")
        }
    }
    
    
    // Hide the canvas and show the helper info
    @IBAction func helperInfo(_ sender: Any) {
        helpRichTextScroller.isHidden = true    // Can't get the scoller hidden at start of the code. Yet.
        
        canvas.isHidden             = true
        canvas.needsDisplay         = true
        helpRichText.isHidden       = false
        helpRichText.needsDisplay   = true
        mouseClickSample.stringValue = "..."
    }
    

    // Invertion of the previous function
    // Hide the helper info and show the canvas
    func showCanvas() {
        helpRichText.isHidden       = true
        helpRichText.needsDisplay   = true
        canvas.isHidden             = false
        canvas.needsDisplay         = true
        mouseClickSample.stringValue = "..."
    }
    

    // Graphical works // ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
    
    // Reading the position on the oscilloscope canvas with a mouse click
    @IBAction func mouseClickOnCanvas(_ sender: Any) {
        let pX      = Int(px)       // CGFloat -> Int
        let pY      = Int(py)       // CGFloat -> Int
        let deltaX  = 0             // 'visual' delta distance (pixels) of the tip of the mouse pointer to the grid
        let deltaY  = 2             // There is some extra delta on my ACER 24" compared to the Retina of the MacBook
        let dV1     = Double(V1)
        let rmpx    = mousePositionX - oX + deltaX
        let rmpy    = mousePositionY - oY + deltaY
        
        // time calculations
        // time based plot is started at division 3 for 20 divisions
        // V1 has the number of pixels per division
        let iTime       = Double(intervalTime.stringValue) ?? 0.0
        let nSamples    = Double(numberOfSamples.stringValue) ?? 0.0
        let sampleTime  = iTime * nSamples / milli2micro                        // This is the sample time in milliseconds

        // Get the plot style
        let hbTime: Bool = plotStyle.indexOfSelectedItem < 2

        if rmpx > 0 && rmpx < pX && rmpy > 0 && rmpy < pY {     // 'extra' range check
            if hbTime { // Time scaled plot -> x-axis is time, y-axis is Voltage
                let xTime = ((Double(rmpx) - 2.0 * dV1) / (Double(pX) - 4.0 * dV1)) * sampleTime
                let yVolt = Double(rmpy - y0) / dV1
                if xTime >= milli2micro {
                    mouseClickSample.stringValue = String(format: "%3.3f s.; %2.3f V.", (xTime/milli2micro), yVolt)
                } else {
                    mouseClickSample.stringValue = String(format: "%3.3f ms.; %2.3f V.", xTime, yVolt)
                }
            } else { // (x,y) Voltage scaled plot -> x-axis and  y-axis are in Volts (1 V/div)
                let xVolt = Double(rmpx - x0) / dV1
                let yVolt = Double(rmpy - y0) / dV1
                mouseClickSample.stringValue = String(format: "( %2.3f V., %2.3f V. )", xVolt, yVolt)
            }
        }
    }
    
    
    func showDataPlot() {
        // Retrieve data from dump to terminal
        retrieveData()
        matchChannelsWithPlotStyle()
        let psix        = plotStyle.indexOfSelectedItem
        let pSamples    = plotPoints.endIndex
        var nChannels   = 0
        
        // ONLY plot if there are at least two (2) points in the plotPoints list
        if pSamples > 1 {
            nChannels = Int(availableChannels[numberOfChannels.indexOfSelectedItem]) ?? 1
            
            initCanvas()            // Start with a blank canvas before drawing a new plot
            image.lockFocus()

            let channels = Array(repeating: NSBezierPath(), count: nChannels)

            // Only plot the channels if all plot data is available
            if nChannels <= plotPoints[0].endIndex {
                if psix < 2 || nChannels < 2 {  // time scaled plot
                    let range   = Float(2*tenVolt*V1)
                    let step    = range / Float(pSamples-1)
                    
                    for ci in (0...nChannels-1).reversed() {
                    // for ci in 0...nChannels-1 {
                        var xpos = Float(x0 - tenVolt*V1)        // Start position for x (at -10V0)
                        var ypos = Float(plotPoints[0][ci] - calibrated0V0[ci])
                        if ypos < 0 {
                            ypos *= correctionFactorMinus[ci]
                        } else {
                            ypos *= correctionFactorPlus[ci]
                        }

                        channelColours[ci].set()
                        channels[ci].lineWidth = 1
                        channels[ci].move(to: NSPoint( x: Int(xpos), y: y0 + Int(ypos)))

                        for s in 1...pSamples-1 {
                            xpos += step
                            ypos = Float(plotPoints[s][ci] - calibrated0V0[ci])
                            if ypos < 0 {
                                ypos *= correctionFactorMinus[ci]
                            } else {
                                ypos *= correctionFactorPlus[ci]
                            }
                            channels[ci].line(to: NSPoint( x: Int(xpos+0.5), y: y0 + Int(ypos)))
                        }
                        channels[ci].stroke()
                        channels[ci].removeAllPoints()
                    }
                        
                } else {
                    // (x,y) plot -- There is NO (x,y,z) plot YET . . .
                    
                    // Create and draw 1 (x,y) plot  if the number of channels is at least 2 or 3
                    // Create and draw 2 (x,y) plots if the number of channels is at least 4 or 5
                    // Create and draw 3 (x,y) plots if the number of channels is 6 or 7
                    // Create and draw 4 (x,y) plots if the number of channels is 8
                    let nPlots = nChannels / 2
                    
                    for pcxy in (0...nPlots-1).reversed() {
                        let chx = 2*pcxy
                        let chy = 2*pcxy+1
                        var xpos = Float(plotPoints[0][chx] - calibrated0V0[chx])
                        var ypos = Float(plotPoints[0][chy] - calibrated0V0[chy])
                        if xpos < 0 {
                            xpos *= correctionFactorMinus[chx]
                        } else {
                            xpos *= correctionFactorPlus[chx]
                        }
                        if ypos < 0 {
                            ypos *= correctionFactorMinus[chy]
                        } else {
                            ypos *= correctionFactorPlus[chy]
                        }
                        
                        channelColours[chx].set()
                        channels[chx].lineWidth = 2
                        channels[chx].move(to: NSPoint( x: x0 + Int(xpos), y: y0 + Int(ypos)))

                        for s in 1...pSamples-1 {
                            xpos = Float(plotPoints[s][chx] - calibrated0V0[chx])
                            ypos = Float(plotPoints[s][chy] - calibrated0V0[chy])
                            if xpos < 0 {
                                xpos *= correctionFactorMinus[chx]
                            } else {
                                xpos *= correctionFactorPlus[chx]
                            }
                            if ypos < 0 {
                                ypos *= correctionFactorMinus[chy]
                            } else {
                                ypos *= correctionFactorPlus[chy]
                            }
                            channels[chx].line(to: NSPoint( x: x0 + Int(xpos), y: y0 + Int(ypos)))
                        }
                        channels[chx].stroke()
                        channels[chx].removeAllPoints()
                    }
                }
            }
            image.unlockFocus()
        }
        plotPoints.removeAll()
        canvas.needsDisplay = true
    }
    
    
    // Draw small cross (relative to grid)
    func drawCross(posx x: Int, posy y: Int, divfactor df: Int ) -> NSBezierPath {
        let xline   = NSBezierPath()
        let ppx     = x0 + x * V1
        let ppy     = y0 + y * V1
        let dpxy    = V1 / df

        xline.move(to: NSPoint( x: ppx - dpxy, y: ppy))
        xline.line(to: NSPoint( x: ppx + dpxy, y: ppy))
        xline.move(to: NSPoint( x: ppx, y: ppy - dpxy))
        xline.line(to: NSPoint( x: ppx, y: ppy + dpxy))
        
        return xline
    }
    
    
    func initCanvas() {
        // Draw the oscilloscope grid
        // plotstyle ~ either time base  or  (x,y)
        // y-axis at          right      or  middle
    
        // Some initials - sizes, colours
        let hbTime: Bool = plotStyle.indexOfSelectedItem < 2
        image = NSImage(size: canvas_size)
        image.lockFocus()
        canvas.image = image
        let line = NSBezierPath()       // Start with a new path of lines
        let rect = NSRect( x:0, y:0, width: px, height: py)
        let colour = bgColour
        colour.setFill()
        rect.fill()
        gridColour.set()
        line.lineWidth  = 1

        // The long axis
        line.move(to: NSPoint( x:    0, y: y0))
        line.line(to: NSPoint( x: 2*x0, y: y0))

        // Only draw a y-axis at the centre is the plot style is (x,y)-plot
        if !hbTime {
            line.move(to: NSPoint( x: x0, y:    0))
            line.line(to: NSPoint( x: x0, y: 2*y0))
        }
        
        // A rectangle for marking the -10 Volt ... +10 Volt borders
        line.appendRect(NSRect(x: x0-tenVolt*V1, y: y0-tenVolt*V1, width: 2*tenVolt*V1, height: 2*tenVolt*V1))

        // Four 5 Volt markers on cross
        // Four bigger versons - on the (x,y) plot axis
        line.append(drawCross(posx: -fiveVolt, posy:  zeroVolt, divfactor: 3))
        line.append(drawCross(posx:  fiveVolt, posy:  zeroVolt, divfactor: 3))
        line.append(drawCross(posx:  zeroVolt, posy: -fiveVolt, divfactor: 3))
        line.append(drawCross(posx:  zeroVolt, posy:  fiveVolt, divfactor: 3))
        
        // A grid of smaller 5 Volt markers
        for rpx in -2...2 {
            let px = fiveVolt * rpx
            for rpy in -2...2 {
                let py = fiveVolt * rpy
                line.append(drawCross(posx: px, posy: py, divfactor: 4))
            }
        }
        
        // All 1 Volt line markers
        for pxy in -tenVolt...tenVolt {
            for rpxy in -oneVolt...oneVolt {
                line.append(drawCross(posx: pxy, posy: tenVolt*rpxy, divfactor: 6))
                if !(hbTime && rpxy==0) {
                    line.append(drawCross(posx: tenVolt*rpxy, posy: pxy, divfactor: 6))
                }
            }
        }

        // And the rest of all the 1 Volt dot markers
        for x1 in -twelveVolt...twelveVolt {
            for y1 in -twelveVolt...twelveVolt {
                line.append(drawCross(posx: x1, posy: y1, divfactor: 1+V1/2))
            }
        }
        
        line.stroke()
        line.removeAllPoints()
        image.unlockFocus()
        canvas.needsDisplay = true
    }
}

// End of code.

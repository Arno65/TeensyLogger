//
//  SerialPortController.swift
//
// (cl)  Spring, Summer, Autumn 2022  by Arno Jacobs
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
//  version 1.6j    2022-07-21      Reformatted the save JSON output file.
//                                  One main object with three objects; version, initialisation, sample values.
//  version 1.7f    2022-07-25      Adding fft-algorithm - first draft
//  version 1.7g    2022-08-20      Small changes - added fft button and loop check box.
//                                  The 'initialize & start' now can run in a loop
//  version 1.8f    2022-08-23      The logged input data transformed and normalized for fft function
//                                  For decent spectrum output need big data-set 2048 or 4096 points with
//                                  'higher' frequency, as in, lots of 'fluctuations' in the data set.
//                                  Stripped fft calculation
//                                  At this stage: fft spectrum output only to console
//  version 1.8j    2022-08-25      The JSON 'parser' for reading data sets was slow    O(n^2)
//                                  Changed to a linear time algorithm                  O(n)
//  version 1.8l    2022-08-27      Complete redo for JSON 'parser'. The 'formatting' of the data set "S#": [ 1,2,3 ],
//                                  is less strick now. No need to place every data entry on a seperate line.
//                                  Minor changes in code.
//  version 1.9b    2022-10-08      Expand the FFT function to a maximum of two channels
//                                  Alas, the code is NOT to my liking...
//                                  Find out how to combine 2D with 1D array's.
//  version 1.9d    2022-11-12      Further work & attention to FFT and adding zoom options for x(t), (x,y) and FFT
//                                  Worked the zoomed time and (x,y) plots
//                                  Still need the FFT plot (incl. zoomed) - try via plot option -> drop down list
//  version 1.9x    2022-11-14      More work on & attention to FFT
//                                  Added 4x, 8x, 16x and 32x zoom on frequency (FFT) - starting from 0 Hz. So low end zoom.
//                                  Working mouse-click-on-plot info for all plot styles.
//                                  (Now FFT is working fine by me. But is Bernd happy with the end result?)
//

//  W.T.D.
//     ~1.      Automatic selection of the correct TeensyLogger port - select one time, use many times.
//                  Can't do this safely. The USB port has a different name on each different Mac.
//                  The current Pop Up Button is working good enough. (Also
//     ~2.      JSON formatted save files - open and save are working -- open recent will not do for the time being...
//              (Rewritten on 2022-07-21 -> 'correct' JSON format)
//              (Rewritten on 2022-08-25 -> faster JSON 'parser' for the dataset (from O(n^2) -> O(n))
//     ~3.      Simple square shaped plot (X,Y) in the range -10...+10V for both axis.
//                  0K. Done. For all even number selected inputs.
//                  So one (x,y)-plot if 2 inputs are selected and four (x,y)-plots if 8 inputs are selected.
//     ~4.      More text info on main window. Like 1 V/div with (x,y)-plot.
//     ~5.      Zoomed view of plot.
//              The timed plot is zoomed on the time scale.
//              The (x,y) plot has a 5X zoom on both axis. Standard [-10V...10V], zoomed [-2V...2V]
//              The FFT has multiple zoom factors on the frequency scale (4X, 8X, 16X and 32X)
//     ~6.      Hint info with mouse click on oscilloscope view. Click a point on the view and show it's corresponding values.
//              There is time and Voltage info from a mouse click on the oscilloscope canvas.
//     .7.      Refactor to clean code - delete all dummy's and unnecessary doubles
//              The crosses on the plots can be more compact as functions.
//     ~8.      Spectrum analysis on 1 or 2 channels.
//     ~9.      The serial I/O code (ORSSerialPort) needs recompilation for release version.
//              A previous version had de Framework compiled for Intel only.
//              Now the source code is integrated and the project can be compiled for Intel and Apple M1
//     ~10.     A functioning HELP window. (Is working but primitive, text on plot screen.)
//     ~11.     Implement a 'stream mode' on the TeensyLogger. After that add that functionality to this app.
//              Only done for (x,y)-plot  -  yet -- ONLY for 'long' sample interval. The TeensyLogger and serial IO have speed limits.
//     ~12.     (Endless) loop options for 'arm' and 'arm & start'
//              For this option the function serialPort() has some recursive elements - so it's endless until the stack is running out
//              Maybe all is fine - but I still have to check memory usage and alike...
//     !13.     Automatic initialisation of the TeensyLogger -- tried it but does not work (yet)
// -->  14.     Optional Z-axis, 2D plot with (line/point) intensity for the Z-axis.
//              In plot style options add a (x,y,z)-plot only for the first 3 channels.
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
         (⌘.)       stream                  (TL)                only for very slow/long time base - I'm not pleased with this part
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

// The fft part
var fft = FFT()
// Outside the SerialPortController-class
// In the function "sendCommand" this constant is used as a default value
let standardSleepTime: UInt32 = 101     // This is just a bit more than the timeout set
                                        // in the Teensy 4.0 module for serial I/O
let maxChannels = 8


class SerialPortController: NSObject, NSApplicationDelegate, ORSSerialPortDelegate {
    
    @objc let serialPortManager = ORSSerialPortManager.shared()         // usbmodem101899901 (in my case...)
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
    
    @IBOutlet weak  var openCloseButton:        NSButton!
    @IBOutlet weak  var sendTextField:          NSTextField!
    @IBOutlet weak  var sendButton:             NSButton!
    @IBOutlet       var baudRateSelector:       NSPopUpButton!
    @IBOutlet       var receivedDataTextView:   NSTextView!
    @IBOutlet weak  var numberOfChannels:       NSPopUpButton!
    @IBOutlet weak  var intervalTime:           NSTextField!
    @IBOutlet weak  var numberOfSamples:        NSTextField!
    @IBOutlet weak  var degreeOfOversampling:   NSPopUpButton!
    @IBOutlet weak  var plotStyle:              NSPopUpButton!
    @IBOutlet weak  var loopArm:                NSButton!
    @IBOutlet weak  var loopRun:                NSButton!
    @IBOutlet weak  var serialPortLabel:        NSTextField!
    @IBOutlet weak  var baudRateLabel:          NSTextField!
    @IBOutlet weak  var statusTeensyLogger:     NSTextField!
    @IBOutlet weak  var mouseClickSample:       NSTextField!
    @IBOutlet       var helpRichText:           NSTextView!
    @IBOutlet weak  var helpRichTextScroller:   NSScroller!
    @IBOutlet weak  var NyquistFrequency:       NSTextField!
    @IBOutlet weak  var sampleTime:             NSTextField!
    @IBOutlet weak  var sampleTimeUnit:         NSTextField!
    @IBOutlet weak  var divisionTime:           NSTextField!
    @IBOutlet weak  var divisionTimeUnit:       NSTextField!
    @IBOutlet weak  var divisionTimeLabel:      NSTextField!
    @IBOutlet weak  var divisionYaxis:          NSTextField!
    @IBOutlet weak  var changePort:             NSPopUpButton!
    @IBOutlet weak  var changeBaudRate:         NSPopUpButton!
    @IBOutlet weak  var canvas:                 NSImageView!
    
    var checkSelectedOpen   = false
    var checkArmed          = false
    var checkLoopArm        = false
    var checkLoopRun        = false
    let tlReady     = "The TeensyLogger is ready for use"
    let tlNOTReady  = "The TeensyLogger is NOT connected"
    let sConnect    = "connect"
    let sDisconnect = "disconnect"
    // Get current application version - for JSON output
    let appVersion  = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
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
    let availablePlotStyles     = ["time","time avg.10","time zoomed","(x,y)","(x,y) avg.10","(x,y) zoomed","FFT","FFT 4x zoomed","FFT 8x zoomed","FFT 16x zoomed","FFT 32x zoomed"]
    let initialOSS              = "3"
    // These are the calibrated values for -10V0, 0V0 and +10V0
    // In my case the eight channels of the TeensyLogger calibrated to the same values
    let calibratedMinus10V0 = [200,200,201,200,201,200,201,200]
    let calibrated0V0       = [510,511,511,509,512,512,512,511]
    let calibratedPlus10V0  = [821,822,821,821,821,821,821,821]
    let maxDepth    = 24576     // Maximum of samples per run - this number is bound by the amount of RAM on the Teensy 4.X
    let zeroVolt    = 0
    let oneVolt     = 1
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
    var image = NSImage()
    var plotPoints:[[Int]]  = [] // Now an empty list for all plot points for all 8 channels.
    var streamPoints:[Int]  = []
    var streamMode:Bool     = false
    var streamStart:Bool    = true
    let streamEndString     = "$$ Streaming stopped."
    let streamPath          = NSBezierPath()
    
    // 'global' var with result of spectrum analysis / FFT calculations
    // Now going for a maximum of two channels.
    var nSpectrumChannels:Int   =    1          // Default 1 channel
    var spectrum1:[Double]      =   []
    var spectrum2:[Double]      =   []
    
    // Some Zoom helpers
    var zoomFactorTime:Float    = 1.0
    let fixedXYZoomFactor:Float = 5.0
    var zoomFactorFFT:Int       = 1
    var HzDivValue:Double       = 0
    
    // 0K. 2D-array is not working here ...
    // Because it's only two arrays I'll keep it this (very non generic and cleaner) way
    var fftInputPointsCh1:[Double] = []     // For a max. of two (2) channels
    var fftInputPointsCh2:[Double] = []     // add points on the locations where the plotPoints are calculated
    
    let fftSampleLengths:[Int]  = [512,1024,2048,4096,8192,16384]    // Either strip logged set or append with 0V0-values
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
    let milli2micro:Double      = 1e3
    let unit2micro:Double       = 1e6
    let NyquistFactor:Double    = 0.5
    
    
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
            // The two loop check buttons
            loopArm.state   = NSControl.StateValue.off
            loopRun.state   = NSControl.StateValue.on
            checkLoopArm    = false
            checkLoopRun    = false
            
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
        checkLoopArm = loopArm.state == NSControl.StateValue.on
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
            let snch    = tl_channels + sEq +   String(nch)     // [1..8]
            let sitime  = tl_interval + sEq +   String(itime)   // the interval time between samples is allways in µs.
            let sms     = tl_samples + sEq +    String(nsm)     // Always a natural number
            let sdovs   = tl_oversmpl + sEq +   String(dovs)    // [0..4] for 2^n times oversampling per channel.
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
        checkLoopRun = loopRun.state == NSControl.StateValue.on
        streamMode   = false
        armTL(self)
        startTL(self)
    }
    
    
    @IBAction func stopTL(_ sender: Any) {
        // Check for stopping 'loop' or 'steam'
        // let stopLoopOrStream = checkLoopArm || checkLoopRun || streamMode
        // Needed a google search: Swift nsbutton style check how to change state
        loopArm.state = NSControl.StateValue.off
        loopRun.state = NSControl.StateValue.off
        checkLoopArm  = false
        checkLoopRun  = false
        streamMode    = false
        streamStart   = false
        // if !stopLoopOrStream { sendCommand(send: tl_stop) }
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
        if streamMode { stopTL(sender) }                    // toggle mode on stream button - [stop] will also work ;-)
        else {
            // Don't forget to initialize and arm the TeensyLogger
            // Only stream mode for (x,y) plot so 2 channels.
            // minimum sample interval 10 ms. (or 10000 µs.)
            let nch     = Int(availableChannels[numberOfChannels.indexOfSelectedItem]) ?? 1
            let itime   = Int(intervalTime.stringValue) ?? 0
            cleanTextView()
            
            if (nch >= 2 && itime >= 10000) {
                armTL(sender)
                initCanvas()
                streamMode  = true
                streamStart = true
                image.lockFocus()
                sendCommand(send: tl_stream, sleep: 200)
            } else
            {
                receivedDataTextView.textStorage?.mutableString.setString("steam mode NOT 0K.");
            }
        }
    }
    
    
    func dumpTL() {
        cleanTextView()
        sendCommand(send: tl_dump)
        showDataPlot()
    }
    
    
    // This code is not used here and now
    // Only for 'debug' info - spectrum data set send to the console
    func spectrumDataToConsole() {
        // Return array of spectrum if half the length of the TeensyLogger data set -> so 2*k for input samples
        print ("n; samples; spectrum")
        // the arrays spectum1 and spectrum2 will have the same length
        // The fftInputPoints are the input for spectrum2
        if (nSpectrumChannels>1) {
            for k in 0 ..< spectrum1.count {
                print("#\(k); ch1: \(fftInputPointsCh1[2*k]) -> \(spectrum1[k]);     ch2: \(fftInputPointsCh2[2*k]) -> \(spectrum2[k]) ")
            }
        } else {
            for k in 0 ..< spectrum1.count {
                print("#\(k); ch1: \(fftInputPointsCh1[2*k]) -> \(spectrum1[k]) ")
            }
        }
    }
    
    
    func normalize( _ i: Double, _ v0: Double, _ dVP: Double, _ dVM: Double ) -> Double {
        var rv = i - v0
        if rv > 0 { rv /= dVP } else { rv /= dVM }
        return rv
    }
    
    
    func workSpectrum() {
        //  1.  Check if there is workable data in NSTextView -> receivedDataTextView
        //          Will work with channel one but need a minimum of 2^n samples, with n >= 10. (So 512,1024,2048,4096,...)
        //  2.  Get timing data - number of samples and time needed for those samples. Need fps. (sample frequency)
        //      fps is/was needed for the bandpass filter -- just 'enter' 1.0
        //  3.  Feed dataset and coefficients to fft-routine: fft.calculate(samples, fps: fps)
        //  4.  Log all input and output for checking. (Plotting in 'Numbers/Excel')
        //
        // Example for: "sine-8Vpp-10.055Hz.json" This is a 8Vpp (so from +4V to -4V) ~ 10Hz sine signal.
        // This one has 1200 points with 250µs sample interval.
        // In this case the function will use the first 1024 samples, 250*1024 = 256 ms
        // fps -> samples / time -> 1024 / 256 -> 4000
        // The fps is allready known in 'sample frequency' that can be seen on the main view.
        
        
        // As all is well the raw logged data is in 'fftInputPoints[]'
        // 1. create a 2^n size list of input samples for the fft function
        //
        // The (normalized) spectrum data set for a maximum of two channels is stored in 'spectrum1[]' and 'spectrum2[]'
        //
        // First check the number of channels.
        // Either plot one spectrum is only one channels is available
        //     or plot the first two channels of more than one channels are available
        nSpectrumChannels = min (2, Int(availableChannels[numberOfChannels.indexOfSelectedItem]) ?? 1)
        
        // Want to do this in ONE two dimensional array - but that seems to be a pain in the . . .
        // Only need two array so that's why
        //
        // Some preps.
        let v0ch1   = Double(calibrated0V0[0])                                  //  0V0 level for channel 1
        let v0a     = Array(repeating: v0ch1, count: fftSampleLengths[0]+1)     //  append array of '0V0'
        fftInputPointsCh1.append(contentsOf: v0a)   // Both will have the same length
        fftInputPointsCh2.append(contentsOf: v0a)
        
        let fftc = fftInputPointsCh1.count               // This way the array > 512 in size -- the minimal length
        for fl in fftSampleLengths.reversed() {
            if (fl < fftc) {
                fftInputPointsCh1 = Array(fftInputPointsCh1[0..<fl])
                if (nSpectrumChannels>1) {
                    fftInputPointsCh2 = Array(fftInputPointsCh2[0..<fl])
                }
                break
            }
        }
        
        // Work the two channels
        for spc in 0...nSpectrumChannels-1 {
            let v0      = Double(calibrated0V0[spc])          //   0V0 level for channel 1 or 2
            let v10p    = Double(calibratedPlus10V0[spc])     // +10V0 level for channel 1 or 2
            let v10m    = Double(calibratedMinus10V0[spc])    // -10V0 level for channel 1 or 2
            let deltaVPlus: Double      = v10p - v0
            let deltaVMinus: Double     = v0 - v10m
            
            // 2. normalize the dataset +10V0 is +1.0  to  -10V0 is -1.0
            // So a -4V20 signal will be 'normalized' to -0.420, and  a +5V50 signal to +0.550
            // The TeensyLogger might be NOT linear so the 'delta' 0V...+10V0 can be different to -10V0...0V0
            // That's why there is a deltaVPlus  for 'delta' 0V...+10V0
            //                 and a deltaVMinus for 'delta' -10V0...0V
            if (spc == 0) {
                fftInputPointsCh1 = fftInputPointsCh1.map { normalize( $0, v0, deltaVPlus, deltaVMinus ) }
                // 3. Set fps -> 1.0    -- This has NO influence on the spectrum output -- I don't understand what is does.
                // 4. Work the fft
                spectrum1 = fft.calculate(fftInputPointsCh1, fps: 1.0)
            } else {
                fftInputPointsCh2 = fftInputPointsCh2.map { normalize( $0, v0, deltaVPlus, deltaVMinus ) }
                // . . . and for the second channel
                spectrum2 = fft.calculate(fftInputPointsCh2, fps: 1.0)
            }
            
        }
        
        // The spectrum data is ready for plotting
        // Uncomment next function if spectrum data is needed in the Console output
        //      spectrumDataToConsole()
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
        //      1                   12 µs.
        //      0                    4 µs.
        //
        //  -- !!!! -- -- !!!! -- -- !!!! -- -- !!!! -- -- !!!! -- -- !!!! -- -- !!!! -- -- !!!! -- -- !!!! --
        // And then I realised these numbers ae only tested on a one (1) channel acquisition.
        // DO the 8 channel measurements!
        // Reminder: The TeensyLogger is reading with two ADC's. So the sample time for 1 channels is as long as for 2 channels.
        //              So 8 channels is like 4 samples per ADC, with 2^4 oversampling ~~> 4x60 is 240 µs. minimal sample interval???
        // Check this again, incl. a log session of more than one channel.
        //
        // Keep the selected oversampling degree and match to a minimal interval time
        // let msit:[Int] = [4,12,20,30,60]     // The production & deploy values
        let msit:[Int] = [2,6,10,15,30]         // The test & debug values
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
        
        // Calculate Nyquist frequency in Hz.
        let nf: Double = NyquistFactor * unit2micro / Double(iIT)
        if nf >= 10     { NyquistFrequency.stringValue = String(format: "%.1f", nf) }
        else
        if nf >= 1  { NyquistFrequency.stringValue = String(format: "%.2f", nf) }
        else        { NyquistFrequency.stringValue = String(format: "%.4f", nf) }
        
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
        var loopPlotHelper = false
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
                    loopPlotHelper = true
                }
            }
        }
        if loopPlotHelper && checkLoopArm { armTL(self) }
        if loopPlotHelper && checkLoopRun { initializeAndStart(self) }
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
            changePort.isEnabled        = true
            changeBaudRate.isEnabled    = true
            serialPortLabel.isEnabled   = true
            baudRateLabel.isEnabled     = true
        } else {
            if let port = self.serialPort {
                if (port.isOpen) {
                    port.close()
                    sendTextField.isEnabled         = false
                    sendButton.isEnabled            = false
                    statusTeensyLogger.stringValue  = tlNOTReady
                    checkSelectedOpen               = false
                    serialPortLabel.isEnabled       = true
                    baudRateLabel.isEnabled         = true
                    changePort.isEnabled            = true
                    changeBaudRate.isEnabled        = true
                } else {
                    port.open()
                    cleanTextView()
                    initCanvas()
                    sendTextField.isEnabled         = true
                    sendButton.isEnabled            = true
                    statusTeensyLogger.stringValue  = tlReady
                    checkSelectedOpen               = true
                    changePort.isEnabled            = false
                    changeBaudRate.isEnabled        = false
                    mouseClickSample.stringValue    = "..."
                    serialPortLabel.isEnabled       = false
                    baudRateLabel.isEnabled         = false
                }
            }
        }
    }
    
    
    @IBAction func clear(_ sender: Any) {
        cleanTextView()
    }
    
    
    @IBAction func changePlotStyle(_ sender: Any) {
        mouseClickSample.stringValue = "..."
        matchChannelsWithPlotStyle()
        showDataPlot()
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
    
    
    // There could be need to change the plot style.
    @IBAction func changeChannels(_ sender: Any) {
        matchChannelsWithPlotStyle()
        updateSampleAndDivisionTime()
        mouseClickSample.stringValue = "..."
    }
    
    
    // MARK: - ORSSerialPortDelegate
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        openCloseButton.title = sDisconnect
    }
    
    
    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        openCloseButton.title       = sConnect
        serialPortLabel.isEnabled   = true
        baudRateLabel.isEnabled     = true
        changePort.isEnabled        = true
        changeBaudRate.isEnabled    = true
    }
    
    
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        self.serialPort             = nil
        openCloseButton.title       = sConnect
        openCloseButton.isEnabled   = false
        checkSelectedOpen           = false
        changePort.isEnabled        = true
        changeBaudRate.isEnabled    = true
        serialPortLabel.isEnabled   = true
        baudRateLabel.isEnabled     = true
    }
    
    
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        infoView(title: "Serial port fail!", message: "SerialPort \(serialPort) encountered an error: \(error)")
        changePort.isEnabled        = true
        changeBaudRate.isEnabled    = true
        serialPortLabel.isEnabled   = true
        baudRateLabel.isEnabled     = true
    }
    
    
    func getZoomFactorFFT() {
        switch plotStyle.indexOfSelectedItem {
        case  7:    zoomFactorFFT =  4
        case  8:    zoomFactorFFT =  8
        case  9:    zoomFactorFFT = 16
        case 10:    zoomFactorFFT = 32
        default:    zoomFactorFFT =  1
        }
    }
    
    
    // Only call this for 'plotStyle.indexOfSelectedItem == 2' [time zoomed]
    func getZoomFactorTimePlot(points: Int) {
        // Zoom in with a factor with minimal 150 plot points
        var factor:Float = 1
        if (points >= 300) {
            factor = 2
            if points >= 600 {
                factor = Float(points) / 300
                if points >= 2400 {
                    factor = Float(points) / 600
                }
            }
        }
        zoomFactorTime = factor
    }
    
    
    func matchChannelsWithPlotStyle() {
        // Match channels with selected plot style
        let nch  = Int(availableChannels[numberOfChannels.indexOfSelectedItem]) ?? 1
        var psix = plotStyle.indexOfSelectedItem
        if (nch%2 == 1 && (psix >= 3 && psix <= 5)) { psix -= 3 }   // (x,y) plot needs even number of channels.
        
        // (x,y) plot settings
        if (psix >= 3 && psix <= 5) {
            divisionTime.isHidden       = true
            divisionTimeUnit.isHidden   = true
            divisionTimeLabel.isHidden  = true
            divisionYaxis.stringValue   = "(x,y):  1 V/div."
            if (psix == 5) {
                divisionYaxis.stringValue   = "(x,y): 0.2 V/div."
            }
        } else
        // FFT plot settings
        if (psix >= 6) {
            // get Nyquist frequency:       nf
            // get zoom factor FFT:         zoomFactorFFT
            // the plot has 20 division:    20
            // So frequency/div is:         Hz/div = nf / (20 * zoomFactorFFT)
            let nf      = Double(NyquistFrequency.stringValue) ?? 0.0
            HzDivValue  = nf/Double(20*zoomFactorFFT)
            
            divisionTime.isHidden       = false
            divisionTimeUnit.isHidden   = false
            divisionTimeLabel.isHidden  = false
            divisionYaxis.stringValue   = String(format: "%2.3f Hz/div", HzDivValue)
        } else
        {
            divisionTime.isHidden       = false
            divisionTimeUnit.isHidden   = false
            divisionTimeLabel.isHidden  = false
            divisionYaxis.stringValue   = "y-axis: 1 V/div."
        }
        plotStyle.selectItem(at: psix)
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
        plotPoints.removeAll()              // Be sure to start with an empty list
        fftInputPointsCh1.removeAll()       // idem
        fftInputPointsCh2.removeAll()       // idem
        
        if lc > 0 { // We need input line . . .
            for c in 1...lc {
                let channelValues = lines[c].split(whereSeparator: \.isPunctuation)
                let chc = channelValues.endIndex - 1
                if chc > ixc { ixc = chc }
                hl = []         // shouldn't this be hl.removeAll()
                for cc in 0...chc {
                    let hi = Int(channelValues[cc]) ?? 0
                    if (hi>0) {
                        hl.append(hi)                               // this is the raw data from the TeensyLogger [0..1023]
                        if (cc==0) { // Here only for channel 1
                            fftInputPointsCh1.append(Double(hi))
                        }
                        if (cc==1) { // And here only for channel 2
                            fftInputPointsCh2.append(Double(hi))
                        }
                    }
                }
                // Only append the sublists that have the correct amount of data (by that the correct data)
                if hl.endIndex - 1 == ixc && hl != [0]  { plotPoints.append(hl) }
            }
            if (plotPoints.endIndex > 2) {
                numberOfSamples.stringValue = String(plotPoints.endIndex)
            }
            
            // Index of selected plot style (helper)
            // availablePlotStyles  -> ["time","time avg.","time zoomed","(x,y)","(x,y) avg.","(x,y) zoomed","FFT","FFT 4x zoomed",...,"FFT 32x zoomed"]
            // index                ->    0      1           2             3       4            5              6     7                   10
            //
            let psix = plotStyle.indexOfSelectedItem
            if (psix==1 || psix==4) && plotPoints.endIndex >= (2*avgSamples) {
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
    

    // Invertion of the previous function   // Hide the helper info and show the canvas
    func showCanvas() {
        helpRichText.isHidden       = true
        helpRichText.needsDisplay   = true
        canvas.isHidden             = false
        canvas.needsDisplay         = true
        mouseClickSample.stringValue = "..."
    }
    
    
    // Graphical works // ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
    //
    // Reading the position on the oscilloscope canvas with a mouse click
    @IBAction func mouseClickOnCanvas(_ sender: Any) {
        let pX      = Int(px)       // CGFloat -> Int
        let pY      = Int(py)       // CGFloat -> Int
        let deltaX  = 0             // 'visual' delta distance (pixels) of the tip of the mouse pointer to the grid
        let deltaY  = 2             // There is some extra delta on my ACER 24" compared to the Retina of the MacBook
        var dV1     = Double(V1)
        let rmpx    = mousePositionX - oX + deltaX
        let rmpy    = mousePositionY - oY + deltaY
        // time calculations
        // time based plot is started at division 3 for 20 divisions
        // V1 has the number of pixels per division
        let iTime       = Double(intervalTime.stringValue) ?? 0.0
        let nSamples    = Double(numberOfSamples.stringValue) ?? 0.0
        let sampleTime  = iTime * nSamples / milli2micro                // This is the sample time in milliseconds
        // Get the plot style
        // At this point - // This is only working for standard time & (x,y)
        // Need for fix the zoomed option
        // Also need to add the FFT option
        let psix = plotStyle.indexOfSelectedItem
        if rmpx > 0 && rmpx < pX && rmpy > 0 && rmpy < pY {     // 'extra' range check
            if (psix <= 2) {                    // Time scaled plot -> x-axis is time, y-axis is Voltage
                var xTime = ((Double(rmpx) - 2.0 * dV1) / (Double(pX) - 4.0 * dV1)) * sampleTime
                xTime /= Double(zoomFactorTime)
                let yVolt = Double(rmpy - y0) / dV1
                if xTime >= milli2micro {
                    mouseClickSample.stringValue = String(format: "%3.3f s.; %2.3f V.", (xTime/milli2micro), yVolt)
                } else {
                    mouseClickSample.stringValue = String(format: "%3.3f ms.; %2.3f V.", xTime, yVolt)
                }
            } else
            if (psix >= 3 && psix <= 5) {       // (x,y) Voltage scaled plot -> x-axis and  y-axis are in Volts (1 V/div)
                var zoomFactorXY: Float = 1.0
                if (psix == 5) { zoomFactorXY = fixedXYZoomFactor }
                dV1 *= Double(zoomFactorXY)
                let xVolt = Double(rmpx - x0) / dV1
                let yVolt = Double(rmpy - y0) / dV1
                mouseClickSample.stringValue = String(format: "( %2.3f V., %2.3f V. )", xVolt, yVolt)
            } else {                            // FFT plot -> x-axis for frequency and y-axis (top/bottom quadrants) for relative energy
                var xFreq   = Double(tenVolt) + Double(rmpx - x0) / dV1
                xFreq = max( 0.0, xFreq)
                xFreq = min( xFreq, (Double(2*tenVolt)))
                xFreq *= HzDivValue
                
                var yEnergy = 10.0*Double(rmpy - y0) / dV1
                if (yEnergy < 0) {              // Correction for the bottom quadrants
                    yEnergy += 100.0
                }
                yEnergy = max( 0.0, yEnergy)
                yEnergy = min( yEnergy, 100.0)
                mouseClickSample.stringValue = String(format: "( %2.2f Hz., %2.0f", xFreq, yEnergy ) + "% )"
            }
        }
    }
    
    
    func showDataPlot() {
        // Retrieve data from dump to terminal
        retrieveData()                              // Here the serial input data [0..1023] is converted to plot-data
        // Only time & (x,y) plot styles
        // Here the fft-data-set is prepared but NOT calculated
        
        // Index of selected plot style (helper)
        // availablePlotStyles  -> ["time","time avg.","time zoomed","(x,y)","(x,y) avg.","(x,y) zoomed","FFT","FFT 4x zoomed",...,"FFT 32x zoomed"]
        // index                ->    0      1           2             3       4            5              6     7                   10
        //
        let psix = plotStyle.indexOfSelectedItem
        getZoomFactorFFT()
        
        // The 'simple' zoom option for zoomed time plot
        var pSamples = plotPoints.endIndex
        zoomFactorTime = 1.0
        if (psix == 2) {
            getZoomFactorTimePlot(points: pSamples)
            pSamples = Int( Float(pSamples) / zoomFactorTime)
        }
        
        matchChannelsWithPlotStyle()
        
        var nChannels   = 0
        // ONLY plot if there are at least two (2) points in the plotPoints list
        if pSamples > 1 {
            nChannels = Int(availableChannels[numberOfChannels.indexOfSelectedItem]) ?? 1
            initCanvas()            // Start with a blank canvas before drawing a new plot
            image.lockFocus()
            let channels = Array(repeating: NSBezierPath(), count: nChannels)
            // Only plot the channels if all plot data is available
            if nChannels <= plotPoints[0].endIndex {
                if (psix <= 2 || (psix <= 5 && nChannels < 2)) {        // time scaled plot
                    let range   = Float(2*tenVolt*V1)
                    let step    = range / Float(pSamples-1)
                    for ci in (0...nChannels-1).reversed() {            // .reversed() -> plot channel 'n' OVER channel 'n+1'
                        // So channel 1 is over all other plotted channels.
                        // for ci in 0...nChannels-1 {
                        var xpos = Float(x0 - tenVolt*V1)               // Start position for x (at -10V0)
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
                } else
                if (psix >= 3 && psix <= 5) {
                    // (x,y) plot                   -- There is NO (x,y,z) plot YET . . .
                    // Create and draw 1 (x,y) plot  if the number of channels is at least 2 or 3
                    // Create and draw 2 (x,y) plots if the number of channels is at least 4 or 5
                    // Create and draw 3 (x,y) plots if the number of channels is 6 or 7
                    // Create and draw 4 (x,y) plots if the number of channels is 8
                    let nPlots = nChannels / 2
                    var zoomFactorXY:Float = 1.0
                    if (psix == 5) { zoomFactorXY = fixedXYZoomFactor }
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
                        // Apply selected zoom factor - initial move
                        xpos *= zoomFactorXY
                        ypos *= zoomFactorXY
                        
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
                            // Apply selected zoom factor - rest of the lines
                            xpos *= zoomFactorXY
                            ypos *= zoomFactorXY
                            
                            channels[chx].line(to: NSPoint( x: x0 + Int(xpos), y: y0 + Int(ypos)))
                        }
                        channels[chx].stroke()
                        channels[chx].removeAllPoints()
                    }
                } else {                        // FFT plot
                    // First get FFT data
                    workSpectrum()
                    var plotPoints = spectrum1.count - 1    // If both spectrum1 and spectrum2 are calculated they have the same length
                    
                    // Zoom factors
                    if (psix >=  7) { plotPoints /=  zoomFactorFFT }
                    let dx:Float = Float(2*tenVolt*V1) / Float(plotPoints)
                    
                    // retrieve maximum value of the spectrum
                    var maxFFT_Y: Double = 0.0
                    for p in 1...plotPoints { // spectrum1.count-1 {
                        if (maxFFT_Y < spectrum1[p]) { maxFFT_Y = spectrum1[p]}
                        if (nChannels>1) {
                            if (maxFFT_Y < spectrum2[p]) { maxFFT_Y = spectrum2[p]}
                        }
                    }
                    let delta10V = tenVolt * V1
                    let zoomFFT_Y:Double = Double(delta10V) / maxFFT_Y
                    var xpos = Float(x0 - delta10V)
                    var ypos = y0
                    
                    // Plot channel 1 -- plotted on top quadrants
                    channelColours[0].set()
                    channels[0].lineWidth = 1
                    channels[0].move(to: NSPoint( x: Int(xpos), y: y0 ))
                    for p in 1...plotPoints {
                        xpos += dx
                        ypos = Int(zoomFFT_Y * spectrum1[p])
                        channels[0].line(to: NSPoint( x: Int(xpos), y: y0 + ypos))
                    }
                    channels[0].stroke()
                    channels[0].removeAllPoints()
                    // If there is a second channel . . .
                    // Channel 1 is plotted in the top quadrants
                    // Channel 2 is plotted in the bottom quadrants
                    if (nChannels > 1) {
                        let y0b = y0 - delta10V
                        xpos = Float(x0 - delta10V)
                        channelColours[0].set()         // Plot both channels in white
                        channels[1].lineWidth = 1
                        channels[1].move(to: NSPoint( x: Int(xpos), y: y0b ))
                        // restart
                        for p in 1...plotPoints {
                            xpos += dx
                            ypos = Int(zoomFFT_Y * spectrum2[p])
                            channels[1].line(to: NSPoint( x: Int(xpos), y: y0b + ypos))
                        }
                        channels[1].stroke()
                        channels[1].removeAllPoints()
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
        
        // The 'timed" and 'FFT' plot have NO vertical line at the centre
        // This vertical line is only plotted for (x,Y)-plots
        let hbXYcross: Bool = plotStyle.indexOfSelectedItem >= 3 && plotStyle.indexOfSelectedItem <= 5
        
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
        if hbXYcross {
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
                if !(!hbXYcross && rpxy==0) {
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
    
    
    // --- Code for loading and storing data sets in JSON format ----- --- -- ----- --- -- ----- --- -- ----- --- -- ----- --- --

    // Open and load data from disk - or - save data to disk // ----- ----- ----- -----
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

    
    // This is a slow version
    // Get a list of Int values - this wil NOT be used for 'parsing' the data set
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
        // Parse JSON
        // Set view with new configuration data
        // Set TextView with new data set incl. '!$ ' part. This will start the showDataPlot() function
        do {
            //  loadData: NSString
            let loadFile = try NSString(contentsOfFile: filename.relativePath, encoding: String.Encoding.utf8.rawValue)
            var datasetJSON = String(loadFile)
            // Strip all unnecessary spaces and new line characters     // just working a fraction faster...
            datasetJSON = String(datasetJSON.trimmingCharacters(in: .whitespacesAndNewlines))
            // Get JSON data like: the function will always return a string?
            // let ci = getJSON(title: "channelsIndex", json: initJSON)
            // ---> "3"
            let json_chix = getJSONInt(title: json_channels, json: datasetJSON)
            let json_osix = getJSONInt(title: json_oversmpl, json: datasetJSON)
            let json_ivix = getJSONInt(title: json_interval, json: datasetJSON)
            let json_spix = getJSONInt(title: json_samples,  json: datasetJSON)
            let json_plix = getJSONInt(title: json_plotStIx, json: datasetJSON)
            // Update view
            if json_chix >= 0   { numberOfChannels.title          = String(json_chix+1) }
            if json_osix >= 0   { degreeOfOversampling.title      = String(json_osix)   }
            if json_ivix >= 0   { intervalTime.stringValue        = String(json_ivix)   }
            if json_spix >= 0   { numberOfSamples.stringValue     = String(json_spix)   }
            if json_plix >= 0   { plotStyle.title                 = String(availablePlotStyles[json_plix])  }
            // 'parse' then JSON data set direct to -> receivedDataTextView.textStorage
            if json_spix >= 0 {
                cleanTextView()
                receivedDataTextView.textStorage?.mutableString.append("\(json_spix) samples\n")
                // First get all "s###" data from the json file
                // This can be a set of 16384 (or even more) Ints.
                var cc: Int     = 0         // "s"-counter
                var scs: String = ""        // "s"-counter string
                var hs: String  = ""
                var workList    = true
                var hc: Int     = 0
                repeat {
                    cc += 1                         // prepare 'search' string like `"s1":`
                    scs = String("\"s\(cc)\":")
                    let sIndex = datasetJSON.range(of: scs)
                    if (sIndex != nil) {
                        // Found s#
                        // Now get list of numbers between characters "[" and "]"
                        datasetJSON = String(datasetJSON[(sIndex?.upperBound...)!])     // very slow without this line of code...
                        let bodsIndex = datasetJSON.range(of: "[")
                        let eodsIndex = datasetJSON.range(of: "]")
                        hs = String(datasetJSON[(bodsIndex?.upperBound)!..<(eodsIndex?.lowerBound)!])
                        // Now only take decimal digits and the "," characters
                        let hhs = hs
                        hs = ""
                        for c in hhs { if ((c >= "0" && c <= "9") || (c == ",")) { hs += String(c) }}
                        // Strip ',' if it's the last character
                        if (hs.last == ",") { hs = String(hs.dropLast()) }
                        // Append data set line to 'receivedDataTextView'
                        receivedDataTextView.textStorage?.mutableString.append("\(hs)\n")
                        // Check if all samples are read already.
                        hc += 1
                        if hc == json_spix { workList = false }
                    } else
                    {
                        workList = false    // Stop further 'parsing' of data
                    }
                } while workList
                
            }
            receivedDataTextView.textStorage?.mutableString.append("\n!$\n")    // End of dataset character - start the plotting
            receivedDataTextView.scrollToEndOfDocument(self)
            receivedDataTextView.needsDisplay = true
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
        // Current date and time    // get the current date and time
        let dateNOW = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let sDateNow = formatter.string(from: dateNOW)
        let ht4     = "    "            // Tabs as spaces...
        let ht8     = ht4 + ht4
        let ht12    = ht4 + ht8
        let ht16    = ht4 + ht12
        let ht20    = ht4 + ht16
        // The four Object titles
        let openJSON    =  "{\n"
        let mainJSON    =  ht4 + "\"TeensyLogger-Controller-JSON\": {\n"
        let verJSON     =  ht8 + "\"TeensyLogger-Controller-version\": {\n"
        let initJSON    =  ht8 + "\"TeensyLogger-Controller-initials\": {\n"
        let dataJSON    =  ht8 + "\"TeensyLogger-Controller-sample-values\": {\n"
        let subclJSON   =  "},\n"
        let closeJSON   =  "}\n"
        let verlJSON    =  ht12 + "\"name\": \"TeensyLogger-Controller setup file\",\n" +
                           ht12 + "\"version\": \"" + appVersion! + "\",\n" +
                           ht12 + "\"sample date\": \"" + sDateNow + "\"\n" + ht8 + subclJSON
        let chJSON = ht12 + "\"" + json_channels + "\": " + String(numberOfChannels.indexOfSelectedItem) + ",\n"
        let osJSON = ht12 + "\"" + json_oversmpl + "\": " + String(degreeOfOversampling.indexOfSelectedItem) + ",\n"
        let ivJSON = ht12 + "\"" + json_interval + "\": " + intervalTime.stringValue + ",\n"
        let spJSON = ht12 + "\"" + json_samples  + "\": " + numberOfSamples.stringValue + ",\n"
        let psJSON = ht12 + "\"" + json_plotStIx + "\": " + String(plotStyle.indexOfSelectedItem) + "\n"
        let initlJSON = chJSON + osJSON + ivJSON + spJSON + psJSON + ht8 + subclJSON
        var dataSetJSON: String = ""
        let ppr     = plotPoints.endIndex
        let ppc     = plotPoints[0].endIndex
        for s in 0...ppr-1 {
            dataSetJSON += ht12 + "\"s" + String(s+1) + "\":\n" + ht16 + "[\n"
            for c in 0...ppc-1 {
                dataSetJSON += ht20 + String(plotPoints[s][c] )
                if c < ppc-1 {
                    dataSetJSON += ",\n"
                } else {
                    dataSetJSON += "\n" + ht16 + "]"
                }
            }
            if s < ppr-1 {
                    dataSetJSON += ","
            }
            dataSetJSON += "\n"
        }
        rsJSON =    openJSON    +
                    mainJSON    +
                    verJSON     +
                    verlJSON    +
                    initJSON    +
                    initlJSON   +
                    dataJSON    +
                    dataSetJSON +
                    ht8 +   closeJSON   +
                    ht4 +   closeJSON   +
                            closeJSON
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

}

// End of code.

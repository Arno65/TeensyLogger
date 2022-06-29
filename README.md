# TeensyLogger
A collection of code for building a Teensy 4.X ~ 8 channel data logger, and a controller running on MacOS.

  This project is based on a Teensy data logger, first built by Bernd Ulmann.
  Rob Jansen changed the code for the Teensy so both ADC's would be used 
  
  I stripped the Teensy code to a minimum and kept only those parts that where needed for the
  TeensyLogger-Controller I later built in Swift.
  
  *   TeensyLogger.zip is the file with the C++ code for the Teensy 4.X hardware.
      You need Teensyduino to compile and upload this code.
      More info on the Teensy modules can be found at: https://www.pjrc.com
  *   TeensyLogger-Controller.zip is the XCode project file for the MacOS application.
      This project was created with XCode 13.4 and Swift 5.0.
      The project was designed in dark-mode but will run in both modes.
      

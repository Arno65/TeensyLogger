# TeensyLogger
A collection of code for building a Teensy 4.X ~ 8 channel data logger, and a controller running on MacOS.

  This project is based on a Teensy data logger, first built by Bernd Ulmann. \
  More information can be found at: https://the-analog-thing.org/wiki/Teensy  \
  Rob Jansen changed the code for the Teensy so both ADC's are used efficiently.
  
  Here the Teensy code is stripped down to a minimum. \
  Only those parts remain that are needed for the TeensyLogger-Controller.
  
  More about the two projects: 
  *   'TeensyLogger.ino' is the file with the C++ code for the Teensy 4.X hardware. \
      You need 'Teensyduino' to compile and upload this code. \
      More info on the Teensy can be found at: https://www.pjrc.com 
  *   'TeensyLogger-Controller' is the XCode project file for the MacOS application. \
      This project was created with XCode 13.4 and Swift 5.0. \
      The project was designed in dark-mode but will run in both modes. 
      

/*
 *  Simple eight channel data recorder for a Teendy 4.0 board
 *  This code is based on the Teensy Data Logger build by Bernd Ulmann and Rob Jansen
 *  I stripped it to a minimal for my TeensyLogger and controller & viewer, written in Swift
 *  This code is also usable with a Haskkel serial I/O library (Using the '$' character as an end of data character.)
 *
 *  17.03.2021  B. Ulmann     Start of implementation, nothing fancy yet, everything out of the box.
 *  13.04.2021  B. Ulmann     Added calibration and floating point output, adapted to Perl library TeensyLogger.
 *  17.09.2021  B. Ulmann     Data is written out as a single large chunk to speed things up considerably.
 *  10.05.2022  R. Jansen     Update ADC speed and use 2 ADC units in parallel
 *  12.05.2022  R. Jansen     Changed normalization and added debugging commands to show raw and voltages for ADC values
 *  16.05.2022  A.J.M. Jacobs Small change for Arnos' DIY logger (version 0.3)
 *  30.05.2022  A.J.M. Jacobs Overwrite EEPROM read data at "void calibration_load()" All channels equal calibration values!
 *  01.06.2022  A.J.M. Jacobs Changes in output texts - distinct end characters like '$'
 *  12.06.2022  A.J.M. Jacobs First strip action
 *                            No benchmark command
 *                            No calibration and no EEPROM calibration data
 *                            All output sequences will end with a '$' character.
 *  13.06.2022  A.J.M. Jacobs Reformat to more readable code
 *                            Clean up output texts - more how I like it... ;-)
 *                            Don't use Serial.println (which will output a '\r') but Serial.print("\n")
 *                            THIS only to help my Haskell code ;-)
 *  21.06.2022  A.J.M. Jacobs Added 'End of data' character after 'dump' list is completed.
 *                              ('!', so ending with "!$ ")
 *                            Added 'Sampling automatically stopped' character after trigger()-run is completed.
 *                              ('~', so ending with "~$ ")
 *                            Maybe also usable for 'stop' command?
 *  22.06.2022 A.J.M. Jacobs  Some debugging...  removing bad code
 *                            Some rewriting (also output text reformatting)
 *  23.06.2022 A.J.M. Jacobs  Reminder for 'stream' mode
 *  30.06.2022 A.J.M. Jacobs  Version 1.2s. Adding 'stream' mode - simple style
 *                            'arm' is needed before stream mode is started.
 *                            Minimal interval time for now is 10000 microseconds / 10 milliseconds.
 *
 *
 *
 *  This version will only send the digital ADC value over serial I/O
 *  My calibration values in Swift are:
 *      let calibratedMinus10V0 = [200,200,201,200,201,200,201,200]
 *      let calibrated0V0       = [510,511,511,509,512,512,512,511]
 *      let calibratedPlus10V0  = [821,822,821,821,821,821,821,821]
 *
 *  These are the ADC values for -10V0, 0V0 and +10V0.
 *  Arno Jacobs
 *
 *
 */
 

#include <ADC.h>
#include <IntervalTimer.h>

#define VERSION "1.2s"

#define STRING_LENGTH     42      // Just a value
#define MAX_CHANNELS      8
// #define DEPTH          16384   // 16 k samples -- was standard value
#define DEPTH             24576   // (16 + 8 =) 24k samples -- > 30k seems too much?
#define ADC_RESOLUTION    10      // Resolution in bits
#define MAX_OVERSAMPLING  4

#define STATE_IDLE    0
#define STATE_ARMED   1
#define STATE_RUNNING 2

// The ports on the TeensyLogger by Arno Jacobs
#define ARMED_LED     11
#define RUNNING_LED   12
#define TRIGGER_IN    9



String help_text = "\n\nTeensy 4.0 data recorder " VERSION "   - - - - - - - - - - -\n\
?               Show this help\n\
arm             Arm recorder, start by trigger or command\n\
channels=x      Set number of channels to x [1.." + String(MAX_CHANNELS) + "]\n\
dump            Display raw samples on multiple lines\n\
interval=x      Set the sampling interval to x microseconds\n\
ms=x            Set the number of samples (max. " + String(DEPTH) + ")\n\
oversampling=x  Set degree of oversampling as 2**x\n\
stream          Start continuous data acquisition & display\n\
start           Start data acqusition (first arm system)\n\
status          Show the current status information\n\
stop            Stop a running/continuous data acquisition";


volatile unsigned short data[DEPTH][MAX_CHANNELS],  // Data storage (10 bits)
                        next_sample = 0,            // Position for the next sample
                        active_channels = 1,        // Number of currently active channels (up to CHANNELS is possible)
                        state = STATE_IDLE,
                        oversampling = 4;

volatile unsigned int interval = 1000,              // Sampling interval in microseconds
                      min_stream_interval = 10000,  // 10 milliseconds? enough? 0K?
                      max_samples = 100;            // In test situation
                      
ADC *adc = new ADC();

IntervalTimer sampling_timer;

bool dataDump   = false;
bool autoStop   = false;
bool streamMode = false;

/* Arno hates this code... :-(
 *  Just read a command and parameter and move on after a [enter] or newline character.
 *
** Local variant of strtok, just better. :-) The first call expects the string to be tokenized as its first argument.
** All subsequent calls only require the second argument to be set. If there is nothing left to be tokenized, a zero pointer
** will be returned. In contrast to strtok this routine will not alter the string to be tokenized since it
** operates on a local copy of this string.
*/
char *tokenize(char *string, char *delimiters) {
    static char local_copy[STRING_LENGTH];
    static char *position;
    char *token;

    if (string) { /* Initial call, create a copy of the string pointer */
        strcpy(local_copy, string);
        position = local_copy;
    } else { /* Subsequent call, scan local copy until a delimiter character will be found */
        /* Skip delimiters if there are any at the beginning of the string */
        while (*position && strchr(delimiters, *position)) position++;
        token = position; /* Now we are at the beginning of a token (or the end of the string :-) ) */

        if (*position == '\'') { /* Special case: Strings delimited by single quotes won't be split! */
            position++;
            while (*position && *position != '\'') position++;
        }

        while (*position) {
            position++;
            if (!*position || strchr(delimiters, *position)) { /* Delimiter found */
                if (*position)
                    *position++ = (char) 0; /* Split string copy */
                return token;
            }
        }
    }
    return NULL;
}


void sample() {
    unsigned i;
    
    if (!active_channels) return;
    if (streamMode) { next_sample = 1; }
        
    // Clear data so we start at 0 when using oversampling
    for (i = 0; i < active_channels; i++) data[next_sample][i] = 0;
    
    for (int j = 0; j < (1 << oversampling); j++) {
        for (i = 0; i < active_channels; i+= 2) {
            adc->startSynchronizedSingleRead(i, i+1);
            while(adc->adc0->isConverting() || adc->adc1->isConverting());
            data[next_sample][i] += adc->adc0->readSingle();    // Using both ADC's
            data[next_sample][i+1] += adc->adc1->readSingle();  // Thank you Rob!
        }
    }

    // Average data after oversampling
    for (i = 0; i < active_channels; i++) data[next_sample][i] >>= oversampling;

    if (streamMode) {
        for (int j = 0; j < active_channels; j++) {
            Serial.print(data[next_sample][j]);
            if (j < active_channels - 1)          // comparing 'int j' with ...int
                Serial.print(",");
        }
        Serial.print("\n");
        Serial.flush();
    } else {
        next_sample++;
        if (next_sample >= max_samples) {
            stop();
            Serial.print("Sampling automatically stopped after " + String(next_sample) + " samples.\n~$ ");
        }
    }
}


void trigger() {
    // In this code, only start with a trigger signal
    if (!streamMode) { detachInterrupt(TRIGGER_IN); }
    state = STATE_RUNNING;
    digitalWrite(ARMED_LED,   LOW);
    digitalWrite(RUNNING_LED, HIGH);
    sampling_timer.begin(sample, interval);
}


void stop() {
    sampling_timer.end();
    detachInterrupt(TRIGGER_IN);
    state = STATE_IDLE;
    digitalWrite(RUNNING_LED, LOW);
    autoStop = true;
    if (streamMode) {
        Serial.print( "$$ Streaming stopped.");
        streamMode = false;
    }
}


void initBlinking() {
    // Some initial LED blinking... the TeensyLogger did start up
    digitalWrite(RUNNING_LED, HIGH);
    digitalWrite(ARMED_LED,   HIGH);
    delay(900);
    digitalWrite(RUNNING_LED, LOW);
    delay(500);
    digitalWrite(RUNNING_LED, HIGH);
    digitalWrite(ARMED_LED,   LOW);
    delay(500);
    digitalWrite(RUNNING_LED, LOW);
}


void setup() {
    // Use both ADC's on board of the Teensy 4.x
    adc->adc0->setResolution(ADC_RESOLUTION);
    adc->adc0->setConversionSpeed(ADC_CONVERSION_SPEED::HIGH_SPEED);
    adc->adc0->setSamplingSpeed(ADC_SAMPLING_SPEED::VERY_HIGH_SPEED);
    
    adc->adc1->setResolution(ADC_RESOLUTION);
    adc->adc1->setConversionSpeed(ADC_CONVERSION_SPEED::HIGH_SPEED);
    adc->adc1->setSamplingSpeed(ADC_SAMPLING_SPEED::VERY_HIGH_SPEED);

    pinMode(ARMED_LED,   OUTPUT);
    pinMode(RUNNING_LED, OUTPUT);
    pinMode(TRIGGER_IN,  INPUT);
    initBlinking();

    // Short serial time out
    Serial.setTimeout(99);
    Serial.print(help_text);
    Serial.print("\n$ ");
}


void outOfBouds (int i) {
    Serial.print("Value ~> " + String(i) + " <~ out of bounds!");
}


void cmd_dump() {
    Serial.print(String(next_sample) + " samples\n");
    for (int i = 0; i < next_sample; i++) {
        for (int j = 0; j < active_channels; j++) {
            Serial.print(data[i][j]);
                if (j < active_channels - 1)
                    Serial.print(",");
        }
        Serial.print("\n");
    }
    streamMode = false;
    dataDump = true;
}



void loop() {
    char input[STRING_LENGTH];
    char command[STRING_LENGTH];
    char value[STRING_LENGTH];
  
    if (Serial.available() > 0) {       // There is something to read and process
        Serial.readString().toCharArray(input, STRING_LENGTH);

        tokenize(input, (char *) 0);
        strcpy(command, tokenize((char *) 0, (char *) " ="));

        // Trigger() & Data Dump helper
        autoStop = false;
        dataDump = false;

        // Show the help info
        if (!strcmp(command, "?")) {
            Serial.print(help_text);
        } else

        // Arm the logger - ready to read the voltages on the selected channels
        if (!strcmp(command, "arm")) {
            digitalWrite(ARMED_LED, HIGH);
            state       = STATE_ARMED;
            next_sample = 0;
            attachInterrupt(TRIGGER_IN, trigger, FALLING);
            Serial.print("armed");
            streamMode = false;
        } else

        // Set the number of channels [1..8]
        if (!strcmp(command, "channels")) {
            strcpy(value, tokenize((char *) 0, (char *) "="));
            unsigned int channels = atoi(value);
            if (channels < 1 || channels > MAX_CHANNELS)
                outOfBouds(channels);
            else {
                active_channels = channels;
                Serial.print("channels=" + String(active_channels));
            }
        } else
        
        // Display samples on multiple lines as ADC (digital) value [0..1023]
        if(!strcmp(command, "dump")) {
            cmd_dump();
        } else

        // Set the interval time (in ms.) between two consecutive samples
        if (!strcmp(command, "interval")) {
            strcpy(value, tokenize((char *) 0, (char *) "="));
            interval = atoi(value);
            Serial.print("interval=" + String(interval));
        } else
    
        // Set the (maximum) number of samples (per channel) for a run
        if (!strcmp(command, "ms")) {
            strcpy(value, tokenize((char *) 0, (char *) "="));
            unsigned int i = atoi(value);
            if (i < 1 || i > DEPTH)
                outOfBouds(i);
            else {
                max_samples = i;
                Serial.print("ms=" + String(max_samples));
            }
        } else

        // Set the degree of oversampling as 2**x  [0..4]
        if (!strcmp(command, "oversampling")) {
            strcpy(value, tokenize((char *) 0, (char *) "="));
            unsigned int i = atoi(value);
            if (i < 0 || i > MAX_OVERSAMPLING)
                outOfBouds(i);
            else {
                oversampling = i;
                Serial.print("oversampling=" + String(oversampling));
            }
        } else
        
        // If armed, 'software' start the data acquisition
        // The logger will also start with a hardware trigger signal (from the analog computer...or so...)
        if (!strcmp(command, "start")) {
            autoStop = false;
            if (state != STATE_ARMED)
                Serial.print("Not armed, no acquisition!");
            else {
                Serial.print("started");
                trigger();
            }
        } else
    
        // Show the current status of the Teensy data logger
        if (!strcmp(command, "status")) {
            Serial.println( "\nCurrent status:");
            Serial.println( "channels     = " + String(active_channels));
            Serial.println( "samples      = " + String(next_sample - 1));
            Serial.print  ( "state        = " );
            if (state != STATE_ARMED) {
                Serial.print ("NOT ");
            }
            Serial.println( "armed");
            Serial.println( "interval     = " + String(interval));
            Serial.println( "max_samples  = " + String(max_samples));
            Serial.println( "oversampling = " + String(oversampling));
        } else
    
        // If started, 'software' stop the data acquisition
        // The logger will not stop with a hardware trigger signal
        if (!strcmp(command, "stop")) {
            if (streamMode) {
                    stop();
                    autoStop = false;
                    dataDump = false;
            } else {
                if (state == STATE_RUNNING) {
                    stop();
                    Serial.print("stopped");
                } else {
                    Serial.print("disarmed");
                    autoStop = false;
                }
            }
            state = STATE_IDLE;
            digitalWrite(RUNNING_LED, LOW);
            digitalWrite(ARMED_LED,   LOW);
        } else

        // Stream mode ... same as 'start' but with BOOL streamMode set to true
        //
        if (!strcmp(command, "stream")) {
            if (interval >= min_stream_interval) {
                if (state != STATE_ARMED)
                    Serial.print("Not armed, no stream!");
                else {
                    // Don't show -- Serial.print("started stream");
                    // Start with a clean slate
                    streamMode = true;
                    attachInterrupt(TRIGGER_IN, stop, FALLING);
                    trigger();
                }
            } else
            {
                Serial.print("Interval time is too low (>= 10000), no stream!");
            }
        } else
        
        {
            Serial.print("Unknown command  ~ " + String(command) + " ~");
        }
        // The output after each command will end with '\n ', so a line feed and a space character
        if (dataDump) {
            Serial.print("\n!$ ");
            dataDump = false;
        } else
            if (autoStop && !streamMode) {
                Serial.print("\n~$ ");
                autoStop = false;
            } else
                if (streamMode) {
                    Serial.print("\n");
                } else {
                    Serial.print("\n$ ");
                }
    }
}
// End of code.

# air-quality-monitor

An air qualitiy monitor using an Arduino Pro Mini. This was used as a capstone project.

## Background

A DIY air quality monitor with Bluetooth technology. This allows users to be able to access the information from the sensors anywhere within the Bluetooth connectivity range. They can also change the display to a cheaper alternative and have a small monochrome display for users who wish to receive basic information without the use of their smartphone.

    The Bluetooth connectivity uses the flutter_bluetooth_serial library from pub.dev created by AgainPsychoX with the help of contributors, Eduardo Folly, Martin Mauch ,and Patryk Ludwikowski. This library uses serial port profile for moving data over RFCOMM and is used for Bluetooth Classic devices such as the HC-06. Some code has been referenced or used from the example on Github in this project to create the connectivity and app.

## Featured Sensors

Temperature: A quantity expressing hot and cold.
Humidity: A measurement of water vapour in the air.
Carbon Dioxide (CO2): An acidic colourless gas.
Ozone (O3): A highly reactive gas.
Volatile Organic Compound (VOC): Organic chemicals that have high vapour pressure at room temperature.
Fine particulate matter (PM2.5): Matter that is 2.5 microns in diameter or less.

## Circuit Diagram

An HC-06 Bluetooth module will be connected to the RX and TX communication lines of the Arduiono with a voltage divider as the module operates on 3.3v while the module is powered with 5v. An SSD1306 1 inch monochrome OLED display is also used to display information about the current values of measurements using the SDA and SCL lines to communicate with the Arduino. A power bank was also added so it can be soldered as Blue Air is not powered by a power cable but 4xAA rechargeable batteries in series will be the power supply, giving approximately outputting 5 volts to the system. Both HC-06 and SSD1306 did not have a model in Altium Designer as such a model had to be made with Altium component designer.

## PCB Diagram

## App Display

The app has four screens, the first screen is to strictly establish a bluetooth connection with Blue Air, ensuring bluetooth is enabled and has the ability to be enabled within the app asking permission in doing so. It also shows the real time status of the Bluetooth state as well as the page where the user can choose what device to connect to via Bluetooth. Once connected the user can view the information page leading into another screen where visual information is presented in numeric format with the addition of a status bar and a button to display a graph with the measurement of the user’s choosing.

## Functions Of The Arduino

The Arduino will collect the data from each sensor and store them in an array with a time label stored with it; this allows for the data to be retrieved that was collected in the past without a smartphone always being connected to receive the data. Memory will be set aside for this function to ensure the data will be kept for a set time, and be able to be retrieved any time the device is connected to a smartphone. Third party libraries were used for each sensor, simplifying the development of the code and the functionality.

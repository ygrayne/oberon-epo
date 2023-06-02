# cv-sk

The Oberon and Verilog modules for Cyclone V Starter Kit for base Embedded Project Oberon.

## fpga

* 'lib': all Verilog modules
* 'build': the Quartus project in directory 'build' creates the FPGA config files.

## oberon

* 'lib':
  * LSB.mod to access the LEDs, switches, buttons, and 7-segment displays
  * I2C.mod: adapted for the I2C device using four IO addresses only

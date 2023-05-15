# arty-a7-100-calltrace

The Oberon and Verilog modules for Arty A7-100 with the added Calltrace feature.

See [Stack Trace](https://www.astrobe.com/forum/viewtopic.php?f=13&t=747) in the Astrobe forum.

## hardware

* 'lib': the changed or added Verilog modules
* 'build': the Vivado project in directory 'build' creates the FPGA config files.
* uses the Verilog modules in '/lib-base/hardware' if unchanged

## oberon

* 'lib': the changed or added Oberon files
* 'config': config file for Astrobe for RISC5
* 'demo': simple demo modules
* uses the Oberon modules in 'lib-base/oberon' if unchanged

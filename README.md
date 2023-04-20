
# EPO Changes and Extensions

EPO: see [Embedded Project Oberon](https://astrobe.com/RISC5/ReadMe.htm).

Note the copyrights and most importantly the ALL CAPs disclaimers in the file COPYRIGHT.md and possibly the single source files!

## Calltrace

I have always found a "stack trace", ie. the display of the chain of procedure calls that lead to an error, very useful to find the causes of run-time problems. This chain is unrolled by walking the stack backwards from the error point -- or from any state of calls -- frame by frame using the frame pointer, which is also stored on the stack.

However, the RISC5 processor, as implemented in the FPGA, and the compiler do not use a frame pointer.

For some FPGA fun, I have implemented a solution there, which I call Calltrace. It works with the Astrobe compiler.

See [Stack Trace](https://www.astrobe.com/forum/viewtopic.php?f=13&t=747) in the Astrobe forum.
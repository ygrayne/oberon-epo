MODULE SPI;
(* =========================================================================
   SPI - Serial Peripheral Interface Driver

   Target: RISC5 Embedded Project Oberon

   (c) 2017-2021 CFB Software
   https://www.astrobe.com

  Permission to use, copy, modify, and/or distribute this software and its
  accompanying documentation (the "Software") for any purpose with or
  without fee is hereby granted, provided that the above copyright notice
  and this permission notice appear in all copies.

  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHORS DISCLAIM ALL WARRANTIES
  WITH REGARD TO THE SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF
  MERCHANTABILITY, FITNESS AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
  AUTHORS BE LIABLE FOR ANY CLAIM, SPECIAL, DIRECT, INDIRECT, OR
  CONSEQUENTIAL DAMAGES OR ANY DAMAGES OR LIABILITY WHATSOEVER, WHETHER IN
  AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
  CONNECTION WITH THE DEALINGS IN OR USE OR PERFORMANCE OF THE SOFTWARE.
  ========================================================================= *)

IMPORT SYSTEM;

CONST
  (* SPI registers *)
  SPIData = -48;
  SPICtrl = -44;

TYPE
  Word* = ARRAY 4 OF BYTE;

PROCEDURE Select*(ctrl: SET);
BEGIN
  SYSTEM.PUT(SPICtrl, ctrl)
END Select;


PROCEDURE SendByte*(data: BYTE);
BEGIN
  SYSTEM.PUT(SPIData, data);
  REPEAT UNTIL SYSTEM.BIT(SPICtrl, 0);
END SendByte;


PROCEDURE SendWord*(data: Word);
BEGIN
  SYSTEM.PUT(SPIData, data);
  REPEAT UNTIL SYSTEM.BIT(SPICtrl, 0);
END SendWord;


PROCEDURE ReceiveByte*(VAR data: BYTE);
BEGIN
  SYSTEM.PUT(SPIData, 0FFH);
  REPEAT UNTIL SYSTEM.BIT(SPICtrl, 0);
  SYSTEM.GET(SPIData, data);
END ReceiveByte;


PROCEDURE ReceiveWord*(VAR data: Word);
BEGIN
  SYSTEM.PUT(SPIData, 0FFH);
  REPEAT UNTIL SYSTEM.BIT(SPICtrl, 0);
  SYSTEM.GET(SPIData, data);
END ReceiveWord;


PROCEDURE Send*(b: ARRAY OF BYTE);
VAR
  i: INTEGER;
BEGIN
  FOR i := 0 TO LEN(b) - 1 DO
    SYSTEM.PUT(SPIData, b[i]);
    REPEAT UNTIL SYSTEM.BIT(SPICtrl, 0);
  END
END Send;


PROCEDURE Receive*(VAR b: ARRAY OF BYTE);
VAR
  i: INTEGER;
BEGIN
  FOR i := 0 TO LEN(b) - 1 DO
    SYSTEM.PUT(SPIData, 0FFH);
    REPEAT UNTIL SYSTEM.BIT(SPICtrl, 0);
    SYSTEM.GET(SPIData, b[i]);
  END
END Receive;

END SPI.

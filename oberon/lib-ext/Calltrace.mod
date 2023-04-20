MODULE Calltrace;
(**
  Driver for the calltrace "shadow" stack.
  --
  (c) 2021-2023 Gray gray@grayraven.org
  https://oberon-rts.org/licences
**)

  IMPORT SYSTEM;

  CONST
    DataAdr = -40;
    StatusAdr = DataAdr + 4;

    (* control bits *)
    ClearCtrl = 1;
    FreezeCtrl = 2;
    UnfreezeCtrl = 4;

    (* status bits *)
    EmptyBit = 0;
    FullBit = 1;
    OverflowBit = 2;
    FrozenBit = 3;

    (* status value ranges *)
    Count0 = 8;
    Count1 = 15;
    MaxCount0 = 16;
    MaxCount1 = 23;


  PROCEDURE Clear*;
  BEGIN
    SYSTEM.PUT(StatusAdr, ClearCtrl);
  END Clear;


  (* unfrozen stack *)
  (* care neds to be taken not to contaminate the stack with these procedures *)
  (* and cause or return false stack values *)

  PROCEDURE Freeze*;
    VAR x: INTEGER;
  BEGIN
    (* pop top element hw-pushed by entering this procedure *)
    SYSTEM.GET(DataAdr, x);
    SYSTEM.PUT(StatusAdr, FreezeCtrl)
  END Freeze;


  PROCEDURE Pop*(VAR value: INTEGER);
    VAR x: INTEGER;
  BEGIN
    SYSTEM.GET(DataAdr, x);   (* pop this procedure's hw-pushed entry *)
    SYSTEM.GET(DataAdr, value);
    SYSTEM.PUT(DataAdr, x)    (* push it back *)
  END Pop;


  PROCEDURE Push*(value: INTEGER);
    VAR x: INTEGER;
  BEGIN
    SYSTEM.GET(DataAdr, x);
    SYSTEM.PUT(DataAdr, value);
    SYSTEM.PUT(DataAdr, x)
  END Push;


  PROCEDURE GetStatus*(VAR status: INTEGER);
    VAR x: INTEGER;
  BEGIN
    SYSTEM.GET(DataAdr, x);
    SYSTEM.GET(StatusAdr, status);
    SYSTEM.PUT(DataAdr, x)
  END GetStatus;


  PROCEDURE GetCount*(VAR count: INTEGER);
    VAR x: INTEGER;
  BEGIN
    SYSTEM.GET(DataAdr, x);
    SYSTEM.GET(StatusAdr, count);
    SYSTEM.PUT(DataAdr, x);
    count := BFX(count, Count1, Count0)
  END GetCount;


  PROCEDURE GetMaxCount*(VAR count: INTEGER);
  (* the max count including any pushes in the overflow state *)
    VAR x: INTEGER;
  BEGIN
    SYSTEM.GET(DataAdr, x);
    SYSTEM.GET(StatusAdr, count);
    SYSTEM.PUT(DataAdr, x);
    count := BFX(count, MaxCount1, MaxCount0)
  END GetMaxCount;


  PROCEDURE Frozen*(): BOOLEAN;
    RETURN SYSTEM.BIT(StatusAdr, FrozenBit)
  END Frozen;


  PROCEDURE Empty*(): BOOLEAN;
    VAR x: INTEGER; empty: BOOLEAN;
  BEGIN
    SYSTEM.GET(DataAdr, x);
    empty := SYSTEM.BIT(StatusAdr, EmptyBit);
    SYSTEM.PUT(DataAdr, x);
    RETURN empty
  END Empty;


  PROCEDURE Full*(): BOOLEAN;
    VAR x: INTEGER; full: BOOLEAN;
  BEGIN
    SYSTEM.GET(DataAdr, x);
    full := SYSTEM.BIT(StatusAdr, FullBit);
    SYSTEM.PUT(DataAdr, x);
    RETURN full
  END Full;


  PROCEDURE Overflow*(): BOOLEAN;
    VAR x: INTEGER; ovfl: BOOLEAN;
  BEGIN
    SYSTEM.GET(DataAdr, x);
    ovfl := SYSTEM.BIT(StatusAdr, OverflowBit);
    SYSTEM.PUT(DataAdr, x);
    RETURN ovfl
  END Overflow;


  (* frozen stack *)

  PROCEDURE Read*(VAR value: INTEGER);
  BEGIN
    SYSTEM.GET(DataAdr, value)
  END Read;


  PROCEDURE Unfreeze*;
  BEGIN
    SYSTEM.PUT(StatusAdr, UnfreezeCtrl);
    (* push dummy value, will be hw-popped upon exiting this procedure *)
    SYSTEM.PUT(DataAdr, 0)
  END Unfreeze;

END Calltrace.

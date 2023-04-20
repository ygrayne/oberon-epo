(**
  Utterly simple demo program for the calltrace feature, run 'Run'.
  'Test' can be used to test the FPGA implementation.
  --
  (c) 2021-2023 Gray, gray@grayraven.org
  https://oberon-rts.org/licences
**)

MODULE TestCall1;

  IMPORT Calltrace, CalltraceView, TestCall2, Texts;

  VAR
    W: Texts.Writer;


  PROCEDURE c2;
  BEGIN
    Texts.WriteString(W, "c2 ");
    TestCall2.Do2
  END c2;

  PROCEDURE c1;
  BEGIN
    Texts.WriteString(W, "c1 ");
    c2
  END c1;

  PROCEDURE c0;
  BEGIN
    Texts.WriteString(W, "c0 ");
    c1
  END c0;


  PROCEDURE do;
  BEGIN;
    CalltraceView.ShowTrace(0);
    c0
  END do;


  PROCEDURE Run*;
  BEGIN
    do
  END Run;


  (* for a 64 item call stack *)
  (* adjust 'Runs' and 'StackItems' *)
  (* restart system after test for accurate real calltraces *)
  (* since we're doing a Calltrace.Clear here *)

  PROCEDURE Test*;
    CONST
      Runs = 70; Runs0 = Runs - 1;
      StackItems = 64; StackItems0 = StackItems - 1;
    VAR
      x, c, i: INTEGER;
  BEGIN
    Calltrace.Clear;
    Texts.WriteString(W, "fill and overflow stack"); Texts.WriteLn(W);
    i := 0;
    WHILE i < Runs DO
      Calltrace.Push(i);
      INC(i)
    END;

    Calltrace.GetCount(c);
    Texts.WriteString(W, "=> count: "); Texts.WriteInt(W, c, 0);
    IF c = StackItems THEN
      Texts.WriteString(W, " OK")
    ELSE
      Texts.WriteString(W, " WRONG"); Texts.WriteLn(W)
    END;
    Texts.WriteLn(W); Texts.WriteLn(W);

    Texts.WriteString(W, "read items without popping"); Texts.WriteLn(W);
    i := 0;
    Calltrace.Freeze;
    WHILE i < c DO
      Calltrace.Read(x);
      IF x # (StackItems0 - i) THEN
        Texts.WriteString(W, "error at: ");  Texts.WriteInt(W, i, 0); Texts.WriteLn(W)
      END;
      INC(i)
    END;
    Calltrace.Unfreeze;

    Calltrace.GetCount(c);
    Texts.WriteString(W, "=> count: "); Texts.WriteInt(W, c, 0);
    IF c = StackItems THEN
      Texts.WriteString(W, " OK")
    ELSE
      Texts.WriteString(W, " WRONG"); Texts.WriteLn(W)
    END;
    Texts.WriteLn(W); Texts.WriteLn(W);

    Texts.WriteString(W, "pop items"); Texts.WriteLn(W);
    i := 0;
    WHILE i < Runs DO
      Calltrace.Pop(x);
      IF i < Runs - StackItems0 THEN
        IF x # StackItems0 THEN
          Texts.WriteString(W, "error at: ");  Texts.WriteInt(W, i, 0); Texts.WriteLn(W)
        END
      ELSE
        IF x # (Runs0 - i) THEN
          Texts.WriteString(W, "error at: ");  Texts.WriteInt(W, i, 0); Texts.WriteLn(W)
        END
      END;
      INC(i)
    END;

    Calltrace.GetCount(c);
    Texts.WriteString(W, "=> count: "); Texts.WriteInt(W, c, 0);
    IF c = 0 THEN
      Texts.WriteString(W, " OK")
    ELSE
      Texts.WriteString(W, " WRONG")
    END;
    Texts.WriteLn(W)
  END Test;

END TestCall1.

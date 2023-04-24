(**
  Print procedure calltrace from calltrace stack.
  --
  (c) 2021-2023 Gray, gray@grayraven.org
  https://oberon-rts.org/licences
**)

MODULE CalltraceView;

  IMPORT Calltrace, Texts, Modules;

  VAR W: Texts.Writer;


  PROCEDURE writeModuleName(name: ARRAY OF CHAR; padTo: INTEGER);
    VAR i, j: INTEGER;
  BEGIN
    Texts.WriteString(W, name);
    i := 0; WHILE name[i] # 0X DO INC(i) END;
    FOR j := i TO padTo DO Texts.Write(W, " ") END
  END writeModuleName;


  PROCEDURE writeTraceLine(adr: INTEGER);
    VAR mod: Modules.Module;
  BEGIN
    mod := Modules.root;
    WHILE (mod # NIL) & ((adr < mod.code) OR (adr >= mod.imp)) DO mod := mod.next END;
    IF mod # NIL THEN
      Texts.WriteString(W, "  "); writeModuleName(mod.name, 20); Texts.WriteHex(W, adr); Texts.WriteHex(W, adr - mod.code);
      Texts.WriteInt(W, (adr - mod.code) DIV 4, 8);
    ELSE
      Texts.WriteString(W, "  "); writeModuleName("unknown", 20); Texts.WriteHex(W, adr)
    END
  END writeTraceLine;


  (*
  'id' is simply an indicator to differentiate different
  calls to ShowTrace, in case the code under test is instrumented
  with more than one. As a "special feature", if 'id' is negative,
  the top element gets popped in order not to see the call to ShowTrace
  which may or may not be useful. The trap handler uses -1.
  *)
  PROCEDURE ShowTrace*(id: INTEGER);
    VAR i, x, cnt: INTEGER;
  BEGIN
    IF id < 0 THEN Calltrace.Pop(x) END;
    Texts.WriteLn(W);
    Texts.WriteString(W, "Calltrace id: "); Texts.WriteInt(W, id, 0); Texts.WriteLn(W);
    Texts.WriteString(W, "  module                "); Texts.WriteString(W, "    addr");
    Texts.WriteString(W, "   m-addr"); Texts.WriteString(W, "    line"); Texts.WriteLn(W);
    Calltrace.GetCount(cnt);
    Calltrace.Freeze;
    i := 0;
    WHILE i < cnt DO
      Calltrace.Read(x);
      DEC(x, 4); (* stored LNK value is 4 addresses "ahead" of corresponding BL call *)
      writeTraceLine(x);
      Texts.WriteLn(W);
      INC(i)
    END;
    Calltrace.Unfreeze;
    Calltrace.GetMaxCount(cnt);
    Texts.WriteString(W, "max depth: "); Texts.WriteInt(W, cnt, 0); Texts.WriteLn(W)
  END ShowTrace;

END CalltraceView.

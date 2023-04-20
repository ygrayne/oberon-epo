MODULE Input;

  IMPORT SYSTEM;

  CONST
    data = -56; stat = -52;

  PROCEDURE Available*(): INTEGER;
  VAR
    count: INTEGER;
  BEGIN
    IF SYSTEM.BIT(stat, 0) THEN
      count := 1
    ELSE
      count := 0
    END;
    RETURN count
  END Available;

  PROCEDURE Read*(VAR ch: CHAR);
  VAR
    x: BYTE;
  BEGIN
    REPEAT UNTIL SYSTEM.BIT(stat, 0);
    SYSTEM.GET(data, x);
    ch := CHR(x)
  END Read;

END Input.



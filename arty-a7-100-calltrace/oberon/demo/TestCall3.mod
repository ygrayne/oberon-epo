MODULE TestCall3;

  IMPORT CalltraceView;

  PROCEDURE c0;
  BEGIN
    CalltraceView.ShowTrace(3);
    ASSERT(FALSE)
  END c0;

  PROCEDURE Do3*;
  BEGIN
    c0
  END Do3;

END TestCall3.

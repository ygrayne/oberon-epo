MODULE TestCall2;

  IMPORT TestCall3, CalltraceView;

  PROCEDURE Do2*;
  BEGIN
    CalltraceView.ShowTrace(1);
    TestCall3.Do3
  END Do2;

END TestCall2.

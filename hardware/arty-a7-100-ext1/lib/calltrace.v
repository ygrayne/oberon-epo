/**
  Calltrace stack
  --
  The calltrace stack registers

  1) the entry into a procedure, pushing the LNK value
  2) the exit from a procedure, popping the topmost LNK value

  Hence, at any point, the stack represents a backtrace of procedure calls, a "stack trace".

  For this, the IR (instruction register) of the CPU is monitored for corresponding
  push and pop instructions.

  The stacked LNK data can be read without popping the stack, to be able to get a trace
  at any time without losing the stacked data.

  As the calltrace shall survive a system restart, there's no 'rst' signal. Clear the
  stack after error handling.
  --
  Control data_in:
  [1]: clear stack
  [2]: freeze stack
  [3]: unfreeze stack
  --
  (c) 2021 - 2023 Gray, gray@grayraven.org
  https://oberon-rts.org/licences
**/

`timescale 1ns / 1ps
`default_nettype none

module calltrace (
  input wire clk,
  input wire wr_data,
  input wire wr_ctrl,
  input wire rd_data,
  input wire [31:0] ir_in,        // instruction register value
  input wire [23:0] lnk_in,       // LNK register value
  input wire [23:0] data_in,
  output wire [31:0] data_out,
  output wire [31:0] status_out
);

  // could be module parameters
  localparam num_slots = 64;      // number of stack slots (depth of stack)
  localparam data_width = 24;     // width of data paths (24 address bits)

  // controls
  wire wr_clear    = wr_ctrl & data_in[0];    // clear stack
  wire wr_freeze   = wr_ctrl & data_in[1];    // freeze stack
  wire wr_unfreeze = wr_ctrl & data_in[2];    // unfreeze stack

  // hardware push and pop signals
  wire push_trig = (ir_in == 32'hAFE00000) ? 1'b1 : 1'b0;  // push trigger: STW LNK, SP, 0
  wire pop_trig = (ir_in == 32'hC700000F) ? 1'b1 : 1'b0;   // pop trigger: B LNK

  reg push_trig0, pop_trig0;                 // edge pulse signals
  wire push_p = push_trig & ~push_trig0;     // push edge pulse
  wire pop_p = pop_trig & ~pop_trig0;        // pop edge pulse

  always @(posedge clk) begin
    push_trig0 <= push_trig;
    pop_trig0 <= pop_trig;
  end

  // actual push and pop signals
  wire push_c = wr_data | push_p;
  wire pop_c = rd_data | pop_p;

  // stacks input data
  wire [23:0] stack_data_in = wr_data ? data_in[23:0] : lnk_in[23:0];

  // stack control and status signals
  // in
  wire push = push_c;
  wire pop = pop_c;
  wire read = rd_data;
  wire rst = wr_clear;
  wire freeze = wr_freeze;
  wire unfreeze = wr_unfreeze;
  // out
  wire empty, full, frozen, ovfl;

  // output from the stack
  wire [7:0] count;
  wire [7:0] max_count;
  wire [23:0] stack_data_out;
  wire [23:0] stack_ctrl_out;

  // the stack
  stackx #(.data_width(data_width), .num_slots(num_slots)) stackx_0 (
    // in
    .clk(clk),
    .rst(rst),
    .push(push),
    .pop(pop),
    .read(read),
    .freeze(freeze),
    .unfreeze(unfreeze),
    .data_in(stack_data_in),
    // out
    .empty(empty),
    .full(full),
    .ovfl(ovfl),
    .frozen(frozen),
    .count(count),
    .max_count(max_count),
    .data_out(stack_data_out)
  );

  // output assignments
  assign stack_ctrl_out = {max_count, count, 4'b0, frozen, ovfl, full, empty};
  assign data_out[31:0] = {8'b0, stack_data_out};
  assign status_out[31:0] = {8'b0, stack_ctrl_out};

endmodule

`resetall

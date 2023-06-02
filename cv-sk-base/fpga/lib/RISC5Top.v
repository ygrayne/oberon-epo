/**
  RISC5 CPU and environment definition for Embedded Project Oberon
  --
  Board and technology: Terasic Cyclone V Starter Kit, Altera Cyclone V GX
  --
  Base/origin:
    * Embedded Project Oberon
    * THM-oberon
  --
  2023 Gray, gray@grayraven.org
  https://oberon-rts.org/licences
**/

`timescale 1ns / 1ps
`default_nettype none

module RISC5Top #(
  parameter
    clock_freq = 38_000_000,  // as set in module 'clocks'
    prom_file = "../bootload/BootLoad-416k-64k.mem",
    rs232_buf_slots = 256,    // RS232 buffer size in bytes, same for for tx and rx
    num_gpio = 26             // number of GPIO pins
  )(
  // clock
  input wire clk_in,
  // RS-232
  input wire rs232_0_rxd,
  output wire rs232_0_txd,
  // SD card (SPI CS = 0)
  output wire sdcard_cs_n,
  output wire sdcard_sclk,
  output wire sdcard_mosi,
  input wire sdcard_miso,
  // SPI CS = 1 and 2
  output wire [2:1] spi_cs_n,
  output wire [2:1] spi_sclk,
  output wire [2:1] spi_mosi,
  input wire [2:1] spi_miso,
  // LEDs, switches, buttons, 7-segment
  output wire [7:0] led_g,
  output wire [9:0] led_r,
  output wire [6:0] hex1_n,
  output wire [6:0] hex0_n,
  input wire [3:0] btn_in_n,
  input wire [9:0] swi_in,
  // GPIO
  inout wire [num_gpio-1:0] gpio,
  // I2C
  inout wire i2c_scl,
  inout wire i2c_sda
);

  // clk
  wire clk_ok;                // clocks stable
  wire clk;
  wire clk_rst;
  // reset
  wire rst;                   // active high
  // cpu
  wire [23:0] adr;            // address bus
  wire [31:0] inbus;          // data to RISC core from RAM or IO
  wire [31:0] codebus;        // code to RISC core from RAM or ROM
  wire [31:0] outbus;         // data from RISC core
  wire rd;                    // CPU read
  wire wr;                    // CPU write
  wire ben;                   // CPU byte enable
  wire irq;                   // interrupt request to CPU
  // prom
  wire prom_stb;
  wire [31:0] prom_dout;
  // ram
  wire ram_stb;
  wire [31:0] ram_dout;
  // i/o
  wire io_en;                 // i/o enable
  wire [31:0] io_out;         // io devices output
  // ms timer
  wire tmr_stb;
  wire [31:0] tmr_dout;       // running milliseconds since reset
  wire tmr_ms_tick;           // millisecond timer tick signal
  wire tmr_ack;
  // lsb
  wire lsb_stb;
  wire [9:0] lsb_leds_r_in;  // direct signals in for red LEDs
  wire [31:0] lsb_dout;      // buttons, switches status
  wire [3:0] lsb_btn;        // button signals out, 'clk' synced
  wire [9:0] lsb_swi;        // switch signals out, 'clk' synced
  wire lsb_ack;
  // rs232
  wire rs232_0_stb;
  wire [31:0] rs232_0_dout;   // received data, status
  wire rs232_0_ack;
  // spi
  wire spi_0_stb;
  wire [31:0] spi_0_dout;     // received data, status
  wire spi_0_sclk_d;          // sclk signal from device
  wire spi_0_mosi_d;          // mosi signal from device
  wire spi_0_miso_d;          // miso signal to device
  wire [2:0] spi_0_cs_n_d;    // chip selects from device
  wire spi_0_ack;
  // gpio
  wire gpio_stb;
  wire [31:0] gpio_dout;      // pin data, in/out control status
  wire gpio_ack;
  // i2c
  wire i2c_stb;
  wire [31:0] i2c_dout;
  wire i2c_ack;

  // clocks
  clocks clocks_0 (
    // in
    .rst(clk_rst),
    .clk_in(clk_in),
    //out
    .clk_ok(clk_ok),
    .clk(clk)
  );

  // reset
  reset reset_0 (
    // in
    .clk(clk),
    .clk_ok(clk_ok),
    .rst_in_n(btn_in_n[3]),
    // out
    .rst_out(rst)
  );

  // CPU
  RISC5 #(.start_addr(24'hFFE000)) risc5_0 (
    // in
    .clk(clk),
    .rst(~rst),
    .irq(irq),
    .codebus(codebus[31:0]),
    .inbus(inbus[31:0]),
    // out
    .rd(rd),
    .wr(wr),
    .ben(ben),
    .adr(adr[23:0]),
    .outbus(outbus[31:0])
  );

  // boot ROM
  prom #(.mem_file(prom_file)) prom_0 (
    // in
    .clk(~clk),
    .en(prom_stb),
    .addr(adr[10:2]),
    // out
    .data_out(prom_dout[31:0])
  );

  // RAM 384k
  ramg5 #(.num_kbytes(416)) ram_0 (
    // in
    .clk(clk),
    .en(ram_stb),
    .we(wr),
    .be(ben),
    .addr(adr[18:0]),
    .data_in(outbus[31:0]),
    // out
    .data_out(ram_dout[31:0])
  );

  // ms timer
  // one IO address
  ms_timer #(.clock_freq(clock_freq)) tmr_0 (
    // in
    .clk(clk),
    .rst(rst),
    .stb(tmr_stb),
    // out
    .data_out(tmr_dout[31:0]),
    .ms_tick(tmr_ms_tick),
    .ack(tmr_ack)
  );

  // LEDs, switches, buttons, 7-seg displays
  // one IO address
  assign lsb_leds_r_in[9:0] = 10'b0; // only 'clk' synced signals
  lsb_s lsb_0 (
    // in
    .clk(clk),
    .rst(rst),
    .stb(lsb_stb),
    .we(wr),
    .leds_r_in(lsb_leds_r_in[9:0]),
    .data_in(outbus[31:0]),
    // out
    .data_out(lsb_dout[31:0]),
    .ack(lsb_ack),
    .btn_out(lsb_btn[3:0]),
    .swi_out(lsb_swi[9:0]),
    // external in
    .btn_in_n(btn_in_n[3:0]),
    .swi_in(swi_in[9:0]),
    // external out
    .leds_g(led_g[7:0]),
    .leds_r(led_r[9:0]),
    .hex1_n(hex1_n[6:0]),
    .hex0_n(hex0_n[6:0])
  );

  // RS232 buffered
  // two consecutive IO addresses
  rs232 #(.clock_freq(clock_freq), .buf_slots(rs232_buf_slots)) rs232_0 (
    // in
    .clk(clk),
    .rst(rst),
    .stb(rs232_0_stb),
    .we(wr),
    .addr(adr[2]),
    .data_in(outbus[7:0]),
    // out
    .data_out(rs232_0_dout[31:0]),
    .ack(rs232_0_ack),
    // external
    .rxd(rs232_0_rxd),
    .txd(rs232_0_txd)
  );

  // SPI
  // two consecutive IO addresses
  spie #(.epo_compat(1'b1), .slow_div(80)) spie_0 (
    // in
    .clk(clk),
    .rst(rst),
    .stb(spi_0_stb),
    .we(wr),
    .addr(adr[2]),
    .data_in(outbus[31:0]),
    // out
    .data_out(spi_0_dout[31:0]),
    .ack(spi_0_ack),
    // external out
    .cs_n(spi_0_cs_n_d[2:0]),
    .sclk(spi_0_sclk_d),
    .mosi(spi_0_mosi_d),
    // external in
    .miso(spi_0_miso_d)
  );

  assign sdcard_cs_n = spi_0_cs_n_d[0];
  assign sdcard_sclk = spi_0_sclk_d;
  assign sdcard_mosi = spi_0_mosi_d;

  assign spi_cs_n[1] = spi_0_cs_n_d[1];
  assign spi_sclk[1] = spi_0_sclk_d;
  assign spi_mosi[1] = spi_0_mosi_d;

  assign spi_cs_n[2] = spi_0_cs_n_d[2];
  assign spi_sclk[2] = spi_0_sclk_d;
  assign spi_mosi[2] = spi_0_mosi_d;

  assign spi_0_miso_d = sdcard_miso & spi_miso[1] & spi_miso[2];

  // GPIO
  // two consecutive IO addresses
  gpio #(.num_gpio(num_gpio)) gpio_0 (
    // in
    .clk(clk),
    .rst(rst),
    .stb(gpio_stb),
    .we(wr),
    .addr(adr[2]),
    .data_in(outbus[num_gpio-1:0]),
    // out
    .data_out(gpio_dout),
    .ack(gpio_ack),
    // external
    .io_pin(gpio[num_gpio-1:0])
  );

  // I2C
  // four consecutive IO addresses
  i2ce i2ce_0 (
    // in
    .clk(clk),
    .rst(rst),
    .stb(i2c_stb),
    .we(wr),
    .addr(adr[3:2]),
    .data_in(outbus[31:0]),
    // out
    .data_out(i2c_dout),
    .ack(i2c_ack),
    // external
    .scl(i2c_scl),
    .sda(i2c_sda)
  );


  // address decoding
  // ----------------
  // cf. memory map below

  // max RAM address space at 000000H to 0FFE000H (16 MB - 8 kB)
  // adr[23:0] = 0FFE000H => adr[23:13] = 11'h7FF
  assign ram_stb = (adr[23:13] != 11'h7FF);

  // codebus multiplexer: RAM or PROM
  // PROM: 2 kB at  0FFE000H => initial code address for CPU
  // PROM uses adr[10:2] (word address)
  assign prom_stb = (adr[23:12] == 12'hFFE && adr[11] == 1'b0);
  assign codebus[31:0] = ~prom_stb ? ram_dout[31:0] : prom_dout[31:0];

  // inbus multiplexer: RAM or IO
  // IO block: 256 bytes (64 words) at 0FFFF00H
  // there's space reserved for three more 256 bytes IO blocks
  // at: 0FFFE00H, 0FFFD00, 0FFFC00
  assign io_en = (adr[23:8] == 16'hFFFF);
  assign inbus[31:0] = ~io_en ? ram_dout[31:0] : io_out[31:0];

  // the traditional 16 IO word addresses of (Embedded) Project Oberon
  assign i2c_stb     = (io_en && adr[7:4] == 4'b1111);    // -16, -12, -8, -4
  assign gpio_stb    = (io_en && adr[7:3] == 5'b11100);   // -32 (data), -28 (ctrl/status)
  assign spi_0_stb   = (io_en && adr[7:3] == 5'b11010);   // -48 (data), -44 (ctrl/status)
  assign rs232_0_stb = (io_en && adr[7:3] == 5'b11001);   // -56 (data), -52 (ctrl/status)
  assign lsb_stb     = (io_en && adr[7:2] == 6'b110001);  // -60 note: system LEDs via LED()
  assign tmr_stb     = (io_en && adr[7:2] == 6'b110000);  // -64

  // extended IO address range
  // eg: calltrace (not implemented)
//  assign cts_stb     = (io_en && adr[7:3] == 5'b10110);  // -80, -76 (ctrl/status)

  // IO data out multiplexing
  // ------------------------
  assign io_out[31:0] =
    i2c_stb     ? i2c_dout[31:0] :
    gpio_stb    ? gpio_dout[31:0] :
    spi_0_stb   ? spi_0_dout[31:0] :
    rs232_0_stb ? rs232_0_dout[31:0] :
    lsb_stb     ? lsb_dout[31:0] :
    tmr_stb     ? tmr_dout[31:0] :
    32'h0;

endmodule

`resetall

/**
FFFFFF  +---------------------------+
        | 64 dev addr (1 word each) |     256 Bytes
FFFF00  +---------------------------+
        | 64 dev addr (unused)      |     256 Bytes
FFFE00  +---------------------------+
        | 64 dev addr (unused)      |     256 Bytes
FFFD00  +---------------------------+
        | 64 dev addr (unused)      |     256 Bytes
FFFC00  +---------------------------+
        |                           |
        |      -- unused --         |     3 kB
        |                           !
FFF000  +---------------------------+
        |                           !
        |     PROM (2k used)        |     4 KB
        |                           |
FFE000  +---------------------------+
        |                           |
        |                           |
        |                           |
        |                           |
        |                           |
        |          max              |
        |          RAM              |     16 MB - 8 kB
        |         space             |
        |                           |
        |                           |
        |                           |
        |                           |
        |                           |
000000  +---------------------------+
**/
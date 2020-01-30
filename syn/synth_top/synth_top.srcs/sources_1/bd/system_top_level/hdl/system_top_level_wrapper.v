//Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2017.2 (win64) Build 1909853 Thu Jun 15 18:39:09 MDT 2017
//Date        : Thu Jan 30 12:39:52 2020
//Host        : HTC219-714-SPC running 64-bit major release  (build 9200)
//Command     : generate_target system_top_level_wrapper.bd
//Design      : system_top_level_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module system_top_level_wrapper
   (pin_aud_bclk,
    pin_aud_data,
    pin_aud_lrclk,
    pin_aud_mclk,
    pin_clk125mhz,
    pin_i2c_sclk,
    pin_i2c_sdata,
    pin_keys,
    pin_leds_i2c,
    pin_rst_n);
  output pin_aud_bclk;
  output pin_aud_data;
  output pin_aud_lrclk;
  output pin_aud_mclk;
  input pin_clk125mhz;
  output pin_i2c_sclk;
  inout pin_i2c_sdata;
  input [3:0]pin_keys;
  output [3:0]pin_leds_i2c;
  input pin_rst_n;

  wire pin_aud_bclk;
  wire pin_aud_data;
  wire pin_aud_lrclk;
  wire pin_aud_mclk;
  wire pin_clk125mhz;
  wire pin_i2c_sclk;
  wire pin_i2c_sdata;
  wire [3:0]pin_keys;
  wire [3:0]pin_leds_i2c;
  wire pin_rst_n;

  system_top_level system_top_level_i
       (.pin_aud_bclk(pin_aud_bclk),
        .pin_aud_data(pin_aud_data),
        .pin_aud_lrclk(pin_aud_lrclk),
        .pin_aud_mclk(pin_aud_mclk),
        .pin_clk125mhz(pin_clk125mhz),
        .pin_i2c_sclk(pin_i2c_sclk),
        .pin_i2c_sdata(pin_i2c_sdata),
        .pin_keys(pin_keys),
        .pin_leds_i2c(pin_leds_i2c),
        .pin_rst_n(pin_rst_n));
endmodule

//Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2017.2 (win64) Build 1909853 Thu Jun 15 18:39:09 MDT 2017
//Date        : Thu Jan 30 12:39:52 2020
//Host        : HTC219-714-SPC running 64-bit major release  (build 9200)
//Command     : generate_target system_top_level.bd
//Design      : system_top_level
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "system_top_level,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=system_top_level,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=5,numReposBlks=5,numNonXlnxBlks=2,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=2,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}" *) (* HW_HANDOFF = "system_top_level.hwdef" *) 
module system_top_level
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

  wire Net;
  wire clk_in1_1;
  wire clk_wiz_0_clk_out1;
  wire clk_wiz_0_clk_out2;
  wire clk_wiz_0_locked;
  wire [3:0]i2c_config_0_param_status_out;
  wire i2c_config_0_sclk_out;
  wire [3:0]keys_in_1;
  wire pin_rst_n_1;
  wire synthesizer_0_aud_bclk_out;
  wire synthesizer_0_aud_data_out;
  wire synthesizer_0_aud_lrclk_out;
  wire [3:0]util_vector_logic_0_Res;
  wire [0:0]util_vector_logic_1_Res;

  assign clk_in1_1 = pin_clk125mhz;
  assign keys_in_1 = pin_keys[3:0];
  assign pin_aud_bclk = synthesizer_0_aud_bclk_out;
  assign pin_aud_data = synthesizer_0_aud_data_out;
  assign pin_aud_lrclk = synthesizer_0_aud_lrclk_out;
  assign pin_aud_mclk = clk_wiz_0_clk_out2;
  assign pin_i2c_sclk = i2c_config_0_sclk_out;
  assign pin_leds_i2c[3:0] = util_vector_logic_0_Res;
  assign pin_rst_n_1 = pin_rst_n;
  system_top_level_clk_wiz_0_0 clk_wiz_0
       (.clk_in1(clk_in1_1),
        .clk_out1(clk_wiz_0_clk_out1),
        .clk_out2(clk_wiz_0_clk_out2),
        .locked(clk_wiz_0_locked));
  system_top_level_i2c_config_0_0 i2c_config_0
       (.clk(clk_wiz_0_clk_out1),
        .param_status_out(i2c_config_0_param_status_out),
        .rst_n(util_vector_logic_1_Res),
        .sclk_out(i2c_config_0_sclk_out),
        .sdat_inout(pin_i2c_sdata));
  system_top_level_synthesizer_0_0 synthesizer_0
       (.aud_bclk_out(synthesizer_0_aud_bclk_out),
        .aud_data_out(synthesizer_0_aud_data_out),
        .aud_lrclk_out(synthesizer_0_aud_lrclk_out),
        .clk(clk_wiz_0_clk_out2),
        .keys_in(keys_in_1),
        .rst_n(util_vector_logic_1_Res));
  system_top_level_util_vector_logic_0_0 util_vector_logic_0
       (.Op1(i2c_config_0_param_status_out),
        .Op2(keys_in_1),
        .Res(util_vector_logic_0_Res));
  system_top_level_util_vector_logic_0_1 util_vector_logic_1
       (.Op1(clk_wiz_0_locked),
        .Op2(pin_rst_n_1),
        .Res(util_vector_logic_1_Res));
endmodule

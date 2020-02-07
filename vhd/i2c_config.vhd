-------------------------------------------------------------------------------
-- Title      : Exercise 11
-- Project    : 
-------------------------------------------------------------------------------
-- File       : i2c_config.vhd
-- Author     : Group 21
-- Company    : 
-- Created    : 2020-02-05
-- Last update: 2020-02-06
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: I2C bus configuration
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  			Description
-- 2020-02-05  1.0      Quang Phan                      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_config is
  generic(
    ref_clk_freq_g  : integer := 50000000;
    i2c_freq_g      : integer := 20000;
    n_params_g      : integer := 15;
    n_leds_g        : integer := 4
    );
  port(
    clk, rst_n      : in  std_logic;
    sdat_inout      : inout std_logic;
    sclk_out        : out std_logic;
    param_status_out: out std_logic_vector(n_leds_g - 1 downto 0);
    finished_out    : out std_logic
  );
end adder;

-------------------------------------------------------------------------------

architecture rtl of i2c_config is
  begin
end rtl;

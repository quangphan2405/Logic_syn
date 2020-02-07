-------------------------------------------------------------------------------
-- Title      : Exercise 11
-- Project    : 
-------------------------------------------------------------------------------
-- File       : i2c_config.vhd
-- Author     : Group 21
-- Company    : 
-- Created    : 2020-02-05
-- Last update: 2020-02-07
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
  constant device_add_c : std_logic_vector(8 - 1 down to 0) := "00110100";
  constant sclk_half_period_c : integer := 1000000000/i2c_freq_g; 
  type state_type is (start, data_trans, ack_listening, stop);
  signal current_state : state_type;
  signal sclk_r : std_logic;
  signal sclk_cnt_r : integer range sclk_half_period_c downto 0;

begin
   sync : process(clk, rst_n)
   begin
     if rst_n = '0' then
     end if;
     
   end proess sync;
     
   sclk_gen : process(clk, rst_n)
   begin
     if rst_n = '0' then
       sclk_r <= '0';
       sclk_cnt_r <= 0;
     elsif clk'EVENT and clk = '1' then
       if sclk_cnt_r = sclk_half_period_c then
         sclk_r <= not sclk_r;
         sclk_cnt_r <= 0;
       else
         sclk <= sclk + 1;
       end if;
     end if;
   end process sclk_gen;
       
end rtl;

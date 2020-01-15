-------------------------------------------------------------------------------
-- Title      : TIE-50206, exercise 3
-- Project    : 
-------------------------------------------------------------------------------
-- File       : adder.vhd
-- Author     : Quang
-- Company    : 
-- Created    : 2019-11-22
-- Last update: 2020-01-14
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Create a testbench for audio codec controller
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-11-22  1.0      Quang   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb_audio_ctrl is
  generic (
    data_width_g : integer := 16;
    clk_freq_g : integer := 20000000;
    sample_rate_g: integer := 500000
    );
  port (
    out_left_r, out_right_r: out std_logic_vector(data_width_g - 1 downto 0)
    );
end tb_audio_ctrl;

-------------------------------------------------------------------------------

architecture testbench of tb_audio_ctrl is

  signal wave_1, wave_2: std_logic_vector(data_width_g - 1 downto 0);
  signal bit_clk, lr_clk, data: std_logic;
  signal clk : std_logic := '0';
  signal rst_n: std_logic;

  constant max_sync_clear_c: integer := 200000;
  constant clk_period_c : time := (1000000000 ns/clk_freq_g);
  signal sync_clear_r: std_logic;
  signal sync_clear_cnt_r: integer range 0 to max_sync_clear_c;

  component wave_gen is
    generic (
      width_g : integer;
      step_g  : integer);
    port (
      clk, rst_n, sync_clear_n_in : in  std_logic;
      value_out                   : out std_logic_vector(width_g - 1 downto 0));
  end component wave_gen;

  component audio_ctrl is
    generic (
      ref_clk_freq_g : integer;
      sample_rate_g  : integer;
      data_width_g   : integer);
    port (
      clk, rst_n                  : in  std_logic;
      left_data_in, right_data_in : in  std_logic_vector(data_width_g - 1 downto 0);
      aud_bclk_out                : out std_logic;
      aud_data_out                : out std_logic;
      aud_lrclk_out               : out std_logic);
  end component audio_ctrl;

  component audio_codec_model is
    generic (
      data_width_g : integer);
    port (
      rst_n                           : in  std_logic;
      aud_data_in                     : in  std_logic;
      aud_bclk_in, aud_lrclk_in       : in  std_logic;
      value_left_out, value_right_out : out std_logic_vector(data_width_g - 1 downto 0));
  end component audio_codec_model;
  
  begin    
    
    wave_gen_1: entity work.wave_gen
    generic map (
      width_g => data_width_g,
      step_g  => 2)
    port map (
      clk             => clk,
      rst_n           => rst_n,
      sync_clear_n_in => sync_clear_r,
      value_out       => wave_1);

    wave_gen_2: entity work.wave_gen
    generic map (
      width_g => data_width_g,
      step_g  => 10)
    port map (
      clk             => clk,
      rst_n           => rst_n,
      sync_clear_n_in => sync_clear_r,
      value_out       => wave_2);
    
    ctrl: entity work.audio_ctrl
    generic map (
      ref_clk_freq_g => clk_freq_g,
      sample_rate_g  => sample_rate_g,
      data_width_g   => data_width_g)
    port map (
      clk           => clk,
      rst_n         => rst_n,
      left_data_in  => wave_1,
      right_data_in => wave_2,
      aud_bclk_out  => bit_clk,
      aud_data_out  => data,
      aud_lrclk_out => lr_clk);
 
    codec_model: entity work.audio_codec_model
    generic map (
      data_width_g => data_width_g)
    port map (
      rst_n           => rst_n,
      aud_data_in     => data,
      aud_bclk_in     => bit_clk,
      aud_lrclk_in    => lr_clk,
      value_left_out  => out_left_r,
      value_right_out => out_right_r);
    
    generate_clock: process(clk)
    begin
      clk <= not clk after clk_period_c/2;
    end process generate_clock;

    generate_sync_clear: process(clk, rst_n)
    begin
      if rst_n = '0' then
        sync_clear_r <= '0';
        sync_clear_cnt_r <= max_sync_clear_c;
      elsif clk'EVENT and clk = '1' then
        if sync_clear_cnt_r = max_sync_clear_c then
          sync_clear_r <= not sync_clear_r;
          sync_clear_cnt_r <= 0;
        else
          sync_clear_cnt_r <= sync_clear_cnt_r + 1;
        end if;
      end if;
    end process generate_sync_clear;

    rst_n <= '0', '1' after 10 ns;
             
end architecture testbench;

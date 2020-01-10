-------------------------------------------------------------------------------
-- Title      : TIE-50206, exercise 3
-- Project    : 
-------------------------------------------------------------------------------
-- File       : adder.vhd
-- Author     : Quang
-- Company    : 
-- Created    : 2019-11-22
-- Last update: 2020-01-10
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
    clk_freq_g : integer := 20e6;
    sample_rate_g: integer := 48e3
    );
  port (
    out_left_r, out_right_r: out std_logic_vector(data_width_g - 1 downto 0)
    );
end tb_multi_port_adder;

-------------------------------------------------------------------------------

architecture testbench of tb_multi_port_adder is

  signal wave_1, wave_2: std_logic_vector(data_width_g - 1 downto 0);
  signal bit_clk, lr_clk, data: std_logic;
  signal clk : std_logic := '0';
  signal rst_n: std_logic := '0';

  constant cnt_width_c: integer := 20;
  constant max_sync_clear_c: integer := 50000;
  signal sync_clear_r: std_logic;
  signal sync_clear_cnt_r: std_logic_vector(cnt_width_c - 1 downto 0);
  
  entity wave_gen is

    generic (
      width_g : integer;
      step_g  : integer);

    port (
      clk, rst_n, sync_clear_n_in : in  std_logic;
      value_out                   : out std_logic_vector(width_g - 1 downto 0));

  end entity wave_gen;

  wave_gen_1: entity work.wave_gen
    generic map (
      width_g => 4,
      step_g  => 2)
    port map (
      clk             => clk,
      rst_n           => rst_n,
      sync_clear_n_in => sync_clear_r,
      value_out       => wave_1);

  wave_gen_2: entity work.wave_gen
    generic map (
      width_g => 4,
      step_g  => 10)
    port map (
      clk             => clk,
      rst_n           => rst_n,
      sync_clear_n_in => sync_clear_r,
      value_out       => wave_2);

  entity audio_ctrl is

    generic (
      ref_clk_freq_g : integer := 12288000;
      sample_rate_g  : integer := 48000;
      data_width_g   : integer := 16);

    port (
      clk, rst_n                  : in  std_logic;
      left_data_in, right_data_in : in  std_logic_vector(data_width_g - 1 downto 0);
      aud_bclk_out                : out std_logic;
      aud_data_out                : out std_logic;
      aud_lrclk_out               : out std_logic);

  end entity audio_ctrl;

  audio_ctrl: entity work.audio_ctrl
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

  entity audio_codec_model is

    generic (
      data_width_g : integer := 16);

    port (
      rst_n                           : in  std_logic;
      aud_data_in                     : in  std_logic;
      aud_bclk_in, aud_lrclk_in       : in  std_logic;
      value_left_out, value_right_out : out std_logic_vector(data_width_g - 1 downto 0));

  end entity audio_codec_model;

  audio_codec_model: entity work.audio_codec_model
    generic map (
      data_width_g => data_width_g)
    port map (
      rst_n           => rst_n,
      aud_data_in     => data,
      aud_bclk_in     => bit_clk,
      aud_lrclk_in    => lr_clk,
      value_left_out  => out_left_r,
      value_right_out => out_right_r);

  entity counter is

    generic (
      width_g : integer := 5);

    port (
      clk          : in  std_logic;
      max_value_in : in  integer;
      count_out    : out std_logic_vector(width_g - 1 downto 0));

  end entity counter;

  sync_clear_counter: entity work.counter
    generic map (
      width_g => cnt_width_c)
    port map (
      clk          => clk,
      max_value_in => max_sync_clear_r,
      count_out    => sync_clear_cnt_r);
  
  begin    
    rst_n <= '1' after 10 ns;
    
    generate_clock: process(clk)
      clk <= not clk after 10e9/clk_freq_g ns;
    end process generate_clock;

    generate_sync_clear: process(clk, rst_n)
      if rst_n = '0' then
        sync_clear_r <= (others => '0');
        sync_clear_cnt_r <= (others => '0');
      elsif clk'EVENT and clk = '1' then
        if to_integer(unsigned(sync_clear_cnt_r)) = max_sync_clear_c - 1 then
          sync_clear_r <= not sync_clear_r;
        end if;
      end if;
    end process generate_sync_clear;
             
end architecture testbench;

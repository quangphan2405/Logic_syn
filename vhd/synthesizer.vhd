-------------------------------------------------------------------------------
-- Title      : TIE-50206, exercise 9
-- Project    : 
-------------------------------------------------------------------------------
-- File       : synthesizer.vhd
-- Author     : Quang
-- Company    : 
-- Created    : 2020-01-15
<<<<<<< HEAD
-- Last update: 2020-01-15
=======
-- Last update: 2020-01-21
>>>>>>> 7cadb9c5a6363b1696b3735d03c16f3a8f8ffcee
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Create a synthesizer being a top level structure
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-01-15  1.0      Quang	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity synthesizer is
  generic (
    clk_freq_g : integer := 12288000;
    sample_rate_g : integer := 48000;
    data_width_g : integer := 16;
    n_keys_g : integer := 4
    );
  
  port(
    clk, rst_n : in std_logic;
    keys_in : in std_logic_vector(n_keys_g - 1 downto 0);
    aud_bclk_out, aud_lrclk_out, aud_data_out : out std_logic
    );
end synthesizer;
    
-------------------------------------------------------------------------------

architecture rtl of synthesizer is
<<<<<<< HEAD
  assert (n_keys_g /= 4)
    report "There must be exactly 4 buttons."
    severity failure;

  signal wave_0, wave_1, wave_2, wave_3: std_logic_vector(data_width_g - 1 downto 0);
  signal wave_data: std_logic_vector(data_width_g - 1 downto 0);

  entity wave_gen is

    generic (
      width_g : integer;
      step_g  : integer);

    port (
      clk, rst_n, sync_clear_n_in : in  std_logic;
      value_out                   : out std_logic_vector(width_g - 1 downto 0));

  end entity wave_gen;

  entity multi_port_adder is

    generic (
      operand_width_g   : integer := 16;
      num_of_operands_g : integer := 4);

=======

  signal wave_0, wave_1, wave_2, wave_3: std_logic_vector(data_width_g - 1 downto 0);
  signal wave_input: std_logic_vector(data_width_g * n_keys_g - 1 downto 0);
  signal wave_data: std_logic_vector(data_width_g - 1 downto 0);

  component wave_gen is
    generic (
      width_g : integer;
      step_g  : integer);
    port (
      clk, rst_n, sync_clear_n_in : in  std_logic;
      value_out                   : out std_logic_vector(width_g - 1 downto 0));
  end component wave_gen;

  component multi_port_adder is
    generic (
      operand_width_g   : integer;
      num_of_operands_g : integer);
>>>>>>> 7cadb9c5a6363b1696b3735d03c16f3a8f8ffcee
    port (
      clk, rst_n  : in  std_logic;
      operands_in : in  std_logic_vector(operand_width_g * num_of_operands_g - 1 downto 0);
      sum_out     : out std_logic_vector(operand_width_g - 1 downto 0));
<<<<<<< HEAD

  end entity multi_port_adder;

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

  begin
    
    wave_gen_1: entity work.wave_gen
      generic map (
        width_g => data_width_g,
        step_g  => step_g)
      port map (
        clk             => clk,
        rst_n           => rst_n,
        sync_clear_n_in => n_keys_g(0),
=======
  end component multi_port_adder;

  component audio_ctrl is
    generic (
      ref_clk_freq_g : integer;
      sample_rate_g  : integer;
      data_width_g   : integer);
    port (
      clk                         : in  std_logic;
      rst_n                       : in  std_logic;
      left_data_in, right_data_in : in  std_logic_vector(data_width_g - 1 downto 0);
      aud_bclk_out                : out std_logic;
      aud_lrclk_out               : out std_logic;
      aud_data_out                : out std_logic);
  end component audio_ctrl;

  begin
    
    assert (n_keys_g = 4)
    report "There must be exactly 4 buttons."
    severity failure;

    wave_input <= wave_3 & wave_2 & wave_1 & wave_0;
    
    wave_gen_1: entity work.wave_gen
      generic map (
        width_g => data_width_g,
        step_g  => 1)
      port map (
        clk             => clk,
        rst_n           => rst_n,
        sync_clear_n_in => keys_in(0),
>>>>>>> 7cadb9c5a6363b1696b3735d03c16f3a8f8ffcee
        value_out       => wave_0);

    wave_gen_2: entity work.wave_gen
      generic map (
        width_g => data_width_g,
<<<<<<< HEAD
        step_g  => step_g)
      port map (
        clk             => clk,
        rst_n           => rst_n,
        sync_clear_n_in => n_keys_g(1),
=======
        step_g  => 2)
      port map (
        clk             => clk,
        rst_n           => rst_n,
        sync_clear_n_in => keys_in(1),
>>>>>>> 7cadb9c5a6363b1696b3735d03c16f3a8f8ffcee
        value_out       => wave_1);

    wave_gen_3: entity work.wave_gen
      generic map (
        width_g => data_width_g,
<<<<<<< HEAD
        step_g  => step_g)
      port map (
        clk             => clk,
        rst_n           => rst_n,
        sync_clear_n_in => n_keys_g(2),
=======
        step_g  => 4)
      port map (
        clk             => clk,
        rst_n           => rst_n,
        sync_clear_n_in => keys_in(2),
>>>>>>> 7cadb9c5a6363b1696b3735d03c16f3a8f8ffcee
        value_out       => wave_2);

    wave_gen_4: entity work.wave_gen
      generic map (
        width_g => data_width_g,
<<<<<<< HEAD
        step_g  => step_g)
      port map (
        clk             => clk,
        rst_n           => rst_n,
        sync_clear_n_in => n_keys_g(3),
=======
        step_g  => 8)
      port map (
        clk             => clk,
        rst_n           => rst_n,
        sync_clear_n_in => keys_in(3),
>>>>>>> 7cadb9c5a6363b1696b3735d03c16f3a8f8ffcee
        value_out       => wave_3);

    multi_port_adder_1: entity work.multi_port_adder
      generic map (
        operand_width_g   => data_width_g,
        num_of_operands_g => n_keys_g)
      port map (
        clk         => clk,
        rst_n       => rst_n,
<<<<<<< HEAD
        operands_in => wave_0 & wave_1 & wave_2 & wave_3,
=======
        operands_in => wave_input,
>>>>>>> 7cadb9c5a6363b1696b3735d03c16f3a8f8ffcee
        sum_out     => wave_data);

    audio_ctrl_1: entity work.audio_ctrl
      generic map (
<<<<<<< HEAD
        ref_clk_freq_g => ref_clk_freq_g,
=======
        ref_clk_freq_g => clk_freq_g,
>>>>>>> 7cadb9c5a6363b1696b3735d03c16f3a8f8ffcee
        sample_rate_g  => sample_rate_g,
        data_width_g   => data_width_g)
      port map (
        clk           => clk,
        rst_n         => rst_n,
        left_data_in  => wave_data,
        right_data_in => wave_data,
        aud_bclk_out  => aud_bclk_out,
        aud_data_out  => aud_data_out,
        aud_lrclk_out => aud_lrclk_out);

    
end rtl;

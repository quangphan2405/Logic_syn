-------------------------------------------------------------------------------
-- Title      : Ex12, testbench for I2C-bus controller
-------------------------------------------------------------------------------
-- File       : tb_i2c_config.vhd
-- Author     : Group 21: Paulus Limma and Quang Phan
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Testbench for i2c_config
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  			Description
-- 2020-01-31  1.0      Paulus Limma	    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_i2c_config is
end entity tb_i2c_config;

architecture testbench of tb_i2c_config is

	component i2c_config
		generic(
			ref_clk_freq_g : integer;
			i2c_freq_g     : integer;
			n_params_g     : integer;
			n_leds_g       : integer
		);
		port(
			clk              : in    std_logic;
			rst_n            : in    std_logic;
			sdat_inout       : inout std_logic;
			sclk_out         : out   std_logic;
			param_status_out : out   std_logic_vector(n_leds_g - 1 downto 0);
			finished_out     : out   std_logic
		);
	end component i2c_config;

	constant clk_period_c             : time    := 20 ns;
	constant ref_clk_freq_c           : integer := 1 sec / clk_period_c;
	constant n_params_c : integer := 2;
	constant n_leds_c : integer := 4;

	signal clk : std_logic := '0';
	signal rst_n :std_logic := '0';
	
	signal i2c_sdat : std_logic;
	signal i2c_sclk : std_logic;
	signal i2c_param_status : std_logic_vector(n_leds_c - 1 downto 0);
	signal i2c_finished : std_logic;
	
begin
	clk                   <= not clk after clk_period_c / 2;
	rst_n                 <= '1' after clk_period_c * 4;
	
	i_i2c : component i2c_config
		generic map(
			ref_clk_freq_g => ref_clk_freq_c,
			i2c_freq_g     => 20000,
			n_params_g     => n_params_c,
			n_leds_g       => n_leds_c
		)
		port map(
			clk              => clk,
			rst_n            => rst_n,
			sdat_inout       => i2c_sdat,
			sclk_out         => i2c_sclk,
			param_status_out => i2c_param_status,
			finished_out     => i2c_finished
		);
end architecture testbench;

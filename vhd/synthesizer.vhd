-------------------------------------------------------------------------------
-- Title      : Exercise 09, audio synthesizer top level module
-- Project    : 
-------------------------------------------------------------------------------
-- File       : synthesizer.vhd
-- Author     : Group 21
-- Company    : 
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity synthesizer is
	generic(
		clk_freq_g    : integer := 12288000;
		sample_rate_g : integer := 48000;
		data_width_g  : integer := 16;
		n_keys_g      : integer := 4
	);
	port(
		clk, rst_n    : in  std_logic;
		keys_in       : in  std_logic_vector(n_keys_g - 1 downto 0);
		aud_bclk_out  : out std_logic;
		aud_data_out  : out std_logic;
		aud_lrclk_out : out std_logic
	);
end entity synthesizer;

architecture structural of synthesizer is

	component wave_gen
		generic(
			width_g : integer;
			step_g  : integer
		);
		port(
			clk, rst_n, sync_clear_n_in : in  std_logic;
			value_out                   : out std_logic_vector(width_g - 1 downto 0)
		);
	end component wave_gen;

	component multi_port_adder
		generic(
			operand_width_g   : integer;
			num_of_operands_g : integer
		);
		port(
			clk, rst_n  : in  std_logic;
			operands_in : in  std_logic_vector(operand_width_g * num_of_operands_g - 1 downto 0);
			sum_out     : out std_logic_vector(operand_width_g - 1 downto 0)
		);
	end component multi_port_adder;

	component audio_ctrl
		generic(
			ref_clk_freq_g : integer;
			sample_rate_g  : integer;
			data_width_g   : integer
		);
		port(
			clk                         : in  std_logic;
			rst_n                       : in  std_logic;
			left_data_in, right_data_in : in  std_logic_vector(data_width_g - 1 downto 0);
			aud_bclk_out                : out std_logic;
			aud_lrclk_out               : out std_logic;
			aud_data_out                : out std_logic
		);
	end component audio_ctrl;
	
	signal values_wave_gen_adder : std_logic_vector(n_keys_g * data_width_g - 1 downto 0);
	signal value_adder_audio_ctrl : std_logic_vector(data_width_g - 1 downto 0);
begin

	g_wave_gens : for i in 0 to n_keys_g - 1 generate
		i_wav : wave_gen
			generic map(
				width_g => data_width_g,
				step_g  => (i + 1) * (i + 1)
			)
			port map(
				clk             => clk,
				rst_n           => rst_n,
				sync_clear_n_in => keys_in(i),
				value_out       => values_wave_gen_adder((i + 1) * data_width_g - 1 downto i * data_width_g)
			);
	end generate g_wave_gens;
	
	i_mul : multi_port_adder
		generic map(
			operand_width_g   => data_width_g,
			num_of_operands_g => n_keys_g
		)
		port map(
			clk         => clk,
			rst_n       => rst_n,
			operands_in => values_wave_gen_adder,
			sum_out     => value_adder_audio_ctrl
		);
	
	i_aud : audio_ctrl
		generic map(
			ref_clk_freq_g => clk_freq_g,
			sample_rate_g  => sample_rate_g,
			data_width_g   => data_width_g
		)
		port map(
			clk           => clk,
			rst_n         => rst_n,
			left_data_in  => value_adder_audio_ctrl,
			right_data_in => value_adder_audio_ctrl,
			aud_bclk_out  => aud_bclk_out,
			aud_lrclk_out => aud_lrclk_out,
			aud_data_out  => aud_data_out
		);

end architecture structural;

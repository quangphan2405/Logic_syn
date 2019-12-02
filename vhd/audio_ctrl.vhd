library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity audio_ctrl is
	generic(
		ref_clk_freq_g : integer := 12288000;
		sample_rate_g  : integer := 48000;
		data_width_g   : integer := 16
	);
	port(
		clk                         : in  std_logic;
		rst_n                       : in  std_logic;
		left_data_in, right_data_in : in  std_logic_vector(data_width_g - 1 downto 0);
		aud_bclk_out                : out std_logic;
		aud_lrclk_out               : out std_logic;
		aud_data_out                : out std_logic
	);
end entity audio_ctrl;

architecture RTL of audio_ctrl is

begin

end architecture RTL;

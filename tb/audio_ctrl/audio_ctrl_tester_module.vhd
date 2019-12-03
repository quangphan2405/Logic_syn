library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity audio_ctrl_tester_module is
	generic(
		data_width_g : integer
	);
	port(
		clk, rst_n                                          : in std_logic;
		lrclk_in                                            : in std_logic;
		left_wave_gen_data_in, right_wave_gen_data_in       : in std_logic_vector(data_width_g - 1 downto 0);
		left_audio_codec_data_in, right_audio_codec_data_in : in std_logic_vector(data_width_g - 1 downto 0)
	);
end entity audio_ctrl_tester_module;

architecture RTL of audio_ctrl_tester_module is
	constant timeout_c : time := 10 ms;

	-- Reference to lrclk, so we can find out when it's value changes.
	signal lrclk_r : std_logic;

	-- Registers for keeping previous outputs of wave generator and audio codec module in memory.
	signal left_wave_gen_data_r, right_wave_gen_data_r       : std_logic_vector(data_width_g - 1 downto 0);
	signal left_audio_codec_data_r, right_audio_codec_data_r : std_logic_vector(data_width_g - 1 downto 0);

	-- Registers for samples
	signal left_sample_r, right_sample_r : std_logic_vector(data_width_g - 1 downto 0);

	-- Helper function for converting std_logic_vector to string.
	function slv_to_string(vec : std_logic_vector) return string is
		variable b : string(vec'length - 1 downto 0) := (others => NUL);
	begin
		for i in vec'length - 1 downto 0 loop
			b(i) := std_logic'image(vec(i))(2);
		end loop;
		return b;
	end function;

	-- Procedure for executing the assertion for left or right channel.
	procedure assert_equals(expected : std_logic_vector(data_width_g - 1 downto 0);
	                        actual   : std_logic_vector(data_width_g - 1 downto 0)
	                       ) is
	begin
		assert expected = actual
		report "Exp: " & slv_to_string(expected) & ", Got: " & slv_to_string(actual)
		severity failure;

	end procedure;

begin
	sync : process(rst_n, clk)
	begin
		if (rst_n = '0') then
			lrclk_r                  <= '0';
			left_wave_gen_data_r     <= (others => '0');
			right_wave_gen_data_r    <= (others => '0');
			left_audio_codec_data_r  <= (others => '0');
			right_audio_codec_data_r <= (others => '0');
			left_sample_r            <= (others => '0');
			right_sample_r           <= (others => '0');
		elsif (clk'event and clk = '1') then

			-- Save samples on the rising edge of lrclk.
			if (lrclk_in /= lrclk_r and lrclk_in = '1') then
				-- We actually save buffered values from previous clock cycle to get exactly same
				-- sampling time that audio controller uses.
				left_sample_r  <= left_wave_gen_data_r;
				right_sample_r <= right_wave_gen_data_r;
			end if;

			-- If audio codec module output changes, assert that output is same than saved sample.
			if (left_audio_codec_data_in /= left_audio_codec_data_r) then
				assert_equals(left_sample_r, left_audio_codec_data_in);
			end if;
			if (right_audio_codec_data_in /= right_audio_codec_data_r) then
				assert_equals(right_sample_r, right_audio_codec_data_in);
			end if;

			-- End condition.
			assert now < timeout_c report "Simulation successfull" severity failure;

			lrclk_r                  <= lrclk_in;
			left_audio_codec_data_r  <= left_audio_codec_data_in;
			right_audio_codec_data_r <= right_audio_codec_data_in;
			left_wave_gen_data_r     <= left_wave_gen_data_in;
			right_wave_gen_data_r    <= right_wave_gen_data_in;
		end if;
	end process;
end architecture RTL;

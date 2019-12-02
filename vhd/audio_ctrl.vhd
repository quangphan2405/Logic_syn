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
	constant min_bclk_period_c   : integer := 75; --ns
	constant one_second_as_nanos : integer := 1000000000;
	constant bclk_counter_steps  : integer := (one_second_as_nanos / ref_clk_freq_g / min_bclk_period_c) + 1;

	signal sampling_counter_r            : integer range 0 to (ref_clk_freq_g / sample_rate_g - 1);
	signal left_sample_r, right_sample_r : std_logic_vector(data_width_g - 1 downto 0);

	signal bclk_counter_r  : integer range 0 to bclk_counter_steps - 1;
	signal lrclk_counter_r : integer range 0 to data_width_g - 1;

	signal bclk_r, lrclk_r, data_out_r : std_logic;

	signal bit_index_r : integer range 0 to data_width_g - 1;
begin
	sync : process(clk, rst_n)
	begin
		if (rst_n = '0') then
			sampling_counter_r <= 0;
			left_sample_r      <= (others => '0');
			right_sample_r     <= (others => '0');
			bclk_counter_r     <= 0;
			lrclk_counter_r    <= 0;
			bclk_r             <= '0';
			lrclk_r            <= '0';
			data_out_r         <= '0';
			bit_index_r        <= 0;
		elsif (clk'event and clk = '1') then
			-- Increment sampling counter and save samples to the sample registers if the counter is full.
			if (sampling_counter_r /= sampling_counter_r'high) then
				sampling_counter_r <= sampling_counter_r + 1;
			else
				sampling_counter_r <= 0;
				left_sample_r      <= left_data_in;
				right_sample_r     <= right_data_in;
			end if;

			-- Generate lrclk
			if (lrclk_counter_r /= lrclk_counter_r'high) then
				lrclk_counter_r <= lrclk_counter_r + 1;
			else
				lrclk_r         <= not lrclk_r;
				lrclk_counter_r <= 0;
				-- Reset bit_index_r on rising edge, which indicates change of transmitted word.
				if (lrclk_r = '0') then
					bit_index_r <= 0;
				end if;
			end if;

			-- Generate bclk
			if (bclk_counter_r /= bclk_counter_r'high) then
				bclk_counter_r <= bclk_counter_r + 1;
			else
				-- Transmit next bit on rising edge of bclk if whole word isn't transmitted yet.
				if (bclk_r = '0' and bit_index_r /= data_width_g) then

					if (lrclk_r = '1') then
						data_out_r <= left_sample_r(bit_index_r);
					else
						data_out_r <= right_sample_r(bit_index_r);
					end if;

					bit_index_r <= bit_index_r + 1;
				end if;

				bclk_r         <= not bclk_r;
				bclk_counter_r <= 0;
			end if;
		end if;
	end process;

	aud_bclk_out  <= bclk_r;
	aud_lrclk_out <= lrclk_r;
	aud_data_out  <= data_out_r;
end architecture RTL;

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

	-- lrclk frequency is same as sampling frequency.
	constant lrclk_counter_steps_c : integer := ref_clk_freq_g / sample_rate_g / 2;
	
	-- Calculate required number of steps to bclk counter.
	constant min_bclk_period_c     : integer := 75; -- ns, read from datasheet.
	constant one_second_as_nanos_c : integer := 1000000000;
	-- Minimum amount of steps. One step is add to round up, or to add safety marginal if division is exact.
	constant min_bclk_counter_steps_c  : integer := (min_bclk_period_c / (one_second_as_nanos_c / ref_clk_freq_g) / 2)  + 1;
	-- Synchronize bclk with lrclk.
	constant bclk_counter_steps_c : integer := lrclk_counter_steps_c / (lrclk_counter_steps_c / min_bclk_counter_steps_c);

	-- Registers for samples and currently transmitted bit index.
	signal left_sample_r, right_sample_r : std_logic_vector(data_width_g - 1 downto 0);
	signal bit_index_r : integer range -1 to data_width_g - 1;
	-- Indicates whether we should read left or right channel.
	signal read_left_channel_r           : std_logic;

	-- Counters for generated clocks.
	signal bclk_counter_r  : integer range 0 to bclk_counter_steps_c - 1;
	signal lrclk_counter_r : integer range 0 to lrclk_counter_steps_c - 1;

	-- Registers for outputs
	signal bclk_r, lrclk_r, data_out_r : std_logic;
begin
	sync : process(clk, rst_n)
	begin
		if (rst_n = '0') then
			left_sample_r       <= (others => '0');
			right_sample_r      <= (others => '0');
			bclk_counter_r      <= 0;
			lrclk_counter_r     <= 0;
			read_left_channel_r <= '0';
			bclk_r              <= '0';
			lrclk_r             <= '0';
			data_out_r          <= '0';
			bit_index_r         <= data_width_g - 1;
		elsif (clk'event and clk = '1') then

			-- Generate lrclk
			if (lrclk_counter_r /= lrclk_counter_steps_c - 1) then
				lrclk_counter_r <= lrclk_counter_r + 1;
			else
				lrclk_r         <= not lrclk_r;
				lrclk_counter_r <= 0;
			end if;

			-- One clock cycle before transition of lrclk.
			if (lrclk_counter_r = lrclk_counter_steps_c - 2) then
				-- Reset the bit index now so that first bit can be send on the transition at the next clock cycle.
				bit_index_r <= data_width_g - 1;
				-- Change transmitted channel.
				read_left_channel_r <= not read_left_channel_r;
				-- Read samples if transition will be rising edge of the lrclk.
				if (lrclk_r = '0') then
					left_sample_r  <= left_data_in;
					right_sample_r <= right_data_in;
				end if;
			end if;

			-- Generate bclk
			if (bclk_counter_r /= bclk_counter_steps_c - 1) then
				bclk_counter_r <= bclk_counter_r + 1;
			else
				bclk_r         <= not bclk_r;
				bclk_counter_r <= 0;
				
				-- Transmit next bit on rising edge of bclk if whole word isn't transmitted yet.
				if (bclk_r = '0' and bit_index_r /= -1) then

					if (read_left_channel_r = '1') then
						data_out_r <= left_sample_r(bit_index_r);
					else
						data_out_r <= right_sample_r(bit_index_r);
					end if;

					bit_index_r <= bit_index_r - 1;
				end if;
			end if;
		end if;
	end process;

	aud_bclk_out  <= bclk_r;
	aud_lrclk_out <= lrclk_r;
	aud_data_out  <= data_out_r;
end architecture RTL;

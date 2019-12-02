library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity audio_codec_module is
	generic(
		data_width_g : integer := 16
	);
	port(
		rst_n                           : in  std_logic;
		aud_bclk_in                     : in  std_logic;
		aud_lrclk_in                    : in  std_logic;
		aud_data_in                     : in  std_logic;
		value_left_out, value_right_out : out std_logic_vector(data_width_g - 1 downto 0)
	);
end entity audio_codec_module;

architecture RTL of audio_codec_module is

	type states_type is (wait_for_input, read_left, read_right);
	signal curr_state_r : states_type;
	signal bit_index_r  : integer range 0 to data_width_g - 1;
	signal curr_word_r  : std_logic_vector(data_width_g - 2 downto 0);

begin
	sync : process(aud_bclk_in, rst_n)
		
		procedure change_state_to(next_state : states_type) is
		begin
			bit_index_r  <= 0;
			curr_state_r <= next_state;
			-- First bit must be read at this stage.
			curr_word_r  <= (0 => aud_data_in, others => '0');
		end procedure;

		procedure collect_next_bit(
			signal value_out : out std_logic_vector(data_width_g -1 downto 0)
		) is
		begin
			if (bit_index_r = data_width_g - 1) then
				-- End of the word. Collect the last bit and and set the output.
				value_out   <= aud_data_in & curr_word_r(curr_word_r'high downto 0);
				-- Set bit_index_r to indicate system to not step into the next branch any longer.
				bit_index_r <= data_width_g;
			elsif (bit_index_r /= data_width_g) then
				-- Collect next bit and increment the index.
				curr_word_r(bit_index_r) <= aud_data_in;
				bit_index_r              <= bit_index_r + 1;
			end if;
		end procedure;

	begin
		if (rst_n = '0') then
			curr_state_r <= wait_for_input;
			curr_word_r  <= (others => '0');
			bit_index_r  <= 0;
		elsif (aud_bclk_in'event and aud_bclk_in = '1') then
			case curr_state_r is
				when wait_for_input =>
					if (aud_lrclk_in = '1') then
						change_state_to(read_left);
					end if;

				when read_left =>
					if (aud_lrclk_in = '0') then
						change_state_to(read_right);
					else
						collect_next_bit(value_right_out);
					end if;

				when read_right =>
					if (aud_lrclk_in = '1') then
						change_state_to(read_left);
					else
						collect_next_bit(value_left_out);
					end if;
			end case;
		end if;
	end process;
end architecture RTL;

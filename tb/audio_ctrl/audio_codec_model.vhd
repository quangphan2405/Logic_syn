library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity audio_codec_model is
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
end entity audio_codec_model;

architecture RTL of audio_codec_model is

	type states_type is (wait_for_input, read_left, read_right);
	signal curr_state_r : states_type;
	-- Buffer for input. LSB does not need buffer, so length is one bit shorted than data_width_g.
	signal curr_word_r  : std_logic_vector(data_width_g - 1 downto 1);
	-- Index of bit to read. Value -1 indicates that word is fully read.
	signal bit_index_r  : integer range -1 to curr_word_r'high - 1;

	signal value_left_out_r, value_right_out_r : std_logic_vector(data_width_g - 1 downto 0);

begin
	sync : process(aud_bclk_in, rst_n)
		
		-- We introduce two procedures to reduce repetition. All state transitions are very similar.
		
		-- Procedure for changing the state. In addition to state transition,
		-- it reads the MSB of next word and resets the bit index.
		procedure change_state_to(next_state : states_type) is
		begin
			curr_state_r <= next_state;
			-- First bit must be read at this stage.
			curr_word_r  <= (curr_word_r'high => aud_data_in, others => '0');		
			bit_index_r  <= curr_word_r'high - 1;
		end procedure;
		
		-- Procedure for reading the single bit of the word. Should be called on each rising edge when reading the data, but
		-- only after the MSB is already read.
		procedure collect_next_bit(
			-- Signal for outputting the potentially read full word.
			signal value_out : out std_logic_vector(data_width_g - 1 downto 0)
		) is
		begin
			if (bit_index_r = 0) then
				-- End of the word, collect the LSB and set the output.
				value_out   <= curr_word_r & aud_data_in;
				-- Set the index to -1 so that next branch will not execute before next state transition.
				bit_index_r <= -1;
			elsif (bit_index_r /= -1) then
				-- Collect the next bit and decrement the index.
				curr_word_r(bit_index_r) <= aud_data_in;
				bit_index_r              <= bit_index_r - 1;
			end if;
		end procedure;

	begin
		if (rst_n = '0') then
			curr_state_r      <= wait_for_input;
			curr_word_r       <= (others => '0');
			bit_index_r       <= -1; -- This value will not be used, signal will be resetted at first state change.
			value_left_out_r  <= (others => '0');
			value_right_out_r <= (others => '0');
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
						collect_next_bit(value_left_out_r);
					end if;

				when read_right =>
					if (aud_lrclk_in = '1') then
						change_state_to(read_left);
					else
						collect_next_bit(value_right_out_r);
					end if;
			end case;
		end if;
	end process;

	value_left_out  <= value_left_out_r;
	value_right_out <= value_right_out_r;
end architecture RTL;

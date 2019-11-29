-------------------------------------------------------------------------------
-- Title      : Bonus 2
-- Project    : 
-------------------------------------------------------------------------------
-- File       : sine_wave_gen.vhd
-- Author     : Group 21
-- Company    : 
-- Created    : 2019-11-29
-- Last update: 2019-11-29
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Sine wave generator
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  			Description
-- 2019-11-29  1.0      Paulus Limma  		Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sine_wave_gen is
	generic(
		freq_g : integer
	);
	port(
		clk, rst_n, sync_clear_n_in : in  std_logic;
		value_out                   : out std_logic_vector(15 downto 0)
	);
end entity sine_wave_gen;

architecture RTL of sine_wave_gen is

	-- Quantization is made by 13-bit shift, so max input value for sine function
	-- is 2^13=8192. Value is also adjusted to be divisible by frequency.
	constant x_max         : integer   := (8192 / freq_g) * freq_g;
	constant x_min         : integer   := -x_max;
	constant upwards_dir_c : std_logic := '1';

	signal direction     : std_logic;
	signal x_current     : signed(15 downto 0);
	signal current_value : signed(15 downto 0);

	-- Function for calculating fixed point 32-bit sine value.
	-- Uses fifth order polynomial approximation described here: http://www.coranac.com/2009/07/sines/
	-- Credits and more info about fixed-point calculation of approximation:
	-- https://www.nullhardware.com/blog/fixed-point-sine-and-cosine-for-embedded-systems/
	pure function sine(x : signed(15 downto 0)) return signed is
		-- Precalculated constants. First two are over 32-bit, so them can not be initialized with integer.
		constant A1 : unsigned := resize(x"C8EC8A4B", 64);
		constant B1 : unsigned := resize(x"A3B2292C", 64);
		constant C1 : unsigned := to_unsigned(292421, 32);
		-- Shifting amount constants.
		constant n  : integer  := 13;
		constant a  : integer  := 12;
		constant p  : integer  := 32;
		constant q  : integer  := 31;
		constant r  : integer  := 3;

		-- Take absolute value of input, convert to unsigned and resize it to 32-bit long.
		constant x_32 : unsigned(31 downto 0) := resize(unsigned(abs (x)), 32);

		-- Because calculation is so complex, local variable is used to make it more readable.	
		constant y_width : integer := 32;
		variable y       : unsigned(y_width - 1 downto 0);

	begin
		-- See the link above for explanation for these statements.
		y := resize(shift_right(C1 * x_32, n), y_width);
		y := resize(B1 - shift_right(x_32 * y, r), y_width);
		y := resize(x_32 * shift_right(y, n), y_width);
		y := resize(x_32 * shift_right(y, n), y_width);
		y := resize(A1 - shift_right(y, p - q), y_width);
		y := resize(x_32 * shift_right(y, n), y_width);
		y := shift_right(y + shift_left(to_unsigned(1, y_width), q - a - 1), q - a);

		-- Check sign of the input and adjust sign of the output accordingly.
		if (x(x'left) = '0') then
			return resize(signed(y), 16);
		else
			return -resize(signed(y), 16);
		end if;
	end function;
begin

	sync : process(clk, rst_n)
	begin
		if (rst_n = '0') then
			x_current     <= (others => '0');
			current_value <= (others => '0');
			direction     <= upwards_dir_c;
		elsif (clk'EVENT and clk = '1') then
			if (sync_clear_n_in = '0') then
				x_current     <= (others => '0');
				current_value <= (others => '0');
				direction     <= upwards_dir_c;
			else
				if (direction = upwards_dir_c) then
					-- Change direction 'beforehand' if next step leads to the max value.
					if (to_integer(x_current) = x_max - freq_g) then
						direction <= not upwards_dir_c;
					end if;
					-- Add 'frequency' to current x value.
					x_current <= x_current + freq_g;
					
				-- Do opposite for another direction.			
				else
					if (to_integer(x_current) = x_min + freq_g) then
						direction <= upwards_dir_c;
					end if;
					x_current <= x_current - freq_g;
				end if;

				-- Call sine function and store result to register.
				current_value <= sine(x_current);
			end if;
		end if;
	end process;

	value_out <= std_logic_vector(current_value);

end architecture RTL;

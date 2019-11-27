-------------------------------------------------------------------------------
-- Title      : Multi port adder test bench
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_multi_port_adder.vhd
-- Author     : Group 21
-- Company    : 
-- Created    : 2019-11-21
-- Last update: 2019-11-21
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Multi port adder test bench
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  			Description
-- 2019-11-21  1.0      Paulus Limma  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb_multi_port_adder is
	generic(operand_width_g : integer := 3);
end entity tb_multi_port_adder;

architecture testbench of tb_multi_port_adder is
	constant period_c          : Time    := 10 ns;
	constant num_of_operands_c : integer := 4;
	constant duv_delay_c       : integer := 2;

	signal clk            : std_logic := '0';
	signal rst_n          : std_logic := '0';
	-- Input operands as single concatented vector.
	signal operands_r     : std_logic_vector(operand_width_g * num_of_operands_c - 1 downto 0);
	signal sum            : std_logic_vector(operand_width_g - 1 downto 0);
	-- Counter for addressing adder delay.
	signal output_valid_r : std_logic_vector(duv_delay_c downto 0);

	file input_f       : text open READ_MODE is "input.txt";
	file ref_results_f : text open READ_MODE is "ref_results.txt";
	file output_f      : text open WRITE_MODE is "output.txt";

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

begin
	clk   <= not clk after period_c / 2;
	rst_n <= '1' after period_c * 4;

	i_adder : component multi_port_adder
		generic map(
			operand_width_g   => operand_width_g,
			num_of_operands_g => num_of_operands_c
		)
		port map(
			clk         => clk,
			rst_n       => rst_n,
			operands_in => operands_r,
			sum_out     => sum
		);

	-- Process for reading input file and directing it to the adder input.
	read_input : process(rst_n, clk)
		type value_array_t is array (3 downto 0) of integer;
		variable line_v         : line;
		variable input_values_v : value_array_t;
	begin
		if (rst_n = '0') then
			operands_r     <= (others => '0');
			output_valid_r <= (others => '0');
		elsif (clk'EVENT and clk = '1') then
			-- Shift output_valid_r one bit to left and set LSB to 1.
			output_valid_r(duv_delay_c downto 0) <= output_valid_r(duv_delay_c - 1 downto 0) & '1';
			if not endfile(input_f) then
				readline(input_f, line_v);
				-- Read 4 space separated value from line.
				for i in 3 downto 0 loop
					read(line_v, input_values_v(i));
					-- Set corresponding bits of operands_r to the value of input_values_v(i).
					operands_r((i + 1) * operand_width_g - 1 downto i * operand_width_g) 
						<= std_logic_vector(to_signed(input_values_v(i), operand_width_g));
				end loop;
			end if;
		end if;
	end process;

	-- Process for checking that output of adder matches to reference values.
	checker : process(clk)
		variable line_in_v       : line;
		variable line_out_v      : line;
		variable ref_output_v    : integer;
		variable sum_out_integer : integer;
	begin
		if (clk'EVENT and clk = '1') then
			-- Wait until MSB of output_valid_r is 1.
			if (output_valid_r(duv_delay_c) = '1') then
				-- Read single line from ref_results to line_in_v
				if not endfile(ref_results_f) then
					readline(ref_results_f, line_in_v);
					read(line_in_v, ref_output_v);
				else
					assert false report "Simulation done" severity failure;
				end if;
				
				-- Convert adder result to intger and write it to the output file.
				sum_out_integer := to_integer(signed(sum));
				write(line_out_v, sum_out_integer);
				writeline(output_f, line_out_v);

				-- Assert correct result.
				assert sum_out_integer = ref_output_v
				report "Expected: " & INTEGER'IMAGE(ref_output_v) & ". Got: " & INTEGER'IMAGE(sum_out_integer)
				severity failure;

			end if;
		end if;
	end process;

end architecture testbench;

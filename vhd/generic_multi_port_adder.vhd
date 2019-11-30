-------------------------------------------------------------------------------
-- Title      : Bonus 1, Generic multi port adder
-- Project    : 
-------------------------------------------------------------------------------
-- File       : multi_port_adder_bonus.vhd
-- Author     : Group 21
-- Company    : 
-- Created    : 2019-11-13
-- Last update: 2019-11-29
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Multi port adder, which has adjustable operand count.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity generic_multi_port_adder is
	generic(operand_width_g : integer := 16;
	        n_g             : integer := 2);
	port(
		clk, rst_n  : in  std_logic;
		operands_in : in  std_logic_vector(operand_width_g * (2**n_g) - 1 downto 0);
		sum_out     : out std_logic_vector(operand_width_g - 1 downto 0)
	);
end generic_multi_port_adder;

-------------------------------------------------------------------------------

architecture structural of generic_multi_port_adder is

	constant num_of_operands_c : integer := 2**n_g;

	-- This array contains cell for each adder input and output.
	-- Outputs of adders will be also inputs of adders in next layer.
	type container_type is array (num_of_operands_c * 2 - 1 - 1 downto 0) of std_logic_vector(operand_width_g downto 0);
	signal value_container : container_type;

	component adder is
		generic(
			operand_width_g : integer);
		port(
			clk, rst_n : in  std_logic;
			a_in, b_in : in  std_logic_vector(operand_width_g - 1 downto 0);
			sum_out    : out std_logic_vector(operand_width_g downto 0));
	end component adder;

begin
	-- This async process initializes the input part of value container.
	copy_inputs_to_value_container : process(operands_in)
	begin
		for i in 0 to num_of_operands_c - 1 loop
			value_container(i) <= '0' & operands_in((i + 1) * operand_width_g - 1 downto i * operand_width_g);
		end loop;
	end process;

	generate_adders : for i in 0 to num_of_operands_c - 2 generate
		adder_i : adder
			generic map(
				operand_width_g => operand_width_g)
			port map(
				clk     => clk,
				rst_n   => rst_n,
				a_in    => value_container(i * 2)(operand_width_g - 1 downto 0),
				b_in    => value_container(i * 2 + 1)(operand_width_g - 1 downto 0),
				sum_out => value_container(num_of_operands_c + i)
			);
	end generate;

	sum_out <= value_container(value_container'HIGH)(operand_width_g - 1 downto 0);

end structural;

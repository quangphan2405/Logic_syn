-------------------------------------------------------------------------------
-- Title      : Exercise 05, triangular wave generator
-- Project    : 
-------------------------------------------------------------------------------
-- File       : wave_gen.vhd
-- Author     : Group 21
-- Company    : 
-- Created    : 2019-11-27
-- Last update: 2019-11-27
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Triangular wave generator
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  		Description
-- 2019-11-27  1.0      Paulus Limma  	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wave_gen is
	generic(
		width_g : integer;
		step_g : integer
	);
	port(
		clk : in std_logic;
		rst_n : in std_logic;
		sync_clear_n_in : in std_logic;
		value_out : std_logic_vector(width_g - 1 downto 0)
	);
end entity wave_gen;

architecture RTL of wave_gen is
	constant max_value_c : integer := (2**(width_g - 1) - 1) / step_g;
	constant min_value_c : integer := -max_value_c;
begin
	
	counter : process(clk, rst_n)
	begin
		if(rst_n = '1') then
			value_out <= (others => '0');
		elsif(clk'EVENT and clk = '1') then
			
		end if;
	end process counter;

end architecture RTL;

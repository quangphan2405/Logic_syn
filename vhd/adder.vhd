-------------------------------------------------------------------------------
-- Title      : Exercise 03
-- Project    : 
-------------------------------------------------------------------------------
-- File       : adder.vhd
-- Author     : Group 21
-- Company    : 
-- Created    : 2019-11-06
-- Last update: 2019-11-06
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Adder module
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-11-06  1.0      limmap  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
  generic(operand_width_g : integer);
  port(
    clk, rst_n : in  std_logic;
    a_in, b_in : in  std_logic_vector(operand_width_g - 1 downto 0);
    sum_out    : out std_logic_vector(operand_width_g downto 0)
    );
end adder;

-------------------------------------------------------------------------------

architecture rtl of adder is
  signal result : signed(operand_width_g downto 0) := (others => '0');
begin
  -- register for the result
  sum_out <= std_logic_vector(result);
  sync : process(clk, rst_n)
  begin
    if (rst_n = '0') then
      result <= (others => '0');        -- reset the register.
    elsif (clk = '1' and clk'event) then
      -- resize the inputs, convert them to signed and calculate the sum.
      result <= resize(signed(a_in), operand_width_g + 1) + resize(signed(b_in), operand_width_g + 1);
    end if;
  end process sync;
end rtl;

-------------------------------------------------------------------------------
-- Title      : Exercise 04
-- Project    : 
-------------------------------------------------------------------------------
-- File       : multi_port_adder.vhd
-- Author     : Group 21
-- Company    : 
-- Created    : 2019-11-13
-- Last update: 2019-11-13
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:Multi port adder module
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-11-06  1.0      limmap  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity multi_port_adder is
  generic(operand_width_g   : integer := 16;
          num_of_operands_g : integer := 4);
  port(
    clk, rst_n  : in  std_logic;
    operands_in : in  std_logic_vector(operand_width_g*num_of_operands_g - 1 downto 0);
    sum_out     : out std_logic_vector(operand_width_g - 1 downto 0)
    );
end multi_port_adder;

-------------------------------------------------------------------------------

architecture structural of multi_port_adder is
  component adder is
    generic (
      operand_width_g : integer);
    port (
      clk, rst_n : in  std_logic;
      a_in, b_in : in  std_logic_vector(operand_width_g - 1 downto 0);
      sum_out    : out std_logic_vector(operand_width_g downto 0));
  end component adder;
  
  type subtotal_type is array (num_of_operands_g/2-1 downto 0) of std_logic_vector(operand_width_g downto 0);
  
  signal subtotal : subtotal_type;
  signal total    : std_logic_vector(operand_width_g + 1 downto 0);
  
begin
  assert (num_of_operands_g = 4)
    report "The num_of_operands_g should only be 4"
    severity failure;
  
  adder_1 : adder
    generic map (
      operand_width_g => operand_width_g)
    port map (
      clk     => clk,
      rst_n   => rst_n,
      -- Divide the operands_in into 4 slices and take them in the descending
      -- order. Each slice has the length of operand_width_g.
      a_in    => operands_in(operand_width_g*num_of_operands_g - 1 downto operand_width_g*(num_of_operands_g - 1)),
      b_in    => operands_in(operand_width_g*(num_of_operands_g - 1) - 1 downto operand_width_g*(num_of_operands_g - 2)),
      sum_out => subtotal(0)
      );
  
  adder_2 : adder
    generic map (
      operand_width_g => operand_width_g)
    port map (
      clk     => clk,
      rst_n   => rst_n,
      a_in    => operands_in(operand_width_g*(num_of_operands_g - 2) - 1 downto operand_width_g*(num_of_operands_g - 3)),
      b_in    => operands_in(operand_width_g*(num_of_operands_g - 3) - 1 downto 0),
      sum_out => subtotal(1)
      );
  
  sum_adder : adder
    generic map (
      operand_width_g => operand_width_g)
    port map (
      clk     => clk,
      rst_n   => rst_n,
      a_in    => subtotal(0),
      b_in    => subtotal(1),
      sum_out => total
      );

  sum_out <= total(operand_width_g - 1 downto 0);

end structural;

-------------------------------------------------------------------------------
-- Title      : Exercise 04
-- Project    : 
-------------------------------------------------------------------------------
-- File       : multi_port_adder_bonus.vhd
-- Author     : Group 21
-- Company    : 
-- Created    : 2019-11-13
-- Last update: 2019-11-13
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:Multi port adder bonus module
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
          n : integer);
  port(
    clk, rst_n  : in  std_logic;
    operands_in : in  std_logic_vector(operand_width_g*(2**n) - 1 downto 0);
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
  
  type container_type is array (2**(n+1) - 2 downto 0) of std_logic_vector(operand_width_g - 1 downto 0);

  signal container : container_type;
  
begin
  container(container'LEFT downto container'LEFT - operands_in'LENGTH + 1) <= operands_in;
  adders : for i in 0 to (2**n - 1) generate
    adder_i : adder
      generic map (
        operand_width_g => operand_width_g)
      port map (
        clk     => clk,
        rst_n   => rst_n,
        a_in    => container(i*,
        b_in    => operands_in(operand_width_g*(num_of_operands_g - 1) - 1 downto operand_width_g*(num_of_operands_g - 2)),
        sum_out => subtotal(0)
        );
  
  

  sum_out <= total(operand_width_g - 1 downto 0);

end structural;

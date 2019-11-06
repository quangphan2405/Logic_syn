-------------------------------------------------------------------------------
-- Title      : Exercise 02
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ripple_carry_adder.vhd
-- Author     : Group 21
-- Company    : 
-- Created    : 2019-11-06
-- Last update: 2019-11-06
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 3-bit ripple-carry-adder
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-11-06  1.0      limmap  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ripple_carry_adder is
  port(
    a_in, b_in : in  std_logic_vector(2 downto 0);
    s_out      : out std_logic_vector(3 downto 0)
    );
end ripple_carry_adder;

-------------------------------------------------------------------------------

architecture gate of ripple_carry_adder is
  signal carry_ha, carry_fa, c, d, e, f, g, h : std_logic;
begin
  s_out(0) <= a_in(0) xor b_in(0);
  carry_ha <= a_in(0) and b_in(0);

  c        <= a_in(1) xor b_in(1);
  s_out(1) <= carry_ha xor c;
  d        <= carry_ha and c;
  e        <= a_in(1) and b_in(1);
  carry_fa <= d or e;

  f        <= a_in(2) xor b_in(2);
  s_out(2) <= carry_fa xor f;
  g        <= carry_fa and f;
  h        <= a_in(2) and b_in(2);
  s_out(3) <= g or h;
end gate;

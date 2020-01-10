-------------------------------------------------------------------------------
-- Title      : TIE-50206, exercise 7
-- Project    : 
-------------------------------------------------------------------------------
-- File       : counter.vhd
-- Author     : Quang
-- Company    : 
-- Created    : 2020-01-09
-- Last update: 2020-01-09
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Create a counter for clock period
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-01-09  1.0      Quang	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
  generic (
    width_g : integer := 5);
  
  port(
    clk : in std_logic;
    max_value_in: in integer;
    count_out : out std_logic_vector(width_g - 1 downto 0)
    );
end entity counter;
    
-------------------------------------------------------------------------------

architecture rtl of counter is
   
  signal count_r : integer range max_value_in - 1 downto 0 := 0;
  
begin 

  sync : process(clk)
  begin    
    if (clk'EVENT and clk = '1') then
      if count_r = max_value_in - 1 then
        count_r <= 0;
      else
        count_r <= count_r + 1; 
  end process sync;
  count_out <= std_logic_vector(to_unsigned(count_r, width_g));
  
end rtl;

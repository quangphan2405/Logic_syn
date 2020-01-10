-------------------------------------------------------------------------------
-- Title      : Exercise 06
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
-- Description: Wave generation module
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author                          Description
-- 2019-11-27  1.0      Quang Phan                      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wave_gen is
  generic(
	    width_g : integer;
	    step_g  : integer
    );
  port(
    clk, rst_n, sync_clear_n_in : in  std_logic;
    value_out                   : out std_logic_vector(width_g - 1 downto 0)
    );
end wave_gen;

-------------------------------------------------------------------------------

architecture generator of wave_gen is

  signal dir           : std_logic;
  signal current_value : signed(width_g - 1 downto 0);
  constant upwards_c   : std_logic := '1';
  constant max_c       : integer := ((2**(width_g-1)-1)/step_g)*step_g;

begin
  
  sync : process(clk, rst_n)
  begin
    if (rst_n = '0') then
      current_value <= (others => '0');
      dir <= upwards_c;
    elsif (clk = '1' and clk'event) then
      if (sync_clear_n_in = '0') then
        -- reset the current value to 0 and change to upwards direction.
        current_value <= (others => '0');
        dir           <= upwards_c;
      else
        -- If current direction is upwards and next step leads to max value,
        -- or current directionn is downwards and next step leads to min value,
        -- then change the direction.
        if (to_integer(current_value) = max_c - step_g and dir = upwards_c) then
          dir <= not upwards_c;
        elsif (to_integer(current_value) = - max_c + step_g and dir = not upwards_c) then
          dir <= upwards_c;
        end if;
        
        if (dir = upwards_c) then
          current_value <= current_value + step_g;
        else
          current_value <= current_value - step_g;
        end if;
        
      end if;
    end if;
  end process sync;
  value_out <= std_logic_vector(current_value);
end generator;

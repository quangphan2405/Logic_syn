-------------------------------------------------------------------------------
-- Title      : TIE-50206, exercise 3
-- Project    : 
-------------------------------------------------------------------------------
-- File       : adder.vhd
-- Author     : Quang
-- Company    : 
-- Created    : 2019-11-22
-- Last update: 2020-01-14
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Create a generic adder
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-11-22  1.0      USER	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity audio_ctrl is
  generic (
    ref_clk_freq_g: integer :=12288000;                 -- Main clock frequency (Hz)
    sample_rate_g: integer := 48000;                    -- lrclk frequency (Hz)
    data_width_g: integer := 16                         -- bits
    );
  
  port(
    clk, rst_n : in std_logic;
    left_data_in, right_data_in: in std_logic_vector(data_width_g - 1 downto 0);
    aud_bclk_out: out std_logic;                        -- Bit clock
    aud_data_out: out std_logic;                        -- Data output
    aud_lrclk_out: out std_logic                        -- Left-right clock
    );
end audio_ctrl;
    
-------------------------------------------------------------------------------

architecture rtl of audio_ctrl is
  
  constant min_bclk_period_c : time := 75 ns;           -- Minimun bclk period
  constant billion_c : integer := 1000000000;                   -- 10^9
  constant min_bclk_freq_c : integer := billion_c/75;             -- Preferred bclk frequency
  -- Maximum value for counters calculated by taking main clock frequency
  -- divided by the frequencies of bit and word clock
  constant max_lrclk_c : integer := (ref_clk_freq_g/sample_rate_g)/2 + 1/2;
  constant max_bclk_c : integer := (ref_clk_freq_g/min_bclk_freq_c)/2 + 1/2;

  -- Registers for counter in two components
  signal lrclk_cnt_r : integer range 0 to max_lrclk_c;
  signal bclk_cnt_r : integer range 0 to max_bclk_c;

  -- Registers for outputs
  signal bclk_r, lrclk_r : std_logic;
  signal data_out_r : std_logic_vector(data_width_g - 1 downto 0);
  signal last_bit_r : std_logic; 
  
  begin
        
    bclk_gen: process(clk, rst_n)                       -- Bclk process
    begin
      if rst_n = '0' then                               -- Asynchonous reset (low)
        bclk_cnt_r <= 0;
        bclk_r <= '0';
      elsif clk'EVENT and clk = '1' then                -- Rising edge
        if bclk_cnt_r = max_bclk_c then
          bclk_r <= not bclk_r;                         -- Invert bit clock value
          bclk_cnt_r <= 0;
        else
          bclk_cnt_r <= bclk_cnt_r + 1;
        end if;
      end if;
    end process bclk_gen;

    lrclk_gen: process(clk, rst_n)                      -- Lrclk process
    begin
      if rst_n = '0' then                               -- Asynchonous reset (low)
        lrclk_cnt_r <= 0;
        lrclk_r <= '0';
      elsif clk'EVENT and clk = '1' then                -- Rising edge
        if lrclk_cnt_r = max_lrclk_c then
          lrclk_r <= not lrclk_r;                       -- Invert LR clock value
          lrclk_cnt_r <= 0;
        else
          lrclk_cnt_r <= lrclk_cnt_r + 1;          
        end if;
      end if;
    end process lrclk_gen;

    -- Save the snapshot of data inputs
    output: process(clk,rst_n)                          -- Output process
    begin        
      if rst_n = '0' then                               -- Asynchonous reset (low)
        data_out_r <= (others => '0');
      elsif clk'EVENT and clk = '1' then                -- Rising edge
        
        if lrclk_r'EVENT then
          if lrclk_r = '1' then
            data_out_r <= left_data_in;
          else
            data_out_r <= right_data_in;
          end if;
        end if;

        data_out_r <= data_out_r(data_width_g - 2 downto 0) & '0';
      end if;
    end process output;
    
    aud_bclk_out <= bclk_r;
    aud_lrclk_out <= lrclk_r;
    aud_data_out <= data_out_r(data_width_g - 1);
           
end rtl;

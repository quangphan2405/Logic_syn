-------------------------------------------------------------------------------
-- Title      : TIE-50206, exercise 3
-- Project    : 
-------------------------------------------------------------------------------
-- File       : adder.vhd
-- Author     : Quang
-- Company    : 
-- Created    : 2019-11-22
-- Last update: 2020-01-10
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
end adder;
    
-------------------------------------------------------------------------------

architecture rtl of audio_ctrl is
  
  constant cnt_width_c : integer := 10;                 -- Default counter's width
  constant bclk_freq_c : integer := 5e6;                -- Preferred bclk frequency
  -- Maximum value for counters calculated by taking main clock frequency
  -- divided by the frequencies of bit and word clock
  constant max_bclk_c : integer := real(ref_clk_freq_g)/real(bclk_freq_c);
  constant max_lrclk_c : integer := real(ref_clk_freq_g)/real(sample_rate_g);

  -- Registers for counter in two components
  signal bclk_cnt_r : std_logic_vector(cnt_width_c - 1 downto 0);
  signal lrclk_cnt_r : std_logic_vector(cnt_width_c - 1 downto 0);

  -- Registers for outputs
  signal bclk_r, lrclk_r : std_logic := 0;
  signal data_out_r : std_logic_vector(2*data_width_g - 1 downto 0);
  signal output_cnt_r : integer range 0 to 2*data_width_g;
  signal data_en_r : std_logic;
    
  entity counter is

    generic (
      width_g : integer := 5);

    port (
      clk          : in  std_logic;
      max_value_in : in  integer;
      count_out    : out std_logic_vector(width_g - 1 downto 0));

  end entity counter;

  bclk_counter: entity work.counter
    generic map (
      width_g => cnt_width_c)
    port map (
      clk          => clk,
      max_value_in => max_bclk_c,
      count_out    => bclk_cnt_r);

  lrclk_counter: entity work.counter
    generic map (
      width_g => cnt_width_c)
    port map (
      clk          => clk,
      max_value_in => max_lrclk_c,
      count_out    => lrclk_cnt_r);  
  
  begin
        
    bclk_gen: process(clk, rst_n)                       -- Bclk process
      if rst_n = '0' then                               -- Asynchonous reset (low)
        bclk_cnt_r <= (others => '0');
        bclk_r <= (others => '0');
      elsif clk'EVENT and clk = '1' then                -- Rising edge
        if to_integer(unsigned(bclk_cnt_r)) = max_bclk_c - 1 then
          bclk_r <= not bclk_r;                         -- Invert bit clock value
        end if;
      end if;
    end process bclk_gen;

    lrclk_gen: process(clk, rst_n)                      -- Lrclk process
      if rst_n = '0' then                               -- Asynchonous reset (low)
        lrclk_cnt_r <= (others => '0');
        lrclk_r <= (others => '0');
      elsif clk'EVENT and clk = '1' then                -- Rising edge
        if to_integer(unsigned(lrclk_cnt_r)) = max_lrclk_c - 1 then
          lrclk_r <= not lrclk_r;                       -- Invert LR clock value
        end if;
      end if;
    end process lrclk_gen;

    -- Save the snapshot of data inputs
    output: process(clk,rst_n)                          -- Output process
            
      if rst_n = '0' then                               -- Asynchonous reset (low)
        data_out_r <= (others => '0');
        output_cnt_r <= 2*data_width_g - 1;
        data_en_r <= (others => '0');
      elsif clk'EVENT and clk = '1' then                -- Rising edge
        
        if lrclk_r'EVENT and lrclk_r = '1' then         -- Sample cycle starts
          data_en_r <= '1';
          output_cnt_r <= '0';
          data_out_r <= left_data_in(data_width_g - 1 downto 0) & right_data_in(data_width_g - 1 downto 0);
        end if;

        if output_cnt_r < 2*data_width_g - 1 then
          output_cnt_r <= output_cnt_r + 1;
          data_out_r <= data_out_r(2*data_width_g - 2 downto 0) & '0';
        else
          data_en_r <= '0';
        end if;
                  
      end if;
    end process output;
    
    aud_bclk_out <= bclk_r;
    aud_lrclk_out <= lrclk_r;
    aud_data_out <= data_out_r(2*data_width_g - 1);
           
end rtl;

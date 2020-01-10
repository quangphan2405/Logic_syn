-------------------------------------------------------------------------------
-- Title      : TIE-50206, exercise 8
-- Project    : 
-------------------------------------------------------------------------------
-- File       : audio_codec_model.vhd
-- Author     : Quang
-- Company    : 
-- Created    : 2020-01-03
-- Last update: 2020-01-08
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Create an audio codec model implementation
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2020-01-03  1.0      Quang	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity audio_codec_model is
  generic (
    data_width_g : integer := 16
    );  
  port(
    rst_n : in std_logic;
    aud_data_in : in std_logic;
    aud_bclk_in, aud_lrclk_in: in std_logic; -- bit and word clocks
    
    value_left_out, value_right_out: out std_logic_vector(data_width_g - 1 downto 0)
    );
end audio_codec_model;
    
-------------------------------------------------------------------------------

architecture rtl of audio_codec_model is

  -- Enumerate possible states
  type states_type is (wait_for_input, read_left, read_right);
  signal present_state_r: states_type;

  -- Counter for output value 's length
  signal cnt_r : integer range 0 to data_width_g - 1;
  -- Store current value to be deliverd 
  signal curr_value_r: std_logic_vector(data_width_g - 1 downto 0);
  signal last_bit_r : std_logic;             -- Store last cycle's bit data
  signal check_r : std_logic;                -- check if the correct channel
                                             -- has deliverd the output
  
begin

  last_bit_r <= aud_data_in;

  sync: process (bclk, rst_n)
  begin
    if rst_n = '0' then                      -- asynchronous reset (active low)

      present_state_r <= wait_for_input;     -- init state
      curr_value_r <= (others => '0');      

    elsif bclk'event and bclk = '1' then     -- rising bit clock edge

      case present_state_r is

        when wait_for_input =>
          if lrclk = '1' then
            present_state_r <= read_left;
            cnt_r <= 0;
            check_r <= '0';
          else
            present_state_r <= wait_for_input;
          end if;

        when read_left =>
          if lrclk = '0' then
            present_state_r <= read_right;
            check_r <= '0';                 -- move to right channel            
          else            
            if check_r = '0' then
              
              if cnt_r = data_width_g then
                cnt_r <= 0;
                check_r <= '1';
                curr_value_r <= (others => '0');
              else
                curr_value_r(cnt_r) <= last_bit_r;
                cnt_r <= cnt_r + 1;
              end if;
              
            end if;
          end if;

        when read_right =>
          if lrclk = '1' then
            present_state_r <= read_left;
            check_r <= '0';                 -- move to left channel
          else            
            if check_r = '0' then
              
              if cnt_r = data_width_g then
                cnt_r <= 0;
                check_r <= '1';
                curr_value_r <= (others => '0');
              else
                curr_value_r(cnt_r) <= last_bit_r;
                cnt_r <= cnt_r + 1;
              end if;
              
            end if;
          end if;
            
      end case;
    end if;
  end process sync;

  output : process(present_state_r)
  begin -- process output
    
    case present_state_r is
      when read_left =>
        value_left_out <= curr_value_r;
      when read_right =>
        value_right_out <= curr_value_r;
      when others =>
        value_left_out <= curr_value_r;
        value_right_out <= curr_value_r;
    end case;
    
  end process output;     
        
end rtl;

-------------------------------------------------------------------------------
-- Title      : Exercise 11
-- Project    : 
-------------------------------------------------------------------------------
-- File       : i2c_config.vhd
-- Author     : Group 21
-- Company    : 
-- Created    : 2020-02-05
-- Last update: 2020-02-07
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: I2C bus configuration
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  			Description
-- 2020-02-05  1.0      Quang Phan    Created
-- 2020-02-17  1.1      Quang Phan    Fix and comment
-- 2020-02-18  1.2      Quang Phan    Fix proceduregit
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_config is
  generic(
    ref_clk_freq_g  : integer := 50000000;
    i2c_freq_g      : integer := 20000;
    n_params_g      : integer := 15;
    n_leds_g        : integer := 4
    );
  port(
    clk, rst_n      : in  std_logic;
    sdat_inout      : inout std_logic;
    sclk_out        : out std_logic;
    param_status_out: out std_logic_vector(n_leds_g - 1 downto 0);
    finished_out    : out std_logic
  );
end i2c_config;

-------------------------------------------------------------------------------

architecture rtl of i2c_config is
  constant byte_width_c         : integer := 8;
  -- Default device address(7-bit) and R/W bit: '0' = write. 
  constant device_address_c     : std_logic_vector(byte_width_c - 1 downto 0) := "0011010" & '0';
  constant sclk_half_period_c   : integer := ref_clk_freq_g/i2c_freq_g;    -- half period
  constant sclk_middle_period_c : integer := sclk_half_period_c/2;         -- middle point of period
  -- Array for saving register addresses and corresponding setting values.
  type param_type is array(0 to n_params_g - 1) of std_logic_vector(byte_width_c - 1 downto 0);
  constant reg_addresses_c : param_type := ("00010010",
                                            "00100111",
                                            "00100010",
                                            "00101000",
                                            "00101001",
                                            "01101001",
                                            "01101010",
                                            "01000111",
                                            "01101011",
                                            "01001100",
                                            "01001011",
                                            "01001100",
                                            "01101110",
                                            "01101111",
                                            "01010001");
  constant values_c : param_type        := ("10000000",
                                            "00000100",
                                            "00001011",
                                            "00000000",
                                            "10000001",
                                            "00001000",
                                            "00000000",
                                            "11100001",
                                            "00001001",
                                            "00001000",
                                            "00001000",
                                            "00001000",
                                            "10001000",
                                            "10001000",
                                            "11110001");
  -- States for FSM.                                          
  type state_type is (start, device_address_trans, reg_address_trans, data_trans, ack_listening, stop_cond, finished);
  signal current_state_r : state_type;
  signal next_state_r    : state_type;
  signal param_num_r     : integer range 0 to n_params_g - 1;               -- nth param
  signal bit_num_r       : integer range -1 to byte_width_c - 1;            -- bit index
  signal sclk_cnt_r      : integer range sclk_half_period_c - 1 downto 0;   
  signal sdat_r, sclk_r, finished_out_r : std_logic;                        -- reg for output

begin

   sync : process(clk, rst_n) -- Process sync

   procedure transmit_next_bit(current_byte : in std_logic_vector(byte_width_c - 1 downto 0);
                               next_state   : in state_type) is
    begin
      -- At the middle of SCK LOW period
      if sclk_r = '0' and sclk_cnt_r = sclk_middle_period_c then
        if bit_num_r /= -1 then
          -- Transmit the current bit data
          sdat_r <= current_byte(bit_num_r);
          bit_num_r <= bit_num_r - 1;
        else
          -- Byte finished. Wait for ACK by setting SDA to tri-state logic
          bit_num_r <= byte_width_c - 1;
          sdat_r <= 'Z';
          current_state_r <= ack_listening;
          next_state_r <= next_state;
        end if;
      end if;
  end procedure transmit_next_bit;

   begin
     if rst_n = '0' then
       current_state_r <= start;
       next_state_r <= device_address_trans;

       sdat_r <= '1';
       sclk_r <= '1';
       finished_out_r <= '0';

       sclk_cnt_r <= 0;
       param_num_r <= 0;
       -- Transmission starts from MSB.
       bit_num_r <= byte_width_c - 1;
     elsif clk'EVENT and clk = '1' then
      -- Sclk generation
      if sclk_cnt_r = sclk_half_period_c - 1 then
        sclk_r <= not sclk_r;
        sclk_cnt_r <= 0;
      else
        sclk_cnt_r <= sclk_cnt_r + 1;
      end if;

      -- FSM
      case current_state_r is
        when start =>
          -- START condition at the middle of HIGH period of SCL
          if sclk_r = '1' and sclk_cnt_r = sclk_middle_period_c then
            sdat_r <= '0';
            current_state_r <= device_address_trans;
          end if;

        when device_address_trans =>
          transmit_next_bit(device_address_c, reg_address_trans);
        
        when reg_address_trans =>
          transmit_next_bit(reg_addresses_c(param_num_r), data_trans);
        
        when data_trans =>
          transmit_next_bit(values_c(param_num_r), stop_cond);
        
        when ack_listening =>
          -- Wait for ACK in the HIGH period of SCL pulse
          if sclk_r = '1' and sclk_cnt_r = sclk_middle_period_c then
            -- ACK
            if sdat_inout = '0' then
              current_state_r <= next_state_r;
            -- NACK, start again for the current byte
            else
              current_state_r <= start;
              sdat_r <= '1';
              sclk_r <= '1';
              sclk_cnt_r <= 0;
              bit_num_r <= byte_width_c - 1;
            end if;
          end if;
        
        when stop_cond =>
          -- Pull SDA low, prepare for STOP condition.
          -- Time for STOP is half period (25 microsec), enough for set-up(4.0) and hold(5.0).
          if sclk_r = '0' and sclk_cnt_r = sclk_middle_period_c then
            sdat_r <= '0';
          end if;
          -- STOP condition at the middle of HIGH period of SCL
          if sclk_r = '1' and sclk_cnt_r = sclk_middle_period_c then
            -- STOP
            sdat_r <= '1';            
            if param_num_r = n_params_g - 1 then
              -- All params have been transmitted suscessfully
              current_state_r <= finished;
            else
              -- Next param
              current_state_r <= start;
              param_num_r <= param_num_r + 1;
            end if;
          end if;

        when finished =>
          sclk_r <= '1';
          sdat_r <= '1';
          finished_out_r <= '1';
      
        end case;  

     end if;     
   end process sync;
   
   sclk_out <= sclk_r;
   sdat_inout <= sdat_r;
   finished_out <= finished_out_r;
   param_status_out <= std_logic_vector(to_unsigned(param_num_r + 1, n_leds_g));
       
end architecture rtl;
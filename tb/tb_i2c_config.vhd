-------------------------------------------------------------------------------
-- Title      : Exercise 12
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_i2c_config.vhd
-- Author     : Group 21
-- Company    : 
-- Created    : 2020-02-18
-- Last update: 2020-02-18
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Testbench for I2C bus configuration
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  			Description
-- 2020-02-18  1.0      Quang Phan    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------
-- Empty entity
-------------------------------------------------------------------------------

entity tb_i2c_config is
end tb_i2c_config;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture testbench of tb_i2c_config is

  -- Number of parameters to expect
  constant n_params_c     : integer := 15;
  constant n_leds_c : integer := 4;
  constant i2c_freq_c     : integer := 20000;
  constant ref_freq_c     : integer := 50000000;
  constant clock_period_c : time    := 20 ns;

  -- Every transmission consists several bytes and every byte contains given
  -- amount of bits. 
  constant n_bytes_c       : integer := 3;
  constant bit_count_max_c : integer := 8;

  -- Reference values
  constant ref_device_address_c : std_logic_vector(bit_count_max_c - 2 downto 0) := "0011010";
  constant ref_rw_bit_c         : std_logic := '0';
  type ref_type is array(0 to n_params_c - 1) of std_logic_vector(bit_count_max_c - 1 downto 0);
  constant ref_reg_addresses_c  : ref_type := ("00011101",
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
  constant ref_values_c : ref_type        := ("10000000",
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

  -- Signals fed to the DUV
  signal clk   : std_logic := '0';  -- Remember that default values supported
  signal rst_n : std_logic := '0';      -- only in synthesis

  -- The DUV prototype
  component i2c_config
    generic (
      ref_clk_freq_g : integer;
      i2c_freq_g     : integer;
      n_params_g     : integer;
	  n_leds_g : integer);
    port (
      clk              : in    std_logic;
      rst_n            : in    std_logic;
      sdat_inout       : inout std_logic;
      sclk_out         : out   std_logic;
      param_status_out : out   std_logic_vector(n_leds_g-1 downto 0);
      finished_out     : out   std_logic
      );
  end component;

  -- Signals coming from the DUV
  signal sdat         : std_logic := 'Z';
  signal sclk         : std_logic;
  signal param_status : std_logic_vector(n_leds_c-1 downto 0);
  signal finished     : std_logic;

  -- To hold the value that will be driven to sdat when sclk is high.
  signal sdat_r : std_logic;

  -- Check for NACK
  variable nack_r : std_logic := '0';

  -- Counters for receiving bits and bytes
  signal bit_counter_r  : integer range 0 to bit_count_max_c-1;
  signal byte_counter_r : integer range 0 to n_bytes_c-1;
  signal param_counter_r: integer range 0 to n_params_c-1;

  -- States for the FSM
  type   states is (wait_start, read_byte, send_ack, wait_stop);
  signal curr_state_r : states;

  -- Previous values of the I2C signals for edge detection
  signal sdat_old_r : std_logic;
  signal sclk_old_r : std_logic;
  
begin  -- testbench

  clk   <= not clk after clock_period_c/2;
  rst_n <= '1'     after clock_period_c*4;

  -- Assign sdat_r when sclk is active, otherwise 'Z'.
  -- Note that sdat_r is usually 'Z'
  with sclk select
    sdat <=
    sdat_r when '1',
    'Z'    when others;

  -- Component instantiation
  i2c_config_1 : i2c_config
    generic map (
      ref_clk_freq_g => ref_freq_c,
      i2c_freq_g     => i2c_freq_c,
      n_params_g     => n_params_c,
	  n_leds_g => n_leds_c)
    port map (
      clk              => clk,
      rst_n            => rst_n,
      sdat_inout       => sdat,
      sclk_out         => sclk,
      param_status_out => param_status,
      finished_out     => finished);

  function print_error(error_message : string) return std_logic is
    begin

      assert false
      report error_message
      severity error;      
      return '1';

  end function print_error;

  procedure check_correct_bit(byte_index   : in integer range 0 to n_bytes_c - 1;
                              bit_index    : in integer range 0 to bit_count_max_c - 1;
                              param_index  : in integer range 0 to n_params_c - 1;
                              signal nack_r: in std_logic) is
      begin

        variable message : string := "";

        if byte_index = 0 then
          if bit_index /= 0 then
            if sdat /= ref_device_address_c then
              message <= "Wrong device address detected.";
            end if;
          else
            if sdat /= ref_rw_bit_c then
              message <= "Wrong read/write bit.";
            end if;
        elsif byte_index = 1 then
          if sdat /= ref_reg_addresses_c(bit_index) then
            message <= "Wrong register address for register " & param_index & "th.";
          end if;
        else
          if sdat /= ref_values_c(bit_index) then
            message <= "Wrong setting value for register"  & param_index & "th.";
          end if;
        end if;

        if message /= "" then
          nack_r <=  print_error(message);
        else
          nack_r <= '0';
        end if;
    
  end procedure check_correct_bit;

  -----------------------------------------------------------------------------
  -- The main process that controls the behavior of the test bench
  fsm_proc : process (clk, rst_n)
  begin  -- process fsm_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)

      curr_state_r <= wait_start;

      sdat_old_r <= '0';
      sclk_old_r <= '0';

      byte_counter_r <= 0;
      bit_counter_r  <= bit_count_max_c - 1;
      param_counter_r <= 0;

      sdat_r <= 'Z';
      nack_r <= '0';
      
    elsif clk'event and clk = '1' then  -- rising clock edge

      -- The previous values are required for the edge detection
      sclk_old_r <= sclk;
      sdat_old_r <= sdat;


      -- Falling edge detection for acknowledge control
      -- Must be done on the falling edge in order to be stable during
      -- the high period of sclk
      if sclk = '0' and sclk_old_r = '1' then

        -- If we are supposed to send ack
        if curr_state_r = send_ack then
          
          check_correct_bit(byte_counter_r, bit_counter_r, param_counter_r, nack_r);
            
          if nack_r = '0' then
            
            -- Send ACK when number of param received is divisible by 4
            -- (low = ACK, high = NACK)
            sdat_r <= '0';
          
          else

            -- Send NACK
            sdat_r <= '1';
          end if;

        else

          -- Otherwise, sdat is in high impedance state.
          sdat_r <= 'Z';
          
        end if;
        
      end if;


      -------------------------------------------------------------------------
      -- FSM
      case curr_state_r is

        -----------------------------------------------------------------------
        -- Wait for the start condition
        when wait_start =>

          -- While clk stays high, the sdat falls
          if sclk = '1' and sclk_old_r = '1' and
            sdat_old_r = '1' and sdat = '0' then

            curr_state_r <= read_byte;

          end if;

          --------------------------------------------------------------------
          -- Wait for a byte to be read
        when read_byte =>

          -- Detect a rising edge
          if sclk = '1' and sclk_old_r = '0' then

            if bit_counter_r /= 0 then

              -- Normally just receive a bit
              bit_counter_r <= bit_counter_r - 1;

            else

              -- When terminal count is reached, let's send the ack
              curr_state_r  <= send_ack;
              bit_counter_r <= bit_count_max_c;
              
            end if;  -- Bit counter terminal count
            
          end if;  -- sclk rising clock edge

          --------------------------------------------------------------------
          -- Send acknowledge
        when send_ack =>

          -- Detect a rising edge
          if sclk = '1' and sclk_old_r = '0' then

            if byte_counter_r /= n_bytes_c-1 then
              
              -- Transmission continues
              byte_counter_r <= byte_counter_r + 1;
              curr_state_r   <= read_byte;

            else

              -- Transmission is about to stop
              byte_counter_r <= 0;
              curr_state_r   <= wait_stop;
              
            end if;

          end if;

          ---------------------------------------------------------------------
          -- Wait for the stop condition
        when wait_stop =>

          -- Stop condition detection: sdat rises while sclk stays high
          if sclk = '1' and sclk_old_r = '1' and
            sdat_old_r = '0' and sdat = '1' then
            
            curr_state_r <= wait_start;
            param_counter_r <= param_counter_r + 1;
            
          end if;

      end case;

    end if;
  end process fsm_proc;

  -----------------------------------------------------------------------------
  -- Asserts for verification
  -----------------------------------------------------------------------------

  -- SDAT should never contain X:s.
  assert sdat /= 'X' report "Three state bus in state X" severity error;

  -- End of simulation, but not during the reset
  assert finished = '1' or rst_n = '0' report
    "Simulation done" severity failure;
  
end testbench;

-------------------------------------------------------------------------------
-- Title      : Testbench for design "keyboard_buf"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : keyboard_buf_tb.vhd
-- Author     : 
-- Company    : 
-- Created    : 2013-10-07
-- Last update: 2013-10-07
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2013-10-07  1.0      svd04   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity keyboard_buf_tb is

end keyboard_buf_tb;

-------------------------------------------------------------------------------

architecture testb of keyboard_buf_tb is

  component keyboard_buf
    generic (
      NUM_DIGITS : integer);
    port (
      clk          : in  std_logic;
      reset        : in  std_logic;
      valid_number : in  std_logic;
      number       : in  std_logic_vector(3 downto 0);
      bcd          : out std_logic_vector(NUM_DIGITS*4-1 downto 0));
  end component;

  -- component generics
  constant NUM_DIGITS : integer := 3;

  -- component ports
  signal reset        : std_logic;
  signal valid_number : std_logic;
  signal number       : std_logic_vector(3 downto 0);
  signal bcd          : std_logic_vector(NUM_DIGITS*4-1 downto 0);

  -- clock
  signal Clk : std_logic := '1';

begin  -- testb

  -- component instantiation
  DUT : keyboard_buf
    generic map (
      NUM_DIGITS => NUM_DIGITS)
    port map (
      clk          => Clk,
      reset        => reset,
      valid_number => valid_number,
      number       => number,
      bcd          => bcd);

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    reset       <= '1';
    
    wait until Clk = '1';
    reset       <= '0';
    number      <= std_logic_vector(to_unsigned(2, 4));
    valid_number <= '1';

    wait until Clk = '1';
    number      <= std_logic_vector(to_unsigned(5, 4));
    valid_number <= '1';

    wait until Clk = '1';
    number      <= std_logic_vector(to_unsigned(5, 4));
    valid_number <= '1';

    wait until Clk = '1';

    wait until Clk = '1';


    
    
  end process WaveGen_Proc;

  

end testb;

-------------------------------------------------------------------------------

configuration keyboard_buf_tb_testb_cfg of keyboard_buf_tb is
  for testb
  end for;
end keyboard_buf_tb_testb_cfg;

-------------------------------------------------------------------------------

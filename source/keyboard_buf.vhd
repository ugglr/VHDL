-------------------------------------------------------------------------------
-- Title      : keyboard_buf
-- Project    : 
-------------------------------------------------------------------------------
-- File       : keyboard_buf.vhd
-- Author     : 
-- Company    : 
-- Created    : 2013-10-07
-- Last update: 2013-10-07
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Reads NUM_DIGITS from 8 bits input and saves it to bcd formated
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

entity keyboard_buf is
  
  generic (
    NUM_DIGITS : integer := 3
    );                                  -- number of digits to buffer

  port (
    clk          : in  std_logic;
    reset        : in  std_logic;
    valid_number : in  std_logic;
	 buf_clr      : in std_logic;
    number       : in  std_logic_vector(3 downto 0);
    bcd          : out std_logic_vector(NUM_DIGITS*4-1 downto 0)
    );                                  -- bcd output


end keyboard_buf;

architecture keyboard_buf_arch of keyboard_buf is
	signal internal_bcd : unsigned(NUM_DIGITS*4-1 downto 0);
	signal last_valid_number : std_logic;
	
begin  -- keyboard_buf_arch
  -- stare registers
  -- 
  -- outputs: 
  
  
  process (clk, reset, number, valid_number)
    variable digit_counter : integer := 0;
  begin  -- process
    if reset = '1' then                 -- asynchronous reset (active high)
      --bcd <= (others => '0');
		internal_bcd <= (others => '0');
		last_valid_number <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
	   if buf_clr = '1' then
			internal_bcd <= (others => '0');
		end if;
	 
		last_valid_number <= valid_number;
      if  last_valid_number = '0' and valid_number = '1' and unsigned(number) <= 9 then
		  internal_bcd <= (internal_bcd sll 4) + unsigned(number);
      end if;
		
    end if;
  end process;
  
  bcd <= std_logic_vector(internal_bcd);
  

end keyboard_buf_arch;

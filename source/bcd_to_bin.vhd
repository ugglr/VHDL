-------------------------------------------------------------------------------
-- Title      : BCD to Binary
-- Project    : 
-------------------------------------------------------------------------------
-- File       : bcd_to_bin.vhd
-- Author     : 
-- Company    : 
-- Created    : 2013-10-05
-- Last update: 2013-10-05
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2013-10-05  1.0      svd04   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity bcd_to_bin is

  generic (
    DIGIT_COUNT : integer := 3;
    OUTPUT_WIDTH: integer := 8
    );

  port (
    bcd    : in  std_logic_vector(DIGIT_COUNT*4-1 downto 0);
    binary : out std_logic_vector(OUTPUT_WIDTH-1 downto 0)
    );

end bcd_to_bin;

-------------------------------------------------------------------------------

architecture bcd_to_bin_arch of bcd_to_bin is

  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
	signal internal_out : std_logic_vector(8 downto 0);
begin  -- str

  conversion : process (bcd)
    variable output : integer := 0;
  begin  -- process convertion
    --for digit in 0 to DIGIT_COUNT-1 loop
    --  output := output + to_integer(unsigned(bcd((digit*4)+3 downto digit*4))) * (10 ** digit);
    --end loop;  -- digit
	--output := output + to_integer(unsigned(bcd(3 downto 0))) * (10 ** 0);
	--output := output + to_integer(unsigned(bcd(7 downto 4))) * (10 ** 1);
	--output := output + to_integer(unsigned(bcd(11 downto 8))) * (10 ** 2);
    
  --  if output > 2**OUTPUT_WIDTH then
  --    binary <= (others => '1');
  --    else
  --     binary <= std_logic_vector(to_unsigned(output, OUTPUT_WIDTH));
  --  end if;
    internal_out  <= std_logic_vector(to_unsigned(
	                                   to_integer(unsigned(bcd(3 downto 0))) + 
	                                   to_integer(unsigned(bcd(7 downto 4))) * (10) + 
	                                   to_integer(unsigned(bcd(11 downto 8))) * (100), OUTPUT_WIDTH+1));
  end process conversion;

	overflow: process(internal_out)
	begin
		if(internal_out(OUTPUT_WIDTH) = '1') then
			binary <= (others => '1');
		else
			binary <= internal_out(7 downto 0);
		end if;
	end process;
		

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------

end bcd_to_bin_arch;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Title      : SQRT Unit
-- Project    : 
-------------------------------------------------------------------------------
-- File       : alu_sqrt.vhd
-- Author     : 
-- Company    : 
-- Created    : 2013-10-08
-- Last update: 2013-10-11
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2013-10-08  1.0      svd04   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity zoom_register is
  port (
		clk       : in  std_logic;
		reset       : in std_logic;
		scancode     : in std_logic_vector(7 downto 0);
		valid_scancode    : in std_logic;
		zoom : out std_logic_vector(4 downto 0)
    );
end zoom_register;

architecture zoom_register_arch of zoom_register is
 
  constant ZOOM_IN     : std_logic_vector(7 downto 0) := X"37";  -- I
  constant ZOOM_OUT     : std_logic_vector(7 downto 0) := X"38";  -- O
  signal internal_zoom, next_internal_zoom : bit_vector(4 downto 0); 
  signal last_valid_scancode : std_logic;
  

  
  begin
  
	zoom <= To_StdLogicVector (internal_zoom);
	--	zoom <= internal_zoom;
  
  synchronous : process (clk, reset)
  begin  --  process  register
    if (reset = '1') then
		internal_zoom <= "10000";
		
    elsif (clk'event and clk = '1') then  --  rising  clock  edge
       internal_zoom <= next_internal_zoom;
	   last_valid_scancode <= valid_scancode;
		

    end if;
  end process;
  
  
  
  logic : process (last_valid_scancode, internal_zoom, valid_scancode)
  begin
  
  next_internal_zoom <= internal_zoom; 
  
	if(last_valid_scancode = '0' and valid_scancode = '1') then
		if(scancode = ZOOM_IN) then
			next_internal_zoom <= internal_zoom ror 1; 
		elsif(scancode = ZOOM_OUT) then
			next_internal_zoom <= internal_zoom rol 1; 
		end if;
	end if;
  end process;

end zoom_register_arch;
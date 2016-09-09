-------------------------------------------------------------------------------
-- Title      : binary_to_sg.vhd 
-- Project    : Keyboard VLSI Lab
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Description: 
-- 	            Simple Look-Up-Table	
-- 		
--
-------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;


entity binary_to_sg is
    port (
	     binary_in : in unsigned(3 downto 0);
	     sev_seg   : out unsigned(7 downto 0)
	 );
end binary_to_sg;

architecture binary_to_sg_arch of binary_to_sg is
begin

	lut : process(binary_in)
	begin
		case (binary_in) is
			when X"0" => sev_seg   <= "11000000";
			when X"1" => sev_seg   <= "11111001";
			when X"2" => sev_seg   <= "10100100";
			when X"3" => sev_seg   <= "10110000";
			when X"4" => sev_seg   <= "10011001";
			when X"5" => sev_seg   <= "10010010";
			when X"6" => sev_seg   <= "10000010";
			when X"7" => sev_seg   <= "11111000";
			when X"8" => sev_seg   <= "10000000";
			when X"9" => sev_seg   <= "10010000";
			
			--space bar
			when X"A" => sev_seg   <= "11111111";
			-- minus sign(-)
			when X"B" => sev_seg   <= "10111111";
			-- (o)verflow
			when X"C" => sev_seg   <= "10100011";
			
			when others => sev_seg <= "10000110"; --display E
		end case;
	end process;

end binary_to_sg_arch;

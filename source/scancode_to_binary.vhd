-------------------------------------------------------------------------------
-- Title      : convert_to_binary.vhd 
-- Project    : Keyboard VLSI Lab
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Description: 
--                      Look-up-Table
--       Error output is "1111"
--  Table is here: http://www.computer-engineering.org/ps2keyboard/scancodes2.html
-------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;


entity scancode_to_binary is
  port (
    scan_code_in : in  unsigned(7 downto 0);
    binary_out   : out std_logic_vector(3 downto 0)
    );
end scancode_to_binary;

architecture scancode_to_binary_arch of scancode_to_binary is
begin
  -- 

-- simple combinational logic using case statements (LUT) 
  lut : process(scan_code_in)
	variable mapped_value : unsigned(3 downto 0);
  begin
    case (scan_code_in) is
      when X"45" => mapped_value := X"0";
      when X"16" => mapped_value := X"1";
      when X"1E" => mapped_value := X"2";
      when X"26" => mapped_value := X"3";
      when X"25" => mapped_value := X"4";
      when X"2E" => mapped_value := X"5";
      when X"36" => mapped_value := X"6";
      when X"3D" => mapped_value := X"7";
      when X"3E" => mapped_value := X"8";
      when X"46" => mapped_value := X"9";

                    -- numpad
      when X"70" => mapped_value := X"0";
      when X"69" => mapped_value := X"1";
      when X"72" => mapped_value := X"2";
      when X"7A" => mapped_value := X"3";
      when X"6B" => mapped_value := X"4";
      when X"73" => mapped_value := X"5";
      when X"74" => mapped_value := X"6";
      when X"6C" => mapped_value := X"7";
      when X"75" => mapped_value := X"8";
      when X"7D" => mapped_value := X"9";

                    -- space bar => nothing
      when X"29" => mapped_value := X"A";

      when others => mapped_value := X"F";  --- means error
    end case;
	 binary_out <= std_logic_vector(mapped_value);
  end process;
end scancode_to_binary_arch;

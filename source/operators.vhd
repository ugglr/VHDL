library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package operators is
  constant OP_NULL  : std_logic_vector(2 downto 0) := "000";
  constant OP_MOD   : std_logic_vector(2 downto 0) := "100";
  constant OP_PLUS  : std_logic_vector(2 downto 0) := "010";
  constant OP_MINUS : std_logic_vector(2 downto 0) := "011";
  constant OP_TIMES : std_logic_vector(2 downto 0) := "110";
  constant OP_SQRT  : std_logic_vector(2 downto 0) := "101";
  constant OP_EQUAL : std_logic_vector(2 downto 0) := "111";
  constant OP_POINT : std_logic_vector(2 downto 0) := "001";
end operators;

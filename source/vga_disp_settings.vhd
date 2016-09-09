library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package vga_disp_settings is

  -- Global constants
  constant RESET_SYSTEM    : std_logic                    := '1';  -- Active high reset
  constant ROM_DEPTH       : integer                      := 33108;  -- The depth of picture ROM
  constant MESSAGE_START_H : integer                      := 0;  -- Horizontal start position of the message
  constant MESSAGE_START_V : integer                      := 0;  -- Vertical start position of the message
  constant MESSAGE_WIDTH   : integer                      := 640;  -- Width of the message
  constant MESSAGE_HEIGHT  : integer                      := 480;  -- Height of the message
  constant COLOR_RED       : std_logic_vector(2 downto 0) := "100";
  constant COLOR_GREEN     : std_logic_vector(2 downto 0) := "010";
  constant COLOR_BLUE      : std_logic_vector(2 downto 0) := "001";
  constant COLOR_BLACK     : std_logic_vector(2 downto 0) := "000";
  constant COLOR_WHITE     : std_logic_vector(2 downto 0) := "111";
  
end vga_disp_settings;

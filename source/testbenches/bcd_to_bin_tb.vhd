-------------------------------------------------------------------------------
-- Title      : Testbench for design "bcd_to_bin"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : bcd_to_bin_tb.vhd
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
-- 2013-10-05  1.0      svd04	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity bcd_to_bin_tb is

end bcd_to_bin_tb;

-------------------------------------------------------------------------------

architecture bc_to_bin_tb_arch of bcd_to_bin_tb is

  component bcd_to_bin
    generic (
      DIGIT_COUNT : integer);
    port (
      bcd    : in  std_logic_vector(DIGIT_COUNT*4-1 downto 0);
      binary : out std_logic_vector(7 downto 0));
  end component;

  -- component generics
  constant DIGIT_COUNT : integer := 3;

  -- component ports
  signal bcd    : std_logic_vector(DIGIT_COUNT*4-1 downto 0);
  signal binary : std_logic_vector(7 downto 0);

  -- clock
  signal Clk : std_logic := '1';

begin  -- bc_to_bin_tb_arch

  -- component instantiation
  DUT: bcd_to_bin
    generic map (
      DIGIT_COUNT => DIGIT_COUNT)
    port map (
      bcd    => bcd,
      binary => binary);

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    --         0   2   4 
    bcd <= "010000100100";
    wait until Clk = '1';
  end process WaveGen_Proc;

  

end bc_to_bin_tb_arch;

-------------------------------------------------------------------------------

configuration bcd_to_bin_tb_bc_to_bin_tb_arch_cfg of bcd_to_bin_tb is
  for bc_to_bin_tb_arch
  end for;
end bcd_to_bin_tb_bc_to_bin_tb_arch_cfg;

-------------------------------------------------------------------------------

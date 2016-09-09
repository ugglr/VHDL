-------------------------------------------------------------------------------
-- Title      : edge_detector.vhd 
-- Project    : Keyboard VLSI Lab
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Description: 
--                      Make sure not to use 'EVENT on anyother signals than clk
--                      
--
-------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;


entity edge_detector is
  port (
    clk         : in  std_logic;
    rst         : in  std_logic;
    kb_clk_sync : in  std_logic;
    edge_found  : out std_logic
    );
end edge_detector;


architecture edge_detector_arch of edge_detector is
  signal last_clk : std_logic;
begin
  synchronous : process (clk, rst)
  begin  --  process  register
    if (rst = '1') then                 --  asynchronous  reset  (active  high)
      last_clk <= '0';
    elsif (clk'event and clk = '1') then  --  rising  clock  edge
      last_clk <= kb_clk_sync;          --save kb clock in register 
    end if;
  end process;

  logic : process(last_clk, kb_clk_sync)
  begin
    
    if (last_clk = '1' and kb_clk_sync = '0') then
      edge_found <= '1';
    else
      edge_found <= '0';
    end if;
    
  end process;

end edge_detector_arch;

-------------------------------------------------------------------------------
-- Title      : scancode_reader.vhd 
-- Project    : Keyboard VLSI Lab
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Description: 
--                      Implement a shift register to convert serial to parallel
--                      A serial_in_counter to flag when the valid code is shifted in
--

-- thanks to http://www.bitweenie.com/listings/vhdl-shift-register/
-------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity scancode_reader is
  port (
    clk             : in  std_logic;
    rst             : in  std_logic;
    edge_found      : in  std_logic;
    serial_data     : in  std_logic;
    valid_scan_code : out std_logic;
    scancode_out    : out unsigned(7 downto 0)
    );
end scancode_reader;

architecture scancode_reader_arch of scancode_reader is
  signal bit_shift_reg     : std_logic_vector(9 downto 0);  --shift register where we store (from MSB to LSB): 
                                                    --Stop, parity bit, 7...1. Start is shifted out. 
  signal serial_in_counter : unsigned(3 downto 0);  --counts the bits coming into the shift register.
  signal symbol_counter    : unsigned(1 downto 0);  --counts the valid symbols read in. 

  constant WIDTH : integer := 11;  --constant for width of symbol sequence.
  

begin
  synchronous : process (clk, rst)
  begin  --  process  register
    if (rst = '1') then                 --  asynchronous  reset  (active  low)
      bit_shift_reg     <= (others => '0');
      serial_in_counter <= (others => '0');
      symbol_counter    <= (others => '0');
      
    elsif (clk'event and clk = '1') then  --  rising  clock  edge
      if edge_found = '1' then

        --shift the incoming bits from the left. 
        bit_shift_reg(8 downto 0) <= bit_shift_reg(9 downto 1);
        bit_shift_reg(9)          <= serial_data;

        --inc as long as we don´t have the whole symbol sequence
        if(serial_in_counter < WIDTH-1) then
          serial_in_counter <= serial_in_counter + 1;
          
        else  --- if a valid 8 bit sequence is in our register
          serial_in_counter <= (others => '0');
          if (symbol_counter < 2) then
            symbol_counter <= symbol_counter + 1;
          else
            symbol_counter <= (others => '0');
          end if;
          
        end if;
        
        
      end if;
    end if;
  end process;

  logic : process (bit_shift_reg, symbol_counter, serial_in_counter)
  begin
    scancode_out <= unsigned(bit_shift_reg(7 downto 0));

    --give out all characters, but activate valid_scan_code ONLY when the 
    --symbol is received, ignore "F0" and the repetition. 
    if symbol_counter = 1 and serial_in_counter = 0 then
      valid_scan_code <= '1';
    else
      valid_scan_code <= '0';
    end if;
    
  end process;
  
  
  
end scancode_reader_arch;

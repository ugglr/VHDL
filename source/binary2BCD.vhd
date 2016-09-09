library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
--use work.ALU_components_pack.all;

entity binary2BCD is
   port ( 
			binary_in : in  unsigned(7 downto 0);  -- binary input width
			BCD_out   : out std_logic_vector(9 downto 0)   -- BCD output, 10 bits [2|4|4] to display a 3 digit BCD value when input has length 8
        );
end binary2BCD;

  

architecture structural of binary2BCD is 

-- SIGNAL DEFINITIONS HERE IF NEEDED
	constant WIDTH : integer := 8; 
	

       --(c)2012 Enthusiasticgeek for Stack Overflow. 
    --Use at your own risk (includes commercial usage). 
    --These functions are released in the public domain and 
    --free to use as long as this copyright notice is retained.

    function to_bcd ( bin : unsigned(7 downto 0) ) return std_logic_vector is
        variable i : integer:=0;
        variable bcd : unsigned(11 downto 0) := (others => '0');
        variable bint : unsigned(7 downto 0) := bin;

        begin
        for i in 0 to 7 loop  -- repeating 8 times.
        bcd(11 downto 1) := bcd(10 downto 0);  --shifting the bits.
        bcd(0) := bint(7);
        bint(7 downto 1) := bint(6 downto 0);
        bint(0) :='0';


        if(i < 7 and bcd(3 downto 0) > "0100") then --add 3 if BCD digit is greater than 4.
        bcd(3 downto 0) := bcd(3 downto 0) + "0011";
        end if;

        if(i < 7 and bcd(7 downto 4) > "0100") then --add 3 if BCD digit is greater than 4.
        bcd(7 downto 4) := bcd(7 downto 4) + "0011";
        end if;

        if(i < 7 and bcd(11 downto 8) > "0100") then  --add 3 if BCD digit is greater than 4.
        bcd(11 downto 8) := bcd(11 downto 8) + "0011";
        end if;

    end loop;
    return std_logic_vector(bcd);
    end to_bcd;

begin  
	BCD_out <= (to_bcd(binary_in)(9 downto 0));
	-- DEVELOPE YOUR CODE HERE
	-- process (binary_in)
	-- variable internal_BCD_out: unsigned(11 downto 0) := (others => '0');
	-- variable binary_in_loc: unsigned(7 downto 0);
	-- variable digit: integer := 0;
	-- begin
		
		-- binary_in_loc := unsigned(binary_in);
		
		-- for digit in 0 to WIDTH-1 loop
			-- shift one bit
			-- internal_BCD_out(9 downto 1) := internal_BCD_out(8 downto 0);
			-- internal_BCD_out(0) := binary_in_loc(WIDTH-1-digit); 
			
			-- internal_BCD_out(11 downto 1) := internal_BCD_out(10 downto 0);  --shifting the bits.
			-- internal_BCD_out(0) := binary_in_loc(7);
			-- binary_in_loc(7 downto 1) := binary_in_loc(6 downto 0);
			-- binary_in_loc(0) :='0';

		    -- check if in any of the columns the binary value is bigger than 4 and add 3 if true. 
		    -- units column
			-- if (internal_BCD_out(3 downto 0) > "0100") then
				-- internal_BCD_out(3 downto 0) := internal_BCD_out(3 downto 0) + 3;
			-- end if;
			-- tens column
			-- if (internal_BCD_out(7 downto 4) > "0100") then
				-- internal_BCD_out(7 downto 4) := internal_BCD_out(7 downto 4) + 3;
			-- end if;
			-- if (internal_BCD_out(11 downto 8) > "0100") then
				-- internal_BCD_out(11 downto 8) := internal_BCD_out(11 downto 8) + 3;
			-- end if;
		  
			
		-- end loop;
		-- BCD_out <= std_logic_vector(internal_BCD_out(9 downto 0));
		
	-- end process;


end structural;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_bank is
   port ( 
			reg_ctrl     : in std_logic_vector (1 downto 0);   -- Register update control from ALU controller
			reg_ctrl_mem : in std_logic_vector (1 downto 0);
			clk 		    : in std_logic; 
			reset		    : in std_logic; 
			reg_clr      : in std_logic;
			input      	 : in std_logic_vector (7 downto 0);   -- Switch inputs
			A          	 : out std_logic_vector (7 downto 0);   -- Input A
			FN        	 : out std_logic_vector (3 downto 0);   -- operator
			B          	 : out std_logic_vector (7 downto 0);  -- Input B
			mem_wr_data  : out std_logic_vector (7 downto 0)   -- Input B
        );
end reg_bank;

architecture behavioral of reg_bank is

-- SIGNAL DEFINITIONS HERE IF NEEDED

	signal internal_A, internal_B :  std_logic_vector (7 downto 0);
	signal internal_FN :  std_logic_vector (3 downto 0);
begin
	A <= internal_A;
	B <= internal_B;
	 FN <= internal_FN;

	synchronous : process (clk, reset, input)
	begin    --  process  register
		if(reset = '1') then 
			internal_A <= input; 
			internal_B <= X"00";
			internal_FN <= X"0";
		elsif(clk'event and clk = '1') then 
			if reg_clr = '1' then
				internal_A <= X"00"; 
				internal_B <= X"00";
				internal_FN <= X"0";
			end if;
			
			case reg_ctrl is
				when "10" => 
					internal_A <= input;
				when "11" =>
					internal_B <= input;
				when "01" =>
					internal_FN <= input(3 downto 0);
				when others => null;
			end case;
		end if; 

	end  process;
	
	
	process (reg_ctrl_mem, internal_A, internal_B, internal_FN)
	begin
				case reg_ctrl_mem is
				when "10" => 
					mem_wr_data <= internal_A;
				when "11" =>
					mem_wr_data <= internal_B;
				when "01" =>
					mem_wr_data <= "0000" & internal_FN;
				when others =>
				   mem_wr_data <= (others => '0');
			end case;
	end process;
   -- DEVELOPE YOUR CODE HERE

end behavioral;

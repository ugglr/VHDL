library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.operators.all;

entity ALU is
   port ( 
			clk  		: in std_logic; 
			rst			: in std_logic; 
			A          	: in  std_logic_vector (7 downto 0);   -- Input A
			B          	: in  std_logic_vector (7 downto 0);   -- Input B
			FN         	: in  std_logic_vector (3 downto 0);   -- ALU functions provided by the ALU_Controller (see the lab manual)
			result 	   	: out std_logic_vector (17 downto 0);   -- ALU output (unsigned binary)
			--overflow   	: out std_logic;                       -- '1' if overflow ocurres, '0' otherwise 
			sign       	: out std_logic                        -- '1' if the result is a negative value, '0' otherwise
		--	error    	: out std_logic
			);
end ALU;

architecture behavioral of ALU is

	component alu_sqrt is
	  port (
			clk       : in  std_logic;
			reset     : in std_logic;
			input     : in std_logic_vector(7 downto 0);
			output    : out std_logic_vector(17 downto 0)
		);
	end component;
	
	


-- SIGNAL DEFINITIONS HERE IF NEEDED

	--signals for the mod3 operator
	signal shift6, shift4, shift2a, shift2b: unsigned(8 downto 0);
	signal internal_result, internal_A, internal_B : std_logic_vector (8 downto 0);
	signal sqrt_result : std_logic_vector (17 downto 0);
begin

	Inst_alu_sqrt: alu_sqrt PORT MAP(
		clk => clk,
		reset => rst,
		input => A,
		output => sqrt_result
	);

	internal_A <= '0' & A(7 downto 0);
	

	-- x = ( x >> 6 ) + (x & 3F)
	shift6  <= (unsigned(internal_A) srl 6) + (unsigned(internal_A) and '0' & X"3F");
	-- x = ( x >> 6 ) + (x & 3F)
	shift4  <= (shift6 srl 4) + (shift6 and '0' & X"0F");
	-- x = ( x >> 6 ) + (x & 3F)
	shift2a <= (shift4 srl 2) + (shift4 and '0' &  X"03");
	-- x = ( x >> 6 ) + (x & 3F)
	shift2b <= (shift2a srl 2) + (shift2a and '0' &  X"03");
	

	
	-- 2er compliment for substraction operation on B
	process (B, FN(1 downto 0))
	begin
		if FN(1 downto 0) = "11" then
			internal_B <= std_logic_vector(unsigned(not('0' & B))+1);
		else
			internal_B <= '0' & B(7 downto 0);
		end if;
	end process;
	
   process ( FN, shift2b, internal_A, internal_B)
   begin
		--error <= '0';
   
		case  FN  is
			-- A+B (unsigned)
			when  "0" & OP_PLUS  =>
				internal_result <=  std_logic_vector(unsigned(internal_A) + unsigned(internal_B));
			-- A-B (unsigned)
			when  "0" & OP_MINUS  =>
				internal_result <=  std_logic_vector(unsigned(internal_A) + unsigned(internal_B));
			-- A mod 3 (unsigned)
			when  "0" & OP_MOD  =>
				if shift2b = 3 then
					internal_result <= (others => '0');
				else
					internal_result <= std_logic_vector(shift2b);
				end if;
			when  "0" & OP_TIMES  =>
				internal_result <= std_logic_vector(unsigned(internal_A)*unsigned(internal_B));
			when  "0" & OP_SQRT  =>
				internal_result <= (others => '0');
				
			when others => internal_result <= (others => '0');
--						   error <= '1';
		end case;
		

   end process;
   
   process(internal_result, FN(2 downto 0), sqrt_result)
   begin
		--output of signed bit
		if FN(2 downto 0) = OP_MINUS and internal_result(8) = '1' then
			sign <= '1';
			--abs value
			result <= std_logic_vector(unsigned(not(internal_result(7 downto 0)))+1) & "0000000000";
		elsif FN(2 downto 0) = OP_SQRT then
			result <= sqrt_result;
			sign <= '0';
		else
			sign <= '0';
			if unsigned(internal_result) > 255 then
				result <= (others => '1');
			else
				result <= internal_result(7 downto 0) & "0000000000";
			end if;
		end if;
   end process;
   
--	process(internal_result(8), internal_result(7), internal_A(7), internal_B(7), FN(3), FN(1 downto 0))
--	begin
--		if FN(3) = '1' and (FN(1 downto 0) = "10" or FN(1 downto 0) = "11") then --signed mode
--			if  (internal_A(7) = '0' and internal_B(7) = '0' and internal_result(7) = '1') or
--			    (internal_A(7) = '1' and internal_B(7) = '1' and internal_result(7) = '0') then
--				overflow <= '1';
--			else
--				overflow <= '0';
--			end if;
--		else --unsigned mode
--			overflow <= internal_result(8);
--		end if;
--	end process;
	
	
	

end behavioral;

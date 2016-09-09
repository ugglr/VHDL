library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.operators.all;

entity alu_tb is

end alu_tb;


architecture structural of alu_tb is



	COMPONENT alu_sqrt
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		input : IN std_logic_vector(7 downto 0);          
		output : OUT std_logic_vector(17 downto 0)
		);
	END COMPONENT;

	COMPONENT ALU
	   port ( 
				clk  		: in std_logic; 
				rst			: in std_logic; 
				A          	: in  std_logic_vector (7 downto 0);   -- Input A
				B          	: in  std_logic_vector (7 downto 0);   -- Input B
				FN         	: in  std_logic_vector (3 downto 0);   -- ALU functions provided by the ALU_Controller (see the lab manual)
				result 	   	: out std_logic_vector (17 downto 0);   -- ALU output (unsigned binary)
				overflow   	: out std_logic;                       -- '1' if overflow ocurres, '0' otherwise 
				sign       	: out std_logic;                        -- '1' if the result is a negative value, '0' otherwise
				error    	: out std_logic
				);
	END COMPONENT;
	
	component CLOCKGENERATOR is
		generic( clkhalfperiod :time  );
		port( clk : out std_logic);
	end component;
	
	signal clk, rst      : std_logic;
	signal output : STD_LOGIC_VECTOR ( 17 downto 0 ); 
	signal input : STD_LOGIC_VECTOR ( 7 downto 0 ); 
	
	constant period   : time := 25 ns;

	
	begin  -- structural
   
	Inst_alu_sqrt: ALU PORT MAP(
		clk => clk,
		rst => rst,
		A => input,
		B => (others => '0'),
		FN => "0" & OP_SQRT,
		result => output
	);


	CLOCKGEN : clockgenerator
		generic map (clkhalfperiod => period*0.25)
		port map (clk              => clk);
   
   -- *************************
   -- User test data pattern
   -- *************************
   
   rst <= '1',
            '0' after 0.25 *period;
            -- "IIIIIIIIFFFFFFFFFF"
    input <= "00000000",
          	 std_logic_vector(to_unsigned(64,8)) after period;


end structural; 
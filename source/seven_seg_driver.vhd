library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_seg_driver is
   port ( clk           : in  std_logic;
          reset         : in  std_logic;
          BCD_digit     : in  std_logic_vector(9 downto 0);          
          sign          : in  std_logic;
          overflow      : in  std_logic;
		  error			: in std_logic; 
          DIGIT_ANODE   : out std_logic_vector(3 downto 0);
          SEGMENT       : out unsigned(7 downto 0)
        );
end seven_seg_driver;


architecture behavioral of seven_seg_driver is

	component binary_to_sg is
	port (
			 binary_in : in unsigned(3 downto 0);
			 sev_seg   : out unsigned(7 downto 0)
		 );
	end component;

-- SIGNAL DEFINITIONS HERE IF NEEDED
	signal output_ptr: unsigned(15 downto 0); --needed to slow down the clock
	signal en_cnt: unsigned(1 downto 0); --2 MSB bits of output_ptr.
	signal code_to_display: unsigned(3 downto 0);

begin

	binary_to_sg_inst: binary_to_sg
    port map ( 
		 binary_in => code_to_display,
		 sev_seg => SEGMENT
        );

	en_cnt <= output_ptr(15) & output_ptr(14);
	
	process (clk, reset)
	begin
		if (reset = '1') then 
			output_ptr <= (others => '0');
		elsif (clk'event  and  clk  =  '1')  then
				output_ptr <= output_ptr + 1;
		end if;
	end process;
	
	
	process (en_cnt, sign, overflow, error, BCD_digit)
	begin
		case(en_cnt) is
			--select the right display and display the corresponding buffer content. 
			when "00" => DIGIT_ANODE   <= "0111";
			    --signed or unsigned or error
				--code_to_display <= ;
				if (sign = '1') then 
					code_to_display <= X"B";
				elsif (overflow = '1') then 
					code_to_display <= X"C";
				elsif (error = '1') then 
					code_to_display <= X"F";
				else		
					code_to_display <= X"A";
				end if; 
			when "01" =>
			    DIGIT_ANODE   <= "1011";
				code_to_display <= unsigned("00" & BCD_digit(9 downto 8));
			when "10" =>
			    DIGIT_ANODE   <= "1101";
				code_to_display <= unsigned(BCD_digit(7 downto 4));
			when "11" =>
			    DIGIT_ANODE   <= "1110";
				code_to_display <=  unsigned(BCD_digit(3 downto 0));
			when others => DIGIT_ANODE <= "0000";
		end case; 
	end process; 
-- DEVELOPE YOUR CODE HERE

end behavioral;

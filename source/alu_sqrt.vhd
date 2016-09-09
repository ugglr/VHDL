-------------------------------------------------------------------------------
-- Title      : SQRT Unit
-- Project    : 
-------------------------------------------------------------------------------
-- File       : alu_sqrt.vhd
-- Author     : 
-- Company    : 
-- Created    : 2013-10-08
-- Last update: 2013-10-11
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2013-10-08  1.0      svd04   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity alu_sqrt is
  port (
		clk       : in  std_logic;
		reset       : in std_logic;
		input     : in std_logic_vector(7 downto 0);
		output    : out std_logic_vector(17 downto 0)
    );
end alu_sqrt;

architecture alu_sqrt_arch of alu_sqrt is
	component divider_the_second is
	  port (
		rfd : out STD_LOGIC; 
		clk : in STD_LOGIC := 'X'; 
		dividend : in STD_LOGIC_VECTOR ( 17 downto 0 ); 
		quotient : out STD_LOGIC_VECTOR ( 17 downto 0 ); 
		divisor : in STD_LOGIC_VECTOR ( 17 downto 0 ); 
		fractional : out STD_LOGIC_VECTOR ( 9 downto 0 ) 
	  );
	end component;


  type state_type is (idle, iter_init, iter_step_a, iter_step_b);
  signal current_state, next_state: state_type;
  signal iter_counter, wait_counter : integer;
  signal xn, xn_n, xn1, xn1_n: unsigned(17 downto 0);
  
  
  signal last_input: std_logic_vector(7 downto 0);
  
  -- div unit
  signal dividend, divisor:  unsigned ( 17 downto 0 ); 
  signal quotient : std_logic_vector  ( 17 downto 0 ); 
  signal fractional : std_logic_vector ( 9 downto 0 ); 
  
  
  
	constant ITERATIONS      : integer := 6;
	constant DIV_WAIT_TIME   : integer := 18+10+3;
	constant TIMES_05        : unsigned(8 downto 0) := "100000000";
  
  function iter_init_lut(input : std_logic_vector(7 downto 0)) return integer is
  begin
	 if unsigned(input) < 32 then
		return 5;
	 elsif unsigned(input) < 81 then
	   return 9;
	 else
	    return 16;
	 end if;
	  
  end iter_init_lut;
  
  begin
  
   devider: divider_the_second
   port map ( clk       => clk,
              dividend	        => std_logic_vector(dividend),
              quotient    		=> quotient,
              divisor     => std_logic_vector(divisor),
			  fractional   => fractional
            );
  
  synchronous : process (clk, reset)
  begin  --  process  register
    if (reset = '1') then
		iter_counter <= 0;
		wait_counter <= 0;
		current_state <= idle;
		--xn <= (others => '0');
		--xn1 <= (others => '0');
		xn1 <= to_unsigned(0, 18);
		xn <= to_unsigned(0, 18);
		last_input <= (others => '0');
		
    elsif (clk'event and clk = '1') then  --  rising  clock  edge
      current_state <= next_state;
		xn <= xn_n;
		xn1 <= xn1_n;
		last_input <= input;
	  
	  if current_state = iter_step_b then
		iter_counter <= iter_counter + 1;
	  elsif current_state = iter_init then
	    iter_counter <= 0;
	  end if;
	  
	   if current_state /= next_state then
			wait_counter <= 0;
		else 
			wait_counter <= wait_counter + 1;
		end if;
    end if;
  end process;
  
  output <= std_logic_vector(xn);
  
  logic : process (current_state, xn, xn1, input, quotient, last_input, wait_counter, iter_counter, fractional)
  variable time05_result : unsigned(26 downto 0) := (others => '0');
  variable xn_concat : unsigned(17 downto 0) := (others => '0');
  begin
    -- keep happy values happy
	next_state <= current_state;
  	xn_n <= xn;
	xn1_n <= xn1;
	
	divisor <= (others => '0');
	dividend <= (others => '0');
	 
    case current_state is
      when idle => 
		if last_input /= input then
			next_state <= iter_init;
		end if;
	   when iter_init =>
	        xn1_n <= to_unsigned(iter_init_lut(input),8) & "0000000000";
		    next_state <= iter_step_a;
		when iter_step_a =>
		   dividend <= unsigned(input) & "0000000000";
		   divisor <= xn1;
		   if wait_counter > DIV_WAIT_TIME then
		      next_state <= iter_step_b;
			end if;
		when iter_step_b =>
		   xn_concat := (unsigned(quotient(7 downto 0)) & unsigned(fractional)) + xn1;
			--time05_result := * (unsigned(xn1)+xn_concat);
		    --xn_n <= "0" & xn_concat(16 downto 0); -- div by 2
			--xn1_n <= "0" & xn_concat(16 downto 0);
			xn1_n <="0" & xn_concat(17 downto 1);
			xn_n <= "0" & xn_concat(17 downto 1);
			
			if iter_counter >= ITERATIONS then
				next_state <= idle;
			else
				next_state <=iter_step_a;
			end if;
	end case;
  end process;

end alu_sqrt_arch;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.operators.all;

entity alu_ctrl is
  port (clk             : in  std_logic;
        reset           : in  std_logic;
        valid_scan_code : in  std_logic;
        scancode_in     : in  std_logic_vector(7 downto 0);
        FN              : out std_logic_vector (3 downto 0);  -- ALU functions
        kb_buf_clr      : out std_logic;  -- Keyboard buffer clearer
        mem_addr        : out std_logic_vector (12 downto 0);
        mem_wea         : out std_logic;  -- memory write enable
        reg_ctrl        : out std_logic_vector(1 downto 0);
		  reg_ctrl_mem    : out std_logic_vector(1 downto 0);
        reg_clr         : out std_logic;
        reg_sel_src     : out std_logic_vector(2 downto 0)
        );
end alu_ctrl;

architecture behavioral of alu_ctrl is
  type state_type is (init, a_inp, a_save, save_addr_incr, op_save, b_inp, b_inp_mod3, b_inp_sqrt, b_save, final_addr_incr, a_load, b_load, op_load, incr_addr, b_addr_incr, load_op_addr_incr, load_a_addr_incr, load_b_addr_incr);
  signal current_state, next_state : state_type;
  signal wait_counter : integer; 
    signal mem_rd_addr, mem_wr_addr : unsigned (12 downto 0);
	 signal mem_wr_addr_incr : unsigned (3 downto 0);
	 signal mem_rd_addr_incr : integer;
	 signal last_valid_scancode: std_logic;
  --signal internal_FN : std_logic_vector (3 downto 0); 
  
  constant plus_op : std_logic_vector(7 downto 0) := X"79";  -- "+" on keypad
  constant minus_op   : std_logic_vector(7 downto 0) := X"7B";  -- "-" on keypad
  constant times_op   : std_logic_vector(7 downto 0) := X"7C";  -- "*" on keypad
  constant mod_op     : std_logic_vector(7 downto 0) := X"3A";  -- "M"
  constant sqrt_op    : std_logic_vector(7 downto 0) := X"1B";  -- "S"
  constant enter      : std_logic_vector(7 downto 0) := X"5A";  -- "Enter" on keypad
  constant arrow_up   : std_logic_vector(7 downto 0) := X"1C";  -- A
  constant arrow_down : std_logic_vector(7 downto 0) := X"1A";  -- Z
  constant escape     : std_logic_vector(7 downto 0) := X"76";  -- ESC
  

  function scancode_to_fn(scancode : std_logic_vector(7 downto 0)) return std_logic_vector is
  begin
    
    case (scancode) is
      when plus_op  => return OP_PLUS;
      when minus_op => return OP_MINUS;
      when times_op => return OP_TIMES;
      when sqrt_op  => return OP_SQRT;
      when mod_op   => return OP_MOD;
      when others   => return OP_NULL;
    end case;
  end scancode_to_fn;

-- SIGNAL DEFINITIONS HERE IF NEEDED
  
begin
  --TODO: memory address assigment
  synchronous : process (clk, reset)
  begin  --  process  register
    if (reset = '1') then               --  asynchronous  reset  (active  low)
      current_state <= init;
		wait_counter <= 0;
		mem_rd_addr  <= (others => '0');
		mem_wr_addr <= (others => '0');
		last_valid_scancode <= '0';
		
	  --internal_FN <= (others => '0');
    elsif (clk'event and clk = '1') then  --  rising  clock  edge
		if current_state /= next_state then
			wait_counter <= 0;
		else 
			wait_counter <= wait_counter + 1;
		end if;
		
		mem_rd_addr <= mem_rd_addr + mem_rd_addr_incr;
		mem_wr_addr <= mem_wr_addr + mem_wr_addr_incr;
      current_state <= next_state;
		last_valid_scancode <= valid_scan_code;
		
			
	  --if valid_scan_code = '1' then 
		--internal_FN <= scancode_to_fn(scancode_in); 
	  --end if; 
    end if;
  end process;

  logic : process (current_state, valid_scan_code, mem_wr_addr, scancode_in, mem_rd_addr, wait_counter, last_valid_scancode)
    


    
	--variable internal_FN : std_logic_vector (3 downto 0) := "0000"; 

  begin
    
    next_state  <= current_state;
    FN          <= (others => '0');
    kb_buf_clr  <= '0';
    mem_addr    <= std_logic_vector(mem_wr_addr);
    mem_wea     <= '0';
    reg_clr     <= '0';
    reg_sel_src <= "001";
	 reg_ctrl_mem  <= "00";
    reg_ctrl    <= (others => '0');
    --mem_rd_addr := (others => '0');
    --mem_wr_addr := (others => '0');
	  mem_rd_addr_incr <= 0;
	  mem_wr_addr_incr <= (others => '0');

    case current_state is
      
      when init =>
        next_state  <= a_inp;
        reg_clr     <= '1';
		  kb_buf_clr  <= '1';
		
      when a_inp =>
        if (scancode_in = plus_op or
            scancode_in = minus_op or
				scancode_in = times_op or
				scancode_in = mod_op or
				scancode_in = sqrt_op) and valid_scan_code = '1' then
          next_state <= a_save;
        elsif (scancode_in = arrow_up) and valid_scan_code = '1' then
          next_state  <= b_load;
			 mem_rd_addr_incr <= to_integer((mem_wr_addr-mem_rd_addr-1));
		    mem_addr <= std_logic_vector(mem_rd_addr);
        end if;
        reg_ctrl <= "10";
		kb_buf_clr <= '0';
		reg_clr     <= '0';
		--reg_ctrl_mem  <= "10";
        
      when a_save =>
				next_state <= save_addr_incr;
        mem_wea    <= '1';
        mem_addr   <= std_logic_vector(mem_wr_addr);
        reg_ctrl   <= "00";
		  reg_ctrl_mem  <= "10";
        
      when save_addr_incr =>
        next_state  <= op_save;
		  mem_wr_addr_incr <= to_unsigned(1, 13);
        kb_buf_clr  <= '1';
        mem_wea     <= '0';
        
      when op_save =>
		
		  if wait_counter > 2 then
			  if scancode_in = mod_op then
			    next_state <= b_inp_mod3;
			  elsif scancode_in = sqrt_op then
				 next_state <= b_inp_sqrt;
			  else
				 next_state <= b_inp;
			  end if;
			 end if;
        mem_wea    <= '1';
        kb_buf_clr <= '1'; 
        reg_ctrl   <= "01";
		  reg_sel_src <= "000";
		  FN <= "0"&scancode_to_fn(scancode_in);
		  reg_ctrl_mem  <= "01";
		  
		  
        
      when b_inp =>
        if (scancode_in = enter) and valid_scan_code = '1' then
          next_state <= b_addr_incr;
        end if;
        mem_wea    <= '0';
        reg_ctrl   <= "11";
		
		when b_inp_mod3 =>
        if (scancode_in = enter) and valid_scan_code = '1' then
          next_state <= b_addr_incr;
        end if;
        --mem_wea    <= '1';
        reg_ctrl   <= "11";
		  reg_sel_src <= "011";
		
		when b_inp_sqrt =>
        if (scancode_in = enter) and valid_scan_code = '1' then
          next_state <= b_addr_incr;
        end if;
        --mem_wea    <= '0';
        reg_ctrl   <= "11";
		  reg_sel_src <= "100";
        
      when b_addr_incr =>
        next_state  <= b_save;
        mem_wr_addr_incr <= X"1";
        
      when b_save =>
        next_state <= final_addr_incr;
        mem_wea    <= '1';
        mem_addr   <= std_logic_vector(mem_wr_addr);
        reg_ctrl   <= "00";
		  reg_ctrl_mem  <= "11";
        
      when final_addr_incr =>
        next_state  <= a_inp;
        mem_wr_addr_incr <= X"1";
        reg_clr     <= '1';
		  kb_buf_clr <= '1';
        
      when b_load =>
			if wait_counter >= 4 then
			  --if scancode_in = escape and valid_scan_code = '1' then
				 --next_state <= init;
			  --if mem_rd_addr > 250 then
				--	mem_rd_addr_incr <= to_integer(mem_wr_addr);
			  --elsif mem_rd_addr >= mem_wr_addr then
				--	mem_rd_addr_incr <= -to_integer(mem_rd_addr-1);
			  --end if;
			 next_state <= load_op_addr_incr;
			 end if;
        reg_sel_src <= "010";
        reg_ctrl    <= "11";
        mem_addr    <= std_logic_vector(mem_rd_addr);
		  --kb_buf_clr  <= '1';
        --reg_clr     <= '1';
		  
			
		when load_op_addr_incr =>
			mem_rd_addr_incr <= -1;
			mem_addr    <= std_logic_vector(mem_rd_addr);
			next_state <= op_load;
        
      when op_load =>
		  if wait_counter > 1 then
          next_state  <= load_a_addr_incr;
		  end if;
        mem_addr    <= std_logic_vector(mem_rd_addr);
        reg_ctrl    <= "01";
        reg_clr     <= '0';
		  reg_sel_src <= "010";
        --what to do with the operator we read in? !!!!!!!!!!!!!!!! TO DO !!!!!!!!!!!!!!!!
		  
		when load_a_addr_incr =>
			mem_rd_addr_incr <= -1;
			mem_addr    <= std_logic_vector(mem_rd_addr);
			next_state  <= a_load;
			
      when a_load =>
        if (scancode_in = arrow_up) and valid_scan_code = '1' and last_valid_scancode = '0' then
          next_state <= load_b_addr_incr;
			 
        elsif (scancode_in = arrow_down) and valid_scan_code = '1' and last_valid_scancode = '0' then
          next_state <= incr_addr;
        elsif scancode_in = escape and valid_scan_code = '1' and last_valid_scancode = '0' then
          next_state <= init;
        end if;

        mem_addr    <= std_logic_vector(mem_rd_addr);
        reg_ctrl    <= "10";
		  reg_sel_src <= "010";


		when load_b_addr_incr =>
		if mem_rd_addr <= 0 then
			mem_rd_addr_incr <= to_integer(mem_wr_addr-1);
		else
			mem_rd_addr_incr <= -1;
		end if;  
		mem_addr    <= std_logic_vector(mem_rd_addr);
		next_state  <= b_load;
		 
      when incr_addr =>
		if mem_rd_addr = mem_wr_addr-3 then
			mem_rd_addr_incr <= -to_integer(mem_wr_addr-5);
		else
		  mem_rd_addr_incr <= 5;
		end if;
      next_state  <= b_load;
      mem_addr    <= std_logic_vector(mem_rd_addr);
        
        
      when others => null;
                     
    end case;
  end process;

end behavioral;

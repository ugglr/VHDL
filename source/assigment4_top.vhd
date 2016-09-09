-------------------------------------------------------------------------------
-- Title      : Assigment 4 & 5 Top -the calculator
-- Project    : 
-------------------------------------------------------------------------------
-- File       : assigment4_top.vhd
-- Author     : 
-- Company    : 
-- Created    : 2013-10-08
-- Last update: 2013-10-11
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: The Calculator
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

entity assigment4_top is
  port (
    clk_board : in  std_logic;
    rst_board : in  std_logic;
    kb_data   : in  std_logic;
    kb_clk    : in  std_logic;
    --seg_en    : out std_logic_vector(3 downto 0);  -- 7-Segment enable
    --seg_num   : out unsigned(7 downto 0);          -- 7-Segment display
    --leds      : out std_logic_vector(7 downto 0);  -- LEDs
    vga_rgb   : out std_logic_vector(2 downto 0);
    vga_vs    : out std_logic;
    vga_hs    : out std_logic
    );
end assigment4_top;

architecture assigment4_top_arch of assigment4_top is
  constant NUM_DIGITS : integer := 3;  -- we operate with 3 digits at input and display
  constant NUM_BITS   : integer := 8;   -- On how many bits do we operate?

  component clock_gen is
    port (clkin_in        : in  std_logic;
          rst_in          : in  std_logic;
          clkdv_out       : out std_logic;
          clkin_ibufg_out : out std_logic;
          clk0_out        : out std_logic;
          locked_out      : out std_logic
          );
  end component;

  component sync_keyboard
    port (
      clk          : in  std_logic;
      kb_clk       : in  std_logic;
      kb_data      : in  std_logic;
      kb_clk_sync  : out std_logic;
      kb_data_sync : out std_logic);
  end component;

  component edge_detector
    port (
      clk         : in  std_logic;
      rst         : in  std_logic;
      kb_clk_sync : in  std_logic;
      edge_found  : out std_logic);
  end component;

  component scancode_reader
    port (
      clk             : in  std_logic;
      rst             : in  std_logic;
      edge_found      : in  std_logic;
      serial_data     : in  std_logic;
      valid_scan_code : out std_logic;
      scancode_out    : out unsigned(7 downto 0));
  end component;

  component keyboard_buf
    generic (
      NUM_DIGITS : integer);
    port (
      clk          : in  std_logic;
      reset        : in  std_logic;
      valid_number : in  std_logic;
		buf_clr  : in std_logic;
      number       : in  std_logic_vector(3 downto 0);
      bcd          : out std_logic_vector(NUM_DIGITS*4-1 downto 0));
  end component;

  component scancode_to_binary
    port (
      scan_code_in : in  unsigned(7 downto 0);
      binary_out   : out std_logic_vector(3 downto 0));
  end component;

  component bcd_to_bin
    generic (
      DIGIT_COUNT  : integer := NUM_DIGITS; 
      OUTPUT_WIDTH : integer
      );
    port (
      bcd    : in  std_logic_vector(DIGIT_COUNT*4-1 downto 0);
      binary : out std_logic_vector(OUTPUT_WIDTH-1 downto 0));
  end component;

  component reg_bank
    port (
      reg_ctrl : in  std_logic_vector (1 downto 0);
      clk      : in  std_logic;
      reset    : in  std_logic;
		reg_clr  : in  std_logic;
		reg_ctrl_mem : in  std_logic_vector (1 downto 0);
		mem_wr_data : out std_logic_vector (7 downto 0);
      input    : in  std_logic_vector (7 downto 0);
      A        : out std_logic_vector (7 downto 0);
		FN       : out std_logic_vector (3 downto 0);
      B        : out std_logic_vector (7 downto 0));
  end component;

  component ALU
    port (
	   clk      : in std_logic;
		rst      : in std_logic;
      A        : in  std_logic_vector (7 downto 0);
      B        : in  std_logic_vector (7 downto 0);
      FN       : in  std_logic_vector (3 downto 0);
      result   : out std_logic_vector (17 downto 0);
      --overflow : out std_logic;
      sign     : out std_logic);
   --   error    : out std_logic);
  end component;

  component vga_disp
    port (
      clk_sys : in  std_logic;
      rst_sys : in  std_logic;
      A       : in  std_logic_vector(9 downto 0);
      B       : in  std_logic_vector(9 downto 0);
      result  : in  std_logic_vector(21 downto 0);
      sign    : in  std_logic;
      FN      : in  std_logic_vector(2 downto 0);
      hs      : out std_logic;
      vs      : out std_logic;
      rgb     : out std_logic_vector (2 downto 0)--;
		--seg_width_in : in std_logic_vector(4 downto 0)
		);
  end component;

  --component binary2BCD
   -- port (
   --   binary_in : in  unsigned(7 downto 0);
   --   BCD_out   : out std_logic_vector(9 downto 0));
  --end component;
  
  --component binary2BCD_18 is
   --port ( 
	--		binary_in : in  unsigned(17 downto 0);  -- binary input width
	--		BCD_out   : out std_logic_vector(21 downto 0)   -- BCD output, 22 bits [2|4|4|4|4|4] to display a 3 digit BCD value when input has length 8
   --     );
	--end component;
	
	component bin_to_bcd_lut8
   port ( 
			binary_in : in  unsigned(7 downto 0);  -- binary input width
			bcd_out   : out std_logic_vector(9 downto 0)   -- BCD output, 10 bits [2|4|4] to display a 3 digit BCD value when input has length 8
		);
	end component;
	
	
	component bin_to_bcd_lut10
   port ( 
			binary_in : in  unsigned(9 downto 0);  -- binary input width
			bcd_out   : out std_logic_vector(11 downto 0)   -- BCD output, 10 bits [2|4|4] to display a 3 digit BCD value when input has length 8
		);
	end component;

  component alu_ctrl
    port (
      clk             : in  std_logic;
      reset           : in  std_logic;
      valid_scan_code : in  std_logic;
      scancode_in     : in  std_logic_vector(7 downto 0);
      FN              : out std_logic_vector (3 downto 0);
      kb_buf_clr      : out std_logic;
      mem_addr        : out std_logic_vector (12 downto 0);
      mem_wea         : out std_logic;
      reg_ctrl        : out std_logic_vector(1 downto 0);
		reg_ctrl_mem        : out std_logic_vector(1 downto 0);
      reg_clr         : out std_logic;
      reg_sel_src     : out std_logic_vector(2 downto 0));
  end component;


  component seven_seg_driver
    port (
      clk         : in  std_logic;
      reset       : in  std_logic;
      BCD_digit   : in  std_logic_vector(9 downto 0);
      DIGIT_ANODE : out std_logic_vector(3 downto 0);
      SEGMENT     : out unsigned(7 downto 0));
  end component;

	component memory_module is
	  port (
		 clka : IN STD_LOGIC;
		 wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		 addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		 dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	  );
	end component;

--	COMPONENT zoom_register
--	PORT(
--		clk : IN std_logic;
--		reset : IN std_logic;
--		scancode : IN std_logic_vector(7 downto 0);
--		valid_scancode : IN std_logic;          
--		zoom : OUT std_logic_vector(4 downto 0)
--		);
--	END COMPONENT;

  signal clk : std_logic; 
    signal rst : std_logic; 
                            signal clk_locked : std_logic;

  --keyboard input
  signal edge_found      : std_logic;
  signal kb_clk_sync     : std_logic;
  signal kb_data_sync    : std_logic;
  --signal serial_data     : std_logic;
  signal valid_scan_code : std_logic;
  signal scancode_out    : unsigned(7 downto 0);
  signal scan_to_bin_out : std_logic_vector(3 downto 0);

  --keyboard buffer
  signal kb_buf_clr : std_logic;
  signal kb_buf_out : std_logic_vector(NUM_DIGITS*4-1 downto 0);
  signal kb_in_data : std_logic_vector(NUM_BITS-1 downto 0);

  signal reg_ctrl : std_logic_vector (1 downto 0);
  signal reg_ctrl_mem : std_logic_vector (1 downto 0);
  signal reg_clr  : std_logic;
  signal reg_sel  : std_logic_vector(2 downto 0);
  signal reg_input : std_logic_vector (7 downto 0);

  signal A_out : std_logic_vector (7 downto 0);
  signal B_out : std_logic_vector (7 downto 0);
  signal FN_out: std_logic_vector (3 downto 0);

  
  signal result   : std_logic_vector (17 downto 0);
  --signal overflow : std_logic;
  signal sign     : std_logic;
 -- signal error    : std_logic;

  signal result_bcd : std_logic_vector(21 downto 0);
  signal A_out_bcd  : std_logic_vector(9 downto 0);
  signal B_out_bcd  : std_logic_vector(9 downto 0);

  signal mem_wea    : std_logic_vector(0 downto 0);
  signal mem_addr   : std_logic_vector(12 downto 0);
  signal mem_data_out: std_logic_vector(7 downto 0);
  signal mem_data_in: std_logic_vector(7 downto 0);
  --signal mem_addr_bcd: std_logic_vector(9 downto 0);
 
 
   --signal seg_width : std_logic_vector(4 downto 0);                                                   
                                                      
  
  signal FN_reg     : std_logic_vector (3 downto 0);
  
  
  
  
  
begin  -- assigment4_top_arch
  
  rst <= rst_board or (not clk_locked);
  

  Inst_clock_gen : clock_gen
    port map (clkin_in        => clk_board,
              rst_in          => '0',   -- Don't touch! active high reset
              clkdv_out       => clk,   -- Divided 50MHz input clock
              clkin_ibufg_out => open,
              clk0_out        => open,
              locked_out      => clk_locked  -- Clock stable signal, active high
              );


  sync_keyboard_1 : sync_keyboard
    port map (
      clk          => clk,
      kb_clk       => kb_clk,
      kb_data      => kb_data,
      kb_clk_sync  => kb_clk_sync,
      kb_data_sync => kb_data_sync);

  edge_detector_1 : edge_detector
    port map (
      clk         => clk,
      rst         => rst,
      kb_clk_sync => kb_clk_sync,
      edge_found  => edge_found);

  scancode_reader_1 : scancode_reader
    port map (
      clk             => clk,
      rst             => rst,
      edge_found      => edge_found,
      serial_data     => kb_data_sync,
      valid_scan_code => valid_scan_code,
      scancode_out    => scancode_out);

  scancode_to_binary_1 : scancode_to_binary
    port map (
      scan_code_in => scancode_out,
      binary_out   => scan_to_bin_out);
  
--      process (clk, rst, valid_scan_code)
--      begin
--              if rst = '1' then 
--                      leds <= (others => '0');
--              elsif clk'event and clk='1' and valid_scan_code='1' then
--                      leds(3 downto 0) <= scan_to_bin_out;
--              end if;
--      end process;

    keyboard_buf_1 : keyboard_buf
    generic map (
      NUM_DIGITS => NUM_DIGITS)
    port map (
      clk          => clk,
      reset        => rst,
      valid_number => valid_scan_code,
      number       => scan_to_bin_out,
      bcd          => kb_buf_out,
      buf_clr      => kb_buf_clr
      );

  bcd_to_bin_1 : bcd_to_bin
    generic map (
      DIGIT_COUNT  => NUM_DIGITS,
      OUTPUT_WIDTH => NUM_BITS)
    port map (
      bcd    => kb_buf_out,
      binary => kb_in_data);

  reg_bank_1 : reg_bank
    port map (
      reg_ctrl => reg_ctrl,
		reg_ctrl_mem => reg_ctrl_mem,
      clk      => clk,
      reset    => rst,
      input    => reg_input,
		FN       => FN_out,
      A        => A_out,
      B        => B_out,
		mem_wr_data => mem_data_in,
		reg_clr  => reg_clr
		);

  ALU_1 : ALU
    port map (
	   clk      => clk,
		rst      => rst,
      A        => A_out,
      B        => B_out,
      FN       => FN_out,
      result   => result,
      --overflow => overflow,
      sign     => sign);
   --   error    => error);

  binary2BCD_result : bin_to_bcd_lut8
    port map (
      binary_in => unsigned(result(17 downto 10)),
      bcd_out   => result_bcd(21 downto 12));


  binary2BCD_result_frac : bin_to_bcd_lut10
    port map (
      binary_in => unsigned(result(9 downto 0)),
      bcd_out   => result_bcd(11 downto 0));

  binary2BCD_A : bin_to_bcd_lut8
    port map (
      binary_in => unsigned(A_out),
      bcd_out   => A_out_bcd);

  binary2BCD_B : bin_to_bcd_lut8
    port map (
      binary_in => unsigned(B_out),
      bcd_out   => B_out_bcd);

--  binary2BCD_mem_addr : bin_to_bcd_lut8
--    port map (
--      binary_in => unsigned(mem_addr(7 downto 0)),
--      bcd_out   => mem_addr_bcd);

--  seven_seg_driver_1: seven_seg_driver
--    port map (
--      clk         => clk,
--      reset       => rst,
--      BCD_digit   => mem_addr_bcd,
--      DIGIT_ANODE => seg_en,
--      SEGMENT     => seg_num);


  vga_disp_1 : vga_disp
    port map (
      clk_sys => clk,
      rst_sys => rst,
      A       => A_out_bcd,
      B       => B_out_bcd,
      result  => result_bcd,
      sign    => sign,
      FN      => FN_out(2 downto 0),
      hs      => vga_hs,
      vs      => vga_vs,
      rgb     => vga_rgb--,
		--seg_width_in => "10000"
		);

  alu_ctrl_1 : alu_ctrl
    port map (
      clk             => clk,
      reset           => rst,
      valid_scan_code => valid_scan_code,
      scancode_in     => std_logic_vector(scancode_out),
      FN              => FN_reg,
      kb_buf_clr      => kb_buf_clr,
      mem_addr        => mem_addr,
      mem_wea         => mem_wea(0),
      reg_ctrl        => reg_ctrl,
      reg_clr         => reg_clr,
      reg_sel_src     => reg_sel,
		reg_ctrl_mem => reg_ctrl_mem);

   mem_1: memory_module
	  port map (
		 clka => clk,
		 wea => std_logic_vector(mem_wea),
		 addra => mem_addr,
		 dina => mem_data_in,
		 douta => mem_data_out
	  );

  reg_sel_mux: process (reg_sel, FN_reg, kb_in_data, mem_data_out)
  begin  -- process
    if reg_sel = "000" then
		reg_input <= "0000" & FN_reg;
	 elsif reg_sel = "001" then
		reg_input <= kb_in_data;
	 elsif reg_sel = "010" then
		reg_input <= mem_data_out;
	 elsif reg_sel = "011" then
	   -- default value for modulo 3
		reg_input <= X"03";
	 elsif reg_sel = "100" then
	   -- default value for sqrt
		reg_input <= X"02";
	 else
		reg_input <= (others => '0');
	end if;
  end process;

  
--  leds(6 downto 0) <= mem_data_out(6 downto 0);
 -- leds(7) <= mem_wea(0);
end assigment4_top_arch;

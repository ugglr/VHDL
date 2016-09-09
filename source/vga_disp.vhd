library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.vga_disp_settings.all;
use work.operators.all;

entity vga_disp is
  port (clk_sys : in  std_logic;
        rst_sys : in  std_logic;
        FN      : in  std_logic_vector(2 downto 0);
        A       : in  std_logic_vector(9 downto 0);
        B       : in  std_logic_vector(9 downto 0);
        result  : in  std_logic_vector(21 downto 0);
        sign    : in  std_logic;
        hs      : out std_logic;
        vs      : out std_logic;
        rgb     : out std_logic_vector (2 downto 0)
        );
end vga_disp;

architecture Behavioral of vga_disp is

  -- component clock_gen is
  -- port (clkin_in        : in  std_logic;
  -- rst_in          : in  std_logic;
  -- clkdv_out       : out std_logic;
  -- clkin_ibufg_out : out std_logic;
  -- clk0_out        : out std_logic;
  -- locked_out      : out std_logic
  -- );
  -- end component;

  component vga_controller_640_60 is
    port (rst       : in  std_logic;
          pixel_clk : in  std_logic;
          HS        : out std_logic;
          VS        : out std_logic;
          blank     : out std_logic;
          hcount    : out std_logic_vector(10 downto 0);
          vcount    : out std_logic_vector(10 downto 0)
          );
  end component;


  -- General signals
  --signal clk_sys             : std_logic;
  --signal clk_locked, rst_sys : std_logic;

  -- VGA module
  signal blank          : std_logic;
  signal hcount, vcount : std_logic_vector(10 downto 0);

  -- Picture ROM
  --signal rom_addr : std_logic_vector(15 downto 0);
  --signal rom_dout : std_logic_vector(2 downto 0);


  signal symb_width  : unsigned(5 downto 0);  -- width in pixel of one symbol
  signal space_width : unsigned(5 downto 0);  -- width in pixel between to symbols
  constant seg_width   : unsigned(5 downto 0) := "010000";  -- -- width of the top segment in a 7 segment display, this is used to set the fontsize


  function draw_rect(hcount, vcount, start_x, start_y, end_x, end_y : unsigned(10 downto 0)
  ) return std_logic_vector is
	variable hcount_v, start_x_v, end_x_v : unsigned(10 downto 0);
	variable vcount_v, start_y_v, end_y_v : unsigned(10 downto 0);
  begin
	hcount_v := hcount; --(10 downto 0);
	start_x_v := start_x; --(10 downto 0);
	end_x_v := end_x; --(10 downto 0);
	
	vcount_v := vcount; --(5 downto 0);
	start_y_v := start_y; --(5 downto 0);
	end_y_v := end_y; --(5 downto 0);

    if unsigned(hcount_v) >= start_x_v and
      unsigned(hcount_v) <= end_x_v then
      --vertical 
      if unsigned(vcount_v) >= start_y_v and
        unsigned(vcount_v) <= end_y_v then
        return COLOR_GREEN;
      end if;
    end if;
	 
    return "000";
  end draw_rect;

  function digit_to_sevenseg(digit_in : std_logic_vector(3 downto 0)) return unsigned is
  begin
    
    case (digit_in) is
      when X"0" => return "1111110";
      when X"1" => return "0110000";
      when X"2" => return "1101101";
      when X"3" => return "1111001";
      when X"4" => return "0110011";
      when X"5" => return "1011011";
      when X"6" => return "1011111";
      when X"7" => return "1110000";
      when X"8" => return "1111111";
      when X"9" => return "1111011";

                   --space bar
      when X"A" => return not("1111111");

      when others => return not("0000110");  --display E
    end case;
  end digit_to_sevenseg;

  -- A function to generate one 7 segment display at pos x

--                               --             a
--                              |  |          f   b
--                               --             g
--                              |  |          e   c
--                               --             d

  function seven_seg(hcount, vcount, pos_x, pos_y: unsigned(10 downto 0);
                     seg_width : unsigned(5 downto 0);
                     input                                   : std_logic_vector(6 downto 0)) return std_logic_vector is
    variable seg_height : unsigned(5 downto 0) := unsigned("00" & seg_width(5 downto 2));  -- shift 2
    variable margin     : unsigned(5 downto 0) := unsigned("000" & seg_width(5 downto 3));  -- shft 3
    
  begin
    
    
    
    return (draw_rect(hcount,           --segment a
                      vcount,
                      pos_x + margin + seg_height,
                      pos_y,
                      pos_x + margin + seg_height + seg_width,
                      pos_y + seg_height) and (input(6) & input(6) & input(6))) or
      (draw_rect(hcount,                --segment b
                 vcount,
                 pos_x + margin + seg_height + seg_width + margin,
                 pos_y + margin + seg_height,
                 pos_x + margin + seg_height + seg_width + margin + seg_height,
                 pos_y + margin + seg_height + seg_width) and (input(5) & input(5) & input(5))) or
      (draw_rect(hcount,                --segment c
                 vcount,
                 pos_x + margin + seg_height + seg_width + margin,
                 pos_y + margin + seg_height + seg_width + margin + margin + seg_height,
                 pos_x + margin + seg_height + seg_width + margin + seg_height,
                 pos_y + margin + seg_height + seg_width + margin + margin + seg_height + seg_width) and (input(4) & input(4) & input(4))) or
      (draw_rect(hcount,                --segment d
                 vcount,
                 pos_x + margin + seg_height,
                 pos_y + margin + seg_height + seg_width + margin + margin + seg_height + seg_width + margin,
                 pos_x + margin + seg_height + seg_width,
                 pos_y + margin + seg_height + seg_width + margin + margin + seg_height + seg_width + margin + seg_height) and (input(3) & input(3) & input(3))) or
      (draw_rect(hcount,                --segment e
                 vcount,
                 pos_x,
                 pos_y + margin + seg_height + seg_width + margin + margin + seg_height,
                 pos_x + seg_height,
                 pos_y + margin + seg_height + seg_width + margin + margin + seg_height + seg_width) and (input(2) & input(2) & input(2)))or
      (draw_rect(hcount,                --segment f
                 vcount,
                 pos_x,
                 pos_y + margin + seg_height,
                 pos_x + seg_height,
                 pos_y + margin + seg_height + seg_width) and (input(1) & input(1) & input(1)))or
      (draw_rect(hcount,                --segment g
                 vcount,
                 pos_x + margin + seg_height,
                 pos_y + margin + seg_height + seg_width + margin,
                 pos_x + margin + seg_height + seg_width,
                 pos_y + margin + seg_height + seg_width + margin + seg_height) and (input(0) & input(0) & input(0)));
  end seven_seg;


  -- purpose: draw an operator
  function draw_operator (
    hcount, vcount, pos_x, pos_y : unsigned(10 downto 0);  -- position
	 seg_width : unsigned(5 downto 0);
    input                                   : std_logic_vector(2 downto 0))  -- select operator
    return std_logic_vector is
    variable seg_height : unsigned(5 downto 0) := unsigned("00" & seg_width(5 downto 2));  -- shift 2
    variable margin     : unsigned(5 downto 0) := unsigned("000" & seg_width(5 downto 3));  -- shft 3
    
  begin  -- draw_operator
    case input is
      when OP_PLUS =>                   --plus
        return draw_rect(hcount,        -- horizontal bar
                         vcount,
                         pos_x + margin + seg_height,
                         pos_y + margin + seg_height + seg_width + margin,
                         pos_x + margin + seg_height + seg_width,
                         pos_y + margin + seg_height + seg_width + margin + seg_height) or
          draw_rect(hcount,             -- vertical bar
                    vcount,
                    pos_x + margin + seg_height + margin + seg_height,
                    pos_y + seg_width + margin,
                    pos_x + margin + seg_height + margin + seg_height + seg_height,
                    pos_y + margin + seg_height + seg_width + margin + seg_height + margin + seg_height);
      when OP_MINUS =>                  -- minus
        return draw_rect(hcount,        -- horizontal bar
                         vcount,
                         pos_x + margin + seg_height,
                         pos_y + margin + seg_height + seg_width + margin,
                         pos_x + margin + seg_height + seg_width,
                         pos_y + margin + seg_height + seg_width + margin + seg_height);
      when OP_MOD =>                    -- mod
        return draw_rect(hcount,        -- vertical bar
                         vcount,
                         pos_x + margin + seg_height + margin + seg_height,
                         pos_y,
                         pos_x + margin + seg_height + margin + seg_height + seg_height,
                         pos_y + margin + seg_height + seg_width + margin + margin + seg_height + seg_width + margin + seg_height) or
          draw_rect(hcount,             -- left top square
                    vcount,
                    pos_x,
                    pos_y,
                    pos_x + seg_height,
                    pos_y + seg_height) or
          draw_rect(hcount,             -- lower right square
                    vcount,
                    pos_x + margin + seg_height + seg_width + margin,
                    pos_y + margin + seg_height + seg_width + margin + margin + seg_height + seg_width + margin,
                    pos_x + margin + seg_height + seg_width + margin + seg_height,
                    pos_y + margin + seg_height + seg_width + margin + margin + seg_height + seg_width + margin + seg_height);            
      when OP_TIMES =>                  -- multiplication operator 
        return draw_rect(hcount,
                         vcount,
                         pos_x + margin + seg_height + margin + seg_height,
                         pos_y + margin + seg_height + seg_width + margin,
                         pos_x + margin + seg_height + margin + seg_height + seg_height,
                         pos_y + margin + seg_height + seg_width + margin + seg_height);         
      when OP_SQRT =>                   -- sqrt operator 
        return draw_rect(hcount,        --vertical big bar
                         vcount,
                         pos_x,
                         pos_y,
                         pos_x + seg_height,
                         pos_y + margin + seg_height + seg_width + margin + margin + seg_height + seg_width) or 
          draw_rect(hcount,             --small horizontal bar
                    vcount,
                    pos_x,
                    pos_y,
                    pos_x + margin + seg_height + seg_width + margin + seg_height,
                    pos_y + seg_height);
      when OP_EQUAL =>                  -- equals
        return draw_rect(hcount,        -- upper bar
                         vcount,
                         pos_x + margin + seg_height,
                         pos_y + margin + seg_width + margin,
                         pos_x + margin + seg_height + seg_width,
                         pos_y + margin + seg_height + seg_width + margin) or
          draw_rect(hcount,             -- upper bar
                    vcount,
                    pos_x + margin + seg_height,
                    pos_y + margin + seg_height + seg_width + margin + seg_height,
                    pos_x + margin + seg_height + seg_width,
                    pos_y + margin + seg_height + seg_width + margin + seg_height + seg_height);
						  
		when OP_POINT =>                  -- point
        return draw_rect(hcount,
                         vcount,
                         pos_x + margin + seg_height + margin + seg_height,
                         pos_y + margin + seg_height + seg_width + margin + margin + seg_height,
                         pos_x + margin + seg_height + margin + seg_height + seg_height,
                         pos_y + margin + seg_height + seg_width + margin + margin + seg_height + seg_width);  				  
      when others => return "000";
    end case;
    
    
  end draw_operator;

begin


--  rst_sys <= rst or (not clk_locked);  -- Release system reset when clock is stable

--  Inst_clock_gen:
--    clock_gen
--      port map (clkin_in        => clk,
--                rst_in          => '0',  -- Don't touch! active high reset
--                clkdv_out       => clk_sys,    -- Divided 50MHz input clock
--                clkin_ibufg_out => open,
--                clk0_out        => open,
--                locked_out      => clk_locked  -- Clock stable signal, active high
--                );

  vgactrl640_60:
    vga_controller_640_60
      port map (pixel_clk => clk_sys,
                rst       => rst_sys,
                blank     => blank,
                hcount    => hcount,
                hs        => hs,
                vcount    => vcount,
                vs        => vs
                );

  --calculation of the symbol width based on the seg_width
  symb_width <= seg_width + ("0" & seg_width(5 downto 1)) + ("00" & seg_width(5 downto 2));

  space_width <= ("0" & seg_width(5 downto 1));

  picture_display:
  process (clk_sys, rst_sys)
  begin
    if rst_sys = RESET_SYSTEM then
--      rom_addr <= (others => '0');
    elsif clk_sys = '1' and clk_sys'event then
      if blank = '1' then
        rgb <= (others => '0');  -- Have to be zeros during the blank period
      else
        rgb <= COLOR_WHITE;             -- Background color

        -- if unsigned(vcount) >= MESSAGE_START_V and unsigned(vcount) <= MESSAGE_START_V + MESSAGE_HEIGHT then
        --   if unsigned(hcount) >= MESSAGE_START_H and unsigned(hcount) <= MESSAGE_START_H + MESSAGE_WIDTH - 1 then  -- "-1" is due to the registered "hcount" output

        rgb <= seven_seg(unsigned(hcount), unsigned(vcount), to_unsigned(MESSAGE_START_H, 11) + 0, to_unsigned(MESSAGE_START_V, 11), seg_width, std_logic_vector(digit_to_sevenseg("00"&A(9 downto 8)))) or
               seven_seg(unsigned(hcount), unsigned(vcount), to_unsigned(MESSAGE_START_H, 11) + 28, to_unsigned(MESSAGE_START_V, 11), seg_width, std_logic_vector(digit_to_sevenseg(A(7 downto 4)))) or
               seven_seg(unsigned(hcount), unsigned(vcount), to_unsigned(MESSAGE_START_H, 11) + 56, to_unsigned(MESSAGE_START_V, 11), seg_width, std_logic_vector(digit_to_sevenseg(A(3 downto 0)))) or

               draw_operator(unsigned(hcount), unsigned(vcount), to_unsigned(MESSAGE_START_H, 11) + 84, to_unsigned(MESSAGE_START_V, 11), seg_width, FN) or

              seven_seg(unsigned(hcount), unsigned(vcount), to_unsigned(MESSAGE_START_H, 11) + 112, to_unsigned(MESSAGE_START_V, 11), seg_width, std_logic_vector(digit_to_sevenseg("00"&B(9 downto 8)))) or
              seven_seg(unsigned(hcount), unsigned(vcount), to_unsigned(MESSAGE_START_H, 11) + 140, to_unsigned(MESSAGE_START_V, 11), seg_width, std_logic_vector(digit_to_sevenseg(B(7 downto 4)))) or
              seven_seg(unsigned(hcount), unsigned(vcount), to_unsigned(MESSAGE_START_H, 11) + 168, to_unsigned(MESSAGE_START_V, 11), seg_width, std_logic_vector(digit_to_sevenseg(B(3 downto 0)))) or

               draw_operator(unsigned(hcount), unsigned(vcount), to_unsigned(MESSAGE_START_H, 11) + 196, to_unsigned(MESSAGE_START_V, 11), seg_width, OP_EQUAL) or

               (draw_operator(unsigned(hcount), unsigned(vcount), to_unsigned(MESSAGE_START_H, 11) + 224, to_unsigned(MESSAGE_START_V, 11), seg_width, OP_MINUS) and (sign & sign & sign)) or
               seven_seg(unsigned(hcount), unsigned(vcount), to_unsigned(MESSAGE_START_H, 11) + 252, to_unsigned(MESSAGE_START_V, 11), seg_width, std_logic_vector(digit_to_sevenseg("00"&result(21 downto 20)))) or
               seven_seg(unsigned(hcount), unsigned(vcount), to_unsigned(MESSAGE_START_H, 11) + 280, to_unsigned(MESSAGE_START_V, 11), seg_width, std_logic_vector(digit_to_sevenseg(result(19 downto 16)))) or
               seven_seg(unsigned(hcount), unsigned(vcount), to_unsigned(MESSAGE_START_H, 11) + 308, to_unsigned(MESSAGE_START_V, 11), seg_width, std_logic_vector(digit_to_sevenseg(result(15 downto 12)))) or
			   
				 draw_operator(unsigned(hcount), unsigned(vcount), to_unsigned(MESSAGE_START_H, 11) + 336, to_unsigned(MESSAGE_START_V, 11), seg_width, OP_POINT) or

				
			   seven_seg(unsigned(hcount), unsigned(vcount), to_unsigned(MESSAGE_START_H, 11) + 364, to_unsigned(MESSAGE_START_V, 11), seg_width, std_logic_vector(digit_to_sevenseg(result(11 downto 8)))) or
               seven_seg(unsigned(hcount), unsigned(vcount), to_unsigned(MESSAGE_START_H, 11) + 392, to_unsigned(MESSAGE_START_V, 11), seg_width, std_logic_vector(digit_to_sevenseg(result(7 downto 4)))) or
               seven_seg(unsigned(hcount), unsigned(vcount), to_unsigned(MESSAGE_START_H, 11) + 420, to_unsigned(MESSAGE_START_V, 11), seg_width, std_logic_vector(digit_to_sevenseg(result(3 downto 0))));

			   
			   
        -- end if;
        -- end if;
      end if;
    end if;
  end process;
end Behavioral;

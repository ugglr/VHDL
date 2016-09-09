



def generate_lut(width):
	f_out = open('source/bin_to_bcd_lut%d.vhd' % width, 'w')

	header = \
	"""
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
--use work.ALU_components_pack.all;

entity bin_to_bcd_lut%d is
   port ( 
			binary_in : in  unsigned(%d downto 0);  -- binary input width
			bcd_out   : out std_logic_vector(9 downto 0)   -- BCD output, 10 bits [2|4|4] to display a 3 digit BCD value when input has length 8
		);
end bin_to_bcd_lut%d;

architecture structural of bin_to_bcd_lut%d is 

begin  
	-- DEVELOPE YOUR CODE HERE
	process (binary_in)
	begin
		case binary_in is\n""" % (width, width-1, width, width)
	
	f_out.writelines([header])
	
	for i in xrange(0,2**width):
		
		bcd = ''
		for c in "{0:0>3}".format(i):
			bcd +=  "{0:0>4b}".format(int(c))
		
		f_out.write('           when "{0:0>8b}" => bcd_out <= "{1}";\n '.format(i, bcd[2:]))
		

	footer  = \
	"""
			when others => null;
		end case;
	end process;
end structural;
		
	"""
	f_out.writelines([footer])
	
def generate_lut_fixed(width):
	f_out = open('source/bin_to_bcd_lut%d.vhd' % width, 'w')

	header = \
	"""
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
--use work.ALU_components_pack.all;

entity bin_to_bcd_lut%d is
   port ( 
			binary_in : in  unsigned(%d downto 0);  -- binary input width
			bcd_out   : out std_logic_vector(11 downto 0)   -- BCD output, 10 bits [2|4|4] to display a 3 digit BCD value when input has length 8
		);
end bin_to_bcd_lut%d;

architecture structural of bin_to_bcd_lut%d is 

begin  
	-- DEVELOPE YOUR CODE HERE
	process (binary_in)
	begin
		case binary_in is""" % (width, width-1, width, width)
	
	f_out.writelines([header])
	
	for i in xrange(0,2**width):
		num = i
		i = str(round((float(i)/1024.0), 3)).split('.')[1][0:3]

		bcd = ''
		for c in "{0:0>3}".format(int(i)):
			bcd +=  "{0:0>4b}".format(int(c))
#		
		f_out.write('           when "{0:0>10b}" => bcd_out <= "{1}"; --{2}\n '.format(num, bcd, i))
		

	footer  = \
	"""
			when others => null;
		end case;
	end process;
end structural;
		
	"""
	f_out.writelines([footer])

generate_lut(8)
generate_lut_fixed(10)
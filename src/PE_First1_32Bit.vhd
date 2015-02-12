
--32 bit priority encoder.Gives the index of first bit in a 32-bit signal.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity PE_First1_32Bit is
    Port ( inp : in  STD_LOGIC_VECTOR (31 downto 0);
           outp : out  STD_LOGIC_VECTOR (4 downto 0);
           v : out  STD_LOGIC);
end PE_First1_32Bit;

architecture Behavioral of PE_First1_32Bit is

component PE_First1_8Bit is
    Port ( inp : in  STD_LOGIC_VECTOR (7 downto 0);
           outp : out  STD_LOGIC_VECTOR (2 downto 0);
           v : out  STD_LOGIC);
end component;

signal PE1_out : STD_LOGIC_VECTOR(2 downto 0);
signal PE2_out : STD_LOGIC_VECTOR(2 downto 0);
signal PE3_out : STD_LOGIC_VECTOR(2 downto 0);
signal PE4_out : STD_LOGIC_VECTOR(2 downto 0);
signal PE1_v	: STD_LOGIC;
signal PE2_v	: STD_LOGIC;
signal PE3_v	: STD_LOGIC;
signal PE4_v	: STD_LOGIC;

begin

PE1: PE_First1_8Bit
		PORT MAP(inp(31 downto 24),PE1_out,PE1_v);

PE2: PE_First1_8Bit
		PORT MAP(inp(23 downto 16),PE2_out,PE2_v);

PE3: PE_First1_8Bit
		PORT MAP(inp(15 downto 8),PE3_out,PE3_v);

PE4: PE_First1_8Bit
		PORT MAP(inp(7 downto 0),PE4_out,PE4_v);
		
	

outp <= "11" & PE1_out  when PE1_v = '1' else
		  "10" & PE2_out  when PE2_v = '1' else
		  "01" & PE3_out  when PE3_v = '1' else
     	  "00" & PE4_out;
v <= '1' when ((PE1_v OR PE2_v OR PE3_v OR PE4_v) = '1') else '0';
		

end Behavioral;


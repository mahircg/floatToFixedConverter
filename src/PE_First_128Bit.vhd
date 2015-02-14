
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity PE_First_128Bit is
    Port ( inp : in  STD_LOGIC_VECTOR (127 downto 0);
           outp : out  STD_LOGIC_VECTOR (6 downto 0);
           v : out  STD_LOGIC);
end PE_First_128Bit;





architecture Behavioral of PE_First_128Bit is

component PE_First1_32Bit is
    Port ( inp : in  STD_LOGIC_VECTOR (31 downto 0);
           outp : out  STD_LOGIC_VECTOR (4 downto 0);
           v : out  STD_LOGIC);
end component;

signal PE1_out : STD_LOGIC_VECTOR(4 downto 0);
signal PE2_out : STD_LOGIC_VECTOR(4 downto 0);
signal PE3_out : STD_LOGIC_VECTOR(4 downto 0);
signal PE4_out : STD_LOGIC_VECTOR(4 downto 0);
signal PE1_v	: STD_LOGIC;
signal PE2_v	: STD_LOGIC;
signal PE3_v	: STD_LOGIC;
signal PE4_v	: STD_LOGIC;

begin

PE1: PE_First1_32Bit
		PORT MAP(inp(127 downto 96),PE1_out,PE1_v);

PE2: PE_First1_32Bit
		PORT MAP(inp(95 downto 64),PE2_out,PE2_v);

PE3: PE_First1_32Bit
		PORT MAP(inp(63 downto 32),PE3_out,PE3_v);

PE4: PE_First1_32Bit
		PORT MAP(inp(31 downto 0),PE4_out,PE4_v);
		
outp <= "11" & PE1_out  when PE1_v = '1' else
		  "10" & PE2_out  when PE2_v = '1' else
		  "01" & PE3_out  when PE3_v = '1' else
     	  "00" & PE4_out;
v <= '1' when ((PE1_v OR PE2_v OR PE3_v OR PE4_v) = '1') else '0';


end Behavioral;


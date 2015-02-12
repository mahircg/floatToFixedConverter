
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity PE_First1_8Bit is
    Port ( inp : in  STD_LOGIC_VECTOR (7 downto 0);
           outp : out  STD_LOGIC_VECTOR (2 downto 0);
           v : out  STD_LOGIC);
end PE_First1_8Bit;

architecture Behavioral of PE_First1_8Bit is

begin

outp		<=		"111" when inp(7) = '1' else
					"110" when inp(6) = '1' else
					"101" when inp(5) = '1' else
					"100" when inp(4) = '1' else
					"011" when inp(3) = '1' else
					"010" when inp(2) = '1' else
					"001" when inp(1) = '1' else
					"000";
					
v <= '0' when inp="00000000" else '1';

end Behavioral;


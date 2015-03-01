library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.NUMERIC_STD.ALL; 

 
ENTITY DecimalToFloatTB IS
END DecimalToFloatTB;
 
ARCHITECTURE behavior OF DecimalToFloatTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DecimalToFloat
    PORT(
         Decimal : IN  REAL;
         FP : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Decimal : REAL := 0.0;

 	--Outputs
   signal FP : std_logic_vector(31 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DecimalToFloat PORT MAP (
          Decimal => Decimal,
          FP => FP
        );

 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      Decimal <= 9.25;
		wait for 100 ns;
		Decimal <= -9.25;
		wait for 100 ns;
		Decimal <= 0.2346;
		wait for 100 ns;
		Decimal <= 1.0306734E-38;
		
      -- insert stimulus here 

      wait;
   end process;

END;

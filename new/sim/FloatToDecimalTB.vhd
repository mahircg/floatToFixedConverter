
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.NUMERIC_STD.ALL;
 
ENTITY FloatToDecimalTB IS
END FloatToDecimalTB;
 
ARCHITECTURE behavior OF FloatToDecimalTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT FloatToDecimal
    PORT(
         FP : IN  std_logic_vector(31 downto 0);
         p_inf : OUT  std_logic;
         n_inf : OUT  std_logic;
         NaN : OUT  std_logic;
         Decimal : OUT  REAL
        );
    END COMPONENT;
    

   --Inputs
   signal FP : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal p_inf : std_logic;
   signal n_inf : std_logic;
   signal NaN : std_logic;
   signal Decimal : REAL;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: FloatToDecimal PORT MAP (
          FP => FP,
          p_inf => p_inf,
          n_inf => n_inf,
          NaN => NaN,
          Decimal => Decimal
        );


 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      FP <= "01000001000101000000000000000000";
		wait for 100 ns;
		FP <= "00000000000101000000000000000000";
		wait for 100 ns;

      -- insert stimulus here 

      wait;
   end process;

END;

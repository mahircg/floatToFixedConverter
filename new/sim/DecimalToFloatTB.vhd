library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.NUMERIC_STD.ALL; 

 
ENTITY DecimalToFloatTB IS
END DecimalToFloatTB;
 
ARCHITECTURE behavior OF DecimalToFloatTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DecimalToFloat
	Port(	Decimal: in REAL;
			p_inf  : out STD_LOGIC;
			n_inf  : out STD_LOGIC;
			NaN	 : out STD_LOGIC;
			FP		 : out STD_LOGIC_VECTOR(31 downto 0)
	);
	END COMPONENT;
    

   --Inputs
   signal Decimal : REAL := 0.0;

 	--Outputs
   signal FP : std_logic_vector(31 downto 0);
   signal p_inf : STD_LOGIC;
	signal n_inf : STD_LOGIC;
	signal NaN : STD_LOGIC;
   
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DecimalToFloat PORT MAP (
          Decimal => Decimal,
			 p_inf => p_inf,
			 n_inf => n_inf,
			 NaN => NaN,
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
		wait for 100 ns;
		Decimal <= 3.1932096E38;
		wait for 100 ns;
		
		Decimal <= 3.5E38;
		
      -- insert stimulus here 

      wait;
   end process;

END;

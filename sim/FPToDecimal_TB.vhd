
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 

 
ENTITY FPToDecimal_TB IS
END FPToDecimal_TB;
 
ARCHITECTURE behavior OF FPToDecimal_TB IS 
 
    
 
    COMPONENT FPToDecimal
    PORT ( fp 					: in  	STD_LOGIC_VECTOR (31 downto 0);
			  fw					: in  	STD_LOGIC_VECTOR (4 downto 0);
			  NaN					: out 	STD_LOGIC;
			  p_infinity		: out 	STD_LOGIC;
			  n_infinity		: out 	STD_LOGIC;
           decimal 			: out  	STD_LOGIC_VECTOR (31 downto 0));
    END COMPONENT;
    


   signal fp : std_logic_vector(31 downto 0) := (others => '0');
	signal fw : std_logic_vector(4 downto 0) := (others => '0');

	

	signal NaN: std_logic :='0';
	signal p_infinity: std_logic :='0';
	signal n_infinity: std_logic :='0';
   signal decimal : std_logic_vector(31 downto 0);

 
   
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: FPToDecimal PORT MAP (
          fp => fp,
			 fw => fw,
			 NaN => NaN,
			 p_infinity => p_infinity,
			 n_infinity => n_infinity,
          decimal => decimal
        );


 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
	   fw <= "00100";
      fp <= "00111110010000000000000000000000";			--0.1875
		wait for 100 ns;
		fw <= "00011";
      fp <= "00111110000000000000000000000000";			--0.125
		wait for 100 ns;
		fw <= "00000";
      fp <= "01000010110010000000000000000000";			--100
		wait for 100 ns;
		fw <= "00010";
      fp <= "11000001000101000000000000000000";			-- -9.25
		wait for 100 ns;
		fp <= "01111111100000000000000000000000";
		wait for 100 ns;
		fp <= "11111111100000000000000000000000";
		wait for 100 ns;
		fp <= "11111111100000000010000000000000";
		wait for 100 ns;
		

    

      wait;
   end process;

END;

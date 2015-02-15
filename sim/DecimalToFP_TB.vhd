
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 

 
ENTITY DecimalToFP_TB IS
END DecimalToFP_TB;
 
ARCHITECTURE behavior OF DecimalToFP_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DecimalToFP
	 Generic (
				inputWidth: INTEGER := 32;
				fwWidth   : INTEGER := 5
				);
	 Port ( 	fw		  : in STD_LOGIC_VECTOR(fwWidth -1 downto 0);
				decimal : in  STD_LOGIC_VECTOR (inputWidth-1 downto 0);
				fp : out  STD_LOGIC_VECTOR (31 downto 0));
    END COMPONENT;
    

   --Inputs
   signal decimal : std_logic_vector(127 downto 0) := (others => '0');
	
	signal fw		: std_logic_vector(6 downto 0) := (others => '0');

 	--Outputs
   signal fp : std_logic_vector(31 downto 0);

 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DecimalToFP 
			GENERIC MAP (
			inputWidth => 128,
			fwWidth	  => 7
			)
			PORT MAP (
	
			 fw		=> fw,
          decimal => decimal,
          fp => fp
        );

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		
		fw<="0000000";
		
		decimal<=X"7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
		wait for 200 ns;
		fw<="1111111";
		
		decimal<=X"00000000000000000000000000000001";
		wait for 200 ns;
		fw<="0000010";
		decimal<=X"00000000000000000000000000000025";
		wait for 200 ns;
		
		
		
     
		wait for 200 ns;
      -- insert stimulus here 

      wait;
   end process;

END;

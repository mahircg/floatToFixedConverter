
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 

 
ENTITY DecimalToFP_TB IS
END DecimalToFP_TB;
 
ARCHITECTURE behavior OF DecimalToFP_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DecimalToFP
	 Generic (
				inputWidth: INTEGER := 150;
				fwWidth   : INTEGER := 8
				);
	 Port ( 	fw		  : in STD_LOGIC_VECTOR(fwWidth -1 downto 0);			-- Floating width
				decimal : in  STD_LOGIC_VECTOR (inputWidth-1 downto 0);		-- Fixed-point input
				fp : out  STD_LOGIC_VECTOR (31 downto 0));						-- Single precision floating-point output
    END COMPONENT;
    

   --Inputs
   signal decimal : std_logic_vector(149 downto 0) := (others => '0');	
	signal fw		: std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal fp : std_logic_vector(31 downto 0);

 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DecimalToFP 
			GENERIC MAP (
			inputWidth => 150,
			fwWidth	  => 8
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
		
		fw<="00000010";
		
		decimal<="00"&X"0000000000000000000000000000000000025";
		wait for 200 ns;
		fw<="10010101";
		
		decimal<="00"&X"0000000000000000000000000000000000001";
		wait for 200 ns;
		fw<="10010100";
		
		decimal<="00"&X"0000000000000000000000000000000000001";
		wait for 200 ns;
		fw<="01111111";
		
		decimal<="00"&X"0000000000000000000000000000000000001";
		
		wait for 200 ns;
		fw<="00010101";
		
		decimal<="01"&X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
		
		wait for 200 ns;
		fw<="00010100";
		
		decimal<="01"&X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
		
		wait for 200 ns;
		fw<="00010100";
		
		decimal<="10"&X"0000000000000000000000000000000000001";
		
		wait for 200 ns;
		fw<="00010101";
		
		decimal<="10"&X"0000000000000000000000000000000000001";
		
		wait for 200 ns;
		fw<="00000010";
		
		decimal<="11"&X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDD";
--		wait for 200 ns;
--		fw<="0000010";
--		decimal<=X"00000000000000000000000000000025";
--		wait for 200 ns;
		
		
		
     
		wait for 200 ns;
      -- insert stimulus here 

      wait;
   end process;

END;

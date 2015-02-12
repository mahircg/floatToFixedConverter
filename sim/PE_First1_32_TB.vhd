
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.all;

 
ENTITY PE_First1_32_TB IS
END PE_First1_32_TB;
 
ARCHITECTURE behavior OF PE_First1_32_TB IS 
 
    
 
    COMPONENT PE_First1_32Bit
    PORT(
         inp : IN  std_logic_vector(31 downto 0);
         outp : OUT  std_logic_vector(4 downto 0);
         v : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal inp : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal outp : std_logic_vector(4 downto 0);
   signal v : std_logic;

 
   constant temp : BIT_VECTOR(31 downto 0) := X"80000000";
	
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PE_First1_32Bit PORT MAP (
          inp => inp,
          outp => outp,
          v => v
        );
	
	

 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

     
		
		for i in 0 to 32 loop
			inp <= to_stdlogicvector(temp srl i);
			wait for 10 ns;
		end loop;
		
		
		

      -- insert stimulus here 

      wait;
   end process;

END;


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

 
ENTITY PE_First_128Bit_TB IS
END PE_First_128Bit_TB;
 
ARCHITECTURE behavior OF PE_First_128Bit_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PE_First_128Bit
    PORT(
         inp : IN  std_logic_vector(127 downto 0);
         outp : OUT  std_logic_vector(6 downto 0);
         v : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal inp : std_logic_vector(127 downto 0) := (others => '0');

 	--Outputs
   signal outp : std_logic_vector(6 downto 0);
   signal v : std_logic;

	constant temp : BIT_VECTOR(127 downto 0) := X"80000000000000000000000000000000";
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PE_First_128Bit PORT MAP (
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

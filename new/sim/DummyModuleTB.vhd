
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.NUMERIC_STD.ALL;
 

 
ENTITY DummyModuleTB IS
END DummyModuleTB;
 
ARCHITECTURE behavior OF DummyModuleTB IS 
 
   
 
    COMPONENT Dummy_Module
    PORT(
         CLK : IN  std_logic;
         enable : IN  std_logic;
         edge : IN  std_logic;
         operand : IN  std_logic_vector(31 downto 0);
         result : OUT  std_logic_vector(31 downto 0);
         valid : OUT  std_logic
        );
    END COMPONENT;
	 
	COMPONENT DecimalToFloat is
	PORT(	Decimal: in REAL;
			p_inf  : out STD_LOGIC;
			n_inf  : out STD_LOGIC;
			NaN	 : out STD_LOGIC;
			FP		 : out STD_LOGIC_VECTOR(31 downto 0)
	);
	END COMPONENT;
	
	COMPONENT FloatToDecimal is
    Port ( FP 			: in  STD_LOGIC_VECTOR (31 downto 0);
			  p_inf		: out STD_LOGIC;
			  n_inf		: out STD_LOGIC;
			  NaN			: out STD_LOGIC;
			  Decimal	: out REAL

	 );
	END COMPONENT;
	
	--Input of decimal to float
   signal Decimal_In : REAL := 0.0;

 	--Outputs of decimal to float
   signal FP_Out : std_logic_vector(31 downto 0);
   signal p_inf_dec_to_float : STD_LOGIC;
	signal n_inf_dec_to_float : STD_LOGIC;
	signal NaN_dec_to_float : STD_LOGIC;
	
	--Inputs of float to decimal
   signal FP_In : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs of float to decimal
   signal p_inf_float_to_dec : std_logic;
   signal n_inf_float_to_dec : std_logic;
   signal NaN_float_to_dec : std_logic;
   signal Decimal_Out : REAL;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal enable : std_logic := '0';
   signal edge : std_logic := '0';
   signal operand : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal result : std_logic_vector(31 downto 0);
   signal valid : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 5 ns;
	
	signal counter  : INTEGER := 0;
	
	type decimalArray  is array (31 downto 0) of REAL;
	signal decimalStimuli : decimalArray;
	

 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Dummy_Module PORT MAP (
          CLK => CLK,
          enable => enable,
          edge => edge,
          operand => operand,
          result => result,
          valid => valid
        );
		  
	decimalToFloatInstance: DecimalToFloat 
	PORT MAP (
          Decimal => Decimal_In,
			 p_inf => p_inf_dec_to_float,
			 n_inf => n_inf_dec_to_float,
			 NaN => NaN_dec_to_float,
          FP => FP_Out
        );
		  
   floatToDecimalInstance: FloatToDecimal 
	PORT MAP (
          FP => FP_In,
          p_inf => p_inf_float_to_dec,
          n_inf => n_inf_float_to_dec,
          NaN => NaN_float_to_dec,
          Decimal => Decimal_Out
        );		
		  
--Circuit uses rising edge
	edge   <= '1';
	
	-- Initialize test values,refer to index values for corresponding fixed point index in each signal
	decimalStimuli(0) 		<= 		9.25;
	decimalStimuli(1)			<=			-9.25;
	decimalStimuli(2)			<=			0.0;
	decimalStimuli(3)			<=			1.0;
	decimalStimuli(4)			<=			2.0;
	decimalStimuli(5)			<=			0.2346;
	decimalStimuli(6)			<=			1.0306734E-38;
	decimalStimuli(7)			<=			3.1932096E38;
	decimalStimuli(8)			<=			3.5E38;
	decimalStimuli(9)			<=			4.408104E-39;
	decimalStimuli(10)		<=			7.14325E-20;
	decimalStimuli(11)		<=			1.1;
	decimalStimuli(12)		<=			1.3031457E-37;
	decimalStimuli(13)		<=			5.8942954E37;		
	decimalStimuli(14)		<=			-2.384306E38;		
	decimalStimuli(15)		<=			16547800.0;		
	decimalStimuli(16)		<=			-8.6187748E17;		
	decimalStimuli(17)		<=			-1.5904026E37;		
	decimalStimuli(18)		<=			7.4080076E27;		
	decimalStimuli(19)		<=			-3.8008235E38;		
	decimalStimuli(20)		<=			-2.00784064E9;		
	decimalStimuli(21)		<=			-3.7038122E28;		
	decimalStimuli(22)		<=			-0.4674866;		
	decimalStimuli(23)		<=			-0.4674904;		
	decimalStimuli(24)		<=			1.5805956E29;		
	decimalStimuli(25)		<=			0.0005;		
	decimalStimuli(26)		<=			1.0001;	
	decimalStimuli(27)		<=			395143.82;	
	decimalStimuli(28)		<=			-443103.1;		
	decimalStimuli(29)		<=			8.5770454E16;		
	decimalStimuli(30)		<=			1.30888748E12;		
	decimalStimuli(31)		<=			1.25185738E17;	
		

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

	FP_Ready_Process: process(CLK)
	begin
	if rising_edge(CLK) then
		if valid = '1' then
			FP_In <= result;
			if counter >= 1 then
				assert false report "Expected: "& REAL'IMAGE(decimalStimuli(counter-1)) & " Actual: "& REAL'IMAGE(Decimal_Out) severity warning;		
			end if;
			counter <= counter + 1;
		end if;
		if counter=31 and valid='0' then 
			assert false report "Simulation ended" severity failure;	-- Stop simulation
		end if;
	end if;
	end process;
	
	stim_proc: process
   begin	
	enable <= '0';
	wait for 10*CLK_period + CLK_period/2;
	enable <= '1' after CLK_period;
	for decimalCounter in 0 to 31 loop
		Decimal_In <= decimalStimuli(decimalCounter);
		operand 	<= FP_Out;
		wait for CLK_period ;
	end loop;
	enable <= '0';
	wait;
   end process;

END;

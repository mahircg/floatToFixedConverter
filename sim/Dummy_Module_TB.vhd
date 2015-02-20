
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY Dummy_Module_TB IS
END Dummy_Module_TB;
 
ARCHITECTURE behavior OF Dummy_Module_TB IS 
 
    
 
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
	 
	 --Component to convert floating-point number into 2's complement decimal number
	 COMPONENT DecimalToFP
    GENERIC (
				inputWidth: INTEGER := 150;
				fwWidth   : INTEGER := 8
				);
    PORT ( 	fw		  : in STD_LOGIC_VECTOR(fwWidth -1 downto 0);			-- Floating width
				decimal : in  STD_LOGIC_VECTOR (inputWidth-1 downto 0);		-- Fixed-point input
				fp : out  STD_LOGIC_VECTOR (31 downto 0));						-- Single precision floating-point output
    END COMPONENT;
	 
	 --Component to convert 2's complement decimal number into single-precision floating-point number
    COMPONENT FPToDecimal
    GENERIC (
			  outputWidth		: INTEGER := 150;
			  fwWidth			: INTEGER := 8
			  );
    PORT ( fp 					: in  	STD_LOGIC_VECTOR (31 downto 0);				--Floating point input.
			  fw					: in  	STD_LOGIC_VECTOR (fwWidth-1 downto 0);		--Place of point in fixed-point output.
			  NaN					: out 	STD_LOGIC;											--Not-a-number signal
			  p_infinity		: out 	STD_LOGIC;											--Positive-negative infinity signals
			  n_infinity		: out 	STD_LOGIC;
           decimal 			: out  	STD_LOGIC_VECTOR (outputWidth-1 downto 0)); --Fixed-point output.
    END COMPONENT;
    
	constant outputWidth 	: INTEGER := 150;
	constant fwWidth			: INTEGER := 8;
	
   --Inputs of dummy module
   signal CLK : std_logic := '0';
   signal enable : std_logic := '0';
   signal edge : std_logic := '0';
   signal operand : std_logic_vector(31 downto 0) := (others => 'X');
	
	--Outputs of dummy module
   signal result : std_logic_vector(31 downto 0);
   signal valid : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 5 ns;
	
	--Inputs of FP to decimal converter
	signal decimalInReg : std_logic_vector(outputWidth-1 downto 0) := (others => 'X');
	signal fwWidthFixedToFloat : std_logic_vector(fwWidth-1 downto 0) := (others => 'X');
	
	--Output of FP to decimal converter
	signal fpOutReg	  : std_logic_vector(31 downto 0) := (others => 'X');
	
   --Inputs of decimal to FP converter
	signal fpInReg : std_logic_vector(31 downto 0) := (others => 'X');
	signal fwWidthFloatToFixed : std_logic_vector(fwWidth-1 downto 0) := (others => 'X');
	
	--Output of decimal to FP converter
	signal decimalOutReg	  : std_logic_vector(outputWidth-1 downto 0) := (others => 'X');
	signal NaN 				  : std_logic := 'X';
	signal p_infinity 	  : std_logic := 'X';
	signal n_infinity 	  : std_logic := 'X';
	
	--Simulation signals

	signal counter  : std_logic_vector(31 downto 0)  := (others => '0');
	




 
BEGIN

	-- Instantiate decimal to FP converter
	decToFP:  DecimalToFP PORT MAP (
					decimal => decimalInReg,
					fw      => fwWidthFixedToFloat,
					fp => fpOutReg
					);
	-- Instantiate FP to decimal converter			
	fpToDev:  FPToDecimal PORT MAP (
					fp => fpInReg,
					fw => fwWidthFloatToFixed,
					NaN => NaN,
					p_infinity => p_infinity,
					n_infinity => n_infinity,
					decimal => decimalOutReg
					);
				
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Dummy_Module PORT MAP (
          CLK => CLK,
          enable => enable,
          edge => edge,
          operand => operand,
          result => result,
          valid => valid
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
	
	--Circuit uses rising edge
	edge   <= '1';
	
	--Read the output of comm. module in each cycle when its internal memory is full.Write the FP number into FP-to-Decimal converter to see the output.
	FP_Ready_Process: process(CLK)
	begin
	if rising_edge(CLK) then
		if valid = '1' then
			fpInReg <= result;
			--assert (fpInReg(30 downto 23) /= X"FF") report "NAN or infinity occured!" severity failure;
		end if;
	end if;
	end process;
	

   --Write all possible values of a 32 bit signal into input of FP-to-decimal counter.Then write its outptut to comm. module for transmit.
	--In every 32 cycles,buffer is full and this process waits until comm. modules internal memory is empty again.
   stim_proc: process
   begin	
	enable <= '0';
	wait for 10*CLK_period + CLK_period/2;
	fwWidthFixedToFloat <= "00000000";
	fwWidthFloatToFixed <= "00000000";
	while true loop
		enable <= '1' after CLK_period;
		for decimalCounter in 0 to 32 loop
			decimalInReg(31 downto 0)	<= counter; 
			decimalInReg(149 downto 32 ) <= (others => '0');
			operand 	<= fpOutReg;
			counter <= std_logic_vector(unsigned(counter) + 1) after CLK_period ;
			wait for CLK_period ;
		end loop;
		enable <= '0';
		wait until valid='0';
	end loop;
	
   end process;



END;

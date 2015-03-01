
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
	 
	 
	 COMPONENT DecimalToFP
    GENERIC (
				inputWidth: INTEGER := 150;
				fwWidth   : INTEGER := 8
				);
    PORT ( 	fw		  : in STD_LOGIC_VECTOR(fwWidth -1 downto 0);			-- Floating width
				decimal : in  STD_LOGIC_VECTOR (inputWidth-1 downto 0);		-- Fixed-point input
				fp : out  STD_LOGIC_VECTOR (31 downto 0));						-- Single precision floating-point output
    END COMPONENT;
	 
	 
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
	
	type fixedPointArray  is array (31 downto 0) of STD_LOGIC_VECTOR(outputWidth-1 downto 0);
	type fixedIndexArray  is array (31 downto 0) of STD_LOGIC_VECTOR(fwWidth-1     downto 0);
	
	signal fixedPointStimuli : fixedPointArray;
	signal indexStimuli		 : fixedIndexArray;
	
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

	signal counter  : INTEGER := 0;
	




 
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
	
	-- Initialize test values,refer to index values for corresponding fixed point index in each signal
	fixedPointStimuli(0) 		<= 		"00"&X"0000000000000000000000000000000000025";		-- 9.25
	indexStimuli(0)				<=			"00000010";
	fixedPointStimuli(1)			<=			"00"&X"0000000000000000000000000000000000001";		-- 2^-149
	indexStimuli(1)				<=			"10010101";
	fixedPointStimuli(2)			<=			"00"&X"0000000000000000000000000000000000001";		-- 2^-148
	indexStimuli(2)				<=			"10010100";
	fixedPointStimuli(3)			<=			"00"&X"0000000000000000000000000000000000001";		-- 2^-127
	indexStimuli(3)				<=			"01111111";
	fixedPointStimuli(4)			<=			"01"&X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";		-- ~3.4E38
	indexStimuli(4)				<=			"00010101";
	fixedPointStimuli(5)			<=			"01"&X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";		-- ~7.8E38
	indexStimuli(5)				<=			"00010100";
	fixedPointStimuli(6)			<=			"10"&X"0000000000000000000000000000000000001";		-- -2^20
	indexStimuli(6)				<=			"00010100";
	fixedPointStimuli(7)			<=			"10"&X"0000000000000000000000000000000000001";		-- -2^21
	indexStimuli(7)				<=			"00010101";
	fixedPointStimuli(8)			<=			"00"&X"0000000000000000000000000000000000002";			-- 0.1875
	indexStimuli(8)				<=			"00000100";
	fixedPointStimuli(9)			<=			"00"&X"0000000000000000000000000000000000001";			-- 0.125
	indexStimuli(9)				<=			"00000011";
	fixedPointStimuli(10)		<=			"11"&X"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDD";		-- -9.25
	indexStimuli(10)				<=			"00000010";
	fixedPointStimuli(11)		<=			"00"&X"0000000000000000000000000000000000064";			-- 100
	indexStimuli(11)				<=			"00000000";
	fixedPointStimuli(12)		<=			"11"&X"2612065234243532FCDB001234176F0100023";		--Arbitrary input values(12 to 31)
	indexStimuli(12)				<=			"01000101";
	fixedPointStimuli(13)		<=			"00"&X"21432532FFEEC781341000123457120100FCD";		
	indexStimuli(13)				<=			"01000101";
	fixedPointStimuli(14)		<=			"10"&X"1237753756835322381DEEE0000BCCADBBBBB";		
	indexStimuli(14)				<=			"00000101";
	fixedPointStimuli(15)		<=			"00"&X"260012FCDDF6578134125341634EDAEDC0012";		
	indexStimuli(15)				<=			"00001111";
	fixedPointStimuli(16)		<=			"00"&X"532452345345342643788790890000CFBDBAA";		
	indexStimuli(16)				<=			"01001101";
	fixedPointStimuli(17)		<=			"00"&X"260012FCDDF65781341000123457120100FCD";		
	indexStimuli(17)				<=			"00000000";
	fixedPointStimuli(18)		<=			"00"&X"FCDDFEA145132568948643653786570111111";		
	indexStimuli(18)				<=			"00101101";
	fixedPointStimuli(19)		<=			"00"&X"260012FCDDF60000000000000000000000000";		
	indexStimuli(19)				<=			"00010101";
	fixedPointStimuli(20)		<=			"00"&X"260012FCDDF65781341000123457120100FCD";		
	indexStimuli(20)				<=			"00000111";
	fixedPointStimuli(21)		<=			"00"&X"260012FCDDF10239012BBBFDE141090301090";		
	indexStimuli(21)				<=			"00000101";
	fixedPointStimuli(22)		<=			"00"&X"260012FCDDF6578130989048120193190248A";		
	indexStimuli(22)				<=			"01000101";
	fixedPointStimuli(23)		<=			"00"&X"260012FCDD156756898760123457EEEEEEEEE";		
	indexStimuli(23)				<=			"00000101";
	fixedPointStimuli(24)		<=			"00"&X"654786548DF6578134100012BCA1232EDAEDA";		
	indexStimuli(24)				<=			"00000101";
	fixedPointStimuli(25)		<=			"00"&X"000000000DF65781341000123457010010101";		
	indexStimuli(25)				<=			"00000101";
	fixedPointStimuli(26)		<=			"00"&X"11123133DDF65781341000123457120100FCD";		
	indexStimuli(26)				<=			"00000101";
	fixedPointStimuli(27)		<=			"00"&X"CD14325789273851130908908978760011FBD";	
	indexStimuli(27)				<=			"00000101";
	fixedPointStimuli(28)		<=			"00"&X"26001FCDBFFFFFFFFFFFFFFF3457120100FCD";		
	indexStimuli(28)				<=			"00110101";
	fixedPointStimuli(29)		<=			"00"&X"FF0002FCDDF65781341000123457120100FCD";		
	indexStimuli(29)				<=			"00000101";
	fixedPointStimuli(30)		<=			"10"&X"AD0012FCDDF65781341000123457120100FCD";		
	indexStimuli(30)				<=			"00000101";
	fixedPointStimuli(31)		<=			"10"&X"260012FCDDF6FBDCAAA131234124000290492";		
	indexStimuli(31)				<=			"01000110";
	
	
	--Read the output of comm. module in each cycle when its internal memory is full.Write the FP number into FP-to-Decimal converter to see the output.
	FP_Ready_Process: process(CLK)
	begin
	if rising_edge(CLK) then
		if valid = '1' then
			fwWidthFloatToFixed <= indexStimuli(counter);
			fpInReg <= result;
			assert(decimalOutReg /= fixedPointStimuli(counter)) report "Value mismatch" severity warning;		--Check if converted variable is the same
			counter <= counter + 1;
		end if;
		if counter=31 and valid='0' then 
			assert false report "Simulation ended" severity failure;	-- Stop simulation
		end if;
	end if;
	end process;
	

   --Try the values in input array on the modules.
   stim_proc: process
   begin	
	enable <= '0';
	wait for 10*CLK_period + CLK_period/2;
	enable <= '1' after CLK_period;
	for decimalCounter in 0 to 31 loop
		decimalInReg <= fixedPointStimuli(decimalCounter);
		fwWidthFixedToFloat <= indexStimuli(decimalCounter);
		operand 	<= fpOutReg;
		wait for CLK_period ;
	end loop;
	enable <= '0';
	wait;
   end process;



END;

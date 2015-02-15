
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;


entity FPToDecimal is
	 Generic (
			  outputWidth		: INTEGER := 128;
			  fwWidth			: INTEGER := 7
			  );
    Port ( fp 					: in  	STD_LOGIC_VECTOR (31 downto 0);				--Floating point input.
			  fw					: in  	STD_LOGIC_VECTOR (fwWidth-1 downto 0);		--Place of point in fixed-point output.
			  NaN					: out 	STD_LOGIC;											--Not-a-number signal
			  p_infinity		: out 	STD_LOGIC;											--Positive-negative infinity signals
			  n_infinity		: out 	STD_LOGIC;
           decimal 			: out  	STD_LOGIC_VECTOR (outputWidth-1 downto 0)); --Fixed-point output.
end FPToDecimal;

architecture Behavioral of FPToDecimal is

begin

process(fp,fw)

variable sign					: STD_LOGIC;								--Sign bit of floating-point input.
variable mantissa				: STD_LOGIC_VECTOR(22 downto 0);		--Register to hold mantissa of input.
variable dec					: STD_LOGIC_VECTOR(22 downto 0);		--Register to hold normalized value of integer part of fixed-point output,extracted from mantissa part of input
variable fraction				: STD_LOGIC_VECTOR(22 downto 0);		--Register to hold fractional part of fixed-point output,extracted from mantissa part of input
variable temp					: STD_LOGIC_VECTOR(22 downto 0);		
variable decimalFracPart	: STD_LOGIC_VECTOR(outputWidth-1 downto 0);		
variable decimalIntPart		: STD_LOGIC_VECTOR(outputWidth-1 downto 0);
variable exponent				: INTEGER RANGE 0 to 255;				--Unsigned value of exponent,used for checking various cases.
variable exponent_val		: INTEGER RANGE -127 to 126;			--Biased value of exponent.
variable fw_val				: INTEGER RANGE 0 to outputWidth-1;	--Value of the index of the point in fixed-point output.

begin
exponent			:=	to_integer(unsigned(fp(30 downto 23)));
mantissa			:=	fp(22 downto 0);
sign				:= fp(31);
fw_val			:= to_integer(unsigned(fw));

if exponent = 255 then
	if mantissa= "000" & X"00000" then
		p_infinity <= not sign;
		n_infinity <= sign;
		NaN		  <= '0';
		decimal <= (others => '0');
	else
		p_infinity <= '0';
		n_infinity <= '0';
		NaN <= '1';
		decimal <= (others => '0');
	end if;

elsif exponent = 0 then
		p_infinity <= '0';
		n_infinity <= '0';
		NaN <= '0';
		decimal <= (others => '0');
	--exponent for every denormalized number is 2^-127. Therefore,in order to represent any denormalized number(except 0) is to extend the
	--output bit length into 128+22
	--denormalized case will be handled here
	--if fp(30 downto 0) = "000" & X"0000000" then
		--decimal <= X"00000000";
else

		p_infinity 				<= '0';
		n_infinity 				<= '0';
		NaN 						<= '0';
		
		
		exponent_val			:=exponent-127;
		mantissa					:=fp(22 downto 0);

		fraction					:= std_logic_vector(unsigned(mantissa) sll exponent_val);

		
		temp						:= std_logic_vector(unsigned(mantissa) srl(23-exponent_val));
		dec						:= ("100"&X"00000") OR  std_logic_vector(unsigned(temp) sll (22 - exponent_val));
		decimalFracPart		:= std_logic_vector(resize(unsigned(fraction) srl (23-fw_val),decimalFracPart'length));
		if sign='0' then
			decimalIntPart			:=  std_logic_vector(resize(unsigned(dec) srl (22-(fw_val+exponent_val)),decimalIntPart'length));
		else
			decimalIntPart			:= std_logic_vector(resize(signed(not(unsigned(dec) srl (22-(fw_val+exponent_val))))+1,decimalIntPart'length)) ;
		end if;
		
		decimal 					<= decimalFracPart OR decimalIntPart;

end if;

end process;





end Behavioral;


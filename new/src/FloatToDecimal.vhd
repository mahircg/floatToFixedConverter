
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.NUMERIC_STD.ALL;


entity FloatToDecimal is
    Port ( FP 			: in  STD_LOGIC_VECTOR (31 downto 0);
			  p_inf		: out STD_LOGIC;
			  n_inf		: out STD_LOGIC;
			  NaN			: out STD_LOGIC;
			  Decimal	: out REAL

	 );
end FloatToDecimal;

architecture Behavioral of FloatToDecimal is

function calculateMantissa(mantissa: STD_LOGIC_VECTOR(22 downto 0);isNormalized: STD_LOGIC) return REAL is
variable retValue : REAL := 0.0;
variable bitVal	: STD_LOGIC;
variable hiddenOne: INTEGER;
begin
if isNormalized='1' then
	hiddenOne := 1;
else
	hiddenOne := 0;
end if;

for i in 22 downto 0 loop
		bitVal  	:=mantissa(i);
		if bitVal='1' then
			retValue	:=retValue + (2.0 ** (-(REAL(22-i+hiddenOne))));
		end if;
	end loop;
return retValue + REAL(hiddenOne);
end calculateMantissa;

begin

process(FP)

variable sign				:	STD_LOGIC;
variable exponent_val	:	INTEGER RANGE -127 to 127;
variable exponent			:  INTEGER RANGE 0 to 255;
variable mantissa			:	STD_LOGIC_VECTOR(22 downto 0);
variable mantissaVal		: 	REAL := 0.0;

begin

exponent	:= TO_INTEGER(unsigned(FP(30 downto 23)));
sign		:= FP(31);
mantissa	:= FP(22 downto 0);

if exponent=255 then
	if mantissa="000"&X"00000" then
		p_inf <= not sign;
		n_inf	<= sign;
		NaN	<= '0';
		decimal <= 0.0;
	else
		p_inf <= '0';
		n_inf <= '0';
		NaN	<= '1';
		decimal <= 0.0;
	end if;
elsif exponent = 0 then
	p_inf	<='0';
	n_inf <= '0';
	NaN 	<= '0';
	exponent_val	:= exponent - 127;
	mantissaVal := calculateMantissa(mantissa,'0');
	if(sign='1') then
		mantissaVal:= -mantissaVal;
	end if;
	Decimal 		<= (2.0**REAL(exponent_val))*mantissaVal;

else
	p_inf	<='0';
	n_inf <= '0';
	NaN 	<= '0';
	exponent_val	:= exponent - 127;
	mantissaVal := calculateMantissa(mantissa,'1');
	if(sign='1') then
		mantissaVal:= -mantissaVal;
	end if;
	Decimal 		<= (2.0**REAL(exponent_val))*mantissaVal;
	
end if;


end process;

end Behavioral;


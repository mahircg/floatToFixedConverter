library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;
use IEEE.NUMERIC_STD.ALL;


entity DecimalToFloat is
	Port(	Decimal: in REAL;
			p_inf  : out STD_LOGIC;
			n_inf  : out STD_LOGIC;
			NaN	 : out STD_LOGIC;
			FP		 : out STD_LOGIC_VECTOR(31 downto 0)
	);
end DecimalToFloat;

architecture Behavioral of DecimalToFloat is

subtype MantissaType is STD_LOGIC_VECTOR(22 downto 0);
subtype BinaryFractionType is STD_LOGIC_VECTOR(149 downto 0);
subtype BinaryIntegerType is STD_LOGIC_VECTOR(127 downto 0);

function findFirstOneInInteger(intBinary: BinaryIntegerType) return INTEGER is
variable index: INTEGER RANGE -1 to 127 := -1;
begin
for i in 0 to 127 loop
	if(intBinary(i)='1') then
		index := i;
	end if;
end loop;
return index;
end findFirstOneInInteger;

function findFirstOneInFraction(fractionBinary: BinaryFractionType) return INTEGER is
variable index: INTEGER RANGE -1 to 149 := -1;
begin
for i in 0 to 149 loop
	if(fractionBinary(i)='1') then
		index := i;
	end if;
end loop;
return index;
end findFirstOneInFraction;

function calculateIntegerPart(int: REAL) return BinaryIntegerType is
variable integerBinary: BinaryIntegerType := (others => '0');
variable res			 : REAL;
begin
res := int;
for i in 0 to 127 loop
	if "MOD"(res,2.0) = 1.0 then
		integerBinary(i) := '1';
	else
		integerBinary(i) := '0';
	end if;
	res := FLOOR(res / 2.0);
end loop;
return integerBinary;
end calculateIntegerPart;


function calculateFractionalPart(fraction:REAL) return BinaryFractionType is
variable res: REAL;
variable fractionBinary: BinaryFractionType := (others => '0');
begin
res := fraction;
for i in 149 downto 0 loop
	res:=res * 2.0;
	if(res>1.0) then
		res:=res-1.0;
		fractionBinary(i) := '1';
	elsif res=1.0 then
		fractionBinary(i) := '1';
		exit;
	else
		fractionBinary(i):='0';
	end if;
		
end loop;
return fractionBinary;
end calculateFractionalPart;

begin

process(Decimal)
variable exponent_val: INTEGER RANGE -127 to 127;
variable mantissa		: STD_LOGIC_VECTOR(22 downto 0);
variable sign			: STD_LOGIC;
variable exponent		: STD_LOGIC_VECTOR(7 downto 0);

variable integerPart : REAL;
variable integerPartBinary: BinaryIntegerType;
variable fractionalPart: REAL;
variable fractionalPartBinary : BinaryFractionType;
variable integerFirstOneIndex : INTEGER;
variable fractionFirstOneIndex: INTEGER;
variable integerOneFound		: STD_LOGIC;
variable fractionOneFound		: STD_LOGIC;
variable p_infinity				: STD_LOGIC := '0';
variable n_infinity				: STD_LOGIC := '0';

begin

if(decimal<0.0) then
	sign := '1';
else
	sign :='0';
end if;

if sign = '0' then
	integerPart := FLOOR(decimal);
	fractionalPart := decimal-integerPart;
else
	integerPart := FLOOR(-decimal);
	fractionalPart := -decimal-integerPart;
end if;


fractionalPartBinary:=calculateFractionalPart(fractionalPart);
integerPartBinary   := calculateIntegerPart(integerPart);
integerFirstOneIndex:= findFirstOneInInteger(integerPartBinary);
fractionFirstOneIndex:=findFirstOneInFraction(fractionalPartBinary);

if integerFirstOneIndex = -1 then
	integerOneFound := '0';
else
	integerOneFound := '1';
end if;

if integerOneFound = '1' then	
	exponent_val:=integerFirstOneIndex;
	if exponent_val > 21 then
		mantissa(22 downto 0) := integerPartBinary(exponent_val-1 downto exponent_val-1-22);			
	else
		mantissa(22 downto 22-exponent_val-1) := integerPartBinary(exponent_val-1 downto 0);
		mantissa(22-exponent_val downto 22-exponent_val-(149-fractionFirstOneIndex)) := fractionalPartBinary(149 downto 149-fractionFirstOneIndex);
	end if;
else
	if fractionFirstOneIndex /= -1 then
		if fractionFirstOneIndex <= 23 then
			exponent_val:=-127;
			mantissa(22 downto 0) := fractionalPartBinary(fractionFirstOneIndex downto fractionFirstOneIndex-22);
		else
			exponent_val := fractionFirstOneIndex-149-1;
			mantissa(22 downto 0) := fractionalPartBinary(fractionFirstOneIndex-1 downto fractionFirstOneIndex-1-22);
		end if;
	else
		exponent_val :=-127;
		mantissa := (others => '0');
	end if;
end if;
	
exponent := std_logic_vector(to_unsigned((exponent_val + 127),8));


FP <= sign & exponent & mantissa;
p_inf <= p_infinity;
n_inf <= n_infinity;
NaN<='0';
end process;


end Behavioral;


--Decimal to single precision floating point converter: Rev. 2
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;


--Converts a decimal 2's complement number into single-precision floating-point number. Only denormalized number that can occur in a 32-bit decimal is zero,which is treated specially.
--Method works as follows;
--1) Find the index of first '1' in the input,if there is none,then number is simply zero. Steer the floating-point equilavent of zero(which is; exponent and mantissa are zero as well as sign bit)
--2) Index of first one gives how many times that the number should be shifted to get the mantissa. Since it is biased,it is added with 127.
--3) To get the mantissa, number is shifted with 32-(shiftNumber),which basically extends the number to the left.
--4) A 32-bit latch is used to store decimal,to check if it is negative. For negative numbers,we negate it first and set the sign bit of FP number.

--Priority encoder is used,so system is combinational.Insted of using a shifter and checking the leftmost bit in each cycle,this design finds the index of first 1 in one cycle.

--Revision 2:
--Since range of previous version is limited by 32 bit integer range,following extensions are made to design;
--1) Input is a fixed point number. Place of the point is determined by input fw. 0<=fw<=30
--2) Mantissa and exponent are calculated with a similar method to first revision.
--3) Apply arithmetic shift to input with fw bits.This gives the decimal part of the number(arithmetic shift is applied to preseve sign bit)
--4) Apply logical shift to input by 32-fw bits to get the fractional part of the number.
--5) Exponent is still given by the index of first 1 of decimal part.

--Revision 3:
-- By default,input is 128-bits to cover all(at least all normalized) numbers in IEEE single-precision floating-point format.
-- Forgotten in notes of revision 2,added here; integer part of fixed-point input is signed.
entity DecimalToFP is
	 Generic (
				inputWidth: INTEGER := 150;
				fwWidth   : INTEGER := 8
				);
    	 Port ( 	fw		  : in STD_LOGIC_VECTOR(fwWidth -1 downto 0);			-- Floating width
				decimal : in  STD_LOGIC_VECTOR (inputWidth-1 downto 0);		-- Fixed-point input
				fp : out  STD_LOGIC_VECTOR (31 downto 0));						-- Single precision floating-point output
end DecimalToFP;




		

architecture Behavioral of DecimalToFP is

--    COMPONENT PE_First_128Bit		--128-bit priority encoder doesn't sound good,does it :) This module causes considerable amount of delay,since it is in the critical path as well.Anyways,without delving into a
--    PORT(								--sequential design,it seems convenient to use.
--         inp : IN  std_logic_vector(inputWidth-1 downto 0);
--         outp : OUT  std_logic_vector(fwWidth -1 downto 0);
--         v : OUT  std_logic
--        );
--    END COMPONENT;
	 
procedure findFirst1
					(  inp : in STD_LOGIC_VECTOR(inputWidth-1 downto 0);
						index: out STD_LOGIC_VECTOR(fwWidth -1  downto 0);
						v : out STD_LOGIC   ) is
begin
	for i in inp'high downto inp'low loop
	if inp(i)='1' then 
		index:=std_logic_vector(to_unsigned(i,index'length));
		v :='1';
		exit;
	else
		index := (others => '0');
		v  := '0';
	end if;
end loop;
end findFirst1;
	






							
begin



--Priority_Encoder: PE_First_128Bit
--	PORT MAP(PEReg,shiftNumber,oneFlag);


process(decimal,fw)

variable PEReg				: STD_LOGIC_VECTOR(inputWidth-1 downto 0);	--Used in order to check the first one in uncomplemented form of input.
variable oneFlag			: STD_LOGIC;											--When asserted,it means there is no 1 in input.
variable shiftNumber		: STD_LOGIC_VECTOR(fwWidth -1  downto 0);		--Gives the index of first one in the input.
variable exponent			: STD_LOGIC_VECTOR(7 downto 0);		--Value of biased exponent.
variable mantissa			: STD_LOGIC_VECTOR(22 downto 0);		--Variable to hold mantissa part of floating point number.
variable temp	  			: STD_LOGIC_VECTOR(inputWidth-1 downto 0);		--Temp. register to hold intermediate values.
variable temp2	  			: STD_LOGIC_VECTOR(inputWidth-1 downto 0);
variable sign				: STD_LOGIC;											--Register for sign bit.
variable decimalReg		: STD_LOGIC_VECTOR(inputWidth-1 downto 0);	--Register to hold unsigned value of signed part of the input.
variable fraction			: STD_LOGIC_VECTOR(inputWidth-1 downto 0);	--Register to hold fractional part.

begin
sign					:=decimal(inputWidth-1);

-- Take two's complement and add 1 to input if it is signed,to achieve unsigned value.
if sign = '0' then
	decimalReg		:= 	to_stdlogicvector(to_bitvector(decimal) sra to_integer(unsigned(fw)));
else
	decimalReg		:=		std_logic_vector(unsigned(not(to_stdlogicvector(to_bitvector(decimal) sra to_integer(unsigned(fw))))) + 1) ;
end if;



--Get the fractional part from input in the leftmost bit of fraction register.
fraction 		:= 	std_logic_vector(unsigned(decimal) sll to_integer(inputWidth-unsigned(fw)));



--Cascade fractional part and unsigned value of integer part to check the first one in the input.
PEReg				:= 	to_stdlogicvector(to_bitvector(decimalReg) sll to_integer(unsigned(fw))) OR to_stdlogicvector(to_bitvector(fraction) srl to_integer(inputWidth-unsigned(fw)));
findFirst1(PEReg,shiftNumber,oneFlag);

if oneFlag='0' then		
	fp<=X"00000000";
else
if ( to_integer(unsigned(fw))-to_integer(unsigned(shiftNumber))) >= 127 then
	exponent := (others => '0');
	mantissa := std_logic_vector(unsigned(PEReg(22 downto 0)) sll to_integer(inputWidth-(unsigned(fw)+1))) ;
else
	exponent := std_logic_vector(to_signed(127,exponent'length)+(( signed(shiftNumber))- ( signed(fw))));		--Starting from the first zero,shift left or right until the first zero,which gives the value of exponent.
	temp		:= std_logic_vector(unsigned(decimalReg) sll to_integer(inputWidth-(('0'& signed(shiftNumber))-('0' & signed(fw))))); --Apply left shift to integer part,so that the magnitude is stored in upper-most bits.
	temp2		:=	std_logic_vector(unsigned(fraction) srl to_integer(signed(shiftNumber)-signed(fw)));										 --Apply right shift to fraction,until it is stored in upper-most bits after the point.
	mantissa:=temp(inputWidth-1 downto (inputWidth-1)-22) OR  temp2(inputWidth-1 downto (inputWidth-1)-22)  ; 							 --Generate the mantissa part,by cascading integer and fraction part of the input.
end if;
	fp<=sign&exponent&mantissa;
end if;

end process;

end Behavioral;


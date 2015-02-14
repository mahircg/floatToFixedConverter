--Decimal to single precision floating point converter: Rev. 2
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
--Note: To cover all IEE754 range,it seems like input has to be 128 bit + 1 sign bit !!!

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
entity DecimalToFP is
	 Generic (
				inputWidth: INTEGER := 128;
				fwWidth   : INTEGER := 7
				);
    Port ( 	fw		  : in STD_LOGIC_VECTOR(fwWidth -1 downto 0);
				decimal : in  STD_LOGIC_VECTOR (inputWidth-1 downto 0);
				fp : out  STD_LOGIC_VECTOR (31 downto 0));
end DecimalToFP;

architecture Behavioral of DecimalToFP is

    COMPONENT PE_First_128Bit
    PORT(
         inp : IN  std_logic_vector(inputWidth-1 downto 0);
         outp : OUT  std_logic_vector(fwWidth -1 downto 0);
         v : OUT  std_logic
        );
    END COMPONENT;

signal shiftNumber	: STD_LOGIC_VECTOR(fwWidth -1  downto 0);
signal oneFlag			: STD_LOGIC;
signal sign				: STD_LOGIC;
signal decimalReg		: STD_LOGIC_VECTOR(inputWidth-1 downto 0);
signal PEReg			: STD_LOGIC_VECTOR(inputWidth-1 downto 0);
signal fraction		: STD_LOGIC_VECTOR(inputWidth-1 downto 0);
signal inputReg		: STD_LOGIC_VECTOR(inputWidth-1 downto 0);

							
begin

decimalReg		<= 	to_stdlogicvector(to_bitvector(decimal) sra to_integer(unsigned(fw))) when decimal(inputWidth-1)='0'	
else 						std_logic_vector(unsigned(not(to_stdlogicvector(to_bitvector(decimal) sra to_integer(unsigned(fw))))) + 1) ;



fraction 		<= 	std_logic_vector(unsigned(decimal) sll to_integer(inputWidth-unsigned(fw)));

PEReg				<= 	to_stdlogicvector(to_bitvector(decimalReg) sll to_integer(unsigned(fw))) OR to_stdlogicvector(to_bitvector(fraction) srl to_integer(inputWidth-unsigned(fw)));

sign<=decimal(inputWidth-1);

Priority_Encoder: PE_First_128Bit
	PORT MAP(PEReg,shiftNumber,oneFlag);



process(decimal,decimalReg,oneFlag,sign,shiftNumber,fw,fraction)

variable exponent: STD_LOGIC_VECTOR(7 downto 0);
variable mantissa: STD_LOGIC_VECTOR(22 downto 0);
variable temp	  : STD_LOGIC_VECTOR(inputWidth-1 downto 0);
variable temp2	  : STD_LOGIC_VECTOR(inputWidth-1 downto 0);
variable offset  : NATURAL;

begin
if oneFlag='0' then
	fp<=X"00000000";
else
	exponent := std_logic_vector(to_signed(127,exponent'length)+(('0'& signed(shiftNumber))- ('0'& signed(fw))));
	temp		:= std_logic_vector(unsigned(decimalReg) sll to_integer(inputWidth-(('0'& signed(shiftNumber))-('0' & signed(fw)))));
	temp2		:=	std_logic_vector(unsigned(fraction) srl to_integer(signed(shiftNumber)-signed(fw)));	
	mantissa:=temp(inputWidth-1 downto (inputWidth-1)-22) OR  temp2(inputWidth-1 downto (inputWidth-1)-22)  ; 
	fp<=sign&exponent&mantissa;
end if;

end process;

end Behavioral;


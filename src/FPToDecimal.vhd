
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;


entity FPToDecimal is
    Port ( fp 					: in  	STD_LOGIC_VECTOR (31 downto 0);
			  fw					: in  	STD_LOGIC_VECTOR (4 downto 0);
			  NaN					: out 	STD_LOGIC;
			  p_infinity		: out 	STD_LOGIC;
			  n_infinity		: out 	STD_LOGIC;
           decimal 			: out  	STD_LOGIC_VECTOR (31 downto 0));
end FPToDecimal;

architecture Behavioral of FPToDecimal is

begin

process(fp,fw)

variable sign					: STD_LOGIC;
--variable exponent_val		: STD_LOGIC_VECTOR(7 downto 0);
variable mantissa				: STD_LOGIC_VECTOR(22 downto 0);
variable dec					: STD_LOGIC_VECTOR(22 downto 0);
variable fraction				: STD_LOGIC_VECTOR(22 downto 0);
variable temp					: STD_LOGIC_VECTOR(22 downto 0);
variable decimalFracPart	: STD_LOGIC_VECTOR(31 downto 0);
variable decimalIntPart		: STD_LOGIC_VECTOR(31 downto 0);
variable exponent				: INTEGER RANGE 0 to 255;
variable exponent_val		: INTEGER RANGE -127 to 126;	
variable fw_val				: INTEGER RANGE 0 to 31;

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
		decimalFracPart		:= "0"& X"00" & std_logic_vector(unsigned(fraction) srl (23-fw_val));
		if sign='0' then
			decimalIntPart			:= "0"& X"00" & std_logic_vector(unsigned(dec) srl (22-(fw_val+exponent_val)));
		else
			decimalIntPart			:= "1"& X"FF" & std_logic_vector(unsigned(not(unsigned(dec) srl (22-(fw_val+exponent_val))))+1) ;
		end if;
		
		decimal 					<= decimalFracPart OR decimalIntPart;

end if;

end process;





end Behavioral;


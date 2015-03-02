library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

ENTITY Dummy_Module IS
	PORT(
		CLK			: IN	std_logic;
		enable		: IN	std_logic;
		edge		: IN	std_logic;
		operand		: IN	std_logic_vector(31 downto 0);

		result		: OUT	std_logic_vector(31 downto 0);
		valid		: OUT	std_logic
		);
END Dummy_Module;

ARCHITECTURE arch OF Dummy_Module IS
	TYPE mem IS ARRAY(0 to 31) OF std_logic_vector(31 downto 0);
	signal memory		: mem;
	
	TYPE STATE_TYPE IS (init, ready, input, output);
	signal state : STATE_TYPE := init;
	
	signal values_stored  : unsigned(7 downto 0);
	signal values_written : unsigned(7 downto 0);
BEGIN
	PROCESS(CLK)
	variable temp_counter : unsigned(7 downto 0);
	BEGIN
		if (CLK'event and CLK = edge)
		then
			case state is
			when init =>
				--Set every output signal 
				result <= (others => '0');
				valid <= '0';
				--Set every internal signal
				memory <= (others => (others => '0'));
				values_stored  <= x"00";
				values_written <= x"00";
				state <= ready;
			when ready =>
				--Set every output signal
				result <= (others => '0');
				valid <= '0';
				--Set internal signals
				memory <= (others => (others => '0'));
				values_stored  <= x"00";
				values_written <= x"00";
				--Wait for input values
				--When there is one, store it and change state to input
				if(enable = '1')then
					memory(0) <= operand;
					values_stored  <= x"01";
					state <= input;
				end if;
			when input =>
				--Set every output signal
				result <= (others => '0');
				valid <= '0';
				--Store input values to memory
				--When there are no more, go to calc-state
				if(enable = '1')
				then
					memory(to_integer(values_stored)) <= operand;
					values_stored <= values_stored + 1;
				else
					state <= output;
				end if;
			when output =>
				--Write the result to the output
				--When everything has been written or this process has been interrupted go back to ready state
				if(enable = '0')
				then
					if(values_written /= values_stored)
					then
						result <= memory(to_integer(values_written));
						valid <= '1';
						values_written <= values_written + 1;
					else
						valid <= '0';
						state <= ready;
					end if;
				else
					state <= ready;
				end if;
			end case;
		end if;
	END PROCESS;
END arch;

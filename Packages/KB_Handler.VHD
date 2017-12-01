-----------------------------------------------------------------------------------
--	Alexandre Luiz Brisighello Filho 	- alexandre.brisighello@gmail.com		 --
--	Andre Nakagaki Filliettaz			- andrentaz@gmail.com					 --
--																				 --
--	Project: sokoban-altera														 --
--	file: KB_Handler.vhd														 --
--	description: Receives a pararell data from the keyboard controller and		 --
--	converts this data to a format used on the game. Only one key can be		 --
--  pressed at a time.															 --
-----------------------------------------------------------------------------------

LIBRARY IEEE;
USE	IEEE.STD_LOGIC_1164.ALL;
USE work.package_KB_Handler.all;

ENTITY	KB_Handler	IS
	PORT
		(
			------------------------	Clock Input	 	------------------------
			CLOCK_27: 	IN		STD_LOGIC_VECTOR (1 downto 0);		--	24 MHz

			------------------------	Push Button		------------------------
			resetn	:	IN		STD_LOGIC;

			------------------------	PS2		--------------------------------
			PS2_DAT :	INOUT	STD_LOGIC;	--	PS2 Data
			PS2_CLK	:	INOUT	STD_LOGIC;	--	PS2 Clock

			------------------------	LOGIC	--------------------------------
			RD		:	IN		STD_LOGIC;	--	Receive the Signal to Erase teh Buffer
			READY	:	OUT		STD_LOGIC;	--	Warn the Logic Controller when the KB was read
			COMMAND	:	OUT		STD_LOGIC_VECTOR(2 DOWNTO 0)	--	WHICH COMMAND WAS TAPPED
		);
END KB_Handler	;
----------------------------------------------------------------------------------------------------
ARCHITECTURE Behavior OF KB_Handler IS

	--------------------------------	SIGNALS		------------------------------------
	SIGNAL	TMP						:	STD_LOGIC_VECTOR(15 DOWNTO 0);	--	It holds the useful bits
	SIGNAL	key_pressed				:	STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL	lights, key_on, CMD_TMP	:	STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL	CLOCKHZ, sctrl			:	STD_LOGIC;
BEGIN
	READY	<=	sctrl	;

	--	Key Board Controller
--	kbdex	:	kbdex_ctrl	GENERIC	MAP(27000)	PORT MAP(
kbdex	:	entity work.kbdex_ctrl	GENERIC	MAP(2700)	PORT MAP(
		PS2_DAT, PS2_CLK, CLOCK_27(0), '1', resetn, lights(1) & lights(2) & lights(0),
		key_on, key_code(15 DOWNTO 0) => key_pressed
	);
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
	-- Playing with lights! xD
	PROCESS(CLOCKHZ, resetn, key_on)
		VARIABLE dir : BOOLEAN := FALSE;
	BEGIN
		IF(RISING_EDGE(CLOCKHZ)) THEN
			IF lights(2) = '1' THEN
				dir := TRUE;
			ELSIF lights(0) = '1' THEN
				dir := false;
			END IF;
			IF key_on = "000" THEN
				IF not dir THEN
					lights <= lights(1 DOWNTO 0) & lights(2);
				ELSE
					lights <= lights(0) & lights(2 DOWNTO 1);
				END IF;
			END IF;
		END IF;
		IF resetn = '0' THEN
			dir := false;
			lights <= "001";
		END IF;
	END PROCESS;

	-- Hz clock
	PROCESS(CLOCK_27(0))
		CONSTANT F_HZ : INTEGER := 5;

--		CONSTANT DIVIDER : INTEGER := 27000000/F_HZ;
		CONSTANT DIVIDER : INTEGER := 2700000/F_HZ;
		variable count : INTEGER RANGE 0 TO DIVIDER := 0;
	BEGIN
		IF(RISING_EDGE(CLOCK_27(0))) THEN
			IF count < DIVIDER / 2 THEN
				CLOCKHZ <= '1';
			ELSE
				CLOCKHZ <= '0';
			END IF;
			IF count = DIVIDER THEN
				count := 0;
			END IF;
			count := count + 1;
		END IF;
	END PROCESS;
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

	TMP	<=	key_pressed;
	WITH TMP SELECT
		CMD_TMP	<=	"000"	WHEN	"1110000001011010",
					"001"	WHEN	"0000000001101011",
					"010"	WHEN	"0000000001110101",
					"011"	WHEN	"0000000001110010",
					"100"	WHEN	"0000000001110100",
					"111"	WHEN	OTHERS;

	PROCESS(CLOCK_27(0), RD)
		VARIABLE	CMD_BUFFER	:	STD_LOGIC_VECTOR(2 DOWNTO 0);
		VARIABLE 	NAO_COPIA	:	STD_LOGIC_VECTOR(2 DOWNTO 0);

	BEGIN
		IF(RD = '1') THEN						-- RD indicates the command was already read
			sctrl	<= '0';
			COMMAND	<=	(OTHERS	=>	'1');
		ELSIF(CLOCK_27(0)'EVENT AND CLOCK_27(0) = '1' AND sctrl = '0') THEN

				IF(NAO_COPIA = CMD_TMP) THEN	-- If it's the same command, ignore

				ELSE 							-- If not, command matters
				CMD_BUFFER	:= CMD_TMP	;
				sctrl		<=	'1';
				NAO_COPIA	:= CMD_TMP	;
				END IF	;

		END	IF	;
		COMMAND	<=	CMD_BUFFER	;
	END PROCESS	;
END Behavior	;
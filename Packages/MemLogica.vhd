-----------------------------------------------------------------------------------
--	Alexandre Luiz Brisighello Filho 	- alexandre.brisighello@gmail.com		 --
--	Andre Nakagaki Filliettaz			- andrentaz@gmail.com					 --
--																				 --
--	Project: sokoban-altera														 --
--	file: MemLogica.vhd															 --
--	description: Stores the logic matrix of a given stage. Receives state		 --
--	modifications e is acessed directly by DisplayWorks.vhd to obtain			 --
--	information regarding the video output.										 --
-----------------------------------------------------------------------------------

LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- Double read and simple write

ENTITY MemLogica IS
	GENERIC (
		WORDSIZE		: NATURAL	:= 3;
		BITS_OF_ADDR	: NATURAL	:= 8;			-- 8 bits, labirynth has 18x13, result: 1110 1010
		MIF_FILE		: STRING	:= "stage.mif"
	);
	PORT (
		clock   		: IN	STD_LOGIC;
		we      		: IN	STD_LOGIC;
		address 		: IN	STD_LOGIC_VECTOR(BITS_OF_ADDR-1 DOWNTO 0);
		datain  		: IN	STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0);
		dataout 		: OUT	STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0);
		address2        : in  	integer range 0 to 255;
		dataout2		: OUT	STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE RTL OF MemLogica IS
	TYPE Memo_Array IS ARRAY (0 TO 2**BITS_OF_ADDR-1) OF
			STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0);
	ATTRIBUTE ram_init_file	:	string	;
	SIGNAL	Data	:	Memo_Array	;
	SIGNAL	read_a	:	STD_LOGIC_VECTOR(BITS_OF_ADDR-1 DOWNTO 0)	;
	SIGNAL	read_b	:	integer range 0 to 255;

	ATTRIBUTE ram_init_file OF Data	:	SIGNAL IS	MIF_FILE	;
BEGIN
	PROCESS(clock)
	BEGIN
		IF(clock'EVENT AND clock = '1')	THEN
			IF(we = '1')	THEN
				Data(TO_INTEGER(UNSIGNED(address))) <= datain	;
			END IF	;

			read_a	<=	address;
			read_b  <=  address2;

		END IF	;
	END PROCESS	;

	dataout			<=	Data(TO_INTEGER(UNSIGNED(read_a)))	;
	dataout2		<=	Data(address2);

END ARCHITECTURE RTL;
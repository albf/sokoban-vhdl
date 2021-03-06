-----------------------------------------------------------------------------------
--	Alexandre Luiz Brisighello Filho 	- alexandre.brisighello@gmail.com		 --
--	Andre Nakagaki Filliettaz			- andrentaz@gmail.com					 --
--																				 --
--	Project: sokoban-altera														 --
--	file: ReadMemory.vhd														 --
--	description: Read-only memory, used to store bitmap information.			 --
-----------------------------------------------------------------------------------

LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- Simple memory, just allows reading, used a bitmap bank

ENTITY ReadMemory IS
	GENERIC (
		WORDSIZE		: NATURAL	:= 4;
		BITS_OF_ADDR	: NATURAL	:= 2;
		MIF_FILE		: STRING	:= "time.mif"
	);
	PORT (
		clock   		: IN	STD_LOGIC;
		address 		: IN	STD_LOGIC_VECTOR(BITS_OF_ADDR-1 DOWNTO 0);
		dataout 		: OUT	STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE RTL OF ReadMemory IS
	TYPE Memo_Array IS ARRAY (0 TO 2**BITS_OF_ADDR-1) OF
			STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0);
	ATTRIBUTE ram_init_file	:	string	;
	SIGNAL	Data	:	Memo_Array	;
	SIGNAL	read_a	:	STD_LOGIC_VECTOR(BITS_OF_ADDR-1 DOWNTO 0)	;

	ATTRIBUTE ram_init_file OF Data	:	SIGNAL IS	MIF_FILE	;
BEGIN
	PROCESS(clock)
	BEGIN
		IF(clock'EVENT AND clock = '1')	THEN
			read_a	<=	address;

		END IF	;
	END PROCESS	;

	dataout			<=	Data(TO_INTEGER(UNSIGNED(read_a)))	;

END ARCHITECTURE RTL;
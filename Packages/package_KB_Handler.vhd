-----------------------------------------------------------------------------------
--	Alexandre Luiz Brisighello Filho 	- alexandre.brisighello@gmail.com		 --
--	Andre Nakagaki Filliettaz			- andrentaz@gmail.com					 --
--																				 --
--	Project: sokoban-altera														 --
--	file: package_KB_Handler.vhd												 --
-----------------------------------------------------------------------------------

LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

PACKAGE package_KB_Handler IS

	COMPONENT	kbdex_ctrl
		GENERIC(
			clkfreq	:	INTEGER
		);
		PORT(
			ps2_data	:	INOUT	STD_LOGIC;
			ps2_clk		:	INOUT	STD_LOGIC;
			clk			:	IN		STD_LOGIC;
			en			:	IN		STD_LOGIC;
			resetn		:	IN		STD_LOGIC;
			lights		:	IN		STD_LOGIC_VECTOR(2 DOWNTO 0);
			key_on		:	OUT		STD_LOGIC_VECTOR(2 DOWNTO 0);
			key_code	:	OUT		STD_LOGIC_VECTOR(47 DOWNTO 0)
		);
	END COMPONENT	;


END package_KB_Handler ;
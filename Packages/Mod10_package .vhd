-----------------------------------------------------------------------------------
--	Alexandre Luiz Brisighello Filho 	- alexandre.brisighello@gmail.com		 --
--	Andre Nakagaki Filliettaz			- andrentaz@gmail.com					 --
--																				 --
--	Project: sokoban-altera														 --
--	file: Mod10_package.vhd														 --
-----------------------------------------------------------------------------------

LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

PACKAGE Mod10_package IS

COMPONENT Mod10
GENERIC (
		Inicial_stage1		: STD_LOGIC_VECTOR(3 DOWNTO 0)	:= "0011";
		Inicial_stage2		: STD_LOGIC_VECTOR(3 DOWNTO 0)	:= "0011";
		Inicial_stage3		: STD_LOGIC_VECTOR(3 DOWNTO 0)	:= "0011";
		Inicial_stage4		: STD_LOGIC_VECTOR(3 DOWNTO 0)	:= "0011"
	);
	PORT ( 	Clock 		: IN STD_LOGIC ;
		Clear			: IN STD_LOGIC ;
		Mode			: IN STD_LOGIC;	-- 0 conta, 1 para!
		Enable			: IN STD_LOGIC;
		Q				: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		Zerou			: OUT STD_LOGIC;
		MUX				: IN STD_LOGIC_VECTOR (1 DOWNTO 0));
END COMPONENT ;

END Mod10_package ;

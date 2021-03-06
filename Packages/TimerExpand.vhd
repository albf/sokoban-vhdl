-----------------------------------------------------------------------------------
--	Alexandre Luiz Brisighello Filho 	- alexandre.brisighello@gmail.com		 --
--	Andre Nakagaki Filliettaz			- andrentaz@gmail.com					 --
--																				 --
--	Project: sokoban-altera														 --
--	file: TimerExpand.vhd														 --
--	description: Multipler module, that calculates x*bitmap^2 by values between	 --
--  10 and 19. Used to convert time entries to the bitmap representations.		 --
-----------------------------------------------------------------------------------

LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;

ENTITY TimerExpand IS
	PORT (
		Entrada			: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		Saida			: OUT STD_LOGIC_VECTOR (12 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE Behavior OF TimerExpand IS

BEGIN
	with Entrada select
	Saida <= 	"0100011001010" when "0000",	-- caso 0, 10*bitmap_size^2
				"0100110101011" when "0001",	-- caso 1, 11*bitmap_size^2
				"0101010001100" when "0010",	-- caso 2, 12*bitmap_size^2
				"0101101101101" when "0011",	-- caso 3, 13*bitmap_size^2
				"0110001001110" when "0100",	-- caso 4, 14*bitmap_size^2
				"0110100101111" when "0101",	-- caso 5, 15*bitmap_size^2
				"0111000010000" when "0110",	-- caso 6, 16*bitmap_size^2
				"0111011110001" when "0111",	-- caso 7, 17*bitmap_size^2
				"0111111010010" when "1000",	-- caso 8, 18*bitmap_size^2
				"1000010110011" when OTHERS;	-- caso 9, 19*bitmap_size^2

END ARCHITECTURE Behavior;
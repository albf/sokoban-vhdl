-----------------------------------------------------------------------------------
--	Alexandre Luiz Brisighello Filho 	- RA:101350								 --
--	Andre Nakagaki Filliettaz			- RA:104595								 --
--																				 --
--	MC613 - Projeto final : Sokoban												 --
--	Arquivo : TimeExpand.vhdl													 --
--	Descri��o : Trata-se de um multiplicador por x*bitmap^2 para valores entre   --
--	10 e 19. Usado para converter as entradas de tempo para as representa��es de --
--  bitmap.																		 --
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
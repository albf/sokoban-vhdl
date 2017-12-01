-----------------------------------------------------------------------------------
--	Alexandre Luiz Brisighello Filho 	- alexandre.brisighello@gmail.com		 --
--	Andre Nakagaki Filliettaz			- andrentaz@gmail.com					 --
--																				 --
--	Project: sokoban-altera														 --
--	file: Mod10.vhd																 --
--	description: Modulo 10 counter, where the counting is made in a decreasing	 --
-- order.  It has clear with conditionals to load initial values for each stage	 --
-----------------------------------------------------------------------------------

LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all ;

ENTITY Mod10 IS
GENERIC (	-- Valores iniciais
		Inicial_stage1		: STD_LOGIC_VECTOR(3 DOWNTO 0)	:= "0011";
		Inicial_stage2		: STD_LOGIC_VECTOR(3 DOWNTO 0)	:= "0011";
		Inicial_stage3		: STD_LOGIC_VECTOR(3 DOWNTO 0)	:= "0011";
		Inicial_stage4		: STD_LOGIC_VECTOR(3 DOWNTO 0)	:= "0011"
	);
	PORT ( 	Clock 		: IN STD_LOGIC ;
		Clear			: IN STD_LOGIC ;
		Mode			: IN STD_LOGIC;							-- 0 counts, 1 stops!
		Enable			: IN STD_LOGIC;							-- Allow it to work or not
		Q				: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);	-- Numbers output
		Zerou			: OUT STD_LOGIC;						-- Indicates if had reached 0
		MUX				: IN STD_LOGIC_VECTOR (1 DOWNTO 0));	-- Mux to select the stage
END Mod10;

ARCHITECTURE Behavior OF Mod10 IS

BEGIN

-- Mode 0 -> Add, normally
-- Mode 1 -> Stops
-- Set with Clear, passed by Generic

Refresh: Process ( Clock, Mode )
	variable count : STD_LOGIC_VECTOR (3 DOWNTO 0);
Begin
	if (Clear = '0') Then				-- Check which value should start with
			if (MUX = "00") THEN
				count := Inicial_stage1;
			elsif (MUX ="01") THEN
				count := Inicial_stage2;
			elsif (MUX ="10") THEN
				count := Inicial_stage3;
			else
				count := Inicial_stage4;
			END IF;

				Zerou <= '0';			-- Correction values for initialization
			IF ( count = 0 ) THEN
				Zerou<='1';
			END IF;
			q<=count;

	elsif (Clock'Event AND Clock='1') Then
		if(Mode = '0' AND Enable = '1') THEN
			if ( count = 1 ) Then
				count := "0000";		-- set to nine to the next counting
				Zerou<='1';
				q<= count;
			elsif ( count = 0 ) Then
				count := "1001";		-- set to nine to the next counting
				Zerou<='0';
				q<= count;
			else
				count := count - 1;
				Zerou<='0';
				q<= count;
			end if;
		end if;
	end if;
end process;

END Behavior ;

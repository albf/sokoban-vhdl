-----------------------------------------------------------------------------------
--	Alexandre Luiz Brisighello Filho 	- RA:101350								 --
--	Andre Nakagaki Filliettaz			- RA:104595								 --
--																				 --
--	MC613 - Projeto final : Sokoban												 --
--	Arquivo : DivClock.vhdl														 --
--	Descri��o : Divisor de clock, usado para conntar contar os segundos no   	 --
--	projeto. Trabalha sincronamente com um clock de 2.7 mhz.				  	 --
-----------------------------------------------------------------------------------

LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_unsigned.all ;

ENTITY DivClock IS
	PORT ( 		Clock : IN STD_LOGIC ;	
				Clear : IN STD_LOGIC;
				Q : OUT STD_LOGIC) ;		
END DivClock ;

ARCHITECTURE Behavior OF DivClock IS
BEGIN

PROCESS ( Clock )	
	VARIABLE COUNT: STD_LOGIC_VECTOR (26 DOWNTO 0);
	
	BEGIN
	IF (clear = '0') THEN
			COUNT := "000000000000000000000000001";
			Q <= '0';
	
	ELSIF ( RISING_EDGE(Clock) ) THEN
		IF (COUNT < 1350001 ) THEN		-- count < (n/2)+1 -- novo 27000000/10 = 2 700 000
			COUNT := COUNT + 1;
			Q<='0';

		ELSIF ( COUNT < 2700000 ) THEN   -- count < n
			COUNT := COUNT+1;
			Q <='1';

		ELSE
			COUNT := "000000000000000000000000001";
		END IF;
	END IF;
	
END PROCESS ;

END Behavior ;
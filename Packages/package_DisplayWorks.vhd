LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

PACKAGE package_DisplayWorks IS

COMPONENT ReadMemory
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
END COMPONENT ;

COMPONENT TimerExpand
	PORT (
		Entrada			: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		Saida			: OUT STD_LOGIC_VECTOR (12 DOWNTO 0)
	);
END COMPONENT ;

COMPONENT vgacon IS
		GENERIC (
			NUM_HORZ_PIXELS : NATURAL := 128;	-- Number of horizontal pixels
			NUM_VERT_PIXELS : NATURAL := 96		-- Number of vertical pixels
		);
		PORT (
			clk27M, rstn              : IN STD_LOGIC;
			write_clk, write_enable   : IN STD_LOGIC;
			write_addr                : IN INTEGER RANGE 0 TO NUM_HORZ_PIXELS * NUM_VERT_PIXELS - 1;
			data_in                   : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			red, green, blue          : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			hsync, vsync              : OUT STD_LOGIC
		);
	END COMPONENT;

END package_DisplayWorks ;

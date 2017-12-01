-----------------------------------------------------------------------------------
--	Alexandre Luiz Brisighello Filho 	- RA:101350								 --
--	Andre Nakagaki Filliettaz			- RA:104595								 --
--																				 --
--	MC613 - Projeto final : Sokoban												 --
--	Arquivo : Sokoban.vhdl														 --
--	Descrição : Top level de todo o projeto, sem debugs.						 --
-----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.package_Sokoban.all;
USE ieee.std_logic_signed.all;

ENTITY Sokoban IS
	PORT (
	-- Clock e Clear
	clock							: IN	STD_LOGIC;		-- clock
	clear							: IN	STD_LOGIC;		-- vai para o estado inicial, de esperar comando
	
	-- Saidas de VGA_Con
	red, green, blue 	: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
	hsync, vsync		: OUT STD_LOGIC;
	
	-- PS2
	PS2_DAT :	INOUT	STD_LOGIC;	--	PS2 Data
	PS2_CLK	:	INOUT	STD_LOGIC	--	PS2 Clock

	);
END ENTITY;

ARCHITECTURE Behavior OF Sokoban IS


-- Constantes
CONSTANT CONS_CLOCK_DIV : INTEGER := 10; --10; --100; --10000; --100000; -- 2000000;

-- Para mudança de clock
SIGNAL slow_clock : STD_LOGIC;

-- Sobre o Clear Lógico
SIGNAL l_clear	  : STD_LOGIC;
SIGNAL r_clear	  : STD_LOGIC;

-- Saida do MUX de memória
SIGNAL Log_Mem_Enable				: STD_LOGIC;						-- Log para memória ligada com a Lógica
SIGNAL Log_Mem_Adress				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL Log_Mem_DataIn				: STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL Log_Mem_DataOut				: STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL Vid_Mem_Adress				: integer range 0 to 255; 	-- Vid para memória ligada com o Vídeo
SIGNAL Vid_Mem_DataOut				: STD_LOGIC_VECTOR(2 DOWNTO 0);  

SIGNAL MUX_SIGNAL					: STD_LOGIC_VECTOR(1 DOWNTO 0);

-- Memória 1.
SIGNAL Log_Mem_Enable1				: STD_LOGIC;						-- Log para memória ligada com a Lógica
SIGNAL Log_Mem_Adress1				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL Log_Mem_DataIn1				: STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL Log_Mem_DataOut1				: STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL Vid_Mem_Adress1				: integer range 0 to 255; 	-- Vid para memória ligada com o Vídeo
SIGNAL Vid_Mem_DataOut1				: STD_LOGIC_VECTOR(2 DOWNTO 0);  

-- Memória 2.
SIGNAL Log_Mem_Enable2				: STD_LOGIC;						-- Log para memória ligada com a Lógica
SIGNAL Log_Mem_Adress2				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL Log_Mem_DataIn2				: STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL Log_Mem_DataOut2				: STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL Vid_Mem_Adress2				: integer range 0 to 255; 	-- Vid para memória ligada com o Vídeo
SIGNAL Vid_Mem_DataOut2				: STD_LOGIC_VECTOR(2 DOWNTO 0); 

-- Memória 3.
SIGNAL Log_Mem_Enable3				: STD_LOGIC;						-- Log para memória ligada com a Lógica
SIGNAL Log_Mem_Adress3				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL Log_Mem_DataIn3				: STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL Log_Mem_DataOut3				: STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL Vid_Mem_Adress3				: integer range 0 to 255; 	-- Vid para memória ligada com o Vídeo
SIGNAL Vid_Mem_DataOut3				: STD_LOGIC_VECTOR(2 DOWNTO 0); 

-- Memória 4.
SIGNAL Log_Mem_Enable4				: STD_LOGIC;						-- Log para memória ligada com a Lógica
SIGNAL Log_Mem_Adress4				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL Log_Mem_DataIn4				: STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL Log_Mem_DataOut4				: STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL Vid_Mem_Adress4				: integer range 0 to 255; 	-- Vid para memória ligada com o Vídeo
SIGNAL Vid_Mem_DataOut4				: STD_LOGIC_VECTOR(2 DOWNTO 0); 

-- Sinais referente ao timer		
SIGNAL Time_Fim						: STD_LOGIC;
SIGNAL Time_Unidade_OUT				: STD_LOGIC_VECTOR (3 DOWNTO 0);
SIGNAL Time_Dezena_OUT				: STD_LOGIC_VECTOR (3 DOWNTO 0); 	
SIGNAL Time_Centena_OUT				: STD_LOGIC_VECTOR (3 DOWNTO 0);

-- Sinais do teclado
SIGNAL Teclado_Ready				: STD_LOGIC;		-- Avisa se há comandos para serem lidos no teclado. Se tiver, fica 1.
SIGNAL Teclado_Entry				: STD_LOGIC_VECTOR (2 DOWNTO 0);		-- Passa o codigo do teclado
SIGNAL Teclado_Red					: STD_LOGIC;


BEGIN

-- OR do clear assíncrono com o sinal de nova "fase"  
 r_clear <= NOT ((NOT l_clear) OR (NOT clear));  
 
 -- Divisor de clock
clock_divider:
	PROCESS (clock, clear)
		VARIABLE i : INTEGER := 0;
	BEGIN
		IF (clear = '0') THEN
			i := 0;
			slow_clock <= '0';
		ELSIF (rising_edge(clock)) THEN
			IF (i <= CONS_CLOCK_DIV/2) THEN
				i := i + 1;
				slow_clock <= '0';
			ELSIF (i < CONS_CLOCK_DIV-1) THEN
				i := i + 1;
				slow_clock <= '1';
			ELSE		
				i := 0;
			END IF;	
		END IF;
	END PROCESS;

-- Instancia das Memória Lógicas : Cada uma representa uma fase.
Memoria_Logica1: ENTITY WORK.MemLogica
	generic MAP( WORDSIZE => 3, BITS_OF_ADDR => 8, MIF_FILE => "stage1.mif")
	PORT MAP (slow_clock, Log_Mem_Enable1, Log_Mem_Adress1, Log_Mem_DataIn1, Log_Mem_DataOut1, Vid_Mem_Adress1, Vid_Mem_DataOut1 );

Memoria_Logica2: ENTITY WORK.MemLogica
	generic MAP( WORDSIZE => 3, BITS_OF_ADDR => 8, MIF_FILE => "stage2.mif")
	PORT MAP (slow_clock, Log_Mem_Enable2, Log_Mem_Adress2, Log_Mem_DataIn2, Log_Mem_DataOut2, Vid_Mem_Adress2, Vid_Mem_DataOut2 );

Memoria_Logica3: ENTITY WORK.MemLogica
	generic MAP( WORDSIZE => 3, BITS_OF_ADDR => 8, MIF_FILE => "stage3.mif")
	PORT MAP (slow_clock, Log_Mem_Enable3, Log_Mem_Adress3, Log_Mem_DataIn3, Log_Mem_DataOut3, Vid_Mem_Adress3, Vid_Mem_DataOut3 );

Memoria_Logica4: ENTITY WORK.MemLogica
	generic MAP( WORDSIZE => 3, BITS_OF_ADDR => 8, MIF_FILE => "stage4.mif")
	PORT MAP (slow_clock, Log_Mem_Enable4, Log_Mem_Adress4, Log_Mem_DataIn4, Log_Mem_DataOut4, Vid_Mem_Adress4, Vid_Mem_DataOut4 );


-- Instancia o Mux de memória
Mux_Memoria: ENTITY WORK.MemLogica_Mux
	PORT MAP (Log_Mem_Enable1, Log_Mem_Adress1,	Log_Mem_DataIn1, Log_Mem_DataOut1, Vid_Mem_Adress1,	Vid_Mem_DataOut1, 
	Log_Mem_Enable2, Log_Mem_Adress2,	Log_Mem_DataIn2, Log_Mem_DataOut2, Vid_Mem_Adress2,	Vid_Mem_DataOut2,
	Log_Mem_Enable3, Log_Mem_Adress3, Log_Mem_DataIn3, Log_Mem_DataOut3, Vid_Mem_Adress3, Vid_Mem_DataOut3,
	Log_Mem_Enable4, Log_Mem_Adress4, Log_Mem_DataIn4, Log_Mem_DataOut4, Vid_Mem_Adress4, Vid_Mem_DataOut4,
	MUX_SIGNAL,
	Log_Mem_Enable,	Log_Mem_Adress,	Log_Mem_DataIn,	Log_Mem_DataOut, Vid_Mem_Adress, Vid_Mem_DataOut);


-- Instancia o Timer
Timer_Contador:	ENTITY WORK.Timer
	GENERIC MAP (	Centena_Stage1 => "0000",	-- Valores Iniciais. Usar tempo+1;
					Dezena_Stage1 => "0110",
					Unidade_Stage1 => "0001",
					Centena_Stage2 => "0010",
					Dezena_Stage2 => "0000",
					Unidade_Stage2 => "0001",
					Centena_Stage3 => "0001",
					Dezena_Stage3 => "1000",
					Unidade_Stage3 => "0001",
					Centena_Stage4 => "0011",
					Dezena_Stage4 => "0000",
					Unidade_Stage4 => "0001"  )	
	PORT MAP (slow_clock, r_clear, Time_Fim, Time_Unidade_OUT, Time_Dezena_OUT, Time_Centena_OUT, MUX_SIGNAL);
	

-- Logica que cuida dos estados do jogo
Logica_Maquina:	ENTITY WORK.Logica
 	GENERIC MAP (
		POS_INICIAL_PERSONAGEM1		    => 	"01111011",	-- MAPA 1		-- Pronto
		BLOCO_INICIAL_PERSONAGEM1		=> 	"101",
		TOTAL_CAIXAS1					=>	"00000100",
		
 		POS_INICIAL_PERSONAGEM2		    => 	"01001111",	-- MAPA 2		-- Pronto		
		BLOCO_INICIAL_PERSONAGEM2		=> 	"100",
		TOTAL_CAIXAS2					=>	"00000110",
		
		POS_INICIAL_PERSONAGEM3		    => 	"10011010",	-- MAPA 3		-- Pronto	
		BLOCO_INICIAL_PERSONAGEM3		=> 	"100",
		TOTAL_CAIXAS3					=>	"00000110",
											
		POS_INICIAL_PERSONAGEM4		    => 	"00101100",	-- MAPA 4		-- Pronto
		BLOCO_INICIAL_PERSONAGEM4		=> 	"100",
		TOTAL_CAIXAS4					=>	"00001011" )
		
PORT MAP (slow_clock, clear, Teclado_Ready, Teclado_Entry, Teclado_Red, Log_Mem_Enable, Log_Mem_Adress, Log_Mem_DataIn, Log_Mem_DataOut,
	Time_Fim, MUX_SIGNAL, l_clear);


-- Display Works : Cuida da impressão
Display:	ENTITY WORK.DisplayWorks
	PORT MAP (slow_clock, clock, r_clear, red, green, blue, hsync, vsync, Time_Unidade_OUT, Time_Dezena_Out, Time_Centena_OUT, Vid_Mem_Adress, Vid_Mem_DataOut, MUX_SIGNAL);

-- Handler de teclado 
Teclado: 	ENTITY WORK.KB_Handler
	PORT MAP (slow_clock & slow_clock, r_clear, PS2_DAT, PS2_CLK, Teclado_Red, Teclado_Ready, Teclado_Entry);
 
END ARCHITECTURE;
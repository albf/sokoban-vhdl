LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

PACKAGE package_Sokoban IS

COMPONENT DisplayWorks
	PORT (
		slow_clock			: IN STD_LOGIC;
		clk27M				: IN STD_LOGIC;
		reset				: IN STD_LOGIC;
		red, green, blue 	: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		hsync, vsync		: OUT STD_LOGIC;
		
		-- Recebe sinais do timer
		Unidade_IN			: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		Dezena_IN			: IN STD_LOGIC_VECTOR (3 DOWNTO 0); 	
		Centena_IN			: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		
		-- Recebe Sinais da Memória Lógica
			-- Mapa lógico
		Vid_address		: OUT integer range 0 to 255;
		Vid_data		: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		MUX_SIGNAL		: IN STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END COMPONENT ;

COMPONENT KB_Handler
	PORT
		(
			------------------------	Clock Input	 	------------------------
			CLOCK_27: 	IN		STD_LOGIC_VECTOR (1 downto 0);		--	24 MHz			

			------------------------	Push Button		------------------------
			resetn	:	IN		STD_LOGIC;

			------------------------	PS2		--------------------------------
			PS2_DAT :	INOUT	STD_LOGIC;	--	PS2 Data
			PS2_CLK	:	INOUT	STD_LOGIC;	--	PS2 Clock

			------------------------	LOGIC	--------------------------------
			RD		:	IN		STD_LOGIC;	--	Receive the Signal to Erase teh Buffer
			READY	:	OUT		STD_LOGIC;	--	Warn the Logic Controller when the KB was read
			COMMAND	:	OUT		STD_LOGIC_VECTOR(2 DOWNTO 0)	--	WHICH COMMAND WAS TAPPED
		);
END COMPONENT ;

COMPONENT MemLogica
GENERIC (
		WORDSIZE		: NATURAL	:= 3;
		BITS_OF_ADDR	: NATURAL	:= 8;			-- 8 bits, labirinto tem 18x13, totalizando 1110 1010
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
END COMPONENT ;

COMPONENT MemLogica_Mux
	PORT (
Log_Mem_Enable				: OUT STD_LOGIC;						
Log_Mem_Adress				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
Log_Mem_DataIn				: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
Log_Mem_DataOut				: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
Vid_Mem_Adress				: OUT integer range 0 to 255; 	
Vid_Mem_DataOut				: IN STD_LOGIC_VECTOR(2 DOWNTO 0);  

Log_Mem_Enable2				: OUT STD_LOGIC;						
Log_Mem_Adress2				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
Log_Mem_DataIn2				: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
Log_Mem_DataOut2			: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
Vid_Mem_Adress2				: OUT integer range 0 to 255; 	
Vid_Mem_DataOut2			: IN STD_LOGIC_VECTOR(2 DOWNTO 0);  

Log_Mem_Enable3				: OUT STD_LOGIC;						
Log_Mem_Adress3				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
Log_Mem_DataIn3				: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
Log_Mem_DataOut3			: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
Vid_Mem_Adress3				: OUT integer range 0 to 255; 	
Vid_Mem_DataOut3			: IN STD_LOGIC_VECTOR(2 DOWNTO 0);  

Log_Mem_Enable4				: OUT STD_LOGIC;						
Log_Mem_Adress4				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
Log_Mem_DataIn4				: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
Log_Mem_DataOut4			: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
Vid_Mem_Adress4				: OUT integer range 0 to 255; 	
Vid_Mem_DataOut4			: IN STD_LOGIC_VECTOR(2 DOWNTO 0); 

Sinal_Mux					: IN STD_LOGIC_VECTOR(1 DOWNTO 0);

Log_Mem_Enable_T			: IN STD_LOGIC;						
Log_Mem_Adress_T			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
Log_Mem_DataIn_T			: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
Log_Mem_DataOut_T			: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
Vid_Mem_Adress_T			: IN integer range 0 to 255; 	
Vid_Mem_DataOut_T			: OUT STD_LOGIC_VECTOR(2 DOWNTO 0) 

	);
END COMPONENT ;

COMPONENT Timer
	GENERIC (
		Centena_Stage1		: STD_LOGIC_VECTOR(3 DOWNTO 0)	:= "0000";
		Dezena_Stage1		: STD_LOGIC_VECTOR(3 DOWNTO 0)  := "0010";
		Unidade_Stage1		: STD_LOGIC_VECTOR(3 DOWNTO 0)	:= "0001";
		Centena_Stage2		: STD_LOGIC_VECTOR(3 DOWNTO 0)	:= "0000";
		Dezena_Stage2		: STD_LOGIC_VECTOR(3 DOWNTO 0)  := "0010";
		Unidade_Stage2		: STD_LOGIC_VECTOR(3 DOWNTO 0)	:= "0001";
		Centena_Stage3		: STD_LOGIC_VECTOR(3 DOWNTO 0)	:= "0000";
		Dezena_Stage3		: STD_LOGIC_VECTOR(3 DOWNTO 0)  := "0010";
		Unidade_Stage3		: STD_LOGIC_VECTOR(3 DOWNTO 0)	:= "0001";
		Centena_Stage4		: STD_LOGIC_VECTOR(3 DOWNTO 0)	:= "0000";
		Dezena_Stage4		: STD_LOGIC_VECTOR(3 DOWNTO 0)  := "0010";
		Unidade_Stage4		: STD_LOGIC_VECTOR(3 DOWNTO 0)	:= "0001"
	);
	PORT (		Clock		: 		IN STD_LOGIC; -- Clock 24mhz.		
				Clear		: 		IN STD_LOGIC; -- Clear Assíncrono que inicia o timer
				Fim			: 		OUT STD_LOGIC;
				Unidade_OUT	:		OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
				Dezena_OUT	:		OUT STD_LOGIC_VECTOR (3 DOWNTO 0); 	
				Centena_OUT	:		OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
				MUX			:		IN STD_LOGIC_VECTOR	(1 DOWNTO 0)
);
END COMPONENT ;

COMPONENT Logica
	GENERIC (
		POS_INICIAL_PERSONAGEM1		    : STD_LOGIC_VECTOR(7 DOWNTO 0)	:= "00101000";	-- Pronto
		BLOCO_INICIAL_PERSONAGEM1		: STD_LOGIC_VECTOR(2 DOWNTO 0)  := "100";
		TOTAL_CAIXAS1					: STD_LOGIC_VECTOR(7 DOWNTO 0)	:= "00000010";
		POS_INICIAL_PERSONAGEM2		    : STD_LOGIC_VECTOR(7 DOWNTO 0)	:= "00101000";	-- Pronto
		BLOCO_INICIAL_PERSONAGEM2		: STD_LOGIC_VECTOR(2 DOWNTO 0)  := "100";
		TOTAL_CAIXAS2					: STD_LOGIC_VECTOR(7 DOWNTO 0)	:= "00000010";
		POS_INICIAL_PERSONAGEM3		    : STD_LOGIC_VECTOR(7 DOWNTO 0)	:= "00101000";	-- Pronto
		BLOCO_INICIAL_PERSONAGEM3		: STD_LOGIC_VECTOR(2 DOWNTO 0)  := "100";
		TOTAL_CAIXAS3					: STD_LOGIC_VECTOR(7 DOWNTO 0)	:= "00000010";
		POS_INICIAL_PERSONAGEM4		    : STD_LOGIC_VECTOR(7 DOWNTO 0)	:= "00101000";	-- FALTA CORRIGIR
		BLOCO_INICIAL_PERSONAGEM4		: STD_LOGIC_VECTOR(2 DOWNTO 0)  := "100";
		TOTAL_CAIXAS4					: STD_LOGIC_VECTOR(7 DOWNTO 0)	:= "00000010"
	);
	PORT (
	clock							: IN	STD_LOGIC;		-- clock
	clear							: IN	STD_LOGIC;		-- vai para o estado inicial, de esperar comando
	
	Teclado_Ready					: IN	STD_LOGIC;		-- Avisa se há comandos para serem lidos no teclado. Se tiver, fica 1.
	Teclado_Entry					: IN	STD_LOGIC_VECTOR (2 DOWNTO 0);		-- Passa o codigo do teclado
	Teclado_Red						: OUT	STD_LOGIC;
	
	Mem_Enable_Out					: OUT	STD_LOGIC;		-- Enable da memória
	Mem_Adress_Out					: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);		-- Endereço da memória
	Mem_DataIn_Out					: OUT	STD_LOGIC_VECTOR(2 DOWNTO 0);		-- Dados da memória, entrada
	Mem_DataOut						: IN	STD_LOGIC_VECTOR(2 DOWNTO 0);		-- Saida da memória

	Alarm							: IN	STD_LOGIC;		-- Indica o fim do timer
	Mux_Signal						: OUT	STD_LOGIC_VECTOR (1 DOWNTO 0);
	Logic_Reset						: OUT 	STD_LOGIC;
	
	Boxes_Left						: OUT	STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT ;

END package_Sokoban ;
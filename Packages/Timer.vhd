-----------------------------------------------------------------------------------
--	Alexandre Luiz Brisighello Filho 	- RA:101350								 --
--	Andre Nakagaki Filliettaz			- RA:104595								 --
--																				 --
--	MC613 - Projeto final : Sokoban												 --
--	Arquivo : Timer.vhdl													 	 --
--	Descrição : Trata-se de um controlador de 3 módulos de 10 que incrementam    --
--	negativamente, cuidado e gerando sinais referentes ao relógio.				 --
-----------------------------------------------------------------------------------

LIBRARY ieee ;
USE ieee.std_logic_1164.all ;		-- Cria os 3 modulos de 10, com um contador regressivo, que avisa quando acabar
USE work.package_Timer.all ;

ENTITY Timer IS
	GENERIC (				-- Iniciais das fases
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
	PORT (		Clock		: 		IN STD_LOGIC; -- Clock 2.7 mhz.		
				Clear		: 		IN STD_LOGIC; -- Clear Assíncrono que inicia o timer
				Fim			: 		OUT STD_LOGIC;
				Unidade_OUT	:		OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
				Dezena_OUT	:		OUT STD_LOGIC_VECTOR (3 DOWNTO 0); 	
				Centena_OUT	:		OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
				MUX			:		IN STD_LOGIC_VECTOR	(1 DOWNTO 0)
);
	END Timer ;
	
ARCHITECTURE behavior OF Timer IS

-- Sinais referente aos módulos dos contadores Mod10
SIGNAL New_Clock	:	STD_LOGIC;						-- Clock convertido
SIGNAL Mode			:	STD_LOGIC;						-- Auxiliar do Modo -- 0 -> Add, 1 -> Para.
SIGNAL Uni_Saida	:	STD_LOGIC_VECTOR (3 DOWNTO 0);	-- Saida de Unidade
SIGNAL Dez_Saida	:	STD_LOGIC_VECTOR (3 DOWNTO 0);	-- Saida de Dezena
SIGNAL Cen_Saida	:	STD_LOGIC_VECTOR (3 DOWNTO 0);	-- Saida de centena
SIGNAL Zerou_Status	:	STD_LOGIC_VECTOR (2 DOWNTO 0);	-- Indica se zerou

BEGIN
-- Conversao do clock
ConversorClock: ENTITY WORK.DivClock	
	PORT MAP ( Clock, Clear, New_Clock );

-- Modulos contadores do timer	
Mod10_Unidade	: ENTITY WORK.Mod10
	GENERIC MAP (Inicial_stage1 => Unidade_Stage1, 			
		Inicial_stage2 => Unidade_Stage2,		
		Inicial_stage3 => Unidade_Stage3,		
		Inicial_stage4 => Unidade_Stage4 )		
	PORT MAP ( New_Clock, Clear, Mode, '1', Uni_Saida, Zerou_Status(0), MUX );
	
Mod10_Dezena	: ENTITY WORK.Mod10
	GENERIC MAP (Inicial_stage1 => Dezena_Stage1, 			
	Inicial_stage2 => Dezena_Stage2,		
	Inicial_stage3 => Dezena_Stage3,		
	Inicial_stage4 => Dezena_Stage4 )				
	PORT MAP ( New_Clock, Clear, Mode, Zerou_Status(0), Dez_Saida, Zerou_Status(1), MUX );
	
Mod10_Centena	: ENTITY WORK.Mod10
	GENERIC MAP (Inicial_stage1 => Centena_Stage1, 			
	Inicial_stage2 => Centena_Stage2,		
	Inicial_stage3 => Centena_Stage3,		
	Inicial_stage4 => Centena_Stage4 )		
	PORT MAP ( New_Clock, Clear, Mode, Zerou_Status(1) AND Zerou_Status(0), Cen_Saida, Zerou_Status(2), MUX );

-- Liga o fim						
Fim <= Mode;											

-- Verifica sincronamente se chegou ao fim ou não. Evitando problemas assíncronos
Verificar_Fim: Process ( Clock, Mode )	
	variable fim_s : STD_LOGIC;
Begin
	if (Clear = '0') Then
		fim_s := '0';
	elsif (Clock'Event AND Clock='1') Then
		if ((Cen_Saida = "0000") AND (Dez_Saida = "0000") AND (Uni_Saida ="0000")) THEN
			fim_s := '1';
		end if;
	end if;
	
	Mode <= fim_s;
end process;

-- Liga saidas										
Unidade_Out <= Uni_Saida;
Dezena_Out <= Dez_Saida;
Centena_Out <= Cen_Saida;

END behavior ;
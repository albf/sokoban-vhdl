-----------------------------------------------------------------------------------
--	Alexandre Luiz Brisighello Filho 	- RA:101350								 --
--	Andre Nakagaki Filliettaz			- RA:104595								 --
--																				 --
--	MC613 - Projeto final : Sokoban												 --
--	Arquivo : Logica.vhdl														 --
--	Descrição : Representa a logica do jogo, representando todos os estados   	 --
--	do jogo com uma máquina de estados e manipulando a matriz lógica.		  	 --
-----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_signed.all;

ENTITY Logica IS
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
		POS_INICIAL_PERSONAGEM4		    : STD_LOGIC_VECTOR(7 DOWNTO 0)	:= "00101000";	-- Pronto
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
	Logic_Reset						: OUT 	STD_LOGIC
		
	);
END ENTITY;

ARCHITECTURE Behavior OF Logica IS

TYPE ESTADOS IS (					-- Define estados possíveis
EsperarComando, 
LerComando1, LerComando2, LerComando3,
ProximoCaixa,
ProximoCaixa_Chao, ProximoCaixa_Chao2, ProximoCaixa_Chao3,
ProximoChao, ProximoChao2,
Termino, TimeOver, 
Fim_Stage1, Fim_Stage2, Fim_Stage3
);

-- Sinais referente ao estado atual
SIGNAL state						: ESTADOS;		-- Representa o estado

-- Sinais referente a memoria logica
SIGNAL Mem_Enable					: STD_LOGIC;
SIGNAL Mem_Adress					: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL Mem_DataIn					: STD_LOGIC_VECTOR(2 DOWNTO 0);

SIGNAL Mux							: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL L_reset						: STD_LOGIC;

BEGIN

Mem_Enable_Out <= Mem_Enable;
Mem_Adress_Out <= Mem_Adress;
Mem_DataIn_Out <= Mem_DataIn;

Mux_Signal <= Mux;
Logic_Reset <= L_reset;

	
Maquina_de_Estados: PROCESS (clock, clear)		-- processo de estado
	-- Latches
	VARIABLE  Pos_Personagem  	: STD_LOGIC_VECTOR (7 DOWNTO 0);	-- Endereço (atual) do personagem
	VARIABLE  Bloco_Personagem	: STD_LOGIC_VECTOR (2 DOWNTO 0);	-- Bloco do personagem
	VARIABLE  ProximaCasa1		: STD_LOGIC_VECTOR (7 DOWNTO 0);	-- Endereço da próxima casa
	VARIABLE  ProximaCasa2		: STD_LOGIC_VECTOR (7 DOWNTO 0);	-- Endereço da próxima casa +1
	VARIABLE  ProximoBloco1		: STD_LOGIC_VECTOR (2 DOWNTO 0);	-- Bloco da próxima casa
	VARIABLE  ProximoBloco2		: STD_LOGIC_VECTOR (2 DOWNTO 0);	-- Bloco da próxima casa +1
	VARIABLE  CaixasFora		: STD_LOGIC_VECTOR (7 DOWNTO 0);	-- Numero de caixas fora do lugar
	
	BEGIN
	
		IF (clear = '0') THEN				-- Verifica se clear inicial esta apertado!
			Teclado_Red 	<='0';			-- Nao leu o buffer do teclado
			Mem_Enable		<='0';						
			Mem_Adress		<="00000000";	
			Mem_Enable		<='0';
			
			Pos_Personagem  :=POS_INICIAL_PERSONAGEM1;
			Bloco_Personagem :=BLOCO_INICIAL_PERSONAGEM1;
			CaixasFora := TOTAL_CAIXAS1;	
			state 			<= EsperarComando;		-- vai pra inicial
			
			Mux <= "00";
			L_reset <='1';
			

		ELSIF (Alarm = '1') THEN
			Teclado_Red 	<='0';			-- Nao leu o buffer do teclado
			Mem_Enable		<='0';			
			Mem_Adress		<="--------";
			Mem_DataIn		<="---";
			state 			<=TimeOver;
			
			
		ELSIF (clock'EVENT AND clock = '1') THEN	-- atualização de clock
			Teclado_Red 	<='0';			-- Nao leu o buffer do teclado
			Mem_Enable		<='0';			
			Mem_Adress		<="--------";
			Mem_DataIn		<="---";
			L_reset 		<='1';
				
			IF 	(state = EsperarComando) THEN			-- se Estado=EsperarComando					

				IF (Teclado_Ready = '1') THEN
					state <= LerComando1;
				END IF;
	
			
			ELSIF (state = LerComando1) THEN
				Teclado_Red 	<='1';					-- Está lendo o comando, avisa o teclado
				
				IF (Teclado_Entry = "001") THEN			-- Verifica a entrada, se for esquerda
					state <= LerComando2;	
					ProximaCasa1 := Pos_Personagem - 1;	-- posição lógica da casa a frente do destino desejado
					ProximaCasa2 := Pos_Personagem - 2;	-- posição lógica de duas casas a frente do destino desejado
				
				ELSIF (Teclado_Entry = "010") THEN		-- se for cima
					state <= LerComando2;
					ProximaCasa1 := Pos_Personagem - 18;
					ProximaCasa2 := Pos_Personagem - 36;
				
				ELSIF (Teclado_Entry = "011") THEN		-- se for baixo
					state <= LerComando2;
					ProximaCasa1 := Pos_Personagem + 18;
					ProximaCasa2 := Pos_Personagem + 36;
					
				ELSIF (Teclado_Entry = "100") THEN		-- se for direito
					state <= LerComando2;
					ProximaCasa1 := Pos_Personagem + 1;	
					ProximaCasa2 := Pos_Personagem + 2;
				
				ELSE									-- caso seja outros, pega outro comando!
					state <= EsperarComando;
				END IF;
					
				Mem_Adress		<=ProximaCasa1;			-- Já carrega a próxima casa, para ver o que fazer!
			
			ELSIF (state = LerComando2) THEN	-- Espera a memória carregar ProximaCasa1, e já pede para carregar PróximaCasa2
				Mem_Adress		<=ProximaCasa2;	-- Aproveita o clock para já carregar a PróximaCasa2
				Mem_DataIn		<="---";
				state <= LerComando3;
				
			ELSIF (state = LerComando3) THEN
				ProximoBloco1 	:=Mem_DataOut; 				-- neste ponto, "ProximaCasa1" já está carregada, pois houve um clock"
				Mem_Adress		<=ProximaCasa2;	-- Aproveita o clock para já carregar a PróximaCasa2
				
				IF( (ProximoBloco1 = 0) OR (ProximoBloco1 = 1) ) THEN
					state <= ProximoChao;
			
				ELSIF( (ProximoBloco1 = 2) OR (ProximoBloco1 = 3) ) THEN
					state <= ProximoCaixa;
			
				ELSE 	-- Parede ou qualquer maluquisse, não vai!
					state <= EsperarComando;
					
				END IF;
	
			ELSIF (state = ProximoChao) THEN 
				Mem_Enable		<='1';				-- Esta na hora de gravar!
				Mem_Adress		<= Pos_Personagem;	
				
				IF( Bloco_Personagem = 4 ) THEN		-- 4 = Chao Normal com personagem.
					Mem_DataIn		<="000";		-- 0 = Chao Normal, o personagem sai
				
				ELSE								-- Neste caso, TEM que ter o personagem em um chao especial = 5
					Mem_DataIn		<="001";		-- 1 = Chao Especial
				
				END IF;
				
				state <= ProximoChao2;
				
			ELSIF (state = ProximoChao2) THEN 
				Mem_Enable		<='1';				-- Esta na hora de gravar!
				Mem_Adress		<= ProximaCasa1;	
				
				IF ( ProximoBloco1 = 0)	THEN		-- 0 = Chao normal
					Mem_DataIn		<="100";		-- 4 = Chao normal com personagem
					Bloco_Personagem := "100";		-- atualiza também o bloco do personagem
							
				ELSE 								-- Neste caso, TEM que ter um chao especial = 1
					Mem_DataIn		<="101";		-- 5 = Chao especial com personagem
					Bloco_Personagem := "101";
							
				END IF;		
				
				Pos_Personagem 	:= ProximaCasa1;	-- atualiza a posição do personagem
				
				state 			<= EsperarComando;

							
			ELSIF (state = ProximoCaixa) THEN 	
				ProximoBloco2 	:=Mem_DataOut;  -- neste ponto, "ProximaCasa2" já está carregada, pois houve um clock"
				
				IF( (ProximoBloco2 = 0) OR (ProximoBloco2 = 1) ) THEN
					state <= ProximoCaixa_Chao;
			
				ELSE 	-- Outra caixa,Parede ou qualquer maluquisse, não vai!
					state <= EsperarComando;
					
				END IF;
			
			ELSIF (state = ProximoCaixa_Chao) THEN 
				Mem_Enable		<='1';				-- Esta na hora de gravar!
				Mem_Adress		<= ProximaCasa2;
				
				IF ( ProximoBloco1 = 3 ) THEN 		-- 3 = Caixa em um chao especial
					CaixasFora := CaixasFora+1;		-- Uma caixa foi tirada do lugar, atualizar.
					
				END IF;
				
				IF ( ProximoBloco2 = 0)	THEN		-- 0 = Chao normal
					Mem_DataIn		<="010";		-- 2 = Chao normal com caixa
							
				ELSE 								-- Neste caso, TEM que ter um chao especial = 1
					Mem_DataIn		<="011";		-- 3 = Chao especial com caixa
					CaixasFora		:= CaixasFora-1;-- Como agora tem uma caixa no chao especial, tirar 1
							
				END IF;		

				State 			<= ProximoCaixa_Chao2;
			
			ELSIF (state = ProximoCaixa_Chao2) THEN
				Mem_Enable		<='1';				-- Esta na hora de gravar!
				Mem_Adress		<= ProximaCasa1;	
				
				IF ( ProximoBloco1 = 2)	THEN		-- 2 = Chao normal com caixa
					Mem_DataIn		<="100";		-- 4 = Chao normal com personagem
							
				ELSE 								-- Neste caso, TEM que ter um chao especial com caixa = 3
					Mem_DataIn		<="101";		-- 5 = Chao especial com personagem
					--CaixasFora		:= CaixasFora+1;	-- Como tirou uma caixa do chao especial, agora falta mais uma
							
				END IF;					 
			
				State 			<= ProximoCaixa_Chao3;	
			
			ELSIF (state = ProximoCaixa_Chao3) THEN 
				Mem_Enable		<='1';				-- Esta na hora de gravar!
				Mem_Adress		<= Pos_Personagem;	
				
				IF ( Bloco_Personagem = 4)	THEN		-- 4 = Chao normal com personagem
					Mem_DataIn		<="000";			-- 0 = Chao normal 
							
				ELSE 									-- Neste caso, TEM que ter um chao especial com personagem = 5
					Mem_DataIn		<="001";			-- 1 = Chao especial 
							
				END IF;					 
			
				IF ( CaixasFora = 0) THEN				-- Verifica se terminou
					IF (Mux = "00") THEN				-- Se terminou a fase 1
						State <= Fim_Stage1;
					
					ELSIF (Mux = "01") THEN				-- Se terminou a fase 2
						State <= Fim_Stage2;
						
					ELSIF (Mux = "10") THEN				-- Se terminou a fase 3
						State <= Fim_Stage3;	
						
					ELSE						
						State <= Termino;
					END IF;	
						
				ELSE
					State 			<= EsperarComando;
				END IF;
				
				Pos_Personagem := ProximaCasa1;
				
				IF ( ProximoBloco1 = 2)	THEN		-- 2 = Chao normal com caixa
					Bloco_Personagem := "100";		-- 4 = Chao normal com personagem
				ELSE 								-- Neste caso, TEM que ter um chao especial com caixa = 3
					Bloco_Personagem := "101";		-- 5 = Chao especial com personagem
				END IF;			
				
			ELSIF (state = Fim_Stage1) THEN		
				Pos_Personagem  :=POS_INICIAL_PERSONAGEM2;
				Bloco_Personagem :=BLOCO_INICIAL_PERSONAGEM2;
				CaixasFora := TOTAL_CAIXAS2;	
				state 			<= EsperarComando;		-- vai pra inicial
				
				Mux <= "01";			-- vai pra fase 2!
				L_reset <='0';			-- Indica fim do stage1
				
			ELSIF (state = Fim_Stage2) THEN			
				Pos_Personagem  :=POS_INICIAL_PERSONAGEM3;
				Bloco_Personagem :=BLOCO_INICIAL_PERSONAGEM3;
				CaixasFora := TOTAL_CAIXAS3;	
				state 			<= EsperarComando;		-- vai pra inicial
				
				Mux <= "10";			-- vai pra fase 3!
				L_reset <='0';			-- Indica fim do stage2	
				
			ELSIF (state = Fim_Stage3) THEN			
				Pos_Personagem  :=POS_INICIAL_PERSONAGEM4;
				Bloco_Personagem :=BLOCO_INICIAL_PERSONAGEM4;
				CaixasFora := TOTAL_CAIXAS4;	
				state 			<= EsperarComando;		-- vai pra inicial
				
				Mux <= "11";			-- vai pra fase 4!
				L_reset <='0';			-- Indica fim do stage3			
			
			ELSIF (state = TimeOver) THEN	-- Acabou tempo, vem pra cá!
			
			ELSE	-- Termino ou qualquer outro estado perdido, vem pra cá!
			
			END IF;
		END IF;	
		
			
	END PROCESS;

END ARCHITECTURE;
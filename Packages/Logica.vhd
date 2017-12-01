-----------------------------------------------------------------------------------
--	Alexandre Luiz Brisighello Filho 	- alexandre.brisighello@gmail.com		 --
--	Andre Nakagaki Filliettaz			- andrentaz@gmail.com					 --
--																				 --
--	Project: sokoban-altera														 --
--	file: Logica.vhd															 --
--	description: Represents the game logic, having all the game states and		 --
--  managing the logic matrix.													 --
-----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_signed.all;

ENTITY Logica IS
	GENERIC (
		POS_INICIAL_PERSONAGEM1		    : STD_LOGIC_VECTOR(7 DOWNTO 0)	:= "00101000";	-- Ready
		BLOCO_INICIAL_PERSONAGEM1		: STD_LOGIC_VECTOR(2 DOWNTO 0)  := "100";
		TOTAL_CAIXAS1					: STD_LOGIC_VECTOR(7 DOWNTO 0)	:= "00000010";
		POS_INICIAL_PERSONAGEM2		    : STD_LOGIC_VECTOR(7 DOWNTO 0)	:= "00101000";	-- Ready
		BLOCO_INICIAL_PERSONAGEM2		: STD_LOGIC_VECTOR(2 DOWNTO 0)  := "100";
		TOTAL_CAIXAS2					: STD_LOGIC_VECTOR(7 DOWNTO 0)	:= "00000010";
		POS_INICIAL_PERSONAGEM3		    : STD_LOGIC_VECTOR(7 DOWNTO 0)	:= "00101000";	-- Ready
		BLOCO_INICIAL_PERSONAGEM3		: STD_LOGIC_VECTOR(2 DOWNTO 0)  := "100";
		TOTAL_CAIXAS3					: STD_LOGIC_VECTOR(7 DOWNTO 0)	:= "00000010";
		POS_INICIAL_PERSONAGEM4		    : STD_LOGIC_VECTOR(7 DOWNTO 0)	:= "00101000";	-- Ready
		BLOCO_INICIAL_PERSONAGEM4		: STD_LOGIC_VECTOR(2 DOWNTO 0)  := "100";
		TOTAL_CAIXAS4					: STD_LOGIC_VECTOR(7 DOWNTO 0)	:= "00000010"
	);
	PORT (
	clock							: IN	STD_LOGIC;		-- clock
	clear							: IN	STD_LOGIC;		-- move to initial state, waiting for command

	Teclado_Ready					: IN	STD_LOGIC;		-- Warn if there are any command ready to be read from the keyboard. If yes, 1.
	Teclado_Entry					: IN	STD_LOGIC_VECTOR (2 DOWNTO 0);		-- Receives keyboard code
	Teclado_Red						: OUT	STD_LOGIC;

	Mem_Enable_Out					: OUT	STD_LOGIC;		-- Enable da mem�ria
	Mem_Adress_Out					: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);		-- Memory address
	Mem_DataIn_Out					: OUT	STD_LOGIC_VECTOR(2 DOWNTO 0);		-- Input memory data
	Mem_DataOut						: IN	STD_LOGIC_VECTOR(2 DOWNTO 0);		-- Output memory

	Alarm							: IN	STD_LOGIC;		-- Indicates timer has finished
	Mux_Signal						: OUT	STD_LOGIC_VECTOR (1 DOWNTO 0);
	Logic_Reset						: OUT 	STD_LOGIC

	);
END ENTITY;

ARCHITECTURE Behavior OF Logica IS

TYPE ESTADOS IS (					-- Defines possible states
EsperarComando,
LerComando1, LerComando2, LerComando3,
ProximoCaixa,
ProximoCaixa_Chao, ProximoCaixa_Chao2, ProximoCaixa_Chao3,
ProximoChao, ProximoChao2,
Termino, TimeOver,
Fim_Stage1, Fim_Stage2, Fim_Stage3
);

-- Sinais referente ao estado atual
SIGNAL state						: ESTADOS;		-- Represents the state

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


Maquina_de_Estados: PROCESS (clock, clear)		-- state process
	-- Latches
	VARIABLE  Pos_Personagem  	: STD_LOGIC_VECTOR (7 DOWNTO 0);	-- Current character address
	VARIABLE  Bloco_Personagem	: STD_LOGIC_VECTOR (2 DOWNTO 0);	-- Character block
	VARIABLE  ProximaCasa1		: STD_LOGIC_VECTOR (7 DOWNTO 0);	-- Next position address
	VARIABLE  ProximaCasa2		: STD_LOGIC_VECTOR (7 DOWNTO 0);	-- Next position + 1 address
	VARIABLE  ProximoBloco1		: STD_LOGIC_VECTOR (2 DOWNTO 0);	-- Next position block
	VARIABLE  ProximoBloco2		: STD_LOGIC_VECTOR (2 DOWNTO 0);	-- Next position +1 block
	VARIABLE  CaixasFora		: STD_LOGIC_VECTOR (7 DOWNTO 0);	-- Number of boxes out of place

	BEGIN

		IF (clear = '0') THEN				-- Verifies if initial clear is pressed
			Teclado_Red 	<='0';			-- Keyboard buffer wasn't read
			Mem_Enable		<='0';
			Mem_Adress		<="00000000";
			Mem_Enable		<='0';

			Pos_Personagem  :=POS_INICIAL_PERSONAGEM1;
			Bloco_Personagem :=BLOCO_INICIAL_PERSONAGEM1;
			CaixasFora := TOTAL_CAIXAS1;
			state 			<= EsperarComando;		-- move to initial state

			Mux <= "00";
			L_reset <='1';


		ELSIF (Alarm = '1') THEN
			Teclado_Red 	<='0';					-- Keyboard buffer wasn't read
			Mem_Enable		<='0';
			Mem_Adress		<="--------";
			Mem_DataIn		<="---";
			state 			<=TimeOver;


		ELSIF (clock'EVENT AND clock = '1') THEN	-- clock update
			Teclado_Red 	<='0';					-- Keyboard buffer wasn't read
			Mem_Enable		<='0';
			Mem_Adress		<="--------";
			Mem_DataIn		<="---";
			L_reset 		<='1';

			IF 	(state = EsperarComando) THEN		-- if is waiting a command

				IF (Teclado_Ready = '1') THEN
					state <= LerComando1;
				END IF;


			ELSIF (state = LerComando1) THEN
				Teclado_Red 	<='1';					-- It's reading the command, warns the keyboard

				IF (Teclado_Entry = "001") THEN			-- Verifies input, if it's left
					state <= LerComando2;
					ProximaCasa1 := Pos_Personagem - 1;	-- logical position in front of the desired position
					ProximaCasa2 := Pos_Personagem - 2;	-- logical position in front by two positions of the desired position

				ELSIF (Teclado_Entry = "010") THEN		-- if it's up
					state <= LerComando2;
					ProximaCasa1 := Pos_Personagem - 18;
					ProximaCasa2 := Pos_Personagem - 36;

				ELSIF (Teclado_Entry = "011") THEN		-- if it's down
					state <= LerComando2;
					ProximaCasa1 := Pos_Personagem + 18;
					ProximaCasa2 := Pos_Personagem + 36;

				ELSIF (Teclado_Entry = "100") THEN		-- if it's right
					state <= LerComando2;
					ProximaCasa1 := Pos_Personagem + 1;
					ProximaCasa2 := Pos_Personagem + 2;

				ELSE									--  case it's other, take the next command!
					state <= EsperarComando;
				END IF;

				Mem_Adress		<=ProximaCasa1;			-- already loads the next position, to see what it is!

			ELSIF (state = LerComando2) THEN			-- Waits memory to loads ProximaCasa1,  and already ask to load next position+2
				Mem_Adress		<=ProximaCasa2;			-- Use the clock to already, get ProximaCasa2
				Mem_DataIn		<="---";
				state <= LerComando3;

			ELSIF (state = LerComando3) THEN
				ProximoBloco1 	:=Mem_DataOut; 			-- at this point, "ProximaCasa1" is loaded, because a "clock has passed"
				Mem_Adress		<=ProximaCasa2;			-- Use the clock to already load ProximaCasa2

				IF( (ProximoBloco1 = 0) OR (ProximoBloco1 = 1) ) THEN
					state <= ProximoChao;

				ELSIF( (ProximoBloco1 = 2) OR (ProximoBloco1 = 3) ) THEN
					state <= ProximoCaixa;

				ELSE 	-- Wall or any nonsense, won't proceed!
					state <= EsperarComando;

				END IF;

			ELSIF (state = ProximoChao) THEN
				Mem_Enable		<='1';				-- Time to store!
				Mem_Adress		<= Pos_Personagem;

				IF( Bloco_Personagem = 4 ) THEN		-- 4 = Normal floor with character
					Mem_DataIn		<="000";		-- 0 = Normal floor, character gets out

				ELSE								-- In this case, it HAS to be a character on special floor
					Mem_DataIn		<="001";		-- 1 = Special floor

				END IF;

				state <= ProximoChao2;

			ELSIF (state = ProximoChao2) THEN
				Mem_Enable		<='1';				-- Time to store!
				Mem_Adress		<= ProximaCasa1;

				IF ( ProximoBloco1 = 0)	THEN		-- 0 = Normal floor
					Mem_DataIn		<="100";		-- 4 = Normal floor with character
					Bloco_Personagem := "100";		-- also updates character block

				ELSE 								-- In such case, it HAS to be a special floor = 1
					Mem_DataIn		<="101";		-- 5 = Special floor with character
					Bloco_Personagem := "101";

				END IF;

				Pos_Personagem 	:= ProximaCasa1;	-- Updates character position

				state 			<= EsperarComando;


			ELSIF (state = ProximoCaixa) THEN
				ProximoBloco2 	:=Mem_DataOut;  	-- at this point, "ProximaCasa2" is loaded, because a "clock has passed"

				IF( (ProximoBloco2 = 0) OR (ProximoBloco2 = 1) ) THEN
					state <= ProximoCaixa_Chao;

				ELSE 								-- Wall or any nonsense, won't proceed!
					state <= EsperarComando;

				END IF;

			ELSIF (state = ProximoCaixa_Chao) THEN
				Mem_Enable		<='1';				-- Time to store!
				Mem_Adress		<= ProximaCasa2;

				IF ( ProximoBloco1 = 3 ) THEN 		-- 3 = Box with special floor
					CaixasFora := CaixasFora+1;		-- Box was moved, update

				END IF;

				IF ( ProximoBloco2 = 0)	THEN		-- 0 = Normal floor
					Mem_DataIn		<="010";		-- 2 = Normal floor with box

				ELSE 								-- In such case, it HAS to be a special floor = 1
					Mem_DataIn		<="011";		-- 3 = Box with special floor
					CaixasFora		:= CaixasFora-1;-- Now there is a box with special floor, update counter

				END IF;

				State 			<= ProximoCaixa_Chao2;

			ELSIF (state = ProximoCaixa_Chao2) THEN
				Mem_Enable		<='1';				-- Time to store!
				Mem_Adress		<= ProximaCasa1;

				IF ( ProximoBloco1 = 2)	THEN		-- 2 = Normal floor with box
					Mem_DataIn		<="100";		-- 4 = Normal floor with character

				ELSE 								-- In this case, it HAS to be a special floor with box = 3
					Mem_DataIn		<="101";		-- 5 = Special floor with character
					--CaixasFora		:= CaixasFora+1;	-- Since a box is not on the special floor, update counter

				END IF;

				State 			<= ProximoCaixa_Chao3;

			ELSIF (state = ProximoCaixa_Chao3) THEN
				Mem_Enable		<='1';				-- Time to store!
				Mem_Adress		<= Pos_Personagem;

				IF ( Bloco_Personagem = 4)	THEN		-- 4 = Normal floor with character
					Mem_DataIn		<="000";			-- 0 = Normal floor

				ELSE 									-- In this case, it HAS to be a special floor with character = 5
					Mem_DataIn		<="001";			-- 1 = Special floor

				END IF;

				IF ( CaixasFora = 0) THEN				-- Verifies if finished
					IF (Mux = "00") THEN				-- If finished stage 1
						State <= Fim_Stage1;

					ELSIF (Mux = "01") THEN				-- If finished stage 2
						State <= Fim_Stage2;

					ELSIF (Mux = "10") THEN				-- If finished stage 3
						State <= Fim_Stage3;

					ELSE
						State <= Termino;
					END IF;

				ELSE
					State 			<= EsperarComando;
				END IF;

				Pos_Personagem := ProximaCasa1;

				IF ( ProximoBloco1 = 2)	THEN		-- 2 = Normal floor with box
					Bloco_Personagem := "100";		-- 4 = Normal floor with character
				ELSE 								-- Ins this case, it HAS to be a special floor with box = 3
					Bloco_Personagem := "101";		-- 5 = Special floor with character
				END IF;

			ELSIF (state = Fim_Stage1) THEN
				Pos_Personagem  :=POS_INICIAL_PERSONAGEM2;
				Bloco_Personagem :=BLOCO_INICIAL_PERSONAGEM2;
				CaixasFora := TOTAL_CAIXAS2;
				state 			<= EsperarComando;		-- go to initial state

				Mux <= "01";			-- go to stage 2!
				L_reset <='0';			-- Indicates stage 1 end

			ELSIF (state = Fim_Stage2) THEN
				Pos_Personagem  :=POS_INICIAL_PERSONAGEM3;
				Bloco_Personagem :=BLOCO_INICIAL_PERSONAGEM3;
				CaixasFora := TOTAL_CAIXAS3;
				state 			<= EsperarComando;		-- go to initial state

				Mux <= "10";			-- go to stage 3!
				L_reset <='0';			-- Indicates stage 2 end

			ELSIF (state = Fim_Stage3) THEN
				Pos_Personagem  :=POS_INICIAL_PERSONAGEM4;
				Bloco_Personagem :=BLOCO_INICIAL_PERSONAGEM4;
				CaixasFora := TOTAL_CAIXAS4;
				state 			<= EsperarComando;		-- go to initial state

				Mux <= "11";			-- go to stage 4!
				L_reset <='0';			-- Indicates stage 3 end

			ELSIF (state = TimeOver) THEN	-- Time is up, comes to here!

			ELSE	-- It's finished or any other bizarre state, comes to here!

			END IF;
		END IF;


	END PROCESS;

END ARCHITECTURE;

-----------------------------------------------------------------------------------
--	Alexandre Luiz Brisighello Filho 	- RA:101350								 --
--	Andre Nakagaki Filliettaz			- RA:104595								 --
--																				 --
--	MC613 - Projeto final : Sokoban												 --
--	Arquivo : DisplayWorks.vhdl													 --
--	Descrição : Cuida da impressão do jogo, utilizando uma máquina de estados  	 --
--	que imprimi bitmap por bitmap. Foi construída iniciando pelo arquivo no test --
--  no site da disciplina, apenas como partida.									 --
--																				 --
--  Modificações no VGACON : Foram feitas pequenas modificações no VGACON.vhd	 --
--  Boa parte devido ao uso de uma resolução que não divide 640x480.			 --
-----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.package_DisplayWorks.all;

ENTITY DisplayWorks IS
	PORT (
		slow_clock 			: IN STD_LOGIC;
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
END ENTITY;

ARCHITECTURE behavior OF DisplayWorks IS
	-- Constantes
	CONSTANT CONS_CLOCK_DIV 		: INTEGER := 10; 
	CONSTANT HORZ_SIZE 				: INTEGER := 240;
	CONSTANT VERT_SIZE 				: INTEGER := 180;
	CONSTANT SIZE_BITMAP 			: INTEGER := 15;	-- O QUE DECIDE TUDO, COMPRIMENTO DO BITMAP
	CONSTANT JUMP_BITMAP_LINHA 		: INTEGER := 240;	-- SIZE_BITMAP * 16
	CONSTANT JUMP_BITMAP_COLUNA		: INTEGER := 3600;	-- 16 * SIZE_BITMAP^2		
	CONSTANT POS_BITMAP_CENTENA		: std_logic_vector (12 DOWNTO 0) := "0011000100111";	-- 7 * SIZE_BITMAP^2
	CONSTANT POS_BITMAP_DEZENA		: std_logic_vector (12 DOWNTO 0) := "0011100001000";	-- 8 * SIZE_BITMAP^2
	CONSTANT POS_BITMAP_UNIDADE		: std_logic_vector (12 DOWNTO 0) := "0011111101001";	-- 9 * SIZE_BITMAP^2
	
	-- Endereços para VGAcon
	SIGNAL video_address	: INTEGER RANGE 0 TO HORZ_SIZE * VERT_SIZE - 1;
	SIGNAL video_word		: STD_LOGIC_VECTOR (2 DOWNTO 0);
	
	-- Endereços da memória Read dos bitmaps
	SIGNAL bitmap_address	: STD_LOGIC_VECTOR (12 DOWNTO 0);
	SIGNAL bitmap_out		: STD_LOGIC_VECTOR (2 DOWNTO 0);
	
	
	SIGNAL map_address		: integer range 0 to 255;
	SIGNAL map_data_out		: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL map_data_out_x_100 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	
	
	-- Estados Possíveis
	TYPE ESTADOS IS (				
	pre1, pre2, pre3, pre4,
	Inicio1, Inicio2, Inicio3, Inicio4,
	Normal,
	carrega1, carrega2, carrega3, carrega4, carrega5
	);

	-- Sinais referente ao estado atual
	SIGNAL state						: ESTADOS;		-- Representa o estado


	-- Sinais referentes ao timer
	SIGNAL 	Unidade			: STD_LOGIC_VECTOR (12 DOWNTO 0);
	SIGNAL 	Dezena			: STD_LOGIC_VECTOR (12 DOWNTO 0); 	
	SIGNAL 	Centena			: STD_LOGIC_VECTOR (12 DOWNTO 0);
	
	SIGNAL  Boxes_Free_c	: STD_LOGIC_VECTOR (12 DOWNTO 0);
	
BEGIN
	Vid_address <= map_address;
	map_data_out <= Vid_data;	


	-- Multiplica a saida do map_data_out por 15^2=225, para obter o valor no banco de bitmaps
	with map_data_out select
		map_data_out_x_100 <= 	"0000000000000" when "000",	-- caso 1, 100
								"0000011100001" when "001",	-- caso 1, 100
								"0000111000010" when "010",	-- caso 2, 200
								"0001010100011" when "011",	-- caso 3, 300
								"0001110000100" when "100",	-- caso 4, 400
								"0010001100101" when "101",	-- caso 5, 500
								"0010101000110" when OTHERS;	-- caso>6, 600


	-- Obtem também a referencia do timer dentro do banco de bitmaps
		C_Unidade: TimerExpand PORT MAP(Unidade_IN, Unidade);
		C_Dezena: TimerExpand PORT MAP (Dezena_IN, Dezena);	
		C_Centena: TimerExpand PORT MAP (Centena_IN, Centena);
		
		
		

	-- Instancia a VGAcon com os paramentros desejados
	vga_component: entity work.vgacon
	GENERIC MAP (
		NUM_HORZ_PIXELS => HORZ_SIZE,
		NUM_VERT_PIXELS => VERT_SIZE
	) PORT MAP (
		clk27M			=> clk27M		,
		rstn			=> reset		,
		write_clk		=> clk27M		,
		write_enable	=> '1'			,
		write_addr      => video_address,
		data_in         => video_word	,
		red				=> red			,
		green			=> green		,
		blue			=> blue			,
		hsync			=> hsync		,
		vsync			=> vsync		
	);
	
	
	-- Banco de Bitmaps
	BitmapRead: ReadMemory
	GENERIC MAP (
		WORDSIZE		=> 3,
		BITS_OF_ADDR	=> 13,	
		MIF_FILE		=> "tijolo.mif"
	) 
	PORT MAP (slow_clock, bitmap_address, bitmap_out);		
	

	-- Processo de escrita no VGACon	
	vga_writer:
	PROCESS (slow_clock, reset)

	variable pos_bitmap 				:	std_logic_vector (12 DOWNTO 0);		-- Posição no banco dos bitmaps
	variable linha_bitmap 				:	INTEGER RANGE 0 TO 20;				-- Linha do bitmap atual
	variable coluna_bitmap 				:	INTEGER RANGE 0 TO 20;				-- Coluna do bitmap atual
	variable enesimo_bitmap_da_linha 	:	INTEGER RANGE 0 TO 20;				-- Marca qual bitmap da linha é.
	variable enesimo_bitmap_da_coluna	:	INTEGER RANGE 0 TO 20;				-- Marca qual bitmap da coluna é.
	
	variable linha_logica				: 	INTEGER RANGE 0 TO 20;				-- Indica qual linha lógica se encontra.
	variable coluna_logica				: 	INTEGER RANGE 0 TO 20;				-- Indica qual coluna lógica se encontra.
	
	
	BEGIN
		IF (reset = '0') THEN						-- Clear

			linha_bitmap:= 0;						-- Começa na linha 0 do bitmap
			coluna_bitmap:= 0;						-- Começa na coluna 0 do bitmap
			enesimo_bitmap_da_linha:= 0;			-- Começa pelo bitmap 0 da linha
			enesimo_bitmap_da_coluna:= 0;			-- Começa pelo bitmap 0 da coluna
			
			linha_logica := 1;						-- Começa pela primeira linha lógica (a 0 é de proteção)
			coluna_logica := 1;						-- Começa pela primeira coluna lógica (a 0 é de proteção)
			
			map_address <= 19;						-- Prepara para carregar a primeira posição da matriz lógica
			state <= pre1;							-- Vai para o estado pre1;
			
		ELSIF (rising_edge(slow_clock)) THEN		-- map_address, map_data_out
			
			IF(state = pre1) THEN					-- Espera para carregar a primeira matriz lógica
				state <= pre2;
		
			ELSIF(state = pre2) THEN
				pos_bitmap := map_data_out_x_100;	-- Pega o valor do bitmap multiplicado por 100!
				state <= Inicio1;					-- Vai para o Inicio.
		
			ELSIF(state = Inicio1) THEN
				bitmap_address <=pos_bitmap;		-- Prepara para carregar a primeira posição do bitmap
				pos_bitmap := pos_bitmap+1;			-- Passa para próxima posição do bitmap
				state <= Inicio2;					-- Vai para o estado dois
				
			ELSIF(state = Inicio2) THEN
				bitmap_address <=pos_bitmap;		-- Prepara para carregar a segunda posição do bitmap
				pos_bitmap := pos_bitmap+1;			-- Vai para o próximo bitmap
				state <= Normal;					-- Vai para o estado normal
			
			ELSIF(state = Normal) THEN				-- Estado normal
				bitmap_address <=pos_bitmap;		-- Prepara para carregar o próximo pixel do bitmap
				pos_bitmap := pos_bitmap+1;			-- avança no bitmap
				
				video_word <= bitmap_out;			-- VideoWord é o bitmap_out
				
				IF(enesimo_bitmap_da_linha = 16) THEN	-- quer dizer que imprimiu uma linha inteira de bitmaps
					enesimo_bitmap_da_linha :=0;
					enesimo_bitmap_da_coluna := enesimo_bitmap_da_coluna+1;
				END IF;
				
				video_address <= linha_bitmap*JUMP_BITMAP_LINHA + coluna_bitmap + SIZE_BITMAP*enesimo_bitmap_da_linha 
				+ JUMP_BITMAP_COLUNA*enesimo_bitmap_da_coluna;
										
				coluna_bitmap := coluna_bitmap + 1;
					
					
				IF(coluna_bitmap = SIZE_BITMAP) THEN				-- Se a próxima coluna for 10, quer dizer que imprimiu a linha toda
					coluna_bitmap := 0;					-- zerar
					linha_bitmap := linha_bitmap+1;		-- passar para a próxima linha
				END IF;
				
				
				IF(linha_bitmap = SIZE_BITMAP) THEN				-- aqui quer dizer que imprimiu todo o bitmap
					linha_bitmap := 0;					-- Zera a linha dos bitmaps
					enesimo_bitmap_da_linha := enesimo_bitmap_da_linha + 1;	-- Passa para o próximo bitmap da linha
					coluna_logica := coluna_logica+1;	-- Passa para a próxima coluna lógica
					state <= carrega1;					-- Vai para o estado carrega1
				
				END IF;
				
				-- Falta verificação de que toda tela foi imprimida (neste caso, vale notar que o bitmap também acabou!).
				-- Caso especial, tratar depois.
				
			
			ELSIF(state = carrega1) THEN	
				
				if(coluna_logica=17) THEN				-- Verifica se acabou a linha
					coluna_logica := 1;					-- Se acabou, volta para inicial
					linha_logica := linha_logica+1;		-- E vai para próxima linha
				end if;
				
					map_address <= 18*linha_logica+1*coluna_logica;	-- Prepara para carregar o próximo endereço
					state <= carrega2;								-- Vai para carrega 2
			
			ELSIF(state = carrega2) THEN	
			
				state <= carrega3;								-- Espera carregar
			
			ELSIF(state = carrega3) THEN	
			
				pos_bitmap := map_data_out_x_100;				-- Obtem map_data_out_x_100
				state <= carrega4;
				
				if (linha_logica = 12) THEN						-- Imprimi bitmaps do relógio
					IF (coluna_logica = 1) THEN
						pos_bitmap :=POS_BITMAP_CENTENA;									
					ELSIF(coluna_logica = 2) THEN
						pos_bitmap :=POS_BITMAP_DEZENA;
					ELSIF(coluna_logica = 3) THEN
						pos_bitmap :=POS_BITMAP_UNIDADE;
					ELSIF(coluna_logica = 4) THEN
						pos_bitmap := Centena;
					ELSIF(coluna_logica = 5) THEN
						pos_bitmap := Dezena;
					ELSIF(coluna_logica = 6) THEN
						pos_bitmap := Unidade;
					ELSIF(coluna_logica = 7) THEN
						pos_bitmap := "1101001011110";
					ELSIF(coluna_logica = 8) THEN
						pos_bitmap := "1101001011110";
					ELSIF(coluna_logica = 9) THEN
						pos_bitmap := "1000110010100";
					ELSIF(coluna_logica = 10) THEN
						IF (MUX_SIGNAL="00") THEN
							pos_bitmap := "0100110101011";
						ELSIF (MUX_SIGNAL="01") THEN
							pos_bitmap := "0101010001100";
						ELSIF (MUX_SIGNAL="10") THEN
							pos_bitmap := "0101101101101";
						ELSE
							pos_bitmap := "0110001001110";
						END IF;
					ELSE
						linha_bitmap:= 0;						-- Começa na linha 0 do bitmap
						coluna_bitmap:= 0;						-- Começa na coluna 0 do bitmap
						enesimo_bitmap_da_linha:= 0;			-- Começa pelo bitmap 0 da linha
						enesimo_bitmap_da_coluna:= 0;			-- Começa pelo bitmap 0 da coluna
						
						linha_logica := 1;						-- Começa pela primeira linha lógica (a 0 é de proteção)
						coluna_logica := 1;						-- Começa pela primeira coluna lógica (a 0 é de proteção)
						
						map_address <= 19;						-- Prepara para carregar a primeira posição da matriz lógica
						state <= pre1;							-- Vai para o estado pre1;
									
					END IF;
				END IF;
			
			ELSIF(state = carrega4) THEN	
	
				bitmap_address <=pos_bitmap;					-- Prepara o bitmap para carregar
				pos_bitmap := pos_bitmap+1;
--				state <= Normal;
				state <= carrega5;
			
			ELSIF(state = carrega5) THEN						-- Prepara o segundo bitmap para carregar
				bitmap_address <=pos_bitmap;
				pos_bitmap := pos_bitmap+1;
				state <= normal;								-- Volta para o estado normal
			
			END IF;
			
			
		END IF;	
	END PROCESS;
END ARCHITECTURE;
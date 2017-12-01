-----------------------------------------------------------------------------------
--	Alexandre Luiz Brisighello Filho 	- alexandre.brisighello@gmail.com		 --
--	Andre Nakagaki Filliettaz			- andrentaz@gmail.com					 --
--																				 --
--	Project: sokoban-altera														 --
--	file: DisplayWorks.vhd														 --
--	description: Takes care of the game video output, by using a state machine	 --
--	which prints bitmap per bitmap.												 --
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

		-- Receive timer signals
		Unidade_IN			: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		Dezena_IN			: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		Centena_IN			: IN STD_LOGIC_VECTOR (3 DOWNTO 0);

		-- Receive logic memory signals
		-- Logic map
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
	CONSTANT SIZE_BITMAP 			: INTEGER := 15;	-- Defines everything, bitmap lenght
	CONSTANT JUMP_BITMAP_LINHA 		: INTEGER := 240;	-- SIZE_BITMAP * 16
	CONSTANT JUMP_BITMAP_COLUNA		: INTEGER := 3600;	-- 16 * SIZE_BITMAP^2
	CONSTANT POS_BITMAP_CENTENA		: std_logic_vector (12 DOWNTO 0) := "0011000100111";	-- 7 * SIZE_BITMAP^2
	CONSTANT POS_BITMAP_DEZENA		: std_logic_vector (12 DOWNTO 0) := "0011100001000";	-- 8 * SIZE_BITMAP^2
	CONSTANT POS_BITMAP_UNIDADE		: std_logic_vector (12 DOWNTO 0) := "0011111101001";	-- 9 * SIZE_BITMAP^2

	-- VGAcon adresses
	SIGNAL video_address	: INTEGER RANGE 0 TO HORZ_SIZE * VERT_SIZE - 1;
	SIGNAL video_word		: STD_LOGIC_VECTOR (2 DOWNTO 0);

	-- Bitmaps memory read addresses
	SIGNAL bitmap_address	: STD_LOGIC_VECTOR (12 DOWNTO 0);
	SIGNAL bitmap_out		: STD_LOGIC_VECTOR (2 DOWNTO 0);


	SIGNAL map_address		: integer range 0 to 255;
	SIGNAL map_data_out		: STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL map_data_out_x_100 : STD_LOGIC_VECTOR(12 DOWNTO 0);


	-- Possible states
	TYPE ESTADOS IS (
	pre1, pre2, pre3, pre4,
	Inicio1, Inicio2, Inicio3, Inicio4,
	Normal,
	carrega1, carrega2, carrega3, carrega4, carrega5
	);

	-- Signals referent to the current state
	SIGNAL state						: ESTADOS;


	-- Signals referent to the timer
	SIGNAL 	Unidade			: STD_LOGIC_VECTOR (12 DOWNTO 0);
	SIGNAL 	Dezena			: STD_LOGIC_VECTOR (12 DOWNTO 0);
	SIGNAL 	Centena			: STD_LOGIC_VECTOR (12 DOWNTO 0);

	SIGNAL  Boxes_Free_c	: STD_LOGIC_VECTOR (12 DOWNTO 0);

BEGIN
	Vid_address <= map_address;
	map_data_out <= Vid_data;


	-- Multiplies map_data_out output by 15^2=225, to obtain its value in the bitmap bank
	with map_data_out select
		map_data_out_x_100 <= 	"0000000000000" when "000",	-- caso 1, 100
								"0000011100001" when "001",	-- caso 1, 100
								"0000111000010" when "010",	-- caso 2, 200
								"0001010100011" when "011",	-- caso 3, 300
								"0001110000100" when "100",	-- caso 4, 400
								"0010001100101" when "101",	-- caso 5, 500
								"0010101000110" when OTHERS;	-- caso>6, 600


	-- Also obtain a reference to the timer inside the bitmap bank
		C_Unidade: TimerExpand PORT MAP(Unidade_IN, Unidade);
		C_Dezena: TimerExpand PORT MAP (Dezena_IN, Dezena);
		C_Centena: TimerExpand PORT MAP (Centena_IN, Centena);




	-- Instantiate VGAcon with the desired parameters
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


	-- Bitmap bank
	BitmapRead: ReadMemory
	GENERIC MAP (
		WORDSIZE		=> 3,
		BITS_OF_ADDR	=> 13,
		MIF_FILE		=> "tijolo.mif"
	)
	PORT MAP (slow_clock, bitmap_address, bitmap_out);


	-- VGACon write process
	vga_writer:
	PROCESS (slow_clock, reset)

	variable pos_bitmap 				:	std_logic_vector (12 DOWNTO 0);		-- Bitmap bank position
	variable linha_bitmap 				:	INTEGER RANGE 0 TO 20;				-- Current bitmap line
	variable coluna_bitmap 				:	INTEGER RANGE 0 TO 20;				-- Current bitmap colum
	variable enesimo_bitmap_da_linha 	:	INTEGER RANGE 0 TO 20;				-- Marks what's the bitmap at line N
	variable enesimo_bitmap_da_coluna	:	INTEGER RANGE 0 TO 20;				-- Marks what's the bitmap at column N

	variable linha_logica				: 	INTEGER RANGE 0 TO 20;				-- Indicates current logic line
	variable coluna_logica				: 	INTEGER RANGE 0 TO 20;				-- Indicates current logic column


	BEGIN
		IF (reset = '0') THEN						-- Clear

			linha_bitmap:= 0;						-- Starts at bitmap's line 0
			coluna_bitmap:= 0;						-- Starts at bitmap's column 0
			enesimo_bitmap_da_linha:= 0;			-- Starts at line's 0th bitmap
			enesimo_bitmap_da_coluna:= 0;			-- Starts at column's 0th bitmap

			linha_logica := 1;						-- Starts at first logic line (0 is for protection)
			coluna_logica := 1;						-- Starts at first logic column (0 is for protection)

			map_address <= 19;						-- Prepares to lod the first position of logic matrix
			state <= pre1;							-- move to "pre1" state

		ELSIF (rising_edge(slow_clock)) THEN		-- map_address, map_data_out

			IF(state = pre1) THEN					-- Wait to load the first logic matrix.
				state <= pre2;

			ELSIF(state = pre2) THEN
				pos_bitmap := map_data_out_x_100;	-- Take bitmap value multiplied by 100
				state <= Inicio1;					-- Go to initial state

			ELSIF(state = Inicio1) THEN
				bitmap_address <=pos_bitmap;		-- Prepares to load the first bitmap position
				pos_bitmap := pos_bitmap+1;			-- Pass to the next bitmap position
				state <= Inicio2;					-- Go to state 2

			ELSIF(state = Inicio2) THEN
				bitmap_address <=pos_bitmap;		-- Prepares to load the second bitmap position
				pos_bitmap := pos_bitmap+1;			-- Pass to the next bitmap
				state <= Normal;					-- Go to normal state

			ELSIF(state = Normal) THEN				-- Normal state
				bitmap_address <=pos_bitmap;		-- Prepare to load the next bitmaps pixel
				pos_bitmap := pos_bitmap+1;			-- Advance on bitmap

				video_word <= bitmap_out;			-- VideoWord is the bitmap_out

				IF(enesimo_bitmap_da_linha = 16) THEN	-- printed a full line of bitmaps
					enesimo_bitmap_da_linha :=0;
					enesimo_bitmap_da_coluna := enesimo_bitmap_da_coluna+1;
				END IF;

				video_address <= linha_bitmap*JUMP_BITMAP_LINHA + coluna_bitmap + SIZE_BITMAP*enesimo_bitmap_da_linha
				+ JUMP_BITMAP_COLUNA*enesimo_bitmap_da_coluna;

				coluna_bitmap := coluna_bitmap + 1;


				IF(coluna_bitmap = SIZE_BITMAP) THEN	-- If next column is 10, everything was printed
					coluna_bitmap := 0;					-- Make it zero
					linha_bitmap := linha_bitmap+1;		-- Go to the next line
				END IF;


				IF(linha_bitmap = SIZE_BITMAP) THEN		-- If here, all bitmap was printed
					linha_bitmap := 0;					-- Make bitmap's line 0
					enesimo_bitmap_da_linha := enesimo_bitmap_da_linha + 1;	-- Move to the next bitmap's line
					coluna_logica := coluna_logica+1;	-- Move to the next logic column
					state <= carrega1;					-- Go to state "carrega1"

				END IF;

				-- Lacks verification that the whole screen was printed (in such case, it worth to note that the bitmap also finished)
				-- Special case, deal with it later


			ELSIF(state = carrega1) THEN

				if(coluna_logica=17) THEN				-- Verifies if line is over
					coluna_logica := 1;					-- If over, go back to initial
					linha_logica := linha_logica+1;		-- And go to next line
				end if;

					map_address <= 18*linha_logica+1*coluna_logica;	-- Prepares to load next address
					state <= carrega2;								-- Go to "carrega 2" state

			ELSIF(state = carrega2) THEN

				state <= carrega3;								-- Wait for it to load

			ELSIF(state = carrega3) THEN

				pos_bitmap := map_data_out_x_100;				-- Obtain map_data_out_x_100
				state <= carrega4;

				if (linha_logica = 12) THEN						-- Print clock bitmaps
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
						linha_bitmap:= 0;						-- Starts at bitmap's line 0
						coluna_bitmap:= 0;						-- Starts at bitmap's column 0
						enesimo_bitmap_da_linha:= 0;			-- Starts at line's 0th bitmap
						enesimo_bitmap_da_coluna:= 0;			-- Starts at column's 0th bitmap

						linha_logica := 1;						-- Starts at first logic line (0 is for protection)
						coluna_logica := 1;						-- Starts at first column line (0 is for protection)

						map_address <= 19;						-- Prepares to load the first position at the logic matrix
						state <= pre1;							-- Go to state pre1

					END IF;
				END IF;

			ELSIF(state = carrega4) THEN

				bitmap_address <=pos_bitmap;					-- Prepares bitmap for loading
				pos_bitmap := pos_bitmap+1;
--				state <= Normal;
				state <= carrega5;

			ELSIF(state = carrega5) THEN						-- Prepares second bitmap for loading
				bitmap_address <=pos_bitmap;
				pos_bitmap := pos_bitmap+1;
				state <= normal;								-- Go back to normal state

			END IF;


		END IF;
	END PROCESS;
END ARCHITECTURE;
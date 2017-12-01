-----------------------------------------------------------------------------------
--	Alexandre Luiz Brisighello Filho 	- RA:101350								 --
--	Andre Nakagaki Filliettaz			- RA:104595								 --
--																				 --
--	MC613 - Projeto final : Sokoban												 --
--	Arquivo : Mod10.vhdl													 	 --
--	Descrição : Contador de módulo 10 onde a contagem é feita de forma 		 	 --
--	regressiva. Possui clear com condicionais para carregar os valores iniciais  --
--  de cada "fase".																 --
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
		Mode			: IN STD_LOGIC;							-- 0 conta, 1 para!
		Enable			: IN STD_LOGIC;							-- Permite funcionar ou nao
		Q				: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);	-- Saida dos numeros
		Zerou			: OUT STD_LOGIC;						-- Indica se zerou
		MUX				: IN STD_LOGIC_VECTOR (1 DOWNTO 0));	-- Mux para seleção de "fase"
END Mod10;

ARCHITECTURE Behavior OF Mod10 IS

BEGIN

-- Mode 0 -> Add, vai adicionando normalmente.
-- Mode 1 -> Para
-- Set com o Clear, passados por Generic

Refresh: Process ( Clock, Mode )
	variable count : STD_LOGIC_VECTOR (3 DOWNTO 0);
Begin
	if (Clear = '0') Then				-- Ve qual valor deve iniciar
			if (MUX = "00") THEN
				count := Inicial_stage1;
			elsif (MUX ="01") THEN	
				count := Inicial_stage2;
			elsif (MUX ="10") THEN	
				count := Inicial_stage3;
			else
				count := Inicial_stage4;
			END IF;
			
				Zerou <= '0';			-- Valores de correção para inicialização
			IF ( count = 0 ) THEN
				Zerou<='1';
			END IF;	
			q<=count;
			
	elsif (Clock'Event AND Clock='1') Then
		if(Mode = '0' AND Enable = '1') THEN
			if ( count = 1 ) Then
				count := "0000";		-- iguala a nove para proxima contagem.
				Zerou<='1';
				q<= count;
			elsif ( count = 0 ) Then
				count := "1001";		-- iguala a nove para proxima contagem.
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

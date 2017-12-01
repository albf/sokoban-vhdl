-----------------------------------------------------------------------------------
--	Alexandre Luiz Brisighello Filho 	- RA:101350								 --
--	Andre Nakagaki Filliettaz			- RA:104595								 --
--																				 --
--	MC613 - Projeto final : Sokoban												 --
--	Arquivo : Mem_Logica_Mux.vhdl												 --
--	Descri��o : Trata-se de um mux que seleciona entre as mem�rias aquela que    --
--	representa a "fase" atual.													 --
-----------------------------------------------------------------------------------

LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;

ENTITY MemLogica_Mux IS
	PORT (
Log_Mem_Enable				: OUT STD_LOGIC;						-- Mem�ria 1					
Log_Mem_Adress				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
Log_Mem_DataIn				: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
Log_Mem_DataOut				: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
Vid_Mem_Adress				: OUT integer range 0 to 255; 	
Vid_Mem_DataOut				: IN STD_LOGIC_VECTOR(2 DOWNTO 0);  

Log_Mem_Enable2				: OUT STD_LOGIC;						-- Mem�ria 2
Log_Mem_Adress2				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
Log_Mem_DataIn2				: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
Log_Mem_DataOut2			: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
Vid_Mem_Adress2				: OUT integer range 0 to 255; 	
Vid_Mem_DataOut2			: IN STD_LOGIC_VECTOR(2 DOWNTO 0);  

Log_Mem_Enable3				: OUT STD_LOGIC;						-- Mem�ria 3
Log_Mem_Adress3				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
Log_Mem_DataIn3				: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
Log_Mem_DataOut3			: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
Vid_Mem_Adress3				: OUT integer range 0 to 255; 	
Vid_Mem_DataOut3			: IN STD_LOGIC_VECTOR(2 DOWNTO 0);  

Log_Mem_Enable4				: OUT STD_LOGIC;						-- Mem�ria 4	
Log_Mem_Adress4				: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
Log_Mem_DataIn4				: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
Log_Mem_DataOut4			: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
Vid_Mem_Adress4				: OUT integer range 0 to 255; 	
Vid_Mem_DataOut4			: IN STD_LOGIC_VECTOR(2 DOWNTO 0); 

Sinal_Mux					: IN STD_LOGIC_VECTOR(1 DOWNTO 0);		-- Sinal seletor de mux

Log_Mem_Enable_T			: IN STD_LOGIC;							-- Saidas escolhidas
Log_Mem_Adress_T			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
Log_Mem_DataIn_T			: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
Log_Mem_DataOut_T			: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
Vid_Mem_Adress_T			: IN integer range 0 to 255; 	
Vid_Mem_DataOut_T			: OUT STD_LOGIC_VECTOR(2 DOWNTO 0) 

	);
END ENTITY;

ARCHITECTURE Behavior OF MemLogica_Mux IS

BEGIN
-- Seleciona todos as saidas/entradas de acordo com o que � dado pelo mux.
-- Note que algumas entradas n�o s�o importantes para o projeto, portanto, 
-- N�o foi utilizado mux, apenas liga��o direta. 

-- OBS: Isso poderia ser representado por fora, por�m, para futuras atualiza��es
-- e mais f�cil entendimento do c�digo, colocamos todos os sinais de mem�ria
-- passando por esta componente.

	with Sinal_Mux select				
	Log_Mem_Enable 	<= 	Log_Mem_Enable_T when "00",	
						'0' when OTHERS;	
						
	with Sinal_Mux select
	Log_Mem_Enable2	<= 	Log_Mem_Enable_T when "01",	
						'0' when OTHERS;
											
	with Sinal_Mux select
	Log_Mem_Enable3	<= 	Log_Mem_Enable_T when "10",	
						'0' when OTHERS;

	with Sinal_Mux select
	Log_Mem_Enable4	<= 	Log_Mem_Enable_T when "11",	
						'0' when OTHERS;
						
	Log_Mem_Adress	<= 	Log_Mem_Adress_T;
	Log_Mem_Adress2	<= 	Log_Mem_Adress_T;	
	Log_Mem_Adress3	<= 	Log_Mem_Adress_T;	
	Log_Mem_Adress4	<= 	Log_Mem_Adress_T;
	
	Log_Mem_DataIn 	<=	Log_Mem_DataIn_T;
	Log_Mem_DataIn2	<=	Log_Mem_DataIn_T;
	Log_Mem_DataIn3	<=	Log_Mem_DataIn_T;
	Log_Mem_DataIn4	<=	Log_Mem_DataIn_T;
	
	Vid_Mem_Adress 	<= 	Vid_Mem_Adress_T;
	Vid_Mem_Adress2	<= 	Vid_Mem_Adress_T;
	Vid_Mem_Adress3 <= 	Vid_Mem_Adress_T;
	Vid_Mem_Adress4 <= 	Vid_Mem_Adress_T;
	
	with Sinal_Mux select 
	Log_Mem_DataOut_T <= 	Log_Mem_DataOut 	when "00",
							Log_Mem_DataOut2 	when "01",
							Log_Mem_DataOut3 	when "10",
							Log_Mem_DataOut4 	when OTHERS;
							
	with Sinal_Mux select 
	Vid_Mem_DataOut_T <= 	Vid_Mem_DataOut 	when "00",
							Vid_Mem_DataOut2	when "01",
							Vid_Mem_DataOut3 	when "10",
							Vid_Mem_DataOut4	when OTHERS;
	
				
END ARCHITECTURE Behavior;
--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY  Execute IS
	PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Sign_extend 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Function_opcode : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 ); --Instruction( 5 DOWNTO 0 )
			ALUOp 			: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			ALUSrc 			: IN 	STD_LOGIC;
			shamt 			: IN 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			Zero 			: OUT	STD_LOGIC;
			ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Add_Result 		: OUT	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			PC_plus_4 		: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			clock			: IN 	STD_LOGIC
			reset			: IN 	STD_LOGIC
			mul      		: IN 	STD_LOGIC ;
			Addi      		: IN 	STD_LOGIC ;
			Andi      		: IN 	STD_LOGIC ;
			Ori       		: IN 	STD_LOGIC ;
			Xori  			: IN 	STD_LOGIC ;
			lui	  			: IN 	STD_LOGIC );
END Execute;

ARCHITECTURE behavior OF Execute IS
SIGNAL Ainput, Binput 				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL ALU_output_mux				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL Branch_Add 					: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
SIGNAL ALU_ctl ,ALU_ctl_with_imm		: STD_LOGIC_VECTOR( 2 DOWNTO 0 );
SIGNAL shift_l,shift_r				: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL multi						: STD_LOGIC_VECTOR( 63 DOWNTO 0 );

BEGIN
	
	
	Ainput <= Read_data_1;
	
						-- ALU input mux
	Binput <= Read_data_2 WHEN ( ALUSrc = '0' ) 
			  ELSE  Sign_extend( 31 DOWNTO 0 );
			  
						-- shift
	shift_l <= sll( Binput, shamt);
	shift_r <= srl( Binput, shamt);
	
						-- multiplication
	multi   <= Ainput * Binput;		  
						-- Generate ALU control bits
	ALU_ctl( 0 ) <= ( Function_opcode( 0 ) OR Function_opcode( 3 ) ) AND ALUOp(1 );
	ALU_ctl( 1 ) <= ( NOT Function_opcode( 2 ) ) OR (NOT ALUOp( 1 ) );
	ALU_ctl( 2 ) <= ( Function_opcode( 1 ) AND ALUOp( 1 )) OR ALUOp( 0 );
	
	ALU_ctl_with_imm <= 
			   "010" when (opcode(5 downto 1) ="00100" AND Imm = '1') OR (Function_opcode = "100001" AND ALUOp(1 ) = '1') else 	----------- addi and addu
			   "000" when Andi = '1' else 	----------- andi
			   "001" when Ori = '1' else 	----------- ori
			   "100" when Xori = '1' else 	----------- xori
			   "101" when lui ='1' else 	----------- lui
			   --"111" when opcode="001010" AND Imm = '1' else 	----------- lsti
			   ALU_ctl;
			   
						-- Generate Zero Flag
	Zero <= '1' 
		WHEN ( ALU_output_mux( 31 DOWNTO 0 ) = X"00000000"  )
		ELSE '0';    
		
						-- Select ALU output        
	ALU_result <= X"0000000" & B"000"  & ALU_output_mux( 31 ) WHEN  ALU_ctl = "111" 
				  ELSE shift_l WHEN (Function_opcode = "000000" AND ALUOp(1) = '1') -- sll if func = 0 and R type 
				  ELSE shift_r WHEN (Function_opcode = "000010" AND ALUOp(1) = '1') -- srl if func = 2 and R type
				  ELSE multi (31 downto 0)   WHEN mul = '1' -- mul
				  ELSE ALU_output_mux( 31 DOWNTO 0 );
		
						-- Adder to compute Branch Address
	Branch_Add	<= PC_plus_4( 9 DOWNTO 2 ) +  Sign_extend( 7 DOWNTO 0 ) ;
		Add_result 	<= Branch_Add( 7 DOWNTO 0 );

PROCESS ( ALU_ctl_with_imm, Ainput, Binput )
	BEGIN
					-- Select ALU operation
 	CASE ALU_ctl_with_imm IS
						-- ALU performs ALUresult = A_input AND B_input
		WHEN "000" 	=>	ALU_output_mux 	<= Ainput AND Binput; 
						-- ALU performs ALUresult = A_input OR B_input
     	WHEN "001" 	=>	ALU_output_mux 	<= Ainput OR Binput;
						-- ALU performs ALUresult = A_input + B_input
	 	WHEN "010" 	=>	ALU_output_mux 	<= Ainput + Binput;
						-- ALU performs ?
 	 	WHEN "011" 	=>	ALU_output_mux <= X"00000000";
						-- ALU performs ALUresult = A_input XOR B_input
 	 	WHEN "100" 	=>	ALU_output_mux 	<= Ainput XOR Binput;
						-- ALU performs ALUresult = Binput(15 downto 0) & X"0000" (lui)
 	 	WHEN "101" 	=>	ALU_output_mux 	<= Binput(15 downto 0) & X"0000";;
						-- ALU performs ALUresult = A_input -B_input
 	 	WHEN "110" 	=>	ALU_output_mux 	<= Ainput - Binput;
						-- ALU performs SLT
  	 	WHEN "111" 	=>	ALU_output_mux 	<= Ainput - Binput ;
 	 	WHEN OTHERS	=>	ALU_output_mux 	<= X"00000000" ;
  	END CASE;
  END PROCESS;
END behavior;


		-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY control IS
   PORT( 	
	Opcode 			: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
	clock, reset	: IN 	STD_LOGIC ;
	Jump,Imm     	: IN 	STD_LOGIC ;
	Instruction		: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0); 
	RegDst 			: OUT 	STD_LOGIC;
	ALUSrc 			: OUT 	STD_LOGIC;
	MemtoReg 		: OUT 	STD_LOGIC;
	RegWrite 		: OUT 	STD_LOGIC;
	MemRead 		: OUT 	STD_LOGIC;
	MemWrite 		: OUT 	STD_LOGIC;
	Branch 			: OUT 	STD_LOGIC;
	ALUop 			: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	mul 			: OUT 	STD_LOGIC;
	Addi      		: OUT 	STD_LOGIC ;
	Andi      		: OUT 	STD_LOGIC ;
	Ori       		: OUT 	STD_LOGIC ;
	Xori  			: OUT 	STD_LOGIC ;
	lui	  			: OUT 	STD_LOGIC ;
	J				: OUT 	STD_LOGIC ;
	JAL 			: OUT 	STD_LOGIC ;
	JR   			: OUT 	STD_LOGIC );
	
END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  R_format, Lw, Sw, Beq , J ,JAR , JR, I_format	: STD_LOGIC;
BEGIN           
				-- Code to generate control signals using opcode bits
	R_format 	<=  '1'  WHEN  Opcode = "000000"  ELSE '0';
	Lw          <=  '1'  WHEN  Opcode = "100011"  ELSE '0';
	I_format 	<=	'1'  WHEN  Opcode(5 downto 3) = "001"  ELSE '0';
 	Sw          <=  '1'  WHEN  Opcode = "101011"  ELSE '0';
   	Beq         <=  '1'  WHEN  Opcode = "000100"  ELSE '0';
	Bne			<=  '1'  WHEN  Opcode = "000101"  ELSE '0'; 
	J			<= 	'1'  WHEN  Opcode = "000010"  ELSE '0';
	JAL 		<=	'1'  WHEN  Opcode = "000011"  ELSE '0';
	JR   		<=  '1'  WHEN  (Opcode = "000000" AND Instruction = "001000") ELSE '0';
	Addi      	<=  '1'  WHEN  Opcode = "001000" ELSE '0';
	Andi      	<=  '1'  WHEN  Opcode = "001100" ELSE '0';
	Ori       	<=  '1'  WHEN  Opcode = "001101" ELSE '0';
	Xori  		<=  '1'  WHEN  Opcode = "001110" ELSE '0';
	lui	  		<=  '1'  WHEN  Opcode = "001111" ELSE '0';
	mul 		<=  '1'  WHEN  (opcode="011100" AND Instruction = "000010") ELSE '0';
	
  	RegDst    	<=  R_format; -- instruction[20-16](I-type) or instruction[15-11](R-type) to write register
 	ALUSrc  	<=  Lw OR Sw OR I_format OR J OR JAL ; -- sign_extend or read_data2 to ALU
	MemtoReg 	<=  Lw; -- read_data_from_memory or alu_result to write_data_in_register_file
  	RegWrite 	<=  R_format OR Lw OR I_format OR JR OR JAL; -- enable to write to register file
  	MemRead 	<=  Lw;
   	MemWrite 	<=  Sw; 
 	Branch      <=  Beq;
	ALUOp( 1 ) 	<=  R_format;
	ALUOp( 0 ) 	<=  Beq OR Bne;
	Jump        <=  J OR JAL OR JR;
	Imm			<=	I_format;
   END behavior;



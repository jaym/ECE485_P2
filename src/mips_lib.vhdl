---------------------------------------------------------------------------
-- Author(s)   : Jay Mundrawala <mundra@ir.iit.edu>
-- 
-- File          : mips_lib.vhdl
-- Creation Date : 06/11/2009
-- Description: 
--
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

package mips_lib is
    constant DATA_WIDTH : integer              := 32;
    constant ADDR_WIDTH : integer              := 32;

    constant rOpcode    : bit_vector(5 downto 0) :="000000";
    constant jOpcode    : bit_vector(5 downto 0) :="000010";
    constant jalOpcode  : bit_vector(5 downto 0) :="000011";
    constant addiOpcode : bit_vector(5 downto 0) :="001000";
    constant andiOpcode : bit_vector(5 downto 0) :="001100";
    constant beqOpcode  : bit_vector(5 downto 0) :="000100";
    constant bneOpcode  : bit_vector(5 downto 0) :="000101";
    constant lwOpcode   : bit_vector(5 downto 0) :="100011";
    constant swOpcode   : bit_vector(5 downto 0) :="101011";

    constant addFunc    : bit_vector(5 downto 0) :="100000";
    constant subFunc    : bit_vector(5 downto 0) :="100010";
    constant andFunc    : bit_vector(5 downto 0) :="100100";
    constant orFunc     : bit_vector(5 downto 0) :="100101";
    constant sltFunc    : bit_vector(5 downto 0) :="101010";
    constant sllFunc    : bit_vector(5 downto 0) :="000000";

    constant UDEXP      : std_logic_vector(31 downto 0) := x"00000003";
    constant OVFEXP     : std_logic_vector(31 downto 0) := x"00000001";



    type t_aluSrcA    is (ASA_PC, ASA_REG_A);
    type t_aluSrcB    is (ASB_REGB, ASB_FOUR, ASB_SEXT, ASB_SEXTS);
    type t_aluOp      is (AOP_AND, AOP_OR, AOP_ADD, AOP_SUB, AOP_SLT, AOP_NOR, AOP_SLL);
    type t_pcSrc      is (PS_PCINC, PS_ALUOUT, PS_JMP, PS_FOUR);
    type t_regDst     is (RD_RT, RD_RD, RD_RA);
    type t_iord       is (IOD_PC, IOD_ALUOUT);
    type t_memToReg   is (MTR_ALUOUT, MTR_MDR, MTR_PC);
    type t_comp       is (eq, ne, gt, lt, lte, gte);
    type t_microinstr is (
         s_if,    --Instruction Fetch 
         s_id     --Instruction Decode
    );   


end package;

---------------------------------------------------------------------------
-- Author(s)   : Jay Mundrawala <mundra@ir.iit.edu>
-- 
-- File          : LW_Testbench.vhdl
-- Creation Date : 21/11/2009
-- Description: 
--              
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.mips_lib.all;

---------------------------------------------------------------------------
Entity LW_Testbench is 
---------------------------------------------------------------------------
end entity;


---------------------------------------------------------------------------
Architecture LW_Testbench_1 of LW_Testbench is
---------------------------------------------------------------------------
    constant T: time := 100 ns;
    signal Clk : std_logic := '0';
    component datapath
            port(
            clk           : in std_logic;
    -- Control Unit
            PCWriteCondEq : in std_logic;
            PCWriteCondNEq : in std_logic;
            PCWrite       : in std_logic;
            IorD          : in t_iord;
            MemRead       : in std_logic;
            MemWrite      : in std_logic;
            MemToReg      : in t_memToReg;
            IRWrite       : in std_logic;
            RegWrite      : in std_logic;
            RegDst        : in t_regDst;
            ALUSrcA       : in t_aluSrcA;
            ALUSrcB       : in t_aluSrcB;
            PCSource      : in t_pcSrc;
            ALUOp         : in t_aluOp;
            UndefInstrEx  : in std_logic;
            OverflowEx    : out std_logic;
            Exception     : in std_logic;
    --Memory
            mem_data_out   : in  std_logic_vector((DATA_WIDTH-1) downto 0);
            mem_read       : out std_logic;
            addr_bus       : out std_logic_vector((DATA_WIDTH-1) downto 0);
            mem_write_data : out std_logic_vector((DATA_WIDTH-1) downto 0)
        );
    end component datapath;

    signal PCWriteCondEq : std_logic;
    signal PCWriteCondNEq : std_logic;
    signal PCWrite       : std_logic;
    signal IorD          : t_iord;
    signal MemRead       : std_logic;
    signal MemWrite      : std_logic;
    signal MemToReg      : t_memToReg;
    signal IRWrite       : std_logic;
    signal RegWrite      : std_logic;
    signal RegDst        : t_regDst;
    signal ALUSrcA       : t_aluSrcA;
    signal ALUSrcB       : t_aluSrcB;
    signal PCSource      : t_pcSrc;
    signal ALUOp         : t_aluOp;
    signal UndefInstrEx  : std_logic;
    signal OverflowEx    : std_logic;
    signal Exception     : std_logic;
 --Memory
    signal mem_data_out   : std_logic_vector((DATA_WIDTH-1) downto 0);
    signal mem_read       : std_logic;
    signal addr_bus       : std_logic_vector((DATA_WIDTH-1) downto 0);
    signal mem_write_data : std_logic_vector((DATA_WIDTH-1) downto 0);

begin
	 --Create a clock.
    PROCESS
    BEGIN
        Clk <= '0';
        WAIT FOR T/2;
        Clk <= '1';
        WAIT FOR T/2;
    END PROCESS;

    DUT: entity work.datapath
    port map(
                clk           => clk,
                PCWriteCondEq => PCWriteCondEq,
                PCWriteCondNEq => PCWriteCondNEq,
                PCWrite       => PCWrite,
                IorD          => IorD,
                MemRead       => MemRead,
                MemWrite      => MemWrite,
                MemToReg      => MemToReg,
                IRWrite       => IRWrite,
                RegWrite      => RegWrite,
                RegDst        => RegDst,
                ALUSrcA       => ALUSrcA,
                ALUSrcB       => ALUSrcB,
                PCSource      => PCSource,
                ALUOp         => ALUOp,
                UndefInstrEx  => UndefInstrEx,
                OverflowEx    => OverflowEx,
                Exception     => Exception,

                mem_data_out   => mem_data_out,
                mem_read       => mem_read,
                addr_bus       => addr_bus,
                mem_write_data => mem_write_data
            );

    PROCESS
    BEGIN
        PCWriteCondEq <= '0';
        PCWriteCondNEq <= '0';
        PCWrite <= '0';
        IorD <= IOD_PC;
        MemRead <= '0';
        MemWrite <= '0';
        MemToReg <= MTR_ALUOUT;
        IRWrite <= '0';
        RegWrite <= '0';
        RegDst <= RD_RT;
        ALUSrcA <= ASA_PC;
        ALUSrcB <= ASB_REGB;
        PCSource <= PS_PCINC;
        ALUOp <= AOP_AND;

        -- R[1] <= R0 + 4
        mem_data_out <= "100011" & "00000" & "00001" & x"00FF";
        wait for T;

        -- IF
        MemRead <= '1';
        ALUSrcA <= ASA_PC;
        IorD <= IOD_PC;
        IRWrite <= '1';
        ALUSrcB <= ASB_FOUR;
        ALUOp <= AOP_ADD;
        PCWrite <= '0';
        PCSource <= PS_PCINC;
        wait for T/2;
        PCWrite <= '1';
        wait for T/2;
        -- ID/Bra Calc
        PCWrite <= '0';
        MemRead <= '0';
        IRWrite <= '0';
        ALUSrcA <= ASA_PC;
        ALUSrcB <= ASB_SEXTS;
        PCSource <= PS_PCINC;
        ALUOp <= AOP_ADD;
        wait for T;

        -- Memory Address Comp
        ALUSrcA <= ASA_REG_A;
        ALUSrcB <= ASB_SEXT;
        ALUOp <= AOP_ADD;
        wait for T;

        -- Memory Access
        IorD <= IOD_ALUOUT;
        MemRead <= '1';
        wait for T/2;
        MemRead <= '0';
        wait for T/2;

        --Write Back
        MemToReg <= MTR_MDR;
        RegDst <= RD_RT;
        wait for T/2;
        RegWrite <= '1';
        wait for T/2;

        
    END PROCESS;
            
end architecture LW_Testbench_1;


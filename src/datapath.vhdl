---------------------------------------------------------------------------
-- Author(s)   : Jay Mundrawala <mundra@ir.iit.edu>
-- 
-- File          : datapath.vhdl
-- Creation Date : 06/11/2009
-- Description: 
--
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.mips_lib.all;

---------------------------------------------------------------------------
Entity datapath is 
---------------------------------------------------------------------------
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

    --Memory
            mem_data_out   : in  std_logic_vector((DATA_WIDTH-1) downto 0);
            mem_read       : out std_logic;
            addr_bus       : out std_logic_vector((DATA_WIDTH-1) downto 0);
            mem_write_data : out std_logic_vector((DATA_WIDTH-1) downto 0)
        );

end entity;



---------------------------------------------------------------------------
Architecture datapath_1 of datapath is
---------------------------------------------------------------------------
    component reg
        generic (
                    SIZE  : natural := 32;
                    DELAY : time := 0 ns
                );
        port (
                 en     : in std_logic;
                 data   : in std_logic_vector((SIZE-1) downto 0);
                 output : out std_logic_vector((SIZE-1) downto 0)
             );
    end component reg;

    component reg_file
        generic (
                    SIZE  : natural :=32;
                    DELAY : time := 0 ns
                );
        port (
                 clk        : in std_logic;
                 write_en   : in std_logic;
                 read_r1    : in std_logic_vector(4 downto 0);
                 read_r2    : in std_logic_vector(4 downto 0);
                 write_r    : in std_logic_vector(4 downto 0);
                 write_data : in std_logic_vector((SIZE-1) downto 0);
                 data_r1    : out std_logic_vector((SIZE-1) downto 0);
                 data_r2    : out std_logic_vector((SIZE-1) downto 0)
             );
    end component reg_file;

    component alu
        port(
                op_A     : in std_logic_vector(31 downto 0);
                op_B     : in std_logic_vector(31 downto 0);
                shamt    : in std_logic_vector(4 downto 0);
                alu_ctrl : in t_aluOp;
                f        : out std_logic_vector(31 downto 0);
                zero     : out std_logic
            );
    end component alu;

    signal PCDATA_int     : std_logic_vector((DATA_WIDTH - 1) downto 0);
    signal PCOUT_int      : std_logic_vector((DATA_WIDTH - 1) downto 0);
    signal instruction    : std_logic_vector((DATA_WIDTH - 1) downto 0);
    signal mdreg          : std_logic_vector((DATA_WIDTH - 1) downto 0);
    signal rf_write_data  : std_logic_vector((DATA_WIDTH - 1) downto 0);
    signal rf_write_reg   : std_logic_vector(4 downto 0);
    signal alu_a          : std_logic_vector((DATA_WIDTH - 1) downto 0);
    signal alu_b          : std_logic_vector((DATA_WIDTH - 1) downto 0);
    signal alu_reg_in     : std_logic_vector((DATA_WIDTH - 1) downto 0);
    signal alu_reg_out    : std_logic_vector((DATA_WIDTH - 1) downto 0);
    signal rega_in        : std_logic_vector((DATA_WIDTH - 1) downto 0);
    signal regb_in        : std_logic_vector((DATA_WIDTH - 1) downto 0);
    signal rega_out       : std_logic_vector((DATA_WIDTH - 1) downto 0);
    signal regb_out       : std_logic_vector((DATA_WIDTH - 1) downto 0);
    signal instr_sext     : std_logic_vector((DATA_WIDTH - 1) downto 0);
    signal instr_sexts    : std_logic_vector((DATA_WIDTH - 1) downto 0);
    signal zero           : std_logic;
    signal PCWrite_int    : std_logic;
begin
    RF: reg_file
    port map(
                clk => clk,
                write_en => RegWrite,
                read_r1 => instruction(25 downto 21),
                read_r2 => instruction(20 downto 16),
                write_r => rf_write_reg,
                write_data => rf_write_data,
                data_r1 => rega_in,
                data_r2 => regb_in
            );

    PC: reg
    port map(
                en     => PCWRITE_int,
                data   => PCDATA_int,
                output => PCOUT_int
            );

    IR: reg
    port map(
               en     => IRWrite,
               data   => mem_data_out,
               output => instruction
           );
    AOR: reg
    port map(
                en => clk,
                data => alu_reg_in,
                output => alu_reg_out
            );

    MDR: reg
    port map(
               en     => clk,
               data   => mem_data_out,
               output => mdreg
           );

    RRA: reg
    port map(
                en     => clk,
                data   => rega_in,
                output => rega_out
            );

    RRB: reg
    port map(
                en     => clk,
                data   => regb_in,
                output => regb_out
            );

    ALUU: alu
    port map(
                op_A     => alu_a,
                op_B     => alu_b,
                alu_ctrl => ALUOp,
                f        => alu_reg_in,
                zero     => zero,
                shamt    => instruction(10 downto 6)
            );

               
    mem_write_data <= regb_out;

    ---- PC Write/Branch MUX ----
    PCFinal : process(PCWriteCondEq, PCWriteCondNEq, PCWrite)
    begin
        if((PCWriteCondEq='1' and zero='1') or (PCWriteCondNEq='1' and zero='0') or PCWrite='1') then
            PCWRITE_int <= '1';
        else
            PCWRITE_int <= '0';
        end if;
    end process;

    -- PCSource Mux --
    PCSMux: process(PCSource, alu_reg_out, alu_reg_in)
    begin
        if(PCSource = PS_PCINC) then
            PCDATA_int <= alu_reg_in;
        elsif(PCSource = PS_ALUOUT) then
            PCDATA_int <= alu_reg_out;
        elsif(PCSource = PS_JMP) then
            PCDATA_int <= PCOUT_int(31 downto 28) & instruction(25 downto 0) & "00";
        end if;
    end process;

    -- IorD Mux
    IorDMux : process (PCOUT_int, alu_reg_out, IorD)
    begin
        if(IorD = IOD_PC) then
            addr_bus <= PCOUT_int;
        else
            addr_bus <= alu_reg_out;
        end if;
    end process;

    -- MemToReg Mux --
    MTRMux: process (MemToReg, mdreg, alu_reg_out)
    begin
        if(MemToReg = MTR_ALUOUT) then
            rf_write_data <= alu_reg_out;
        elsif(MemToReg = MTR_MDR) then
            rf_write_data <= mdreg;
        else
            rf_write_data <= PCOUT_int;
        end if;
    end process;

    -- RegDst Mux --
    RDMux : process (instruction, RegDst)
    begin
        if(RegDst = RD_RT) then
            rf_write_reg <= instruction(20 downto 16);
        elsif(RegDst = RD_RD) then
            rf_write_reg <= instruction(15 downto 11);
        else
            rf_write_reg <= "11111";
        end if;
    end process;

    -- ALUSrcA Mux --
    ALUSA: process (ALUSrcA, PCOUT_int, rega_out)
    begin
        if(ALUSrcA = ASA_PC) then
            alu_a <= PCOUT_int;
        else
            alu_a <= rega_out;
        end if;
    end process;

    -- ALUSrcB Mux --
    ALUSB: process (ALUSrcB, regb_out, instr_sext, instr_sexts)
    begin
        if(ALUSrcB = ASB_REGB) then
            alu_b <= regb_out;
        elsif(ALUSrcB = ASB_FOUR) then
            alu_b <= "00000000000000000000000000000100";
        elsif(ALUSrcB = ASB_SEXT) then
            alu_b <= instr_sext;
        else
            alu_b <= instr_sexts;
        end if;
    end process;

    -- Sign Extend and Shift --
    SEXTS: process(instruction)
    begin
        instr_sext <= (31 downto 16 => instruction(15)) & instruction(15 downto 0);
        instr_sexts <= (31 downto 18 => instruction(15)) & instruction(15 downto 0) & "00";
    end process;

end architecture datapath_1;


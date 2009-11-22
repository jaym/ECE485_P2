---------------------------------------------------------------------------
-- Author(s)   : Jay Mundrawala <mundra@ir.iit.edu>
-- 
-- File          : alu.vhdl
-- Creation Date : 21/11/2009
-- Description: 
--
---------------------------------------------------------------------------

library IEEE; 
use work.mips_lib.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
---------------------------------------------------------------------------
Entity alu is 
---------------------------------------------------------------------------
port 
(
    op_A     : in std_logic_vector(31 downto 0);
    op_B     : in std_logic_vector(31 downto 0);
    shamt    : in std_logic_vector(4 downto 0);
    alu_ctrl : in t_aluOp;
    f        : out std_logic_vector(31 downto 0);
    zero     : out std_logic
);
end entity;



---------------------------------------------------------------------------
Architecture alu_1 of alu is
---------------------------------------------------------------------------
-- from http://www.csee.umbc.edu/~squire/download/bshift.vhdl
  function to_integer(sig : std_logic_vector) return integer is
    variable num : integer := 0;  -- descending sig as integer
  begin
    for i in sig'range loop
      if sig(i)='1' then
        num := num*2+1;
      else
        num := num*2;
      end if;
    end loop;  -- i
    return num;
  end function to_integer;
    CONSTANT DELAY : time := 0 ns;
    signal value   : std_logic_vector(31 downto 0);
begin
    process(alu_ctrl, op_A, op_B)
    begin
        case alu_ctrl is
            when AOP_AND =>
                value <= op_A and op_B after DELAY;
            when AOP_OR =>
                value <= op_A or op_B after DELAY;
            when AOP_ADD =>
                value <= std_logic_vector(signed(op_A) + signed(op_B)) after DELAY;
            when AOP_SUB =>
                value <= std_logic_vector(signed(op_A) - signed(op_B)) after DELAY;
            when AOP_SLT =>
                if(signed(op_A) < signed(op_B)) then
                    value <= (others => '0');
                    value(0) <=  '1';
                else
                    value <= (others => '0');
                end if;
            when AOP_NOR =>
                value <= NOT (op_A or op_B) after DELAY;
            when AOP_SLL =>
                value <= to_stdlogicvector(to_bitvector(op_B) sll to_integer(shamt));
            when others =>
                value <= (others => '1');
        end case;
       end process;
       f <= value;
       zero <= '1' when value = x"00000000" else
               '0';
end architecture alu_1;


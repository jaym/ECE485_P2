---------------------------------------------------------------------------
-- Author(s)   : Jay Mundrawala <mundra@ir.iit.edu>
-- 
-- File          : reg_file.vhdl
-- Creation Date : 06/11/2009
-- Description: 
--
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
---------------------------------------------------------------------------
Entity reg_file is 
---------------------------------------------------------------------------
generic
(
    SIZE : natural :=32;
    DELAY : time := 0 ns
);
port 
(
    clk        : in std_logic;
    write_en   : in std_logic;
    read_r1    : in std_logic_vector(4 downto 0);
    read_r2    : in std_logic_vector(4 downto 0);
    write_r    : in std_logic_vector(4 downto 0);
    write_data : in std_logic_vector((SIZE-1) downto 0);
    data_r1    : out std_logic_vector((SIZE-1) downto 0);
    data_r2    : out std_logic_vector((SIZE-1) downto 0)
);
end entity;


---------------------------------------------------------------------------
Architecture reg_file_1 of reg_file is
---------------------------------------------------------------------------
    type t_reg is array (0 to 31) of std_logic_vector(31 downto 0); 
    signal reg : t_reg := ((others => (others=>'0'))); 

begin
    process(clk)
    begin
        if(clk'event and clk='0') then
            data_r1 <= reg(CONV_INTEGER(read_r1)) after DELAY/2;
            data_r2 <= reg(CONV_INTEGER(read_r2)) after DELAY/2;
        elsif(clk'event and clk='1') then
            if(write_en ='1') then
                reg(CONV_INTEGER(write_r)) <= write_data after DELAY;
            end if;
        end if;
        reg(0) <= (others => '0');
    end process;
end architecture reg_file_1;


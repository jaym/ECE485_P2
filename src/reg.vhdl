---------------------------------------------------------------------------
-- Author(s)   : Jay Mundrawala <mundra@ir.iit.edu>
-- 
-- File          : reg.vhdl
-- Creation Date : 06/11/2009
-- Description: 
--
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

---------------------------------------------------------------------------
Entity reg is 
---------------------------------------------------------------------------
generic
(
    SIZE  : natural := 32;
    DELAY : time := 0 ns
);


port 
(
    en     : in std_logic;
    data   : in std_logic_vector((SIZE-1) downto 0);
    output : out std_logic_vector((SIZE-1) downto 0)
);
end entity;


---------------------------------------------------------------------------
Architecture reg_1 of reg is
---------------------------------------------------------------------------
    signal tmp : std_logic_vector((SIZE-1) downto 0) := (others => '0');
begin
    process(en)
    begin
        if(en='1') then
            tmp <= data;
        end if;
    end process;
    output <= tmp;
end architecture reg_1;


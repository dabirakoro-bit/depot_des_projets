library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DataMemory is
    Port ( 
        clk      : in  STD_LOGIC;
        tick     : in STD_LOGIC;
        we       : in  STD_LOGIC;                      -- write enable
        addr     : in  STD_LOGIC_VECTOR (5 downto 0);   -- 64 cases
        data_in  : in  STD_LOGIC_VECTOR (7 downto 0);   -- donnée à écrire (STORE)
        data_out : out STD_LOGIC_VECTOR (7 downto 0)    -- donnée lue (LOAD)
    );
end DataMemory;

architecture Behavioral of DataMemory is

    type mem_array is array (0 to 63) of STD_LOGIC_VECTOR(7 downto 0);
    signal data_mem : mem_array := (others => (others => '0'));

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' and tick = '1'then
                data_mem(to_integer(unsigned(addr))) <= data_in;
            end if;
        end if;
    end process;

    data_out <= data_mem(to_integer(unsigned(addr)));

end Behavioral;
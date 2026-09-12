library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterFile is
    Port (
        clk    : in  STD_LOGIC;
        tick   : in  STD_LOGIC;
        we     : in  STD_LOGIC;
        data_w : in  STD_LOGIC_VECTOR (7 downto 0);
        addr_a : in  STD_LOGIC_VECTOR (1 downto 0);
        addr_b : in  STD_LOGIC_VECTOR (1 downto 0);
        addr_w : in  STD_LOGIC_VECTOR (1 downto 0);

        data_a : out STD_LOGIC_VECTOR (7 downto 0);
        data_b : out STD_LOGIC_VECTOR (7 downto 0)
    );
end RegisterFile;

architecture Behavioral of RegisterFile is

    type reg_array is array (0 to 3) of STD_LOGIC_VECTOR(7 downto 0);
    signal regs : reg_array := (others => (others => '0'));

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' and tick = '1' then
                regs(to_integer(unsigned(addr_w))) <= data_w;
            end if;
        end if;
    end process;

    data_a <= regs(to_integer(unsigned(addr_a)));
    data_b <= regs(to_integer(unsigned(addr_b)));

end Behavioral;
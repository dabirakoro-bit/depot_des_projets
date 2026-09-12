library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ClockDivider is
    Port ( 
        clk  : in  STD_LOGIC;
        tick : out STD_LOGIC -- impulsion d'un cycle, une fois par seconde
    );
end ClockDivider;

architecture Behavioral of ClockDivider is
    constant MAX_COUNT : unsigned(26 downto 0) := to_unsigned(99_999_999, 27); -- 100 MHz - 1
    signal counter : unsigned(26 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if counter = MAX_COUNT then
                counter <= (others => '0');
                tick    <= '1';
            else
                counter <= counter + 1;
                tick    <= '0';
            end if;
        end if;
    end process;
end Behavioral;
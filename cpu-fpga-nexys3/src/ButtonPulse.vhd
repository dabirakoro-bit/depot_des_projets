library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ButtonPulse is
    Port ( 
        clk    : in  STD_LOGIC;
        btn_in : in  STD_LOGIC;
        pulse  : out STD_LOGIC
    );
end ButtonPulse;

architecture Behavioral of ButtonPulse is
    signal sync1, sync2, prev : STD_LOGIC := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            sync1 <= btn_in;  -- synchronise le signal externe avec l'horloge
            sync2 <= sync1;   -- filtre les métastabilités
            prev  <= sync2;   -- garde la valeur du cycle précédent
        end if;
    end process;

    pulse <= sync2 and not prev; -- '1' pendant exactement 1 cycle, au moment où btn_in passe de 0 à 1
end Behavioral;
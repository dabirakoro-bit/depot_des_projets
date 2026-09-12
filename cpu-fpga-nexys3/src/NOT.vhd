library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Not8 is
    Port ( 
        a : in  STD_LOGIC_VECTOR (7 downto 0); -- Entrée 8 bits
        y : out STD_LOGIC_VECTOR (7 downto 0)  -- Sortie 8 bits (Inverse bit à bit)
    );
end Not8;

architecture Behavioral of Not8 is
begin

    -- Inversion logique bit à bit de chaque signal
    y <= not a;

end Behavioral;
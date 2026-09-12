library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TwosComplement8 is
    Port (
        a : in  STD_LOGIC_VECTOR(7 downto 0); -- Entrée 8 bits
        y : out STD_LOGIC_VECTOR(7 downto 0)  -- Sortie (-A en complément à 2)
    );
end TwosComplement8;

architecture Behavioral of TwosComplement8 is

    signal not_a      : STD_LOGIC_VECTOR(7 downto 0);
    signal dummy_cout : STD_LOGIC;

begin

    -- 1. Étape 1 : Inversion bit à bit (NOT A) avec ton composant Not8
    U_NOT : entity work.Not8
        port map (
            a => a,
            y => not_a
        );

    -- 2. Étape 2 : Addition de 1 (NOT A + 0 + 1) avec ton composant Adder8
    U_ADD : entity work.Adder8
        port map (
            a    => not_a,
            b    => "00000000",
            cin  => '1',         -- On ajoute +1 via la retenue d'entrée
            s    => y,
            cout => dummy_cout
        );

end Behavioral;
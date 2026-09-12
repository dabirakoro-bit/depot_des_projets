library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Adder8 is
    Port ( 
        a    : in  STD_LOGIC_VECTOR (7 downto 0);
        b    : in  STD_LOGIC_VECTOR (7 downto 0);
        cin  : in  STD_LOGIC;
        s    : out STD_LOGIC_VECTOR (7 downto 0);
        cout : out STD_LOGIC
    );
end Adder8;

architecture Behavioral of Adder8 is
    signal temp_sum : unsigned(8 downto 0);
begin

    -- Calcul de la somme sur 9 bits pour extraire la retenue
    temp_sum <= resize(unsigned(a), 9) + resize(unsigned(b), 9) + ("00000000" & cin);

    -- Sorties de l'additionneur
    s    <= std_logic_vector(temp_sum(7 downto 0));
    cout <= temp_sum(8);

end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LogicUnit8 is
    Port ( 
        a        : in  STD_LOGIC_VECTOR (7 downto 0);
        b        : in  STD_LOGIC_VECTOR (7 downto 0);
        op       : in  STD_LOGIC_VECTOR (1 downto 0); -- Sélection de l'opération logique
        y        : out STD_LOGIC_VECTOR (7 downto 0);
        flag_z   : out STD_LOGIC;                      -- Drapeau Zero
        flag_n   : out STD_LOGIC                       -- Drapeau Négatif
    );
end LogicUnit8;

architecture Behavioral of LogicUnit8 is

    signal res_int : STD_LOGIC_VECTOR(7 downto 0);

begin

    -- Calcul combinatoire selon l'opération
    process(a, b, op)
    begin
        case op is
            when "00" => res_int <= a and b;  -- AND
            when "01" => res_int <= a or b;   -- OR
            when "10" => res_int <= a xor b;  -- XOR
            when "11" => res_int <= not a;    -- NOT
            when others => res_int <= (others => '0');
        end case;
    end process;

    -- Sortie du résultat
    y <= res_int;

    -- Drapeau Zero : '1' si le résultat vaut "00000000"
    flag_z <= '1' when res_int = "00000000" else '0';

    -- Drapeau Négatif : Égal au bit de poids fort (MSB)
    flag_n <= res_int(7);

end Behavioral;
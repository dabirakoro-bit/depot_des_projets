library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Subtractor8 is
    Port ( 
        a        : in  STD_LOGIC_VECTOR (7 downto 0);
        b        : in  STD_LOGIC_VECTOR (7 downto 0);
        bin      : in  STD_LOGIC; -- Emprunt d'entrée (Borrow In) pour SBB
        diff     : out STD_LOGIC_VECTOR (7 downto 0);
        
        -- Flags de condition
        flag_z   : out STD_LOGIC; -- Zero
        flag_n   : out STD_LOGIC; -- Négatif
        flag_v   : out STD_LOGIC; -- Overflow
        flag_c   : out STD_LOGIC  -- Borrow Out (Emprunt de sortie)
    );
end Subtractor8;

architecture Behavioral of Subtractor8 is

    signal not_b     : STD_LOGIC_VECTOR(7 downto 0);
    signal res_int   : STD_LOGIC_VECTOR(7 downto 0);
    signal cout_int  : STD_LOGIC;
    signal cin_add   : STD_LOGIC;

begin

    -- 1. Inversion de B
    U_NOT : entity work.Not8
        port map (
            a => b,
            y => not_b
        );

    -- 2. Calcul du CIN effectif pour l'additionneur :
    -- Si bin = '0' => cin_add = '1' (Calcul : A + NOT(B) + 1 = A - B)
    -- Si bin = '1' => cin_add = '0' (Calcul : A + NOT(B) + 0 = A - B - 1)
    cin_add <= not bin;

    -- 3. Additionneur
    U_ADD : entity work.Adder8
        port map (
            a    => a,
            b    => not_b,
            cin  => cin_add,
            s    => res_int,
            cout => cout_int
        );

    -- 4. Affectation du résultat
    diff <= res_int;

    -- 5. Generation des Flags
    flag_z <= '1' when res_int = "00000000" else '0';
    flag_n <= res_int(7);
    
    -- Borrow Out : Si cout_int = '0', un emprunt s'est produit
    flag_c <= not cout_int;

    -- Overflow (V) pour la soustraction
    flag_v <= (a(7) and not b(7) and not res_int(7)) or (not a(7) and b(7) and res_int(7));

end Behavioral;
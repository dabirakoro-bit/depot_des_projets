library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ShiftRotate8 is
    Port ( 
        a        : in  STD_LOGIC_VECTOR (7 downto 0);
        cin      : in  STD_LOGIC;                      -- Retenue d'entrée (Carry In) pour ROL / ROR
        op       : in  STD_LOGIC_VECTOR (1 downto 0); -- "00": SHL, "01": SHR, "10": ROL, "11": ROR
        y        : out STD_LOGIC_VECTOR (7 downto 0);
        flag_z   : out STD_LOGIC;                      -- Drapeau Zero
        flag_n   : out STD_LOGIC;                      -- Drapeau Négatif
        flag_c   : out STD_LOGIC                       -- Drapeau Carry (bit éjecté)
    );
end ShiftRotate8;

architecture Behavioral of ShiftRotate8 is

    signal res_int  : STD_LOGIC_VECTOR(7 downto 0);
    signal cout_int : STD_LOGIC;

begin

    process(a, cin, op)
    begin
        case op is
            when "00" => -- SHL : Décalage gauche (A(6..0) & '0'), le bit A(7) va dans Carry
                res_int  <= a(6 downto 0) & '0';
                cout_int <= a(7);

            when "01" => -- SHR : Décalage droit ('0' & A(7..1)), le bit A(0) va dans Carry
                res_int  <= '0' & a(7 downto 1);
                cout_int <= a(0);

            when "10" => -- ROL : Rotation gauche via Carry (A(6..0) & cin), A(7) va dans Carry
                res_int  <= a(6 downto 0) & cin;
                cout_int <= a(7);

            when "11" => -- ROR : Rotation droite via Carry (cin & A(7..1)), A(0) va dans Carry
                res_int  <= cin & a(7 downto 1);
                cout_int <= a(0);

            when others =>
                res_int  <= a;
                cout_int <= '0';
        end case;
    end process;

    -- Affectation des sorties
    y      <= res_int;
    flag_c <= cout_int;
    flag_z <= '1' when res_int = "00000000" else '0';
    flag_n <= res_int(7);

end Behavioral;
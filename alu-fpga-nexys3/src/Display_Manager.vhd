library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Display_Manager is
    Port ( 
        clk        : in  STD_LOGIC;                    -- Horloge 100 MHz
        alu_op     : in  STD_LOGIC_VECTOR (3 downto 0); -- Opération ALU
        btnL       : in  STD_LOGIC;                    -- Appui = RegB
        btnR       : in  STD_LOGIC;                    -- Appui = Résultat ALU
        regA       : in  STD_LOGIC_VECTOR (7 downto 0);
        regB       : in  STD_LOGIC_VECTOR (7 downto 0);
        alu_res    : in  STD_LOGIC_VECTOR (7 downto 0);
        flags      : in  STD_LOGIC_VECTOR (3 downto 0); -- [V, C, N, Z]
        
        -- Sorties physiques
        seg        : out STD_LOGIC_VECTOR (6 downto 0);
        dp         : out STD_LOGIC;
        an         : out STD_LOGIC_VECTOR (3 downto 0);
        led        : out STD_LOGIC_VECTOR (7 downto 0)
    );
end Display_Manager;

architecture Behavioral of Display_Manager is

    signal raw_data     : STD_LOGIC_VECTOR(7 downto 0);
    signal is_signed    : boolean := false;
    signal is_negative  : boolean := false;
    signal val_abs      : integer range 0 to 255;
    
    -- Chiffres BCD
    signal d0, d1, d2   : STD_LOGIC_VECTOR(3 downto 0);
    signal refresh_cnt  : unsigned(16 downto 0) := (others => '0');
    signal active_digit : STD_LOGIC_VECTOR(1 downto 0);
    signal current_digit: STD_LOGIC_VECTOR(3 downto 0);

begin

    ------------------------------------------------------------------
    -- 1. SÉLECTION DONNÉE ET AFFICHAGE DIRECT SUR LES LEDS (8 BITS)
    ------------------------------------------------------------------
    process(btnL, btnR, regA, regB, alu_res)
    begin
        if btnR = '1' then
            raw_data <= alu_res;  -- BTNR -> Résultat
        elsif btnL = '1' then
            raw_data <= regB;     -- BTNL -> RegB
        else
            raw_data <= regA;     -- Défaut -> RegA
        end if;
    end process;

    -- Les 8 LEDs affichent directement l'intégralité du registre/résultat sélectionné
    led <= raw_data;

    ------------------------------------------------------------------
    -- 2. DÉCODAGE SIGNÉ ET CALCUL BCD
    ------------------------------------------------------------------
    process(alu_op)
    begin
        case alu_op is
            when "0001" | "0011" | "0100" | "0110" | "0111" => -- ADDS, INC, SUB, DEC, NEG
                is_signed <= true;
            when others =>
                is_signed <= false;
        end case;
    end process;

    process(raw_data, is_signed)
    begin
        if is_signed and (raw_data(7) = '1') then
            is_negative <= true;
            val_abs     <= to_integer(unsigned(not(raw_data))) + 1;
        else
            is_negative <= false;
            val_abs     <= to_integer(unsigned(raw_data));
        end if;
    end process;

    d0 <= std_logic_vector(to_unsigned(val_abs mod 10, 4));
    d1 <= std_logic_vector(to_unsigned((val_abs / 10) mod 10, 4));
    d2 <= std_logic_vector(to_unsigned(val_abs / 100, 4));

    ------------------------------------------------------------------
    -- 3. MULTIPLEXAGE DES ANODES (7-SEGMENTS)
    ------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            refresh_cnt <= refresh_cnt + 1;
        end if;
    end process;

    active_digit <= std_logic_vector(refresh_cnt(16 downto 15));
    
    -- Le point décimal s'allume si le flag Carry (C) est actif
    dp <= not flags(2); 

    process(active_digit, d0, d1, d2, is_negative, val_abs)
    begin
        case active_digit is
            when "00" => 
                an <= "1110";          -- AN0 (Droite) : Unités
                current_digit <= d0;
                
            when "01" => 
                an <= "1101";          -- AN1 : Dizaines
                if (val_abs < 10) and not is_negative then
                    current_digit <= "1111"; -- Éteint si < 10
                else
                    current_digit <= d1;
                end if;
                
            when "10" => 
                an <= "1011";          -- AN2 : Centaines
                if (val_abs >= 100) then
                    current_digit <= d2;
                else
                    current_digit <= "1111"; -- Éteint si < 100
                end if;
                
            when "11" => 
                an <= "0111";          -- AN3 (Gauche) : Signe Moins '-'
                if is_negative then
                    current_digit <= "1110"; -- Tiret '-'
                else
                    current_digit <= "1111"; -- Éteint
                end if;
                
            when others => 
                an <= "1111";
                current_digit <= "1111";
        end case;
    end process;

    ------------------------------------------------------------------
    -- 4. DÉCODEUR 7 SEGMENTS
    ------------------------------------------------------------------
    process(current_digit)
    begin
        case current_digit is
            when "0000" => seg <= "1000000"; -- 0
            when "0001" => seg <= "1111001"; -- 1
            when "0010" => seg <= "0100100"; -- 2
            when "0011" => seg <= "0110000"; -- 3
            when "0100" => seg <= "0011001"; -- 4
            when "0101" => seg <= "0010010"; -- 5
            when "0110" => seg <= "0000010"; -- 6
            when "0111" => seg <= "1111000"; -- 7
            when "1000" => seg <= "0000000"; -- 8
            when "1001" => seg <= "0010000"; -- 9
            when "1110" => seg <= "0111111"; -- Tiret '-'
            when others => seg <= "1111111"; -- Éteint
        end case;
    end process;

end Behavioral;
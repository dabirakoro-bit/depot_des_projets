library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Display_Manager is
    Port ( 
        clk        : in  STD_LOGIC;
        sel        : in  STD_LOGIC_VECTOR (2 downto 0); -- sw(7:5)
        class_bit  : in  STD_LOGIC;
        alu_op     : in  STD_LOGIC_VECTOR (3 downto 0);
        alu_res    : in  STD_LOGIC_VECTOR (7 downto 0);
        pc_out     : in  STD_LOGIC_VECTOR (5 downto 0);
        instr_out  : in  STD_LOGIC_VECTOR (15 downto 0);
        flags_reg  : in  STD_LOGIC_VECTOR (3 downto 0);
        data_a     : in  STD_LOGIC_VECTOR (7 downto 0);
        data_b     : in  STD_LOGIC_VECTOR (7 downto 0);

        seg        : out STD_LOGIC_VECTOR (6 downto 0);
        dp         : out STD_LOGIC;
        an         : out STD_LOGIC_VECTOR (3 downto 0);
        led        : out STD_LOGIC_VECTOR (7 downto 0)
    );
end Display_Manager;

architecture Behavioral of Display_Manager is

    signal raw_data     : STD_LOGIC_VECTOR(7 downto 0);
    signal is_signed    : boolean := false;
    signal is_hex_mode  : boolean := false;
    signal is_negative  : boolean := false;
    signal val_abs      : integer range 0 to 255;
    
    signal d0, d1, d2   : STD_LOGIC_VECTOR(3 downto 0);
    signal hex0, hex1, hex2, hex3 : STD_LOGIC_VECTOR(3 downto 0);
    signal refresh_cnt  : unsigned(16 downto 0) := (others => '0');
    signal active_digit : STD_LOGIC_VECTOR(1 downto 0);
    signal current_digit: STD_LOGIC_VECTOR(3 downto 0);

begin

    is_hex_mode <= (sel = "110");

    -- Sélection de la donnée à afficher (mode décimal/LEDs), selon sw(7:5)
    process(sel, alu_res, pc_out, instr_out, flags_reg, data_a, data_b)
    begin
        case sel is
            when "000"  => raw_data <= alu_res;
            when "001"  => raw_data <= "00" & pc_out;
            when "010"  => raw_data <= instr_out(7 downto 0);
            when "011"  => raw_data <= "0000" & flags_reg;
            when "100"  => raw_data <= data_a;
            when "101"  => raw_data <= data_b;
            when others => raw_data <= (others => '0');
        end case;
    end process;

    led <= raw_data;

    -- Découpage en hexadécimal 16 bits : data_a = poids fort, data_b = poids faible
    hex0 <= data_b(3 downto 0);
    hex1 <= data_b(7 downto 4);
    hex2 <= data_a(3 downto 0);
    hex3 <= data_a(7 downto 4);

    -- Signé uniquement pour la vue alu_res, et seulement si l'instruction est bien de type ALU
    process(sel, class_bit, alu_op)
    begin
        if sel = "000" and class_bit = '0' then
            case alu_op is
                when "0001" | "0011" | "0100" | "0101" | "0110" | "0111" =>
                    is_signed <= true;
                when others =>
                    is_signed <= false;
            end case;
        else
            is_signed <= false;
        end if;
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

    process(clk)
    begin
        if rising_edge(clk) then
            refresh_cnt <= refresh_cnt + 1;
        end if;
    end process;

    active_digit <= std_logic_vector(refresh_cnt(16 downto 15));
    dp <= not flags_reg(2);

    -- Choix du chiffre courant : mode hexa (4 chiffres pleins) ou mode décimal (avec signe)
    process(active_digit, d0, d1, d2, is_negative, val_abs, is_hex_mode, hex0, hex1, hex2, hex3)
    begin
        if is_hex_mode then
            case active_digit is
                when "00"   => an <= "1110"; current_digit <= hex0;
                when "01"   => an <= "1101"; current_digit <= hex1;
                when "10"   => an <= "1011"; current_digit <= hex2;
                when "11"   => an <= "0111"; current_digit <= hex3;
                when others => an <= "1111"; current_digit <= "1111";
            end case;
        else
            case active_digit is
                when "00" => 
                    an <= "1110";
                    current_digit <= d0;
                when "01" => 
                    an <= "1101";
                    if (val_abs < 10) and not is_negative then
                        current_digit <= "1111";
                    else
                        current_digit <= d1;
                    end if;
                when "10" => 
                    an <= "1011";
                    if (val_abs >= 100) then
                        current_digit <= d2;
                    else
                        current_digit <= "1111";
                    end if;
                when "11" => 
                    an <= "0111";
                    if is_negative then
                        current_digit <= "1110";
                    else
                        current_digit <= "1111";
                    end if;
                when others => 
                    an <= "1111";
                    current_digit <= "1111";
            end case;
        end if;
    end process;

    -- Table 7-segments : décimal 0-9 (existant) + hexadécimal A-F (ajouté)
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
            when "1010" => seg <= "0001000"; -- A
            when "1011" => seg <= "0000011"; -- b
            when "1100" => seg <= "1000110"; -- C
            when "1101" => seg <= "0100001"; -- d
            when "1110" => seg <= "0111111"; -- - (signe négatif, réutilisé)
            when others => seg <= "1111111"; -- éteint
        end case;
    end process;

end Behavioral;
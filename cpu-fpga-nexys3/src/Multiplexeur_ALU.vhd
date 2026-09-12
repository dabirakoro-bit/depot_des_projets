library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU_Mux is
    Port ( 
        alu_op      : in  STD_LOGIC_VECTOR (3 downto 0);
        
        -- Entrées de résultats des sous-modules
        res_add     : in  STD_LOGIC_VECTOR (7 downto 0);
        res_sub     : in  STD_LOGIC_VECTOR (7 downto 0);
        res_comp2   : in  STD_LOGIC_VECTOR (7 downto 0);
        res_logic   : in  STD_LOGIC_VECTOR (7 downto 0);
        res_shift   : in  STD_LOGIC_VECTOR (7 downto 0);
        regA_in     : in  STD_LOGIC_VECTOR (7 downto 0);
        
        -- Entrées de drapeaux [V, C, N, Z]
        flags_add   : in  STD_LOGIC_VECTOR (3 downto 0);
        flags_sub   : in  STD_LOGIC_VECTOR (3 downto 0);
        flags_comp2 : in  STD_LOGIC_VECTOR (3 downto 0);
        flags_log   : in  STD_LOGIC_VECTOR (3 downto 0);
        flags_sh    : in  STD_LOGIC_VECTOR (3 downto 0);
        
        -- Sorties
        alu_res     : out STD_LOGIC_VECTOR (7 downto 0);
        alu_flags   : out STD_LOGIC_VECTOR (3 downto 0)
    );
end ALU_Mux;

architecture Behavioral of ALU_Mux is
    signal flags_pass_a : STD_LOGIC_VECTOR (3 downto 0);
begin

    -- Flags pour PASS_A : [V=0, C=0, N=MSB, Z]
    flags_pass_a(3) <= '0';
    flags_pass_a(2) <= '0';
    flags_pass_a(1) <= regA_in(7);
    flags_pass_a(0) <= '1' when regA_in = "00000000" else '0';

    process(alu_op, res_add, res_sub, res_comp2, res_logic, res_shift, regA_in,
            flags_add, flags_sub, flags_comp2, flags_log, flags_sh, flags_pass_a)
    begin
        case alu_op is
            -- Addition : ADD, ADDS, ADC, INC (0000 à 0011)
            when "0000" | "0001" | "0010" | "0011" =>
                alu_res   <= res_add;
                alu_flags <= flags_add;

            -- Soustraction : SUB, SBB, DEC (0100, 0101, 0110)
            when "0100" | "0101" | "0110" => -- Correction de "0105" en "0101"
                alu_res   <= res_sub;
                alu_flags <= flags_sub;

            -- Complément à 2 : NEG (0111)
            when "0111" =>
                alu_res   <= res_comp2;
                alu_flags <= flags_comp2;

            -- Logique : AND, OR, XOR, NOT (1000 à 1011)
            when "1000" | "1001" | "1010" | "1011" =>
                alu_res   <= res_logic;
                alu_flags <= flags_log;

            -- Décalages / Rotations (1100 à 1110)
            when "1100" | "1101" | "1110" =>
                alu_res   <= res_shift;
                alu_flags <= flags_sh;

            -- Transfert PASS_A (1111)
            when "1111" =>
                alu_res   <= regA_in;
                alu_flags <= flags_pass_a;

            when others =>
                alu_res   <= (others => '0');
                alu_flags <= (others => '0');
        end case;
    end process;

end Behavioral;
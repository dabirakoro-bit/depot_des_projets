library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_Unit is
    Port ( 
        clk           : in  STD_LOGIC;
        tick          : in  STD_LOGIC;
        regA_in       : in  STD_LOGIC_VECTOR (7 downto 0);
        regB_in       : in  STD_LOGIC_VECTOR (7 downto 0);
        alu_op        : in  STD_LOGIC_VECTOR (3 downto 0);
        flags_update  : in  STD_LOGIC; -- '1' si l'instruction courante doit mettre à jour les flags

        alu_res       : out STD_LOGIC_VECTOR (7 downto 0);
        flags         : out STD_LOGIC_VECTOR (3 downto 0);
        flags_reg_out : out STD_LOGIC_VECTOR (3 downto 0)
    );
end ALU_Unit;

architecture Behavioral of ALU_Unit is

    signal internal_flags : STD_LOGIC_VECTOR(3 downto 0);
    signal flags_reg      : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal cin             : STD_LOGIC;

    signal add_b, sub_b     : STD_LOGIC_VECTOR(7 downto 0);
    signal real_b           : STD_LOGIC_VECTOR(7 downto 0);
    signal add_cin, sub_bin : STD_LOGIC;

    signal out_add, out_sub, out_comp2, out_logic, out_shift : STD_LOGIC_VECTOR(7 downto 0);
    signal cout_add, cout_comp2 : STD_LOGIC;
    signal not_regA : STD_LOGIC_VECTOR(7 downto 0);

    signal flags_add, flags_sub, flags_comp2, flags_log, flags_sh : STD_LOGIC_VECTOR(3 downto 0);
    signal f_sub_z, f_sub_n, f_sub_v, f_sub_c                      : STD_LOGIC;
    signal f_log_z, f_log_n                                        : STD_LOGIC;
    signal f_sh_z, f_sh_n, f_sh_c                                  : STD_LOGIC;

begin

    cin <= flags_reg(2);

    process(clk)
    begin
        if rising_edge(clk) then
            if flags_update = '1' and tick ='1' then
                flags_reg <= internal_flags;
            end if;
        end if;
    end process;

    process(alu_op, regB_in, cin)
    begin
        if alu_op = "0010" then            -- ADC
            add_b   <= regB_in; 
            add_cin <= cin;
            real_b  <= regB_in;
        elsif alu_op = "0011" then         -- INC
            add_b   <= "00000000";   
            add_cin <= '1';
            real_b  <= "00000001";
        else                               -- ADD / ADDS
            add_b   <= regB_in; 
            add_cin <= '0';
            real_b  <= regB_in;
        end if;
    end process;

    U_ADD : entity work.Adder8
        port map (a => regA_in, b => add_b, cin => add_cin, s => out_add, cout => cout_add);

    flags_add(3) <= (regA_in(7) and real_b(7) and not out_add(7)) or (not regA_in(7) and not real_b(7) and out_add(7));
    flags_add(2) <= cout_add;
    flags_add(1) <= out_add(7);
    flags_add(0) <= '1' when out_add = "00000000" else '0';

    not_regA <= not regA_in;

    U_COMP2 : entity work.Adder8
        port map (a => not_regA, b => "00000000", cin => '1', s => out_comp2, cout => cout_comp2);

    flags_comp2(3) <= '1' when regA_in = "10000000" else '0';
    flags_comp2(2) <= cout_comp2;
    flags_comp2(1) <= out_comp2(7);
    flags_comp2(0) <= '1' when out_comp2 = "00000000" else '0';

    process(alu_op, regB_in, cin)
    begin
        if alu_op = "0101" then            -- SBB
            sub_b   <= regB_in; 
            sub_bin <= cin;
        elsif alu_op = "0110" then         -- DEC
            sub_b   <= "00000001";   
            sub_bin <= '0';
        else                               -- SUB
            sub_b   <= regB_in; 
            sub_bin <= '0';
        end if;
    end process;

    U_SUB : entity work.Subtractor8
        port map (
            a      => regA_in, 
            b      => sub_b, 
            bin    => sub_bin, 
            diff   => out_sub, 
            flag_z => f_sub_z, 
            flag_n => f_sub_n, 
            flag_v => f_sub_v, 
            flag_c => f_sub_c
        );
    
    flags_sub <= f_sub_v & f_sub_c & f_sub_n & f_sub_z;

    U_LOGIC : entity work.LogicUnit8
        port map (
            a      => regA_in, 
            b      => regB_in, 
            op     => alu_op(1 downto 0), 
            y      => out_logic, 
            flag_z => f_log_z, 
            flag_n => f_log_n
        );
    
    flags_log <= '0' & '0' & f_log_n & f_log_z;

    U_SHIFT : entity work.ShiftRotate8
        port map (
            a      => regA_in, 
            cin    => cin, 
            op     => alu_op(1 downto 0), 
            y      => out_shift, 
            flag_z => f_sh_z, 
            flag_n => f_sh_n, 
            flag_c => f_sh_c
        );
    
    flags_sh <= '0' & f_sh_c & f_sh_n & f_sh_z;

    U_MUX : entity work.ALU_Mux
        port map (
            alu_op      => alu_op,
            res_add     => out_add,
            res_sub     => out_sub,
            res_comp2   => out_comp2,
            res_logic   => out_logic,
            res_shift   => out_shift,
            regA_in     => regA_in,
            flags_add   => flags_add,
            flags_sub   => flags_sub,
            flags_comp2 => flags_comp2,
            flags_log   => flags_log,
            flags_sh    => flags_sh,
            alu_res     => alu_res,
            alu_flags   => internal_flags
        );

    flags         <= internal_flags;
    flags_reg_out <= flags_reg;

end Behavioral;
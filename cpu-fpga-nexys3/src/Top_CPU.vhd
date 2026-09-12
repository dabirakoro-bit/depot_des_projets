library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Top_CPU is
    Port ( 
        clk  : in  STD_LOGIC;
        sw   : in  STD_LOGIC_VECTOR (7 downto 0);
        btnL : in  STD_LOGIC; -- charge adresse mémoire programme
        btnC : in  STD_LOGIC; -- charge poids fort instruction
        btnR : in  STD_LOGIC; -- charge poids faible instruction (+auto-incrément)
        btnU : in  STD_LOGIC; -- run/pause
        btnD : in  STD_LOGIC; -- reset PC

        led  : out STD_LOGIC_VECTOR (7 downto 0);
        seg  : out STD_LOGIC_VECTOR (6 downto 0);
        dp   : out STD_LOGIC;
        an   : out STD_LOGIC_VECTOR (3 downto 0)
    );
end Top_CPU;

architecture Behavioral of Top_CPU is

    -- Debounce et horloge lente
    signal p_addrMem, p_writeHigh, p_writeLow, p_run, p_resetPC : STD_LOGIC;
    signal tick_sig : STD_LOGIC;

    -- Mémoire programme
    signal instr_sig : STD_LOGIC_VECTOR(15 downto 0);
    signal pc_sig    : STD_LOGIC_VECTOR(5 downto 0);
    signal run_sig   : STD_LOGIC;

    -- Décodeur
    signal class_bit_sig  : STD_LOGIC;
    signal alu_op_sig      : STD_LOGIC_VECTOR(3 downto 0);
    signal subop_sig       : STD_LOGIC_VECTOR(2 downto 0);
    signal rd_field_sig, rs1_sig, rs2_sig : STD_LOGIC_VECTOR(1 downto 0);
    signal imm_sig         : STD_LOGIC_VECTOR(7 downto 0);
    signal addr_field_sig  : STD_LOGIC_VECTOR(5 downto 0);

    signal reg_write_enable_sig : STD_LOGIC;
    signal wb_sel_sig           : STD_LOGIC_VECTOR(1 downto 0);
    signal mem_we_sig           : STD_LOGIC;
    signal jump_enable_sig      : STD_LOGIC;
    signal halt_sig             : STD_LOGIC;
    signal rd_role_sig          : STD_LOGIC;

    signal addr_a_sig, addr_b_sig, addr_w_sig : STD_LOGIC_VECTOR(1 downto 0);

    -- Banc de registres / ALU / mémoire de données
    signal data_a_sig, data_b_sig     : STD_LOGIC_VECTOR(7 downto 0);
    signal alu_res_sig                : STD_LOGIC_VECTOR(7 downto 0);
    signal flags_sig, flags_reg_sig   : STD_LOGIC_VECTOR(3 downto 0);
    signal data_mem_out_sig           : STD_LOGIC_VECTOR(7 downto 0);
    signal data_w_sig                 : STD_LOGIC_VECTOR(7 downto 0);
    signal flags_update_sig           : STD_LOGIC;

begin

    flags_update_sig <= not class_bit_sig; -- met à jour les flags seulement sur une instruction ALU

    -- Debounce des 5 boutons physiques
    U_BP1 : entity work.ButtonPulse port map (clk => clk, btn_in => btnL, pulse => p_addrMem);
    U_BP2 : entity work.ButtonPulse port map (clk => clk, btn_in => btnC, pulse => p_writeHigh);
    U_BP3 : entity work.ButtonPulse port map (clk => clk, btn_in => btnR, pulse => p_writeLow);
    U_BP4 : entity work.ButtonPulse port map (clk => clk, btn_in => btnU, pulse => p_run);
    U_BP5 : entity work.ButtonPulse port map (clk => clk, btn_in => btnD, pulse => p_resetPC);

    U_CLKDIV : entity work.ClockDivider
        port map (clk => clk, tick => tick_sig);

    -- Mémoire programme
    U_PROGMEM : entity work.ProgramMemory
        port map (
            clk          => clk,
            sw           => sw,
            btnAddrMem   => p_addrMem,
            btnWriteHigh => p_writeHigh,
            btnWriteLow  => p_writeLow,
            btnRun       => p_run,
            btnResetPC   => p_resetPC,
            tick         => tick_sig,
            jump_enable  => jump_enable_sig,
            jump_addr    => addr_field_sig,
            halt         => halt_sig,
            instr_out    => instr_sig,
            pc_out       => pc_sig,
            run_out      => run_sig
        );

    -- Décodeur : extraction des champs
    U_FIELDS : entity work.InstructionFields
        port map (
            instr      => instr_sig,
            class_bit  => class_bit_sig,
            alu_op     => alu_op_sig,
            subop      => subop_sig,
            rd_field   => rd_field_sig,
            rs1        => rs1_sig,
            rs2        => rs2_sig,
            imm        => imm_sig,
            addr_field => addr_field_sig
        );

    -- Décodeur : logique de contrôle
    U_CONTROL : entity work.ControlUnit
        port map (
            class_bit        => class_bit_sig,
            subop             => subop_sig,
            flags_reg         => flags_reg_sig,
            reg_write_enable  => reg_write_enable_sig,
            wb_sel            => wb_sel_sig,
            mem_we            => mem_we_sig,
            jump_enable       => jump_enable_sig,
            halt              => halt_sig,
            rd_role           => rd_role_sig
        );

    -- Décodeur : résolution des adresses registre
    U_ADDRMUX : entity work.AddressMux
        port map (
            rd_field => rd_field_sig,
            rs1      => rs1_sig,
            rs2      => rs2_sig,
            rd_role  => rd_role_sig,
            addr_a   => addr_a_sig,
            addr_b   => addr_b_sig,
            addr_w   => addr_w_sig
        );


    -- Banc de registres
 U_REGFILE : entity work.RegisterFile
    port map (
        clk    => clk,
        tick   => tick_sig,
        we     => reg_write_enable_sig,
        addr_w => addr_w_sig,
        data_w => data_w_sig,
        addr_a => addr_a_sig,
        addr_b => addr_b_sig,
        data_a => data_a_sig,
        data_b => data_b_sig
    );


    -- ALU
    U_ALU : entity work.ALU_Unit
        port map (
            tick          => tick_sig,
            clk           => clk,
            regA_in       => data_a_sig,
            regB_in       => data_b_sig,
            alu_op        => alu_op_sig,
            flags_update  => flags_update_sig,
            alu_res       => alu_res_sig,
            flags         => flags_sig,
            flags_reg_out => flags_reg_sig
        );

    -- Mémoire de données
    U_DATAMEM : entity work.DataMemory
        port map (
            clk      => clk,
 tick     => tick_sig,
            we       => mem_we_sig,
            addr     => addr_field_sig,
            data_in  => data_a_sig,
            data_out => data_mem_out_sig
        );

    -- Mux d'écriture registre (writeback)
    U_WBMUX : entity work.WritebackMux
        port map (
            wb_sel       => wb_sel_sig,
            alu_res      => alu_res_sig,
            imm          => imm_sig,
            data_mem_out => data_mem_out_sig,
            data_w       => data_w_sig
        );

    -- Affichage
    U_DISPLAY : entity work.Display_Manager
        port map (
            clk       => clk,
            sel       => sw(7 downto 5),
            class_bit => class_bit_sig,
            alu_op    => alu_op_sig,
            alu_res   => alu_res_sig,
            pc_out    => pc_sig,
            instr_out => instr_sig,
            flags_reg => flags_reg_sig,
            data_a    => data_a_sig,
            data_b    => data_b_sig,
            seg       => seg,
            dp        => dp,
            an        => an,
            led       => led
        );

end Behavioral;
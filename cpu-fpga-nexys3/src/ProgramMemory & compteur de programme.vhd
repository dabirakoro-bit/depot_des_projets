library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ProgramMemory is
    Port ( 
        clk          : in  STD_LOGIC;
        sw           : in  STD_LOGIC_VECTOR (7 downto 0);
        btnAddrMem   : in  STD_LOGIC;
        btnWriteHigh : in  STD_LOGIC;
        btnWriteLow  : in  STD_LOGIC;
        btnRun       : in  STD_LOGIC;
        btnResetPC   : in  STD_LOGIC;
        tick         : in  STD_LOGIC;

        jump_enable  : in  STD_LOGIC;                     -- vient du décodeur
        jump_addr    : in  STD_LOGIC_VECTOR (5 downto 0); -- vient du décodeur
        halt         : in  STD_LOGIC;                     -- vient du décodeur

        instr_out    : out STD_LOGIC_VECTOR (15 downto 0);
        pc_out       : out STD_LOGIC_VECTOR (5 downto 0);
        run_out      : out STD_LOGIC
    );
end ProgramMemory;

architecture Behavioral of ProgramMemory is

    type mem_array is array (0 to 63) of STD_LOGIC_VECTOR(15 downto 0);
    signal program_mem : mem_array := (others => (others => '0'));

    signal addr_mem       : STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
    signal write_reg_high : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal pc             : STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
    signal run_state      : STD_LOGIC := '0';

begin

    -- Bascule marche/pause
    process(clk)
    begin
        if rising_edge(clk) then
            if btnRun = '1' then
                run_state <= not run_state;
            end if;
        end if;
    end process;

    -- Écriture manuelle du programme
    process(clk)
    begin
        if rising_edge(clk) then
            if btnAddrMem = '1' then
                addr_mem <= sw(5 downto 0);
            elsif btnWriteHigh = '1' then
                write_reg_high <= sw;
            elsif btnWriteLow = '1' then
                program_mem(to_integer(unsigned(addr_mem))) <= write_reg_high & sw;
                addr_mem <= std_logic_vector(unsigned(addr_mem) + 1);
            end if;
        end if;
    end process;

    -- Compteur de programme : priorité reset > halt > jump > avancement normal
    process(clk)
    begin
        if rising_edge(clk) then
            if btnResetPC = '1' then
                pc <= (others => '0');
            elsif halt = '1' then
                null; -- pc ne bouge pas, exécution terminée
            elsif run_state = '1' and tick = '1' then
                if jump_enable = '1' then
                    pc <= jump_addr;
                else
                    pc <= std_logic_vector(unsigned(pc) + 1);
                end if;
            end if;
        end if;
    end process;

    instr_out <= program_mem(to_integer(unsigned(pc)));
    pc_out    <= pc;
    run_out   <= run_state;

end Behavioral;
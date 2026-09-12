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

        jump_enable  : in  STD_LOGIC;
        jump_addr    : in  STD_LOGIC_VECTOR (5 downto 0);
        halt         : in  STD_LOGIC;

        instr_out    : out STD_LOGIC_VECTOR (15 downto 0);
        pc_out       : out STD_LOGIC_VECTOR (5 downto 0);
        run_out      : out STD_LOGIC
    );
end ProgramMemory;

architecture Behavioral of ProgramMemory is

    type mem_array is array (0 to 63) of STD_LOGIC_VECTOR(15 downto 0);

    -- Programme de test précâblé : compte à rebours R0 de 5 à 0, puis HALT
    -- 0: LOADI R0,5  1: DEC R0  2: JZ 5  3: JMP 1  4: HALT  5: HALT
 signal program_mem : mem_array := (
     0 => "1000000000000101", -- LOADI R0,5
     1 => "0001100000000000", -- INC R0
     2 => "1111000000000000", -- STORE R0,0    (attendu: 6)
     3 => "1000000000001010", -- LOADI R0,10
     4 => "1000010000000011", -- LOADI R1,3
     5 => "0010010000100000", -- SUB R2,R0,R1
     6 => "1111100000000001", -- STORE R2,1    (attendu: 7)
     7 => "1000000000000101", -- LOADI R0,5
     8 => "0011100000000000", -- NEG R0
     9 => "1111000000000010", -- STORE R0,2    (attendu: 251, soit -5)
    10 => "1000000000001100", -- LOADI R0,12
    11 => "1000010000001010", -- LOADI R1,10
    12 => "0100110000100000", -- OR R2,R0,R1
    13 => "1111100000000011", -- STORE R2,3    (attendu: 14)
    14 => "0101010000100000", -- XOR R2,R0,R1
    15 => "1111100000000100", -- STORE R2,4    (attendu: 6)
    16 => "1000000000001111", -- LOADI R0,15
    17 => "0101110000000000", -- NOT R2,R0
    18 => "1111100000000101", -- STORE R2,5    (attendu: 240)
    19 => "1000000010000001", -- LOADI R0,129
    20 => "0110010000000000", -- SHL R2,R0
    21 => "1111100000000110", -- STORE R2,6    (attendu: 2, carry=1)
    22 => "1000000010000001", -- LOADI R0,129
    23 => "0110110000000000", -- SHR R2,R0
    24 => "1111100000000111", -- STORE R2,7    (attendu: 64, carry=1)
    25 => "1000000010000000", -- LOADI R0,128
    26 => "0111010000000000", -- ROL R2,R0
    27 => "1111100000001000", -- STORE R2,8    (attendu: 1, carry précédent réinjecté)
    28 => "1000000001100100", -- LOADI R0,100
    29 => "1000010000110010", -- LOADI R1,50
    30 => "0000110000100000", -- ADDS R2,R0,R1
    31 => "1111100000001001", -- STORE R2,9    (attendu: 150, V=1)
    32 => "1000000000001010", -- LOADI R0,10
    33 => "1000010000000011", -- LOADI R1,3
    34 => "0010110000100000", -- SBB R2,R0,R1
    35 => "1111100000001010", -- STORE R2,10   (attendu: 6, avec retenue précédente)
    36 => "1000000001001101", -- LOADI R0,77
    37 => "0111110000000000", -- PASSA R2,R0   (MOV)
    38 => "1111100000001011", -- STORE R2,11   (attendu: 77)
    39 => "1110000000000000", -- LOAD R0,0
    40 => "0111111000000000", -- PASSA R3,R0 (affiche mem[0], attendu: 6)
    41 => "1110000000000001", -- LOAD R0,1
    42 => "0111111000000000", -- PASSA R3,R0 (affiche mem[1], attendu: 7)
    43 => "1110000000000010", -- LOAD R0,2
    44 => "0111111000000000", -- PASSA R3,R0 (affiche mem[2], attendu: 251)
    45 => "1110000000000011", -- LOAD R0,3
    46 => "0111111000000000", -- PASSA R3,R0 (affiche mem[3], attendu: 14)
    47 => "1110000000000100", -- LOAD R0,4
    48 => "0111111000000000", -- PASSA R3,R0 (affiche mem[4], attendu: 6)
    49 => "1110000000000101", -- LOAD R0,5
    50 => "0111111000000000", -- PASSA R3,R0 (affiche mem[5], attendu: 240)
    51 => "1110000000000110", -- LOAD R0,6
    52 => "0111111000000000", -- PASSA R3,R0 (affiche mem[6], attendu: 2)
    53 => "1110000000000111", -- LOAD R0,7
    54 => "0111111000000000", -- PASSA R3,R0 (affiche mem[7], attendu: 64)
    55 => "1110000000001000", -- LOAD R0,8
    56 => "0111111000000000", -- PASSA R3,R0 (affiche mem[8], attendu: 1)
    57 => "1110000000001001", -- LOAD R0,9
    58 => "0111111000000000", -- PASSA R3,R0 (affiche mem[9], attendu: 150)
    59 => "1110000000001010", -- LOAD R0,10
    60 => "0111111000000000", -- PASSA R3,R0 (affiche mem[10], attendu: 6)
    61 => "1110000000001011", -- LOAD R0,11
    62 => "0111111000000000", -- PASSA R3,R0 (affiche mem[11], attendu: 77)
    63 => "1101000000000000"  -- HALT
);

    signal addr_mem       : STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
    signal write_reg_high : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal pc             : STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
    signal run_state      : STD_LOGIC := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if btnRun = '1' then
                run_state <= not run_state;
            end if;
        end if;
    end process;

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

    process(clk)
    begin
        if rising_edge(clk) then
            if btnResetPC = '1' then
                pc <= (others => '0');
            elsif halt = '1' then
                null;
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
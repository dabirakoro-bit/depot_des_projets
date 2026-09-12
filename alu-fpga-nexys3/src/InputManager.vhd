library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DataRegisterManager is
    Port ( 
        clk     : in  STD_LOGIC;
        sw      : in  STD_LOGIC_VECTOR (7 downto 0);
        btnA    : in  STD_LOGIC; -- valide A
        btnB    : in  STD_LOGIC; -- valide B
        btnOp   : in  STD_LOGIC; -- valide alu_op
        regA    : out STD_LOGIC_VECTOR (7 downto 0);
        regB    : out STD_LOGIC_VECTOR (7 downto 0);
        alu_op  : out STD_LOGIC_VECTOR (3 downto 0)
    );
end DataRegisterManager;

architecture Behavioral of DataRegisterManager is
    signal rA, rB   : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal rOp      : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if btnA = '1' then
                rA <= sw;
            end if;
            if btnB = '1' then
                rB <= sw;
            end if;
            if btnOp = '1' then
                rOp <= sw(3 downto 0);
            end if;
        end if;
    end process;

    regA   <= rA;
    regB   <= rB;
    alu_op <= rOp;
end Behavioral;
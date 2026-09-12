library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity InstructionFields is
    Port ( 
        instr      : in  STD_LOGIC_VECTOR (15 downto 0);

        class_bit  : out STD_LOGIC;
        alu_op     : out STD_LOGIC_VECTOR (3 downto 0);
        subop      : out STD_LOGIC_VECTOR (2 downto 0);
        rd_field   : out STD_LOGIC_VECTOR (1 downto 0);
        rs1        : out STD_LOGIC_VECTOR (1 downto 0);
        rs2        : out STD_LOGIC_VECTOR (1 downto 0);
        imm        : out STD_LOGIC_VECTOR (7 downto 0);
        addr_field : out STD_LOGIC_VECTOR (5 downto 0)
    );
end InstructionFields;

architecture Behavioral of InstructionFields is
begin

    class_bit  <= instr(15);
    alu_op     <= instr(14 downto 11);
    subop      <= instr(14 downto 12);

    -- Position de RD différente selon CLASS (le "piège" repéré plus tôt)
    rd_field <= instr(10 downto 9) when instr(15) = '0' else instr(11 downto 10);

    rs1        <= instr(8 downto 7);
    rs2        <= instr(6 downto 5);
    imm        <= instr(7 downto 0);
    addr_field <= instr(5 downto 0);

end Behavioral;
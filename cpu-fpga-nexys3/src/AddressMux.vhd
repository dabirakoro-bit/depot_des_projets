library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity AddressMux is
    Port ( 
        rd_field : in  STD_LOGIC_VECTOR (1 downto 0);
        rs1      : in  STD_LOGIC_VECTOR (1 downto 0);
        rs2      : in  STD_LOGIC_VECTOR (1 downto 0);
        rd_role  : in  STD_LOGIC;

        addr_a   : out STD_LOGIC_VECTOR (1 downto 0);
        addr_b   : out STD_LOGIC_VECTOR (1 downto 0);
        addr_w   : out STD_LOGIC_VECTOR (1 downto 0)
    );
end AddressMux;

architecture Behavioral of AddressMux is
begin

    addr_w <= rd_field;
    addr_a <= rd_field when rd_role = '1' else rs1;
    addr_b <= rs2;

end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ControlUnit is
    Port ( 
        class_bit        : in  STD_LOGIC;
        subop            : in  STD_LOGIC_VECTOR (2 downto 0);
        flags_reg        : in  STD_LOGIC_VECTOR (3 downto 0); -- V,C,N,Z

        reg_write_enable : out STD_LOGIC;
        wb_sel           : out STD_LOGIC_VECTOR (1 downto 0);
        mem_we           : out STD_LOGIC;
        jump_enable      : out STD_LOGIC;
        halt             : out STD_LOGIC;
        rd_role          : out STD_LOGIC -- '0'=destination, '1'=source (STORE)
    );
end ControlUnit;

architecture Behavioral of ControlUnit is
begin

    process(class_bit, subop, flags_reg)
    begin
        reg_write_enable <= '0';
        wb_sel           <= "00";
        mem_we           <= '0';
        jump_enable      <= '0';
        halt             <= '0';
        rd_role          <= '0';

        if class_bit = '0' then
            reg_write_enable <= '1';
            wb_sel           <= "00";
        else
            case subop is
                when "000" => reg_write_enable <= '1'; wb_sel <= "01"; -- LOADI
                when "001" => jump_enable <= '1';                       -- JMP
                when "010" => jump_enable <= flags_reg(0);              -- JZ
                when "011" => jump_enable <= flags_reg(2);              -- JC
                when "100" => jump_enable <= flags_reg(1);              -- JN
                when "101" => halt <= '1';                              -- HALT
                when "110" => reg_write_enable <= '1'; wb_sel <= "10";  -- LOAD
                when "111" => mem_we <= '1'; rd_role <= '1';            -- STORE
                when others => null;
            end case;
        end if;
    end process;

end Behavioral;
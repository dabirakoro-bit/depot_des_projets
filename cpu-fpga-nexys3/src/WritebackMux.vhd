library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity WritebackMux is
    Port ( 
        wb_sel       : in  STD_LOGIC_VECTOR (1 downto 0);
        alu_res      : in  STD_LOGIC_VECTOR (7 downto 0);
        imm          : in  STD_LOGIC_VECTOR (7 downto 0);
        data_mem_out : in  STD_LOGIC_VECTOR (7 downto 0);

        data_w       : out STD_LOGIC_VECTOR (7 downto 0)
    );
end WritebackMux;

architecture Behavioral of WritebackMux is
begin

    process(wb_sel, alu_res, imm, data_mem_out)
    begin
        case wb_sel is
            when "00"   => data_w <= alu_res;
            when "01"   => data_w <= imm;
            when "10"   => data_w <= data_mem_out;
            when others => data_w <= (others => '0');
        end case;
    end process;

end Behavioral;
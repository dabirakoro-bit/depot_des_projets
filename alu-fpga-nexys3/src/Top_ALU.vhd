library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Top_ALU is
    Port ( 
        clk    : in  STD_LOGIC;
        sw     : in  STD_LOGIC_VECTOR (7 downto 0);
        btnL   : in  STD_LOGIC; -- Valide alu_op
        btnC   : in  STD_LOGIC; -- Valide RegA
        btnR   : in  STD_LOGIC; -- Valide RegB
        btnU   : in  STD_LOGIC; -- Afficher RegB
        btnD   : in  STD_LOGIC; -- Afficher Résultat ALU
        
        led    : out STD_LOGIC_VECTOR (7 downto 0);
        led_op : out STD_LOGIC_VECTOR (3 downto 0); -- vers JA1
        seg    : out STD_LOGIC_VECTOR (6 downto 0);
        dp     : out STD_LOGIC;
        an     : out STD_LOGIC_VECTOR (3 downto 0)
    );
end Top_ALU;

architecture Behavioral of Top_ALU is
    signal regA_out    : STD_LOGIC_VECTOR(7 downto 0);
    signal regB_out    : STD_LOGIC_VECTOR(7 downto 0);
    signal alu_res     : STD_LOGIC_VECTOR(7 downto 0);
    signal flags       : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_op_disp : STD_LOGIC_VECTOR(3 downto 0);
begin

    U_ALU_UNIT : entity work.ALU_Unit
        port map (
            clk        => clk,
            sw         => sw,
            btnA       => btnC,
            btnB       => btnR,
            btnOp      => btnL,
            regA_out   => regA_out,
            regB_out   => regB_out,
            alu_op_out => alu_op_disp,
            alu_res    => alu_res,
            flags      => flags
        );

    led_op <= alu_op_disp;

    U_DISPLAY : entity work.Display_Manager
        port map (
            clk     => clk,
            alu_op  => alu_op_disp,
            btnL    => btnU,
            btnR    => btnD,
            regA    => regA_out,
            regB    => regB_out,
            alu_res => alu_res,
            flags   => flags,
            seg     => seg,
            dp      => dp,
            an      => an,
            led     => led
        );
end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity Loop_Control is
    Port (
        clk : in std_logic;
        reset_n : in std_logic;
        
        e : in  STD_LOGIC_VECTOR(255 downto 0);
        
        MUX_e_sel : in  STD_LOGIC;
        LOOP_SHIFT: in STD_LOGIC;
        
        e_exhausted : out STD_LOGIC;
        e_lsb: out STD_LOGIC
        
         );
end Loop_Control;

architecture Behavioral of Loop_Control is
    signal e_reg : STD_LOGIC_VECTOR (255 downto 0);
    signal MUX_e_out : STD_LOGIC_VECTOR (255 downto 0);
    
begin

    -- Register for e
    process(clk, reset_n, LOOP_SHIFT)
    begin
        if reset_n = '0' then
            e_reg <= (others => '0');
            
        elsif rising_edge(clk) then
            e_reg <= MUX_e_out;
        end if;
        
        if LOOP_SHIFT = '1' then
            MUX_e_out <= STD_LOGIC_VECTOR(unsigned(e_reg) srl 1);
        elsif MUX_e_sel = '0' then
            MUX_e_out <= e;
        else
            MUX_e_out <= e_reg;
        end if;
    end process;

    e_exhausted <= '1' when unsigned(e_reg) = 0 else '0';

    -- Assuming the LSB of e_reg is the exp_bit_0 output
    e_lsb <= e_reg(0);

end Behavioral;
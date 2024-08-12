library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;



entity RL_Binary_Method is
    generic( k_msb_i : natural := 255);
    Port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           M : in STD_LOGIC_VECTOR (k_msb_i downto 0);
           n : in STD_LOGIC_VECTOR (k_msb_i downto 0);
           e : in STD_LOGIC_VECTOR (k_msb_i downto 0);

           C_reg_en : in std_logic;
           P_reg_en : in std_logic;

           MUX_e_sel : in STD_LOGIC;
           MUX_P_sel : in STD_LOGIC;
           MUX_C_sel : in STD_LOGIC;
           MUX_A_sel : STD_LOGIC;
           
           LOOP_SHIFT: in std_logic;
           BL_out_reset: in std_logic;
           
           C : out STD_LOGIC_VECTOR (k_msb_i downto 0);
           blakley_idle : out std_logic;
           e_exhausted : out std_logic;
           
           e_lsb: out std_logic          
           );
end RL_Binary_Method;

architecture Behavioral of RL_Binary_Method is
    signal P_reg, C_reg : STD_LOGIC_VECTOR(k_msb_i downto 0);
    signal P_out, C_out : STD_LOGIC_VECTOR(k_msb_i downto 0);
    signal MUX_P_out, MUX_C_out : STD_LOGIC_VECTOR(k_msb_i downto 0);
    signal p_idle, c_idle: STD_LOGIC;
begin          

    loop_control: entity work.Loop_Control
    port map (
        clk => clk,
        reset_n => reset_n,
        e => e,
        MUX_e_sel => MUX_e_sel,
        e_exhausted => e_exhausted,
        e_lsb => e_lsb,
        LOOP_SHIFT => LOOP_SHIFT
    );


    -- P = P * P mod n
    blakley_P: entity work.blakley
    generic map (
        k_msb_i => 255
        )
    port map (
        clk => clk,
        reset_n => reset_n,
        a => P_reg,
        b => P_reg,
        n => n,
        mux_A_sel => MUX_A_sel,
        R => P_out,
        idle => p_idle,
        R_reset => BL_out_reset
    );

    -- C = C * P mod n
    blakley_C: entity work.blakley
    generic map (
        k_msb_i => 255
        )
    port map (
        clk => clk,
        reset_n => reset_n,
        a => P_reg,
        b => C_reg,
        n => n,
        mux_A_sel => MUX_A_sel,
        R => C_out,
        idle => c_idle,
        R_reset => BL_out_reset
    );

    -- MUX_P and MUX_C logic
    MUX_P_out <= M when MUX_P_sel = '1' else P_out;
    MUX_C_out <= ((k_msb_i downto 1 => '0') & '1') when MUX_C_sel = '0' else C_out;
    
    
    -- Register logic
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            P_reg <= (others => '0');
            C_reg <= (others => '0');
            
        elsif rising_edge(clk) then
        
            if P_reg_en = '1' then
                P_reg <= MUX_P_out;
            else
                P_reg <= P_reg;
            end if;
            
            if C_reg_en = '1' then
                    C_reg <= MUX_C_out;
                else
                    C_reg <= C_reg;
                end if;
 
        end if;
    end process;
    
    -- Output Assignment
    C <= C_reg;
    blakley_idle <= p_idle;

end Behavioral;
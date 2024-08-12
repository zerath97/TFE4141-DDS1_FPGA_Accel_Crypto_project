library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;



entity RL_Binary_Method_tb is
    generic( k_msb_i : natural := 15);
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           M : in STD_LOGIC_VECTOR (k_msb_i downto 0);
           n : in STD_LOGIC_VECTOR (k_msb_i downto 0);
           e : in STD_LOGIC_VECTOR (k_msb_i downto 0);
           MUX_e_sel : in STD_LOGIC;
           MUX_P_sel : in STD_LOGIC;
           MUX_C_sel : in STD_LOGIC;
           MUX_A_sel : STD_LOGIC;
           Output_C : out STD_LOGIC_VECTOR (k_msb_i downto 0);
           blakley_idle : out std_logic;
           e_exhausted : out std_logic
           );
end RL_Binary_Method_tb;

architecture Behavioral of RL_Binary_Method_tb is
    signal P_reg, C_reg : STD_LOGIC_VECTOR(k_msb_i downto 0);
    signal P_out, C_out : STD_LOGIC_VECTOR(k_msb_i downto 0);
    signal MUX_P_out, MUX_C_out : STD_LOGIC_VECTOR(k_msb_i downto 0);
    signal one_reg : STD_LOGIC_VECTOR(k_msb_i downto 0) := (0 => '1', others => '0');
    signal C_reg_en : STD_LOGIC;
    signal p_idle, c_idle: STD_LOGIC;
begin          

    loop_control: entity work.Loop_Control
    port map (
        clk => clk,
        reset => reset,
        e => e,
        MUX_e_sel => MUX_e_sel,
        blakley_idle => p_idle,
        e_exhausted => e_exhausted,
        e_bit_0 => C_reg_en
    );


    -- P = P * P mod n
    blakley_P: entity work.blakley
    generic map (
        k_msb_i => 15
        )
    port map (
        clk => clk,
        reset => reset,
        a => P_reg,
        b => P_reg,
        n => n,
        mux_A_sel => MUX_A_sel,
        R => P_out,
        idle => p_idle     
    );

    -- C = C * P mod n
    blakley_C: entity work.blakley
    generic map (
        k_msb_i => 15
        )
    port map (
        clk => clk,
        reset => reset,
        a => P_reg,
        b => C_reg,
        n => n,
        mux_A_sel => MUX_A_sel,
        R => C_out,
        idle => c_idle
    );

    -- MUX_P and MUX_C logic
    MUX_P_out <= M when MUX_P_sel = '1' else P_out;
    MUX_C_out <= one_reg when (MUX_C_sel = '0') else C_out;
    
    
    -- Register logic
    process(clk, reset)
    begin
        if reset = '1' then
            P_reg <= (others => '0');
            C_reg <= (others => '0');
            
        elsif rising_edge(clk) then
        
            if p_idle = '1' then
                P_reg <= MUX_P_out;
            else
                P_reg <= P_reg;
            end if;
        
            if c_idle = '1' and C_reg_en = '1' then
                C_reg <= MUX_C_out;
            else
                C_reg <= C_reg;
            end if;
        
        end if;
    end process;
    

    -- Output Assignment
    Output_C <= C_reg;
    blakley_idle <= p_idle;

end Behavioral;
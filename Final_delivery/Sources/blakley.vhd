library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity Blakley is
    generic (k_msb_i : natural := 255); -- Length of the k-bit numbers - 1 to set MSB for vectors.

    Port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           a : in STD_LOGIC_VECTOR (k_msb_i downto 0);
           b : in STD_LOGIC_VECTOR (k_msb_i downto 0);
           n : in STD_LOGIC_VECTOR (k_msb_i downto 0);
           R_reset: in std_logic;
           MUX_A_sel : in STD_LOGIC;
           
           R : out STD_LOGIC_VECTOR (k_msb_i downto 0);
           idle : out STD_LOGIC
           
           );
end Blakley;

architecture Behavioral of Blakley is
    -- Registers
    signal R_reg : STD_LOGIC_VECTOR (k_msb_i + 1 downto 0) := (others => '0');
        -- Higher bit-length for A_reg and A_reg_sll to track the blakley's progression.
    signal A_reg : STD_LOGIC_VECTOR(k_msb_i + 1 downto 0) := (others => '0'); 
    
    -- Register enables
    signal R_reg_en : STD_LOGIC := '0';
    signal A_reg_en : STD_LOGIC := '0';
    
    -- MUXes
    signal MUX_B : STD_LOGIC_VECTOR (k_msb_i downto 0);
    signal MUX_A, MUX_R : STD_LOGIC_VECTOR (k_msb_i + 1 downto 0);
    
    -- MUX Selects
    signal MUX_R_sel : STD_LOGIC_VECTOR (1 downto 0);

    -- Operations
    signal ADDER : STD_LOGIC_VECTOR(k_msb_i + 1 downto 0);
    signal SUB_n : STD_LOGIC_VECTOR(k_msb_i downto 0);
    signal SUB_2n : STD_LOGIC_VECTOR(k_msb_i + 1 downto 0);
    signal diocane : STD_LOGIC_VECTOR(k_msb_i+1 downto 0);
    signal diocane2 : STD_LOGIC_VECTOR(k_msb_i + 1 downto 0);
    signal internal_idle : std_logic;
    signal last_step : std_logic;

begin          

    -- Clock and Reset operations
    main_process : process(clk, reset_n)
    begin
        if reset_n = '0' then
            -- Reset registers
            A_reg <= (others => '0');
            R_reg <= (others => '0');
        elsif rising_edge(clk) then
            if A_reg_en = '1' then
                A_reg <= MUX_A;
            else
                A_reg <= A_reg;
            end if;
       
            -- To prevent blakley from outputting new data until it is done.
            if R_reset = '1' then
                R_reg <= (others => '0');
            elsif R_reg_en = '1' then
                R_reg <= MUX_R;
            else
                R_reg <= R_reg;
            end if;
            
        end if;    
    end process main_process;
    
    MUX_A <= (a & '1') when MUX_A_sel = '0' else std_logic_vector(unsigned(A_reg) sll 1);
    MUX_B <= b when A_reg(k_msb_i + 1) = '1' else (others => '0'); -- Comparing for a_{k-l-i}.
    MUX_R <= ADDER when MUX_R_sel = "00" else (others => '0') when MUX_R_sel = "01" else '0' & SUB_n when MUX_R_sel = "10" else SUB_2n; 
    
    
    ADDER <= STD_LOGIC_VECTOR( (unsigned(R_reg) sll 1) + unsigned(MUX_B) ); -- R = 2R + a_{k-l-i}*b
    SUB_n <= STD_LOGIC_VECTOR(unsigned(ADDER(k_msb_i downto 0)) - unsigned(n)); -- If SUM_reg > 2n - 2
    SUB_2n <= STD_LOGIC_VECTOR(unsigned(ADDER) - (unsigned('0' & n) sll 1)); -- If SUM_reg > 3n - 3
    
    MUX_R_sel <= "01" when reset_n = '0' else "11" when unsigned(ADDER) > (unsigned('0' & n) sll 1) else "10" when unsigned(ADDER) > unsigned(n) else "00";

    R_reg_en <= '1' when internal_idle = '0' else '0';
    A_reg_en <= '1' when internal_idle = '0' or R_reset = '1' else '0';
        
    internal_idle <= '1' when (A_reg = ("1" & (k_msb_i downto 0 => '0'))) or (A_reg = (k_msb_i + 1 downto 0 => '0')) else '0';

    idle <= internal_idle;
    R <= R_reg(k_msb_i downto 0);
    
end Behavioral;
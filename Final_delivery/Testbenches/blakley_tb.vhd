-- The valid data is available for one clock cycle at rising edge number, 2*(k_msb_i).
-- --> Alternative description: It takes [2*(k-number's bit-length - 1)] clock cycles to finish Blakley.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity Blakley_tb is
    generic (k_msb_i : natural := 15); -- Length of the k-bit numbers - 1 to set MSB for vectors.

    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           a : in STD_LOGIC_VECTOR (k_msb_i downto 0);
           b : in STD_LOGIC_VECTOR (k_msb_i downto 0);
           n : in STD_LOGIC_VECTOR (k_msb_i downto 0);
           MUX_A_sel : in STD_LOGIC;
           R : out STD_LOGIC_VECTOR (k_msb_i downto 0);
           idle : out STD_LOGIC
           );
end Blakley_tb;

architecture Behavioral of Blakley_tb is
    -- Registers
    signal A_reg : STD_LOGIC_VECTOR(k_msb_i downto 0) := (others => '0'); -- Higher bit-length to track the program's progression.
    signal R_reg : STD_LOGIC_VECTOR (k_msb_i downto 0) := (others => '0'); -- SUM_reg used to reduce wire length.
    signal counter : natural := 0;
    signal R_reg_en : STD_LOGIC := '0';
    
    -- MUXes
    signal MUX_B, MUX_R, SUM_reg : STD_LOGIC_VECTOR (k_msb_i downto 0);

    -- MUX Selects
    signal MUX_R_sel : STD_LOGIC_VECTOR (1 downto 0);

    -- Operations
    signal ADDER, SUB_n, SUB_2n : STD_LOGIC_VECTOR(k_msb_i downto 0);
    signal A_reg_sll : STD_LOGIC_VECTOR(k_msb_i downto 0);

    -- Counters
    signal A_counter : STD_LOGIC; -- Used to slow down A_reg, since MUX_B -> SUM_reg -> R_reg takes more than 1 clock cycle.
    

begin          

    -- Clock and Reset operations
    main_process : process(clk, reset)
    begin
        if reset = '1' then
            
            -- Reset registers
            A_reg <= (others => '0');
            --SUM_reg <= (others => '0');
            R_reg <= (others => '0');
            
            -- Reset other signals
            A_counter <= '0';

        elsif rising_edge(clk) then
            counter <= counter + 1;
            if MUX_A_sel = '0' then
                A_reg <= a;
            else 
                A_reg <= std_logic_vector(unsigned(A_reg) sll 1);
            end if;
        
            --SUM_reg <= ADDER;
            
            if R_reg_en = '1' then
                R_reg <= MUX_R;
            else
                R_reg <= R_reg;
            end if;
                    
        end if;    
    end process main_process;
    

    MUX_B <= b when A_reg(k_msb_i) = '1' else (others => '0'); -- Comparing for a_{k-l-i}.
    MUX_R <= SUM_reg when MUX_R_sel = "00" else (others => '0') when MUX_R_sel = "01" else SUB_n when MUX_R_sel = "10" else SUB_2n; 
    
    SUM_reg <= STD_LOGIC_VECTOR( (unsigned(R_reg) sll 1) + unsigned(MUX_B) ); -- R = 2R + a_{k-l-i}*b

    SUB_n <= STD_LOGIC_VECTOR(UNSIGNED(unsigned(SUM_reg) - unsigned(n))); -- If SUM_reg > 2n - 2
    SUB_2n <= STD_LOGIC_VECTOR(unsigned(unsigned(SUM_reg) - (unsigned(n) sll 1))); -- If SUM_reg > 3n - 3

    A_reg_sll <= std_logic_vector(unsigned(A_reg) sll 1);

    MUX_R_sel <= "01" when reset = '1' else "11" when unsigned(SUM_reg) > (unsigned(n) sll 1) else "10" when unsigned(SUM_reg) > unsigned(n) else "00";

    R_reg_en <= '0' when A_reg = (k_msb_i downto 0 => '0') else '1';
    
    -- Output Assignment
    R <= R_reg;
    
    idle <= '1' when A_reg = (k_msb_i downto 0 => '0') else '0';

end Behavioral;
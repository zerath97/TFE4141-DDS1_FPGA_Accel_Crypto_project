library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity Loop_Control_TB is
-- Test bench has no ports.
end Loop_Control_TB;

architecture sim of Loop_Control_TB is
    constant k_msb_i : natural := 6;
    signal clk, reset : std_logic := '0';
    signal e, exp_exhausted, exp_bit_0 : std_logic;
    
    -- Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal e : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal MUX_e_sel : std_logic := '0';

    -- Outputs
    signal exp_exhausted : std_logic;
    signal exp_bit_0 : std_logic;

    -- Clock period definitions
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    dut: Loop_Control
    Port map (
        clk => clk,
        reset => reset,
        e => e,
        MUX_e_sel => MUX_e_sel,
        exp_exhausted => exp_exhausted,
        exp_bit_0 => exp_bit_0
    );

    -- Clock process definitions
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- hold reset state for 100 ns.
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for clk_period*2;  -- Wait for the system to stabilize

        -- Load a value into e and select the input 'e' to be loaded into e_reg
        MUX_e_sel <= '0';  -- Select input 'e' to pass through MUX
        e <= "0000000000000011";  -- MSB is '1', LSB as defined as MSB in this case
        wait for clk_period*1;  -- Wait for one clock cycle to load the value

        -- Change MUX select to keep shifting the e_reg right
        MUX_e_sel <= '1';  -- After this point e_reg should keep shifting right
        wait for clk_period*16;  -- Wait long enough to see the shifting and exhausting of e_reg

        -- Finish simulation
        wait;
    end process;
    

end Behavioral;
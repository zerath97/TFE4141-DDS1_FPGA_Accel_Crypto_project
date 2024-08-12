library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity tb_blakley is
end tb_blakley;

architecture sim of tb_blakley is
    -- Declare signals that match the blakley module's ports
    signal clk       : STD_LOGIC := '0';
    signal reset     : STD_LOGIC := '0';
    signal a         : STD_LOGIC_VECTOR(15 downto 0);
    signal b         : STD_LOGIC_VECTOR(15 downto 0);
    signal n         : STD_LOGIC_VECTOR(15 downto 0);
    signal MUX_A_sel : STD_LOGIC;
    signal R         : STD_LOGIC_VECTOR(15 downto 0);
    signal mul_done  : STD_LOGIC;
begin
    -- Clock generation
    clk_proc: process
    begin
        wait for 10 ns; 
        clk <= not clk; 
    end process;

    DUT: entity work.blakley port map(
        clk       => clk,
        reset     => reset,
        a         => a,
        b         => b,
        n         => n,
        MUX_A_sel => MUX_A_sel,
        R         => R
    );

    -- Test sequence
    stim_proc: process
    begin
        
        -- Apply test vectors
        a <= "0000000011000111";  -- Example value
        b <= "0000000010011101";  -- Example value
        n <= "0000000011100011";  -- Example value
        -- Apply initial reset
        reset <= '1';
        
        wait for 20 ns;  -- Adjust as necessary
        
        reset <= '0';
        MUX_A_sel <= '0';
        wait for 20ns;
        MUX_A_sel <= '1';
        wait;  -- Adjust as necessary

        -- Apply next test vectors
        -- a <= ...;
        -- b <= ...;
        -- ...
        -- Continue the sequence as required

        -- Terminate simulation after tests
    end process;

end sim;
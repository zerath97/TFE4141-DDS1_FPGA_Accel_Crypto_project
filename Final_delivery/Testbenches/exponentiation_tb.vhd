library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity exponentiation_tb is
	generic (
		C_block_size : integer := 256
	);
end exponentiation_tb;


architecture expBehave of exponentiation_tb is

	signal message 		: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
	signal key 			: STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
	signal valid_in 	: STD_LOGIC := '0';
	signal ready_in 	: STD_LOGIC;
	signal ready_out 	: STD_LOGIC := '0';
	signal valid_out 	: STD_LOGIC;
	signal result 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0);
	signal modulus 		: STD_LOGIC_VECTOR(C_block_size-1 downto 0);
	signal clk 			: STD_LOGIC := '0';
	signal restart 		: STD_LOGIC;
	signal reset_n 		: STD_LOGIC;
	signal  msgin_last, msgout_last : STD_LOGIC := '0';
	signal done: std_logic ;
begin
	i_exponentiation : entity work.exponentiation
		port map (
			message   => message  ,
			key       => key      ,
			valid_in  => valid_in ,
			ready_in  => ready_in ,
			ready_out => ready_out,
			valid_out => valid_out,
			result    => result   ,
			modulus   => modulus  ,
			clk       => clk      ,
			reset_n   => reset_n,
			msgin_last => msgin_last ,
		    msgout_last => msgout_last,
			done => done
		);
	clk_process : process
    begin
        wait for 10 ns;
        clk <= not clk;
    end process;
    
    stimulus_process : process
    begin
        -- a and b has to be co-primes.
        message <= x"0000000011111111222222223333333344444444555555556666666677777777";
        --a <= (others => '1');
        key <= x"0000000000000000000000000000000000000000000000000000000000010001";  -- Example value
        modulus <= x"99925173ad65686715385ea800cd28120288fc70a9bc98dd4c90d676f8ff768d";  -- Example value
        valid_in <= '1';
        ready_out <= '0';
        reset_n <= '0';
        wait for 40 ns;
        reset_n <= '1';
        wait;
    end process;
    

end expBehave;
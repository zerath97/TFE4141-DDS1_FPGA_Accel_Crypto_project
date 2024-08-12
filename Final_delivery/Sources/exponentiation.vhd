library ieee;
use ieee.std_logic_1164.all;

entity exponentiation is
	generic (
		C_block_size : integer := 256
	);
	port (
		--input controll
		valid_in	: in STD_LOGIC;
		ready_in	: out STD_LOGIC;
		msgin_last  : in std_logic;

		--input data
		message 	: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
		key 		: in STD_LOGIC_VECTOR ( C_block_size-1 downto 0 );
		

		--ouput controll
		ready_out	: in STD_LOGIC;
		valid_out	: out STD_LOGIC;
		msgout_last : out STD_LOGIC;

		--output data
		result 		: out STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		--modulus
		modulus 	: in STD_LOGIC_VECTOR(C_block_size-1 downto 0);

		--utility
		clk 		: in STD_LOGIC;
		reset_n 	: in STD_LOGIC;
		done : out std_logic
		
	);
end exponentiation;


architecture expBehave of exponentiation is
 signal MUX_A_sel, MUX_e_sel, MUX_P_sel, MUX_C_sel : std_logic;
    signal e_exhausted, blakley_idle : std_logic;
    signal internal_output : std_logic_vector(C_block_size - 1 downto 0);
    signal loop_shift, BL_out_rst: std_logic;
    signal reg_en : std_logic;
    signal BL_out_reset : std_logic;
    signal C_reg_en : std_logic;
    signal P_reg_en: std_logic ;
    signal last_message_reg: std_logic;
    signal e_lsb: std_logic;
begin

    
    FSM: entity work.FSM
    port map (
        clk => clk,
        reset_n => reset_n,
        valid_in => valid_in,
        valid_out => valid_out,
        ready_in => ready_in,
        ready_out => ready_out,
        e_exhausted => e_exhausted,
        blakley_idle => blakley_idle,
        BL_out_reset => BL_out_reset,
        MUX_A_sel => MUX_A_sel,
        MUX_e_sel => MUX_e_sel,
        MUX_P_sel => MUX_P_sel,
        MUX_C_sel => MUX_C_sel,
        LOOP_SHIFT => loop_shift,
        C_reg_en => C_reg_en,
        P_reg_en => P_reg_en,
        e_lsb => e_lsb,
        msgin_last => msgin_last ,
		msgout_last => msgout_last
    );
    
    RL_Binary_Method: entity work.RL_Binary_Method
    generic map ( k_msb_i => C_block_size - 1)
    port map (
        clk => clk,
        reset_n => reset_n,
        M => message,
        n => modulus,
        e => key,
        C_reg_en => C_reg_en,
        P_reg_en => P_reg_en,
        e_exhausted => e_exhausted,
        blakley_idle => blakley_idle,
        MUX_A_sel => MUX_A_sel,
        MUX_e_sel => MUX_e_sel,
        MUX_P_sel => MUX_P_sel,
        MUX_C_sel => MUX_C_sel,
        C => internal_output,
        LOOP_SHIFT => loop_shift,
        BL_out_reset => BL_out_reset,
        e_lsb => e_lsb
        
    );
    result <= internal_output;
end expBehave;
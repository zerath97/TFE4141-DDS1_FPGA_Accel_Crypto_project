library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM is
    generic (k_msb_i : natural := 255);
    port(
        clk : in std_logic;
        reset_n : in std_logic;
        
        e_lsb : in std_logic;
        valid_in : in std_logic;
        ready_out : in std_logic;
        
        msgin_last  : in std_logic;
        msgout_last : out STD_LOGIC;

        e_exhausted : in std_logic;
        blakley_idle : in std_logic;
        
        BL_out_reset: out std_logic;
        
        MUX_A_sel : out std_logic;
        MUX_e_sel : out std_logic;
        MUX_P_sel : out std_logic;
        MUX_C_sel : out std_logic;
        LOOP_SHIFT: out std_logic;
        P_reg_en : out std_logic;
        C_reg_en : out std_logic;
        
        valid_out : out std_logic;
        ready_in : out std_logic
        
    );
end FSM;

architecture Behavioral of FSM is
    type state_type is (IDLE, RLB_INIT, RLB_ACT, BL_INIT, BL_ACT, FINISHED);
    signal state, next_state : state_type;
    signal last_message : std_logic;
    signal last_bl : std_logic;
    signal reg_en : std_logic;
begin
    process (all)
    begin
    P_reg_en <= reg_en;
    C_reg_en <= '1' when reg_en = '1' and e_lsb = '1' else '0';
        
        if reset_n = '0' then
            state <= IDLE;
            MUX_e_sel <= '0';
            MUX_P_sel <= '0';
            MUX_C_sel <= '1';
            LOOP_SHIFT <= '0';
            BL_out_reset <= '0';
            last_message <= '0';
            msgout_last <= '0';
            reg_en <= '0';
            
            
            
        elsif rising_edge(clk) then
            state <= next_state;
            if(state = RLB_INIT and valid_in = '1') then
                last_message <= msgin_last;
            elsif (state = FINISHED and valid_out = '1' and ready_out = '1') then
                last_message <= '0';
            end if;
        end if;


        case state is
            when IDLE =>
                MUX_A_sel <= '1';
                MUX_e_sel <= '1';
                MUX_P_sel <= '0';
                MUX_C_sel <= '1';
                LOOP_SHIFT <= '0';
                reg_en <= '0';
                valid_out <= '0';
                ready_in <= '0';
                BL_out_reset <= '0';

                msgout_last <= '0';
                if valid_in = '1' then
                    next_state <= RLB_INIT;
                else
                    next_state <= IDLE;
                end if;
                
            when RLB_INIT =>
                MUX_A_sel <= '1';
                MUX_e_sel <= '0';
                MUX_P_sel <= '1';        
                MUX_C_sel <= '0';
                LOOP_SHIFT <= '0';
                reg_en <= '1';
                C_reg_en <= '1';
                valid_out <= '0';
                ready_in <= '1';
                BL_out_reset <= '0';
                msgout_last <= '0';
                

                               
                --if e_exhausted = '0' then
                    next_state <= BL_INIT;
                --else
                    --next_state <= RLB_INIT;
                --end if;
                
            when RLB_ACT =>
                MUX_A_sel <= '1';
                MUX_e_sel <= '1';
                MUX_P_sel <= '0';
                MUX_C_sel <= '1';
                LOOP_SHIFT <= '0';
                reg_en <= '0';
                valid_out <= '0';
                ready_in <= '0';
                BL_out_reset <= '0';
                msgout_last <= '0';
                
                if e_exhausted = '1' then
                    next_state <= FINISHED;
                else
                   next_state <= BL_INIT;
                end if;
                
            when BL_INIT =>
                MUX_A_sel <= '0';
                MUX_e_sel <= '1';
                MUX_P_sel <= '0';
                MUX_C_sel <= '1';
                LOOP_SHIFT <= '0';
                reg_en <= '0';
                valid_out <= '0';
                ready_in <= '0';
                BL_out_reset <= '1';
                msgout_last <= '0';
                
                next_state <= BL_ACT;
                
                
            when BL_ACT =>
                MUX_A_sel <= '1';
                MUX_e_sel <= '1';
                MUX_P_sel <= '0';
                MUX_C_sel <= '1';
                reg_en <= '0';
                valid_out <= '0';
                ready_in <= '0';                
                BL_out_reset <= '0';
                msgout_last <= '0';
                
                if blakley_idle = '1' then
                    reg_en <= '1';
                    LOOP_SHIFT <= '1';
                    next_state <= RLB_ACT;
                else
                    reg_en<= '0';
                    LOOP_SHIFT <= '0';
                    next_state <= BL_ACT;
                end if;
                
                
            when FINISHED =>
                    MUX_A_sel <= '1';
                    MUX_e_sel <= '1';
                    MUX_P_sel <= '0';
                    MUX_C_sel <= '1';
                    LOOP_SHIFT <= '0';
                    reg_en <= '0';
                    valid_out <= '1';
                    ready_in <= '0';
                    BL_out_reset <= '0';
                    msgout_last <= last_message;
                    
                if ready_out = '0' then
                    next_state <= FINISHED;
                elsif valid_in = '1' then
                    next_state <= RLB_INIT;
                else
                    next_state <= IDLE;     
                end if;
                
            when others =>
                MUX_A_sel <= '1';
                MUX_e_sel <= '1';
                MUX_P_sel <= '0';
                MUX_C_sel <= '1';
                LOOP_SHIFT <= '0';
                reg_en <= '0';
                valid_out <= '0';
                ready_in <= '0';
                BL_out_reset <= '0';
                msgout_last <= '0';
                
                next_state <= IDLE;
        end case;
    end process;
    


end Behavioral;
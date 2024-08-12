----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.10.2023 13:39:10
-- Design Name: 
-- Module Name: blakley - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity blakley is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           a : in STD_LOGIC_VECTOR (15 downto 0);
           b : in STD_LOGIC_VECTOR (15 downto 0);
           n : in STD_LOGIC_VECTOR (15 downto 0);
           MUX_A_sel : in STD_LOGIC;
           R : out STD_LOGIC_VECTOR (15 downto 0)
           );
end blakley;

architecture Behavioral of blakley is
    signal A_reg, B_reg, ADD_reg, R_reg, n_reg : STD_LOGIC_VECTOR(15 downto 0);
    signal MUX_MUL_out, MUX_R_out : STD_LOGIC_VECTOR(15 downto 0);
    signal sub1, sub2 : STD_LOGIC_VECTOR(15 downto 0);
    signal out_select: STD_LOGIC_VECTOR(1 downto 0);
begin          
    -- A Register
    process(clk, reset)
    begin
        if reset = '1' then
            n_reg <= n;
            B_reg <= b;
            A_reg <= (others => '0');
            R_reg <= (others => '0');
        elsif rising_edge(clk) then
            R_reg <= MUX_R_out;
            if MUX_A_sel = '1' then
                A_reg <= std_logic_vector(unsigned(A_reg) sll 1);  -- Left shift after MUX_A
            else
                A_reg <= a;
            end if;

        end if;
    end process;
    

    out_select <= "11" when unsigned(ADD_reg) > (unsigned(n_reg) sll 1) else "10" when unsigned(ADD_reg) > unsigned(n_reg) else "00";
    -- 2:1 MUX MUL
    MUX_MUL_out <= B_reg when A_reg(15) = '1' else (others => '0');

    -- Adder
    ADD_reg <= STD_LOGIC_VECTOR((unsigned(R_reg) sll 1) + unsigned(MUX_MUL_out)); -- Kan kanskje forbedre med Riccardos metode.

    -- Subtractors for MUX_R
    sub1 <= STD_LOGIC_VECTOR(unsigned(ADD_reg) - unsigned(n_reg));
    sub2 <= STD_LOGIC_VECTOR(unsigned(ADD_reg) - (unsigned(n_reg) sll 1)); 

    -- 4:1 MUX R
    MUX_R_out <=    ADD_reg when out_select = "00" else
                    (others => '0') when out_select = "01" else 
                    sub1 when out_select = "10" else 
                    sub2;

    -- Output Assignment
    R <= R_reg; -- Enten gjøre MUX_R_out eller R_reg avhengig om vi ønsker å klokke outputen.

end Behavioral;

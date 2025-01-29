----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2024 01:58:22 PM
-- Design Name: 
-- Module Name: round_keys_rom - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity round_keys_rom is
--  Port ( );
Port(
            clka : in  std_logic;
            addra : in  std_logic_vector(7 downto 0);
            douta : out std_logic_vector(7 downto 0)
        );
end round_keys_rom;

architecture Behavioral of round_keys_rom is
component blk_mem_gen_2
        Port (
            clka  : in  std_logic;                   
            addra : in  std_logic_vector(7 downto 0);   
            douta : out std_logic_vector(7 downto 0)   
        );
    end component;
begin
bram_inst : blk_mem_gen_2
        port map (
            clka  => clka,               
            addra => addra,                            
            douta => douta               
        );

end Behavioral;

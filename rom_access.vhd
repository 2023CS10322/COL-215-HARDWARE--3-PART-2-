----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2024 02:07:16 PM
-- Design Name: 
-- Module Name: rom_access - Behavioral
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

entity rom_access is
--  Port ( );
Port ( clk      : in  std_logic; -- enable signal that basically enables memory for read/write   
           in_1    : in  std_logic_vector(7 downto 0); -- Address for accessing BRAM -- Data to write into BRAM
           outpt     : out std_logic_vector(7 downto 0)  -- Data read from BRAM
         );
end rom_access;

architecture Behavioral of rom_access is
component blk_mem_gen_3
        Port (
            clka  : in  std_logic;                   
            addra : in  std_logic_vector(7 downto 0);   
            douta : out std_logic_vector(7 downto 0)   
        );
    end component;
begin
bram_inst : blk_mem_gen_3
        port map (
            clka  => clk,               
            addra => in_1,                            
            douta => outpt               
        );

end Behavioral;

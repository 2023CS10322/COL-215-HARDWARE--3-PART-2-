----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2024 01:47:15 PM
-- Design Name: 
-- Module Name: encrypted_text_rom - Behavioral
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

entity encrypted_text_rom is
--  Port ( );
 Port ( clka      : in  std_logic; -- enable signal that basically enables memory for read/write   
           addra     : in  std_logic_vector(3 downto 0); -- Address for accessing BRAM -- Data to write into BRAM
           douta     : out std_logic_vector(7 downto 0)  -- Data read from BRAM
         );
end encrypted_text_rom;

architecture Behavioral of encrypted_text_rom is
component blk_mem_gen_1
        Port (
            clka  : in  std_logic;                   
            addra : in  std_logic_vector(3 downto 0);   
            douta : out std_logic_vector(7 downto 0)   
        );
    end component;
begin
bram_inst : blk_mem_gen_1
        port map (
            clka  => clka,               
            addra => addra,                            
            douta => douta               
        );

end Behavioral;

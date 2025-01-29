----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/22/2024 04:03:15 PM
-- Design Name: 
-- Module Name: Inv_sub_byte - Behavioral
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

entity Inv_sub_byte is
    Port (
            clk : in  STD_LOGIC;
            input_subbyte : in STD_LOGIC_VECTOR(7 downto 0);
            output_subbyte : out  STD_LOGIC_VECTOR(7 downto 0)
        );
        
end Inv_sub_byte;

architecture Behavioral of Inv_sub_byte is
component rom_access is
    Port ( clk      : in  std_logic;   
           in_1    : in  std_logic_vector(7 downto 0); 
           outpt     : out std_logic_vector(7 downto 0)  
         );
end component;
begin
	
	uut: rom_access
    Port Map ( 
    clk => clk,
           in_1=>input_subbyte,
           outpt=>output_subbyte
         );
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Row_Shift is
    Port (
        input_rowshift : in  STD_LOGIC_VECTOR(31 downto 0); 
        tempo: in STD_LOGIC_VECTOR(1 downto 0); 
        output_rowshift : out  STD_LOGIC_VECTOR(31 downto 0) 
    );
end Row_Shift;

architecture Behavioral of Row_Shift is

begin
    process(input_rowshift, tempo)
    begin
        case tempo is
            when "00" =>
                output_rowshift <= input_rowshift;                          
            when "11" =>
                output_rowshift <= input_rowshift(23 downto 0) &  input_rowshift(31 downto 24);
            when "10" =>
                output_rowshift <= input_rowshift(15 downto 0) &  input_rowshift(31 downto 16);   
            when "01" =>
                output_rowshift <= input_rowshift(7 downto 0) &  input_rowshift(31 downto 8); 
              
            when others =>
                output_rowshift <= (others => '0'); 
        end case;
    end process;
end Behavioral;

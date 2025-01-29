library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cipherram is
    Port ( clk      : in  std_logic;
           rst      : in  std_logic;
           ena      : in  std_logic;  -- enable signal that basically enables memory for read/write
           we       : in  std_logic_vector(0 downto 0);   
           addr     : in  std_logic_vector(3 downto 0); -- Address for accessing BRAM
           din      : in  std_logic_vector(7 downto 0); -- Data to write into BRAM
           dout     : out std_logic_vector(7 downto 0)  -- Data read from BRAM
         );
end cipherram;


architecture Behavioral of cipherram is

   
    component blk_mem_gen_cipher
        Port (
            clka  : in  std_logic;                 
            ena   : in  std_logic;                     
            wea   : in  std_logic_vector(0 downto 0);  
            addra : in  std_logic_vector(3 downto 0);  
            dina  : in  std_logic_vector(7 downto 0); 
            douta : out std_logic_vector(7 downto 0)   
        );
    end component;

begin

    
    bram_inst : blk_mem_gen_cipher
        port map (
            clka  => clk,               
            ena   => ena,                
            wea   => we,  
            addra => addr,              
            dina  => din,                
            douta => dout               
        );

end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/09/2024 09:54:43 PM
-- Design Name: 
-- Module Name: readtest - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity readtest is
--  Port ( );
Port ( 
        clk      : in  std_logic;
        rst      : in  std_logic;
        start    : in  std_logic;                     -- Start signal to begin reading
        done     : out std_logic;                     -- Done signal when all slots are read
        cipher : out std_logic_vector(127 downto 0);
        round : out std_logic_vector(1279 downto 0)   -- Current address being read
    );
end readtest;

architecture Behavioral of readtest is
component cipherram
Port ( clk      : in  std_logic;
           rst      : in  std_logic;
           ena      : in  std_logic;  -- enable signal that basically enables memory for read/write
           we       : in  std_logic_vector(0 downto 0);   
           addr     : in  std_logic_vector(3 downto 0); -- Address for accessing BRAM
           din      : in  std_logic_vector(7 downto 0); -- Data to write into BRAM
           dout     : out std_logic_vector(7 downto 0)
             -- Data read from BRAM
         );
         
end component;

type state_type is (IDLE, READ_DATA, READ_WAIT, DONE_STATE);
    signal state : state_type := IDLE;

 -- Internal signals
    signal addr_cnt   : unsigned(3 downto 0);           -- Address counter
    signal ram_en     : std_logic;                      -- RAM enable
    signal ram_addr   : std_logic_vector(3 downto 0);   -- RAM address
    signal ram_dout   : std_logic_vector(7 downto 0);   -- RAM data output
begin
ram_inst: cipherram
    port map (
        clk  => clk,
        rst => rst,
        ena  => ram_en,
        we  => "0",      -- We're only reading, so write enable is always 0
        addr => ram_addr,
        din  => (others => '0'),  -- Not used since we're only reading
        dout => ram_dout
    );
process(clk, rst)
    begin
        if rst = '1' then
            state <= IDLE;
            addr_cnt <= (others => '0');
            ram_en <= '0';
            done <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    if start = '1' then
                        state <= READ_DATA;
                        ram_en <= '1';
                        addr_cnt <= (others => '0');
                        done <= '0';
                    end if;
                when READ_DATA =>
                    -- Move to wait state to allow RAM read to complete
                    state <= READ_WAIT;
                when READ_WAIT =>
                    -- Data is now ready on ram_dout
                    if addr_cnt = 15 then
                        state <= DONE_STATE;
                    else
                        addr_cnt <= addr_cnt + 1;
                        state <= READ_DATA;
                    end if;
                when DONE_STATE =>
                    done <= '1';
                    ram_en <= '0';
                    if start = '0' then  -- Wait for start to go low before returning to IDLE
                        state <= IDLE;
                    end if;
                    END CASE;
                    END IF;
                    END PROCESS;
                    ram_addr <= std_logic_vector(addr_cnt);
                    addr_out <= ram_addr;
                    data_out <= ram_dout;
end Behavioral;

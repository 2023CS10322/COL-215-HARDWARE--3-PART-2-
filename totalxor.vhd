----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2024 08:41:50 AM
-- Design Name: 
-- Module Name: totalxor - Behavioral
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

entity totalxor is
--  Port ( );
Port ( 
        clk      : in  std_logic;
        rst      : in  std_logic;
        start    : in  std_logic;
        round    : IN INTEGER;                     -- Start signal to begin operation
        done     : out std_logic;                     -- Done signal when all operations complete
        addr_OUT : out std_logic_vector(3 downto 0);
        FINALOUTPUT : OUT std_logic_vector(7 DOWNTO 0)   -- Current address being processed
    );
end totalxor;

architecture Behavioral of totalxor is
component cipherram
    Port ( 
        clk      : in  std_logic;
        rst      : in  std_logic;
        ena      : in  std_logic;
        we       : in  std_logic_vector(0 downto 0);   
        addr     : in  std_logic_vector(3 downto 0);
        din      : in  std_logic_vector(7 downto 0);
        dout     : out std_logic_vector(7 downto 0)
    );
    end component;
component keysrom
Port ( clk      : in  std_logic;
           ena      : in  std_logic;  -- enable signal that basically enables memory for read/write   
           addr     : in  std_logic_vector(7 downto 0); -- Address for accessing BRAM -- Data to write into BRAM
           dout     : out std_logic_vector(7 downto 0)  -- Data read from BRAM
         );
end component;
type state_type is (IDLE, READ_SETUP, READ_DATA, WRITE_FIRST,WRITE_FHALF, WRITE_SECOND, DONE_STATE);
    signal state : state_type := IDLE;
    
    signal addr_cnt    : unsigned(3 downto 0);           -- Address counter
    signal ram_en      : std_logic;                      -- RAM enable
    signal ram_we      : std_logic_vector(0 downto 0);   -- RAM write enable
    signal ram_addr    : std_logic_vector(3 downto 0);   -- RAM address
    signal ram_din     : std_logic_vector(7 downto 0);   -- RAM data input
    signal ram_dout    : std_logic_vector(7 downto 0);   -- RAM data output
    signal KEYS_en     : std_logic;                      -- SBOX enable
    signal KEYS_addr   : std_logic_vector(7 downto 0);   -- SBOX address
    signal KEYS_data   : std_logic_vector(7 downto 0);   -- SBOX data output
    signal temp_data   : std_logic_vector(7 downto 0);
    SIGNAL XOR_RESULT  : std_logic_vector(7 DOWNTO 0);
begin
ram_inst: cipherram
    port map (
        clk  => clk,
        rst  => rst,
        ena  => ram_en,
        we   => ram_we,
        addr => ram_addr,
        din  => ram_din,
        dout => ram_dout
    );

    -- Instantiate the SBOX component
    KEYS_inst: KEYSROM
    port map (
        clk  => clk,
        ena  => KEYS_en,
        addr => KEYS_addr,
        dout => KEYS_data
    );
    process(clk, rst)
    begin
        if rst = '1' then
            state <= IDLE;
            addr_cnt <= (others => '0');
            ram_en <= '0';
            ram_we <= "0";
            KEYS_en <= '0';
            done <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    if start = '1' then
                        state <= READ_SETUP;
                        ram_en <= '1';
                        ram_we <= "0";  -- Ensure write is disabled
                        KEYS_en <= '1';
                        addr_cnt <= (others => '0');
                        done <= '0';
                    end if;
               when READ_SETUP =>
                    -- Setup for reading from RAM
                    state <= READ_DATA;
               when READ_DATA =>
                    -- Wait for SBOX lookup to complete
                    -- SBOX data will be available on next clock cycle
                    state <= WRITE_FIRST;
                    ram_we <= "1"; 
                    finaloutput <= XOR_RESULT; -- Prepare for write
                    ram_din <= XOR_RESULT;
                when WRITE_FIRST =>
                    -- First cycle of write operation
                    state <= WRITE_FHALF;
                WHEN WRITE_FHALF =>
                    state <= WRITE_SECOND;
                when WRITE_SECOND =>
                    -- Second cycle of write operation
                    ram_we <= "0";  -- Disable write
                    
                    if addr_cnt = 15 then  -- Last address
                        state <= DONE_STATE;
                    else
                        addr_cnt <= addr_cnt + 1;
                        state <= READ_SETUP;  -- Go back to read next address
                    end if;

                when DONE_STATE =>
                    done <= '1';
                    ram_en <= '0';
                    KEYS_en <= '0';
                    if start = '0' then  -- Wait for start to go low before returning to IDLE
                        state <= IDLE;
                    end if;
            end case;
        end if;
    end process;
               
ram_addr <= std_logic_vector(addr_cnt);
KEYS_ADDR <= std_logic_vector(to_unsigned((16 * ROUND) + to_integer(unsigned(ADDR_CNT)), KEYS_ADDR'length));
XOR_RESULT <= RAM_DOUT XOR KEYS_DATA;
end Behavioral;

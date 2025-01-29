----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/09/2024 04:02:45 PM
-- Design Name: 
-- Module Name: totalsboxinv - Behavioral
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

entity cipher_operation is
    Port ( 
        clk      : in  std_logic;
        rst      : in  std_logic;
        start    : in  std_logic;                     -- Start signal to begin operation
        done     : out std_logic;                     -- Done signal when all operations complete
        addr_OUT : out std_logic_vector(3 downto 0);
        FINALOUTPUT : OUT std_logic_vector(7 DOWNTO 0);
        temp_data : out std_logic_vector(7 downto 0)   -- Current address being processed
    );
end cipher_operation;

architecture Behavioral of cipher_operation is
    -- Component declaration for cipherram
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

    -- Component declaration for sboxinv ROM
    component sboxROM
    Port ( 
        clk      : in  std_logic;
        ena      : in  std_logic;
        addr     : in  std_logic_vector(7 downto 0);
        dout    : out std_logic_vector(7 downto 0)
    );
    end component;

    -- State machine definition
    type state_type is (IDLE, READ_SETUP, READ_DATA, SBOX_LOOKUP_SETUP_1,SBOX_LOOKUP, WRITE_FIRST,WRITE_FHALF,WRITE_FFHALF, WRITE_SECOND, DONE_STATE);
    signal state : state_type := IDLE;

    -- Internal signals
    signal addr_cnt    : unsigned(3 downto 0);           -- Address counter
    signal ram_en      : std_logic;                      -- RAM enable
    signal ram_we      : std_logic_vector(0 downto 0);   -- RAM write enable
    signal ram_addr    : std_logic_vector(3 downto 0);   -- RAM address
    signal ram_din     : std_logic_vector(7 downto 0);   -- RAM data input
    signal ram_dout    : std_logic_vector(7 downto 0);   -- RAM data output
    signal sbox_en     : std_logic;                      -- SBOX enable
    signal sbox_addr   : std_logic_vector(7 downto 0);   -- SBOX address
    signal sbox_data   : std_logic_vector(7 downto 0);   -- SBOX data output  -- Temporary data storage

begin
    -- Instantiate the RAM component
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
    sbox_inst: sboxROM
    port map (
        clk  => clk,
        ena  => sbox_en,
        addr => sbox_addr,
        dout => sbox_data
    );

    -- Main process for state machine and control
    process(clk, rst)
    begin
        if rst = '1' then
            state <= IDLE;
            addr_cnt <= (others => '0');
            ram_en <= '0';
            ram_we <= "0";
            sbox_en <= '0';
            done <= '0';
            
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    if start = '1' then
                        state <= READ_SETUP;
                        ram_en <= '1';
                        ram_we <= "0";  -- Ensure write is disabled
                        sbox_en <= '1';
                        addr_cnt <= (others => '0');
                        done <= '0';
                    end if;

                when READ_SETUP =>
                    -- Setup for reading from RAM
                    state <= READ_DATA;

                when READ_DATA =>
                    -- Data is now available on ram_dout
                    temp_data <= ram_dout;  -- Store the read data
                    sbox_addr <= ram_dout;  -- Use RAM output as SBOX address
                    state <= SBOX_LOOKUP_SETUP_1;
                when SBOX_LOOKUP_SETUP_1 =>
                    STATE <= SBOX_LOOKUP;
                when SBOX_LOOKUP =>
                    -- Wait for SBOX lookup to complete
                    -- SBOX data will be available on next clock cycle
                    state <= WRITE_FIRST;
                    ram_we <= "1"; 
                    finaloutput <= sbox_data; -- Prepare for write
                    ram_din <= sbox_data;  -- Use SBOX output as RAM input

                when WRITE_FIRST =>
                    -- First cycle of write operation
                    state <= WRITE_FHALF;
                WHEN WRITE_FHALF =>
                    state <= WRITE_FFHALF;
                WHEN WRITE_FFHALF =>
                    STATE <= WRITE_SECOND;
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
                    sbox_en <= '0';
                    if start = '0' then  -- Wait for start to go low before returning to IDLE
                        state <= IDLE;
                    end if;
            end case;
        end if;
    end process;

    -- Continuous assignments
    ram_addr <= std_logic_vector(addr_cnt);
    addr_OUT <= ram_addr;

end Behavioral;




-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2024 04:56:01 PM
-- Design Name: 
-- Module Name: aestb - Behavioral
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

entity aes_decryption_tb is
end aes_decryption_tb;

architecture Behavioral of aes_decryption_tb is

    -- Component declaration for the DUT (aes_decryption)
    component aes_decryption is
        Port (
            clk             : in  STD_LOGIC;
            anodes          : out STD_LOGIC_VECTOR(3 downto 0);
            cathodes        : out STD_LOGIC_VECTOR(6 downto 0);
            ram_addr_out    : out STD_LOGIC_VECTOR(3 downto 0);
            ram_data_out    : out STD_LOGIC_VECTOR(7 downto 0);
            decryption_done_1 : out std_logic
        );
    end component;

    -- Test bench signals
    signal clk_tb             : std_logic := '0';
    signal anodes_tb          : std_logic_vector(3 downto 0);
    signal cathodes_tb        : std_logic_vector(6 downto 0);
    signal ram_addr_tb        : std_logic_vector(3 downto 0);
    signal ram_data_tb        : std_logic_vector(7 downto 0);
    signal decryption_done_tb : std_logic;

    -- Clock period definition
    constant clk_period : time := 20 ns;

    -- Variables for test data
    type data_array is array (0 to 15) of std_logic_vector(7 downto 0);
    -- Expected plaintext after decryption (modify this to match your expected data)
    constant expected_plaintext : data_array := (
        x"32", x"88", x"31", x"E0",
        x"43", x"5A", x"31", x"37",
        x"F6", x"30", x"98", x"07",
        x"A8", x"8D", x"A2", x"34"
    );
    signal decrypted_data : data_array := (others => (others => '0'));

begin

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk_tb <= '0';
            wait for clk_period / 2;
            clk_tb <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Instantiate the DUT (aes_decryption)
    DUT: aes_decryption
        Port map (
            clk             => clk_tb,
            anodes          => anodes_tb,
            cathodes        => cathodes_tb,
            ram_addr_out    => ram_addr_tb,
            ram_data_out    => ram_data_tb,
            decryption_done_1 => decryption_done_tb
        );

    -- Stimulus process
    stimulus_process: process
        variable addr_index : integer := 0;
    begin
        -- Wait for the decryption to complete
        wait until decryption_done_tb = '1';
        wait for clk_period;  -- Ensure all signals are stable

        -- Read the decrypted data from RAM
        for addr_index in 0 to 15 loop
            -- Set the RAM address
            ram_addr_tb <= std_logic_vector(to_unsigned(addr_index, 4));
            wait for clk_period;

            -- Capture the data
            decrypted_data(addr_index) <= ram_data_tb;

            wait for clk_period;
        end loop;

        -- Verify the decrypted data matches the expected plaintext
--        for addr_index in 0 to 15 loop
--            assert decrypted_data(addr_index) = expected_plaintext(addr_index)
--                report "Mismatch at address " & integer'image(addr_index)
--                & ": expected " & std_logic_vector'image(expected_plaintext(addr_index))
--                & ", got " & std_logic_vector'image(decrypted_data(addr_index))
--                severity error;
--        end loop;

--        report "Decryption verified successfully." severity note;

        -- Finish simulation
        wait;
    end process;

end Behavioral;
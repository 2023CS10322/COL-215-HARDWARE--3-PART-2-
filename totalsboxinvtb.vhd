----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/09/2024 05:10:07 PM
-- Design Name: 
-- Module Name: totalsboxinvtb - Behavioral
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

entity cipher_operation_tb is
end cipher_operation_tb;

architecture Behavioral of cipher_operation_tb is
    component cipher_operation is
        Port ( 
            clk      : in  std_logic;
            rst      : in  std_logic;
            start    : in  std_logic;
            done     : out std_logic;
            addr_OUT : out std_logic_vector(3 downto 0);
            finaloutput : out std_logic_vector(7 downto 0);
            temp_data : out std_logic_vector(7 downto 0)
        );
    end component;
    
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;
    
    -- Test bench signals
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal start    : std_logic := '0';
    signal done     : std_logic;
    signal addr_OUT : std_logic_vector(3 downto 0);
    signal finaloutput : std_logic_vector(7 downto 0);
    -- Simulation control
    signal sim_done : boolean := false;
    signal temp_data : std_logic_vector(7 downto 0);
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: cipher_operation 
    port map (
        clk      => clk,
        rst      => rst,
        start    => start,
        done     => done,
        addr_OUT => addr_OUT,
        finaloutput => finaloutput,
        temp_data => temp_data
    );

    -- Clock generation process
    clk_process: process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initial reset
        rst <= '1';
        wait for CLK_PERIOD * 2;
        rst <= '0';
        wait for CLK_PERIOD * 2;

        -- Test Case 1: Normal operation
        start <= '1';
        -- Wait for operation to complete
        wait until done = '1';
        wait for CLK_PERIOD * 2;
        start <= '0';
        
        -- Test Case 2: Reset during operation
        wait for CLK_PERIOD * 5;
        start <= '1';
        wait for CLK_PERIOD * 5;  -- Wait for a few operations
        rst <= '1';    -- Assert reset mid-operation
        wait for CLK_PERIOD * 2;
        rst <= '0';
        start <= '0';
        
        -- Test Case 3: Quick start-stop test
        wait for CLK_PERIOD * 5;
        start <= '1';
        wait for CLK_PERIOD * 3;
        start <= '0';
        wait until done = '1';
        
        -- End simulation
        wait for CLK_PERIOD * 10;
        sim_done <= true;
        wait;
    end process;

    -- Monitor process
    monitor_proc: process
        variable last_addr : std_logic_vector(3 downto 0) := (others => '0');
    begin
        wait until rising_edge(clk);
        
        if rst = '1' then
            report "Reset asserted";
        end if;
        
        if start = '1' then
            report "Starting cipher operation";
        end if;
        
        if done = '1' then
            report "Cipher operation completed";
        end if;
        
        -- Monitor address changes
        if last_addr /= addr_OUT then
            report "Processing Address: " & integer'image(to_integer(unsigned(addr_OUT)));
        end if;
        last_addr := addr_OUT;
        
        if sim_done then
            wait;
        end if;
    end process;

end Behavioral;



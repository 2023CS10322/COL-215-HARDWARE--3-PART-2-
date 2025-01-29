----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/09/2024 10:31:59 PM
-- Design Name: 
-- Module Name: readtest_tb - Behavioral
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

entity readtest_tb is
end readtest_tb;

architecture Behavioral of readtest_tb is
    -- Component declaration for the Unit Under Test (UUT)
    component readtest is
        Port ( 
            clk      : in  std_logic;
            rst      : in  std_logic;
            start    : in  std_logic;
            done     : out std_logic;
            data_out : out std_logic_vector(7 downto 0);
            addr_OUT : out std_logic_vector(3 downto 0)
        );
    end component;
    
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;
    
    -- Test bench signals
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal start    : std_logic := '0';
    signal done     : std_logic;
    signal data_out : std_logic_vector(7 downto 0);
    signal addr_OUT : std_logic_vector(3 downto 0);
    
    -- Signal to end simulation
    signal sim_done : boolean := false;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: readtest 
    port map (
        clk      => clk,
        rst      => rst,
        start    => start,
        done     => done,
        data_out => data_out,
        addr_OUT => addr_OUT
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
        wait for CLK_PERIOD;

        -- Test Case 1: Normal read operation
        wait for CLK_PERIOD * 2;
        start <= '1';  -- Begin reading operation
        
        -- Wait for done signal
        wait until done = '1';
        wait for CLK_PERIOD * 2;
        start <= '0';  -- Clear start signal
        
        -- Test Case 2: Reset during operation
        wait for CLK_PERIOD * 5;
        start <= '1';
        wait for CLK_PERIOD * 3;
        rst <= '1';    -- Assert reset mid-operation
        wait for CLK_PERIOD * 2;
        rst <= '0';
        start <= '0';
        
        -- Test Case 3: Quick start-stop test
        wait for CLK_PERIOD * 5;
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        wait until done = '1';
        
        -- End simulation
        wait for CLK_PERIOD * 10;
        sim_done <= true;
        wait;
    end process;

    -- Monitor process to display results
    monitor_proc: process
    begin
        wait until rising_edge(clk);
        if rst = '1' then
            report "Reset asserted";
        end if;
        
        if start = '1' then
            report "Starting read operation";
        end if;
        
        if done = '1' then
            report "Read operation completed";
        end if;
        
        -- Monitor address and data changes
        if rising_edge(clk) then
            report "Address: " & integer'image(to_integer(unsigned(addr_OUT))) & 
                   " Data: " & integer'image(to_integer(unsigned(data_out)));
        end if;
        
        if sim_done then
            wait;
        end if;
    end process;

end Behavioral;


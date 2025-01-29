----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2024 09:38:29 AM
-- Design Name: 
-- Module Name: TOTALXORTB - Behavioral
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

entity totalxor_tb is
end totalxor_tb;

architecture Behavioral of totalxor_tb is

    -- Component declaration for totalxor
    component totalxor
        Port (
            clk         : in  std_logic;
            rst         : in  std_logic;
            start       : in  std_logic;
            round       : in  integer;
            done        : out std_logic;
            addr_OUT    : out std_logic_vector(3 downto 0);
            FINALOUTPUT : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Signals for connecting to the totalxor instance
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal start       : std_logic := '0';
    signal round       : integer := 0;
    signal done        : std_logic;
    signal addr_OUT    : std_logic_vector(3 downto 0);
    signal FINALOUTPUT : std_logic_vector(7 downto 0);

    -- Clock period constant
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: totalxor
        Port map (
            clk         => clk,
            rst         => rst,
            start       => start,
            round       => round,
            done        => done,
            addr_OUT    => addr_OUT,
            FINALOUTPUT => FINALOUTPUT
        );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize signals
        rst <= '1';
        start <= '0';
        wait for 20 ns;
        
        -- Release reset and start the operation
        rst <= '0';
        start <= '1';
        
        -- Wait for some cycles to allow the process to complete
        wait for 200 ns;

        -- Monitor output by stopping `start`
        start <= '0';

        -- Wait until the operation is done
        wait until done = '1';

        -- Check the final output
        wait for 10 ns;

        -- Stop the simulation
        wait;
    end process;

end Behavioral;



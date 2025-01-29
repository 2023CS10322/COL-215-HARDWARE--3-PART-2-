----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2024 11:22:49 AM
-- Design Name: 
-- Module Name: fsm - Behavioral
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

entity FSM is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        start     : in  STD_LOGIC;
        round_num : out integer range 0 to 9;
        done      : out STD_LOGIC;
        operation : out integer range 0 to 4
    );
end FSM;

architecture Behavioral of FSM is
    signal round_number : integer range 0 to 9 := 0;
    signal operation_num : integer range 0 to 4 := 0;
    signal is_done : STD_LOGIC := '0';

begin
    operation <= operation_num;
    round_num <= round_number;
    done <= is_done;

    process(clk, reset)
    begin
        if reset = '1' then
            round_number <= 0;
            operation_num <= 0;
            is_done <= '0';
        elsif rising_edge(clk) and (start = '1') then
            if round_number =0 then
                case operation_num is
                    when 0 =>
                        operation_num <= 1;
                    when 1 =>
                        operation_num <= 3;
                    when 3 =>
                        operation_num <= 4;
                    when others =>
                        operation_num <= 0;
                        round_number <= round_number + 1;
                end case;
            elsif (round_number > 0) and (round_number < 9) then
                case operation_num is
                    when 0 =>
                        operation_num <= 1;
                    when 4 =>
                        operation_num <= 0;
                        round_number <= round_number + 1;
                    when others =>
                        operation_num <= operation_num + 1;
                end case;
            elsif round_number = 9 then
                if operation_num = 0 then
                    operation_num <= 1;
                elsif operation_num = 1 then
                    is_done <= '1';
                    operation_num <= 0;
                end if;
            end if;
        end if;
    end process;
end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/10/2024 11:09:24 AM
-- Design Name: 
-- Module Name: compute - Behavioral
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

entity aes_decryption is
    Port (
        clk       : in  STD_LOGIC;
        anodes    : out STD_LOGIC_VECTOR(3 downto 0);
        cathodes  : out STD_LOGIC_VECTOR(6 downto 0);
        ram_addr_out  : out STD_LOGIC_VECTOR(3 downto 0);  -- Exposed RAM address
        ram_data_out  : out STD_LOGIC_VECTOR(7 downto 0);  -- Exposed RAM data output
        decryption_done_1 : out std_logic
    );
end aes_decryption;

architecture Behavioral of aes_decryption is

    component xor_gate
        Port (
            var1 : in STD_LOGIC_VECTOR(7 downto 0);
            var2 : in STD_LOGIC_VECTOR(7 downto 0);
            result : out  STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component InverseMixColumns is
        Port (
            input_invmix : in STD_LOGIC_VECTOR(31 downto 0);
            output_invmix : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component Inv_sub_byte is
        Port (
            clk : in  STD_LOGIC;
            input_subbyte : in STD_LOGIC_VECTOR(7 downto 0);
            output_subbyte : out  STD_LOGIC_VECTOR(7 downto 0)
        );

    end component;

    component Row_Shift is
        Port (
            input_rowshift : in  STD_LOGIC_VECTOR(31 downto 0);
            tempo: in STD_LOGIC_VECTOR(1 downto 0);
            output_rowshift : out  STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    component display is
        Port(
            clk_in: in STD_LOGIC;
            input_row_d: in STD_LOGIC_VECTOR(31 downto 0);
            anode: out STD_LOGIC_VECTOR(3 downto 0);
            finalout: out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    component encrypted_text_ram
        Port (
            clka  : in  std_logic;
            wea   : in  std_logic_vector(0 downto 0);
            addra : in  std_logic_vector(3 downto 0);
            dina  : in  std_logic_vector(7 downto 0);
            douta : out std_logic_vector(7 downto 0)
        );
    end component;

    component round_keys_rom
        Port(
            clka : in  std_logic;
            addra : in  std_logic_vector(7 downto 0);
            douta : out std_logic_vector(7 downto 0)
        );
    end component;

    component encrypted_text_rom
        Port(
            clka : in  std_logic;
            addra : in  std_logic_vector(3 downto 0);
            douta : out std_logic_vector(7 downto 0)
        );
    end component;

    component FSM
        Port(
            clk       : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            start     : in  STD_LOGIC;
            round_num : out integer range 0 to 9;
            done      : out STD_LOGIC;
            operation : out integer range 0 to 4
        );
    end component;
    signal round_number : integer range 0 to 9 := 0;
    signal addr_keys      : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal var1           : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal var2           : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal result         : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal input_subbyte  : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal output_subbyte : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
signal dina           : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
signal douta_ram      : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
signal douta_keys     : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
signal douta_text     : STD_LOGIC_VECTOR(7 downto 0) := "00000000";

    signal input_row_d_temp  : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal input_rowshift    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal output_rowshift   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal input_row_d       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal output_invmix     : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal input_invmix      : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal start, done             : std_logic := '0';
signal decryption_done          : std_logic := '0';
signal reset_FSM                : std_logic := '0';
signal processing               : integer range 0 to 4 := 0;
signal processing2              : integer range 0 to 11 := 0;
signal operation                : integer range 0 to 4 := 0;
signal finalout                 : STD_LOGIC_VECTOR(6 downto 0) := "0000000";
signal input_row_temp           : std_logic_vector(31 downto 0) := (others => '0');
signal input_col_temp           : std_logic_vector(31 downto 0) := (others => '0');
signal tempo                    : STD_LOGIC_VECTOR(1 downto 0) := "00";
signal wea                      : STD_LOGIC_VECTOR(0 downto 0) := "0";
signal anode, addra_ram, addr_text : STD_LOGIC_VECTOR(3 downto 0) := "0000";

begin
    xor_inst : xor_gate port map (
        var1 => var1,
        var2 => var2,
        result => result
    );

    InvMixColumns: InverseMixColumns port map (
        input_invmix => input_invmix, -----column------
        output_invmix => output_invmix
    );

    InvSubBytes: Inv_sub_byte port map (
        clk => clk,
        input_subbyte => input_subbyte,
        output_subbyte => output_subbyte
    );

    RowShift: Row_Shift port map (
        input_rowshift => input_rowshift,
        tempo => tempo,
        output_rowshift => output_rowshift
    );

    display_inst: display port map (
        clk_in => clk,
        input_row_d => input_row_d,
        anode => anode,
        finalout => finalout
    );

    round_keys_rom_inst: round_keys_rom port map (
        clka => clk,
        addra => addr_keys,
        douta => douta_keys
    );

    encrypted_text_ram_inst: encrypted_text_ram port map (
        clka => clk,
        wea => wea,
        addra => addra_ram,
        dina => dina,
        douta => douta_ram
    );

    encrypted_text_rom_inst: encrypted_text_rom port map (
        clka => clk,
        addra => addr_text,
        douta => douta_text
    );

    FSM_inst: FSM port map (
        clk => clk,
        reset => reset_FSM,
        start => start,
        round_num => round_number,
        done => done,
        operation => operation
    );
    process(clk)
        variable pos: integer range 0 to 16 := 0;
        variable i, j, k: integer range 0 to 3 := 0;
        variable counter, delay_counter : integer := 0;
    begin
        if rising_edge(clk) then
            case operation is
                when 0 =>
                    if round_number = 0 then
                        if pos = 16 then
                            start <= '1';
                            pos := 0;
                            processing <= 0;
                        elsif processing = 0 then
                            wea <= "0";
                            addr_text <= std_logic_vector(to_unsigned(pos, 4));
                            processing <= 1;
                        elsif processing = 1 then
                            processing <= 2;
                        elsif processing = 2 then
                            wea <= "1";
                            addra_ram <= std_logic_vector(to_unsigned(pos, 4));
                            dina <= douta_text;
                            processing <= 3;
                        elsif processing = 3 then
                            processing <= 4;
                        elsif processing = 4 then
                            pos := pos + 1;
                            processing <= 0;
                        end if;
                    else
                        start <= '1';
                    end if;
                        

                when 1 =>
                    if pos = 16 then
                        if round_number < 9 then
                            start <= '1';
                        end if;
                        pos := 0;
                        processing <= 0;
                    elsif processing = 0 then
                        addr_keys <= std_logic_vector(to_unsigned(16*(9 - round_number) + pos , 4));
                        wea <= "0";
                        addra_ram <= std_logic_vector(to_unsigned(pos, 4));
                        processing <= 1;
                    elsif processing = 1 then
                        var1 <= douta_keys;
                        var2 <= douta_ram;
                        wea <= "1";
                        addra_ram <= std_logic_vector(to_unsigned(pos, 4));
                        dina <= result;
                        processing <= 2;
                    elsif processing = 2 then
                        processing <= 3;
                    elsif processing = 3 then
                        pos := pos + 1;
                        processing <= 0;
                    end if;

                when 2 =>
                    if processing2 = 0 then
                        wea <= "0";
                        addra_ram <= std_logic_vector(to_unsigned(4*i + j, 4));
                        processing2 <= 1;
                    elsif processing2 = 1 then
                        input_col_temp(31 - 8*k downto 24 - 8*k) <= douta_ram;
                        i := i + 1;
                        addra_ram <= std_logic_vector(to_unsigned(4*i + j, 4));
                        processing2 <= 2;
                    elsif processing2 = 2 then
                        k := k + 1;
                        input_col_temp(31 - 8*k downto 24 - 8*k) <= douta_ram;
                        i := i + 1;
                        addra_ram <= std_logic_vector(to_unsigned(4*i + j, 4));
                        processing2 <= 3;
                    elsif processing2 = 3 then
                        k := k + 1;
                        input_col_temp(31 - 8*k downto 24 - 8*k) <= douta_ram;
                        i := i + 1;
                        addra_ram <= std_logic_vector(to_unsigned(4*i + j, 4));
                        processing2 <= 4;
                    elsif processing2 = 4 then
                        k := k + 1;
                        input_col_temp(31 - 8*k downto 24 - 8*k) <= douta_ram;
                        i := 0;
                        input_invmix <= input_col_temp;
                        wea <= "1";
                        addra_ram <= std_logic_vector(to_unsigned(4*i + j, 4));
                        dina <= input_invmix(31 - 8*i downto 24 - 8*i);
                        processing2 <= 5;
                    elsif processing2 = 5 then
                        processing2 <= 6;
                    elsif processing2 = 6 then
                        wea <= "1";
                        i := i + 1;
                        addra_ram <= std_logic_vector(to_unsigned(4*i + j, 4));
                        dina <= input_invmix(31 - 8*i downto 24 - 8*i);
                        processing2 <= 7;
                    elsif processing2 = 7 then
                        processing2 <= 8;
                    elsif processing2 = 8 then
                        wea <= "1";
                        i := i + 1;
                        addra_ram <= std_logic_vector(to_unsigned(4*i + j, 4));
                        dina <= input_invmix(31 - 8*i downto 24 - 8*i);
                        processing2 <= 9;
                    elsif processing2 = 9 then
                        processing2 <= 10;
                    elsif processing2 = 10 then
                        wea <= "1";
                        i := i + 1;
                        addra_ram <= std_logic_vector(to_unsigned(4*i + j, 4));
                        dina <= input_invmix(31 - 8*i downto 24 - 8*i);
                        processing2 <= 11;
                    elsif processing2 = 11 then
                        wea <= "0";
                        processing2 <= 0;
                        i := 0;
                        k := 0;
                        if j = 3 then
                            j := 0;
                            start <= '1';
                        else
                            j := j + 1;
                        end if;
                    end if;

                when 3 =>
                    if processing2 = 0 then
                        wea <= "0";
                        addra_ram <= std_logic_vector(to_unsigned(4*i + j, 4));
                        processing2 <= 1;
                    elsif processing2 = 1 then
                        input_row_temp(31 - 8*k downto 24 - 8*k) <= douta_ram;
                        j := j + 1;
                        addra_ram <= std_logic_vector(to_unsigned(4*i + j, 4));
                        processing2 <= 2;
                    elsif processing2 = 2 then
                        k := k + 1;
                        input_row_temp(31 - 8*k downto 24 - 8*k) <= douta_ram;
                        j := j + 1;
                        addra_ram <= std_logic_vector(to_unsigned(4*i + j, 4));
                        processing2 <= 3;
                    elsif processing2 = 3 then
                        k := k + 1;
                        input_row_temp(31 - 8*k downto 24 - 8*k) <= douta_ram;
                        j := j + 1;
                        addra_ram <= std_logic_vector(to_unsigned(4*i + j, 4));
                        processing2 <= 4;
                    elsif processing2 = 4 then
                        k := k + 1;
                        input_row_temp(31 - 8*k downto 24 - 8*k) <= douta_ram;
                        j := 0;
                        tempo <= std_logic_vector(to_unsigned(i, 2));
                        input_rowshift <= input_row_temp;
                        wea <= "1";
                        addra_ram <= std_logic_vector(to_unsigned(4*i + j, 4));
                        dina <= input_invmix(31 - 8*j downto 24 - 8*j);
                        processing2 <= 5;
                    elsif processing2 = 5 then
                        processing2 <= 6;
                    elsif processing2 = 6 then
                        wea <= "1";
                        j := j + 1;
                        addra_ram <= std_logic_vector(to_unsigned(4*i + j, 4));
                        dina <= input_invmix(31 - 8*j downto 24 - 8*j);
                        processing2 <= 7;
                    elsif processing2 = 7 then
                        processing2 <= 8;
                    elsif processing2 = 8 then
                        wea <= "1";
                        j := j + 1;
                        addra_ram <= std_logic_vector(to_unsigned(4*i + j, 4));
                        dina <= input_invmix(31 - 8*j downto 24 - 8*j);
                        processing2 <= 9;
                    elsif processing2 = 9 then
                        processing2 <= 10;
                    elsif processing2 = 10 then
                        wea <= "1";
                        j := j + 1;
                        addra_ram <= std_logic_vector(to_unsigned(4*i + j, 4));
                        dina <= input_invmix(31 - 8*j downto 24 - 8*j);
                        processing2 <= 11;
                    elsif processing2 = 11 then
                        wea <= "0";
                        processing2 <= 0;
                        j := 0;
                        k := 0;
                        if i = 3 then
                            i := 0;
                            start <= '1';
                        else
                            i := i + 1;
                        end if;
                    end if;

                when 4 =>
                    if pos = 16 then
                        start <= '1';
                        pos := 0;
                        processing <= 0;
                    elsif processing = 0 then
                        wea <= "0";
                        addra_ram <= std_logic_vector(to_unsigned(pos , 4));
                        processing <= 1;
                    elsif processing = 1 then
                        input_subbyte <= douta_ram;
                        processing <= 2;
                    elsif processing = 2 then
                        wea <= "1";
                        addra_ram <= std_logic_vector(to_unsigned(pos, 4));
                        dina <= output_subbyte;
                        processing <= 3;
                    elsif processing = 3 then
                        processing <= 4;
                    elsif processing = 4 then
                        pos := pos + 1;
                        processing <= 0;
                    end if;
            end case;
        elsif falling_edge(clk) then
            start <= '0';
        end if;
    end process;
    ram_addr_out <= addra_ram;
ram_data_out <= douta_ram;
decryption_done_1 <= done;

    -- for displaying the text
--    process(clk)
--        variable delay_counter : integer := 0;
--        variable delay_cycles : integer := 100000000;
--        variable i, j, k: integer range 0 to 3 := 0;
--    begin
--        if rising_edge(clk) and done = '1' then
--            wea <= "0";
--            if delay_counter = 0 then
--                addra_ram <= std_logic_vector(to_unsigned(4 * i + j, 4));
--                delay_counter := delay_counter + 1;
--            elsif delay_counter = 1 then
--                input_row_d_temp(31 - 8 * k downto 24 - 8 * k) <= douta_ram;
--                j := j + 1;
--                addra_ram <= std_logic_vector(to_unsigned(4 * i + j, 4));
--                delay_counter := delay_counter + 1;
--            elsif delay_counter = 2 then
--                k := k + 1;
--                input_row_d_temp(31 - 8 * k downto 24 - 8 * k) <= douta_ram;
--                j := j + 1;
--                addra_ram <= std_logic_vector(to_unsigned(4 * i + j, 4));
--                delay_counter := delay_counter + 1;
--            elsif delay_counter = 3 then
--                k := k + 1;
--                input_row_d_temp(31 - 8 * k downto 24 - 8 * k) <= douta_ram;
--                j := j + 1;
--                addra_ram <= std_logic_vector(to_unsigned(4 * i + j, 4));
--                delay_counter := delay_counter + 1;
--            elsif delay_counter = 4 then
--                k := k + 1;
--                input_row_d_temp(31 - 8 * k downto 24 - 8 * k) <= douta_ram;
--                delay_counter := delay_counter + 1;
--            elsif delay_counter = 5 then
--                    input_row_d <= input_row_d_temp;
--                    anodes <= anode;
--                    cathodes <= finalout;
--                    delay_counter := delay_counter + 1;
--            elsif delay_counter = delay_cycles then
--                    delay_counter := 0;
--                    if i = 3 then
--                        i:= 0;
--                    else
--                        i := i + 1;
--                    end if;
--                    j := 0;
--                    k := 0;
--            else
--                delay_counter := delay_counter + 1;
--            end if;
--        end if;
--    end process;
end Behavioral;



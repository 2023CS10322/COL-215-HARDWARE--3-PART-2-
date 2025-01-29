library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
entity InverseMixColumns is
   Port (
       input_invmix : in STD_LOGIC_VECTOR(31 downto 0);
       output_invmix : out STD_LOGIC_VECTOR(31 downto 0) 
   );
end InverseMixColumns;

architecture Behavioral of InverseMixColumns is
    type row is array (0 to 3) of std_logic_vector(7 downto 0);
    type matrix is array (0 to 3) of row;
    constant MULT_MATRIX : matrix := (
        (x"0E", x"0B", x"0D", x"09"), 
        (x"09", x"0E", x"0B", x"0D"), 
        (x"0D", x"09", x"0E", x"0B"), 
        (x"0B", x"0D", x"09", x"0E")  
    );
    signal ans :  std_logic_vector(31 downto 0);
    function m2(a: STD_LOGIC_VECTOR(7 downto 0)) return STD_LOGIC_VECTOR is
        variable result: STD_LOGIC_VECTOR(7 downto 0);
    begin
        if a(7) = '1' then 
            result := (a(6 downto 0) & '0') xor "00011011";
        else
            result := a(6 downto 0) & '0';
        end if;
        return result;
    end m2;
    
    function valueoutput(p: STD_LOGIC_VECTOR(7 downto 0); q: STD_LOGIC_VECTOR(7 downto 0))
     return STD_LOGIC_VECTOR is
     
variable product : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    begin
        if p=x"09" then 
            product:= q xor (m2(m2(m2(q))));
        elsif p=x"0E" then 
            product:= m2(q xor m2(q xor (m2(q))));
        elsif p=x"0D" then 
            product:= q xor m2(m2(q xor (m2(q))));
        elsif p=x"0B" then 
            product:= q xor m2(q xor (m2(m2(q))));
        
        end if;
        return product;
    end valueoutput;

begin
    process(input_invmix)
        variable temp : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
        variable row_idx: integer := 0;
        begin
        	temp:= "00000000";
        	row_idx := 0;
            for row_idx in 0 to 3 loop
            for i in 0 to 3 loop
                temp := temp xor valueoutput(MULT_MATRIX(row_idx)(3-i), input_invmix(8*i + 7 downto 8*i));
            end loop;
            ans(31-8*row_idx downto 24-8*row_idx) <=temp;
            end loop;
            output_invmix<=ans;
        end process;
end Behavioral;
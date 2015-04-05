-- -----------------------------------------------------------------------------
--
--  Title      :  Testbench for pad unit and shaicore project.
--             :
--             :  Antonis Spyropoulos
-- -----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
use WORK.types.all;

entity testbench is
end testbench;

architecture structure of  testbench is
   component clock
      generic (period : time := 80 ns);
      port (stop : in  std_logic;
            clk  : out std_logic := '0');
   end component;

   

   component pad
  
      port (clk    : in		std_logic;
	reset  : in 	std_logic;
	start  : in 	std_logic;
	 
	input  :  in std_logic_vector ( 511 downto 0);
	msg_length: in std_logic_vector (5 downto 0); --message size
	stop   : out	std_logic;
	message_sent: out bit_t;
	msg_rcv: in bit_t;
	W1 : out schedule_var; --32-bit length 20 depth 
	W2 : out schedule_var;
	W3 : out schedule_var;
	W4 : out schedule_var
	);          
   end component;
   
  component sha1core  
	port (clk: in bit_t;
		reset : in bit_t;
		message_sent: in bit_t;
		msg_rcv: out bit_t;
		W1 : in schedule_var; --32-bit length 20 depth 
		W2 : in schedule_var;
		W3 : in schedule_var;
		W4 : in schedule_var;
		
		HASH_VALUE: out std_logic_vector (159 downto 0 )
		);
		
end component;

	

   signal StopSimulation   : bit_t := '0';
   signal clk   : bit_t;
   signal reset : bit_t;
   signal message_sent : bit_t;
   signal msg_rcv : bit_t;
   signal start  : bit_t;
   signal stop : bit_t;
   --pad unit signals
   
   signal input : std_logic_vector(511 downto 0);
   signal msg_length: std_logic_vector(5 downto 0);
   signal W1 : schedule_var;
   signal W2 : schedule_var;
   signal W3 : schedule_var;
   signal W4 : schedule_var;
    
   signal HASH_VALUE : std_logic_vector(159 downto 0);
 
begin
   -- reset is active-low
   reset <= '1', '0' after 80 ns;

   -- start logic
   start_logic : process is
   begin
      start <= '0';

      wait until reset = '0' and clk'event and clk = '1';
      start <= '1';
	  
	  --Message = "abc"in ascii 011000010110001001100011
	  
	  input(511 downto 488) <= "011000010110001001100011";
	  
	  input(487 downto 0) <= (others =>'0');
	  msg_length <= "000011";
		
		-- Expected output a9993e364706816aba3e25717850c26c9cd0d89d
		
		
      -- wait before accelerator is complete before deasserting the start
      wait until clk'event and clk = '1' and stop = '1';
      start <= '0';

      wait until clk'event and clk = '1';
      report "Message 1 padded" severity NOTE;
	  
	  
	  
      wait until start='0' and clk'event and clk = '1';
      start <= '1';
	  
	  -- --Message =  "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnop"in ascii --0110000101100010011000110110010001100010011000110110010001100101011000110110010001100101011001100110010001100101011001100110011101100101011001100110011101101000011001100110011101101000011010010110011101101000--0110100101101010011010000110100101101010011010110110100101101010011010110110110001101010011010110110110001101101011010110110110001101101011011100110110001101101011011100110111101101101011011100110111101110000--011011100110111101110000 440 bits
	  
	  input(511 downto 72) <= "01100001011000100110001101100100011000100110001101100100011001010110001101100100011001010110011001100100011001010110011001100111011001010110011001100111011010000110011001100111011010000110100101100111011010000110100101101010011010000110100101101010011010110110100101101010011010110110110001101010011010110110110001101101011010110110110001101101011011100110110001101101011011100110111101101101011011100110111101110000011011100110111101110000";
	  
	  input(71 downto 0) <= (others =>'0');
	  msg_length <= "110111"; --message length in characters

      -- expected output 47b172810795699fe739197d1a1f5960700242f1
	  
      wait until clk'event and clk = '1' and stop = '1';
      start <= '0';

      wait until clk'event and clk = '1';
      report "Message 2 padded" severity NOTE;
	  
	   wait until start='0' and clk'event and clk = '1';
      start <= '1';
	  
	  -- --Message =  "Hello World"in ascii 
	  --0100100001100101011011000110110001101111001000000101011101101111011100100110110001100100  88 bits
	  
	  input(511 downto 424) <= "0100100001100101011011000110110001101111001000000101011101101111011100100110110001100100";
	  
	  input(423 downto 0) <= (others =>'0');
	  msg_length <= "001011";

      -- expected output 0a4d55a8d778e5022fab701977c5d840bbc486d0
	  
      wait until clk'event and clk = '1' and stop = '1';
      start <= '0';

      wait until clk'event and clk = '1';
      report "Message 3 padded" severity NOTE;
      StopSimulation <= '0', '1' after 1 ms;
   end process;

   SysClk : clock
      port map (stop => StopSimulation,
                clk => clk);

   PADDING : pad
	 
		  port map (
				clk => clk,
				reset => reset,
				start  => start,
				 
				input  => input,
				msg_length => msg_length,
				message_sent=> message_sent,
				msg_rcv => msg_rcv,
				stop   => stop,
				W1 => W1,
				W2 => W2,
				W3 => W3,
				W4 => W4);

   
	Hashing : sha1core
	port  map(clk => clk,
		reset=> reset,
		message_sent=> message_sent,
		msg_rcv => msg_rcv,
		W1 =>W1, --32-bit length 20 depth 
		W2 =>W2,
		W3 =>W3,
		W4 => W4,
		
		HASH_VALUE => HASH_VALUE
		 
		);
					

end structure;



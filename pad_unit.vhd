-------------------------------------
--Padding unit for SHA-1 Hash function
--
--Antonis Spyropoulos 
-- s141707@student.dtu.dk
--January 2015
--Simplifying assumption is that the message is up to 55 characters or 440 bit
-- so it is split in one 512 - bit block
-- future work can be an expansion for accepting longer messages
-------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.types.ALL;

entity pad is



port (
	clk    : in		std_logic;
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
end pad;


Architecture behavior of pad is 


type state_type is (idle, pad1,pad2, create_words,create_16_21,create_22_27,create_28_33,create_34_39,create_40_45, create_46_51, create_52_57, create_58_63, create_64_69, create_70_75, create_76_79, output, fin);
signal state, next_state: state_type;
--input message register
signal M, M_next: std_logic_vector(511 downto 0);
--temp signals
signal temp1,temp2,temp3: word_t;

--Registers for W vectors
type W_array is array (0 to 79) of word_t;
signal W, W_next :W_array;

	
begin
padding:

process(start,M,  input, W, temp1,temp2,temp3,state, msg_rcv, msg_length)
 
	begin
	

	 
	stop <='0';
	next_state<=state;
	message_sent<='0';
	M_next <=M;
	temp1<=(others=>'0');
	temp2<=(others=>'0');
	temp3<=(others=>'0');
	W1 <=(others => (others=>'0'));
	W2 <=(others => (others=>'0'));
	W3 <=(others => (others=>'0'));
	W4 <=(others => (others=>'0'));
	W_next(0)<= W(0);
	W_next(1)<= W(1);
	W_next(2)<= W(2);
	W_next(3)<= W(3);
	W_next(4)<= W(4);
	W_next(5)<= W(5);
	W_next(6)<= W(6);
	W_next(7)<= W(7);
	W_next(8)<= W(8);
	W_next(9)<= W(9);
	W_next(10)<= W(10);
	W_next(11)<= W(11);
	W_next(12)<= W(12);
	W_next(13)<= W(13);
	W_next(14)<= W(14);
	W_next(15)<= W(15);
	W_next(16)<= W(16);
	W_next(17)<= W(17);
	W_next(18)<= W(18);
	W_next(19)<= W(19);
	W_next(20)<= W(20);
	W_next(21)<= W(21);
	W_next(22)<= W(22);
	W_next(23)<= W(23);
	W_next(24)<= W(24);
	W_next(25)<= W(25);
	W_next(26)<= W(26);
	W_next(27)<= W(27);
	W_next(28)<= W(28);
	W_next(29)<= W(29);
	W_next(30)<= W(30);
	W_next(31)<= W(31);
	W_next(32)<= W(32);
	W_next(33)<= W(33);
	W_next(34)<= W(34);
	W_next(35)<= W(35);
	W_next(36)<= W(36);
	W_next(37)<= W(37);
	W_next(38)<= W(38);
	W_next(39)<= W(39);
	W_next(40)<= W(40);
	W_next(41)<= W(41);
	W_next(42)<= W(42);
	W_next(43)<= W(43);
	W_next(44)<= W(44);
	W_next(45)<= W(45);
	W_next(46)<= W(46);
	W_next(47)<= W(47);
	W_next(48)<= W(48);
	W_next(49)<= W(49);
	W_next(50)<= W(50);
	W_next(51)<= W(51);
	W_next(52)<= W(52);
	W_next(53)<= W(53);
	W_next(54)<= W(54);
	W_next(55)<= W(55);
	W_next(56)<= W(56);
	W_next(57)<= W(57);
	W_next(58)<= W(58);
	W_next(59)<= W(59);
	W_next(60)<= W(60);
	W_next(61)<= W(61);
	W_next(62)<= W(62);
	W_next(63)<= W(63);
	W_next(64)<= W(64);
	W_next(65)<= W(65);
	W_next(66)<= W(66);
	W_next(67)<= W(67);
	W_next(68)<= W(68);
	W_next(69)<= W(69);
	W_next(70)<= W(70);
	W_next(71)<= W(71);
	W_next(72)<= W(72);
	W_next(73)<= W(73);
	W_next(74)<= W(74);
	W_next(75)<= W(75);
	W_next(76)<= W(76);
	W_next(77)<= W(77);
	W_next(78)<= W(78);
	W_next(79)<= W(79);
	
	
	case(state) is
	
		when idle =>
		--start parsing when are messages exist in the queue
			if start = '1' then
				
				M_next <= input; 
				next_state <= pad1;
				
			else
				next_state <=idle;
			end if;
			

		when pad1 =>
		
			M_next(511 - to_integer(unsigned(msg_length))*8) <='1';
		next_state<=pad2;
			
		when pad2 =>
		
			M_next(63 downto 0) <= std_logic_vector(to_unsigned(to_integer(unsigned(msg_length))*8,64));
			
			next_state<= create_words;
		
		when create_words=>
		
		 -- for i in 0 to 15 loop
		 -- W(i)_next <=M(511 downto 511-s-1);
		 -- s:=s+32;
		 -- end loop;
			W_next(0) <=M(511 downto 480);
			W_next(1) <=M(479 downto 448);
			W_next(2) <=M(447 downto 416);
			W_next(3) <=M(415 downto 384);
			W_next(4) <=M(383 downto 352);
			W_next(5) <=M(351 downto 320);
			W_next(6) <=M(319 downto 288);
			W_next(7) <=M(287 downto 256);
			W_next(8) <=M(255 downto 224);
			W_next(9) <=M(223 downto 192);
			W_next(10) <=M(191 downto 160);
			W_next(11) <=M(159 downto 128);
			W_next(12) <=M(127 downto 96);
			W_next(13) <=M(95 downto 64);
			W_next(14) <=M(63 downto 32);
			W_next(15) <=M(31 downto 0);
			
		  next_state <= create_16_21;
			
		when create_16_21 =>
			temp1 <= std_logic_vector(( unsigned(W(13)) xor unsigned(W(8)) xor unsigned(W(2)) xor unsigned(W(0)) ) rol 1 );
			temp2 <= std_logic_vector(( unsigned(W(14)) xor unsigned(W(9)) xor unsigned(W(3)) xor unsigned(W(1)) ) rol 1 );
			temp3 <= std_logic_vector(( unsigned(W(15)) xor unsigned(W(10)) xor unsigned(W(4)) xor unsigned(W(2)) ) rol 1 );
			
			W_next(16) <= temp1;
			W_next(17) <= temp2;
			W_next(18) <= temp3;
			
			W_next(19) <= std_logic_vector(( unsigned(temp1) xor unsigned(W(11)) xor unsigned(W(5)) xor unsigned(W(3)) ) rol 1 );
			W_next(20) <= std_logic_vector(( unsigned(temp2) xor unsigned(W(12)) xor unsigned(W(6)) xor unsigned(W(4)) ) rol 1 );
			W_next(21) <= std_logic_vector(( unsigned(temp3) xor unsigned(W(13)) xor unsigned(W(7)) xor unsigned(W(5)) ) rol 1 );

			next_state <= create_22_27;
			
		when create_22_27 =>
			temp1 <= std_logic_vector(( unsigned(W(19)) xor unsigned(W(14)) xor unsigned(W(8)) xor unsigned(W(6)) ) rol 1 );
			temp2 <= std_logic_vector(( unsigned(W(20)) xor unsigned(W(15)) xor unsigned(W(9)) xor unsigned(W(7)) ) rol 1 );
			temp3 <= std_logic_vector(( unsigned(W(21)) xor unsigned(W(16)) xor unsigned(W(10)) xor unsigned(W(8)) ) rol 1 );
			
			W_next(22) <= temp1;
			W_next(23) <= temp2;
			W_next(24) <= temp3;
			
			W_next(25) <= std_logic_vector(( unsigned(temp1) xor unsigned(W(17)) xor unsigned(W(11)) xor unsigned(W(9)) ) rol 1 );
			W_next(26) <= std_logic_vector(( unsigned(temp2) xor unsigned(W(18)) xor unsigned(W(12)) xor unsigned(W(10)) ) rol 1 );
			W_next(27) <= std_logic_vector(( unsigned(temp3) xor unsigned(W(19)) xor unsigned(W(13)) xor unsigned(W(11)) ) rol 1 );

			next_state <= create_28_33;
			
		when create_28_33 =>
		
			temp1 <= std_logic_vector(( unsigned(W(25)) xor unsigned(W(20)) xor unsigned(W(14)) xor unsigned(W(12)) ) rol 1 );
			temp2 <= std_logic_vector(( unsigned(W(26)) xor unsigned(W(21)) xor unsigned(W(15)) xor unsigned(W(13)) ) rol 1 );
			temp3 <= std_logic_vector(( unsigned(W(27)) xor unsigned(W(22)) xor unsigned(W(16)) xor unsigned(W(14)) ) rol 1 );
			
			W_next(28) <= temp1;
			W_next(29) <= temp2;
			W_next(30) <= temp3;
			
			W_next(31) <= std_logic_vector(( unsigned(temp1) xor unsigned(W(23)) xor unsigned(W(17)) xor unsigned(W(15)) ) rol 1 );
			W_next(32) <= std_logic_vector(( unsigned(temp2) xor unsigned(W(24)) xor unsigned(W(18)) xor unsigned(W(16)) ) rol 1 );
			W_next(33) <= std_logic_vector(( unsigned(temp3) xor unsigned(W(25)) xor unsigned(W(19)) xor unsigned(W(17)) ) rol 1 );

			next_state <= create_34_39;
			
		when create_34_39 =>
		
			temp1 <= std_logic_vector(( unsigned(W(31)) xor unsigned(W(26)) xor unsigned(W(20)) xor unsigned(W(18)) ) rol 1 );
			temp2 <= std_logic_vector(( unsigned(W(32)) xor unsigned(W(27)) xor unsigned(W(21)) xor unsigned(W(19)) ) rol 1 );
			temp3 <= std_logic_vector(( unsigned(W(33)) xor unsigned(W(28)) xor unsigned(W(22)) xor unsigned(W(20)) ) rol 1 );
			
			W_next(34) <= temp1;
			W_next(35) <= temp2;
			W_next(36) <= temp3;
			
			W_next(37) <= std_logic_vector(( unsigned(temp1) xor unsigned(W(29)) xor unsigned(W(23)) xor unsigned(W(21)) ) rol 1 );
			W_next(38) <= std_logic_vector(( unsigned(temp2) xor unsigned(W(30)) xor unsigned(W(24)) xor unsigned(W(22)) ) rol 1 );
			W_next(39) <= std_logic_vector(( unsigned(temp3) xor unsigned(W(31)) xor unsigned(W(25)) xor unsigned(W(23)) ) rol 1 );

			next_state <= create_40_45;
			
		when create_40_45 =>
		
			temp1 <= std_logic_vector(( unsigned(W(37)) xor unsigned(W(32)) xor unsigned(W(26)) xor unsigned(W(24)) ) rol 1 );
			temp2 <= std_logic_vector(( unsigned(W(38)) xor unsigned(W(33)) xor unsigned(W(27)) xor unsigned(W(25)) ) rol 1 );
			temp3 <= std_logic_vector(( unsigned(W(39)) xor unsigned(W(34)) xor unsigned(W(28)) xor unsigned(W(26)) ) rol 1 );
			
			W_next(40) <= temp1;
			W_next(41) <= temp2;
			W_next(42) <= temp3;
			
			W_next(43) <= std_logic_vector(( unsigned(temp1) xor unsigned(W(35)) xor unsigned(W(29)) xor unsigned(W(27)) ) rol 1 );
			W_next(44) <= std_logic_vector(( unsigned(temp2) xor unsigned(W(36)) xor unsigned(W(30)) xor unsigned(W(28)) ) rol 1 );
			W_next(45) <= std_logic_vector(( unsigned(temp3) xor unsigned(W(37)) xor unsigned(W(31)) xor unsigned(W(29)) ) rol 1 );

			next_state <= create_46_51;
			
		when create_46_51 =>
		
			temp1 <= std_logic_vector(( unsigned(W(43)) xor unsigned(W(38)) xor unsigned(W(32)) xor unsigned(W(30)) ) rol 1 );
			temp2 <= std_logic_vector(( unsigned(W(44)) xor unsigned(W(39)) xor unsigned(W(33)) xor unsigned(W(31)) ) rol 1 );
			temp3 <= std_logic_vector(( unsigned(W(45)) xor unsigned(W(40)) xor unsigned(W(34)) xor unsigned(W(32)) ) rol 1 );
			
			W_next(46) <= temp1;
			W_next(47) <= temp2;
			W_next(48) <= temp3;
			
			W_next(49) <= std_logic_vector(( unsigned(temp1) xor unsigned(W(41)) xor unsigned(W(35)) xor unsigned(W(33)) ) rol 1 );
			W_next(50) <= std_logic_vector(( unsigned(temp2) xor unsigned(W(42)) xor unsigned(W(36)) xor unsigned(W(34)) ) rol 1 );
			W_next(51) <= std_logic_vector(( unsigned(temp3) xor unsigned(W(43)) xor unsigned(W(37)) xor unsigned(W(35)) ) rol 1 );

			next_state <= create_52_57;
			
		when create_52_57 =>
		
			temp1 <= std_logic_vector((unsigned(W(49)) xor unsigned(W(44)) xor unsigned(W(38)) xor unsigned(W(36))) rol 1);
			temp2 <= std_logic_vector((unsigned(W(50)) xor unsigned(W(45)) xor unsigned(W(39)) xor unsigned(W(37))) rol 1);
			temp3 <= std_logic_vector((unsigned(W(51)) xor unsigned(W(46)) xor unsigned(W(40)) xor unsigned(W(38))) rol 1);
			
			W_next(52) <= temp1;
			W_next(53) <= temp2;
			W_next(54) <= temp3;
			
			W_next(55) <= std_logic_vector((unsigned(temp1) xor unsigned(W(47)) xor unsigned(W(41)) xor unsigned(W(39))) rol 1);
			W_next(56) <= std_logic_vector((unsigned(temp2) xor unsigned(W(48)) xor unsigned(W(42)) xor unsigned(W(40))) rol 1);
			W_next(57) <= std_logic_vector((unsigned(temp3) xor unsigned(W(49)) xor unsigned(W(43)) xor unsigned(W(41))) rol 1);
			next_state <= create_58_63;
		
		when create_58_63 =>
			
			temp1 <= std_logic_vector((unsigned(W(55)) xor unsigned(W(50)) xor unsigned(W(44)) xor unsigned(W(42))) rol 1);
			temp2 <= std_logic_vector((unsigned(W(56)) xor unsigned(W(51)) xor unsigned(W(45)) xor unsigned(W(43))) rol 1);
			temp3 <= std_logic_vector((unsigned(W(57)) xor unsigned(W(52)) xor unsigned(W(46)) xor unsigned(W(44))) rol 1);
			
			W_next(58) <= temp1;
			W_next(59) <= temp2;
			W_next(60) <= temp3;
			
			W_next(61) <= std_logic_vector((unsigned(temp1) xor unsigned(W(53)) xor unsigned(W(47)) xor unsigned(W(45))) rol 1);
			W_next(62) <= std_logic_vector((unsigned(temp2) xor unsigned(W(54)) xor unsigned(W(48)) xor unsigned(W(46))) rol 1);
			W_next(63) <= std_logic_vector((unsigned(temp3) xor unsigned(W(55)) xor unsigned(W(49)) xor unsigned(W(47))) rol 1);
			next_state <=create_64_69;
			
		when create_64_69 =>
			temp1 <= std_logic_vector((unsigned(W(61)) xor unsigned(W(56)) xor unsigned(W(50)) xor unsigned(W(48))) rol 1);
			temp2 <= std_logic_vector((unsigned(W(62)) xor unsigned(W(57)) xor unsigned(W(51)) xor unsigned(W(49))) rol 1);
			temp3 <= std_logic_vector((unsigned(W(63)) xor unsigned(W(58)) xor unsigned(W(52)) xor unsigned(W(50))) rol 1);
			
			W_next(64) <= temp1;
			W_next(65) <= temp2;
			W_next(66) <= temp3;
			
			W_next(67) <= std_logic_vector((unsigned(temp1) xor unsigned(W(59)) xor unsigned(W(53)) xor unsigned(W(51))) rol 1);
			W_next(68) <= std_logic_vector((unsigned(temp2) xor unsigned(W(60)) xor unsigned(W(54)) xor unsigned(W(52))) rol 1);
			W_next(69) <= std_logic_vector((unsigned(temp3) xor unsigned(W(61)) xor unsigned(W(55)) xor unsigned(W(53))) rol 1);
			next_state <= create_70_75;
			
		when create_70_75 =>
		
			temp1 <= std_logic_vector((unsigned(W(67)) xor unsigned(W(62)) xor unsigned(W(56)) xor unsigned(W(54))) rol 1);
			temp2 <= std_logic_vector((unsigned(W(68)) xor unsigned(W(63)) xor unsigned(W(57)) xor unsigned(W(55))) rol 1);
			temp3 <= std_logic_vector((unsigned(W(69)) xor unsigned(W(64)) xor unsigned(W(58)) xor unsigned(W(56))) rol 1);
			W_next(70) <= temp1;
			W_next(71) <= temp2;
			W_next(72) <= temp3;
			W_next(73) <= std_logic_vector((unsigned(temp1) xor unsigned(W(65)) xor unsigned(W(59)) xor unsigned(W(57))) rol 1);
			W_next(74) <= std_logic_vector((unsigned(temp2) xor unsigned(W(66)) xor unsigned(W(60)) xor unsigned(W(58))) rol 1);
			W_next(75) <= std_logic_vector((unsigned(temp3) xor unsigned(W(67)) xor unsigned(W(61)) xor unsigned(W(59))) rol 1);
			next_state <= create_76_79;

		when create_76_79 =>
			temp1 <= std_logic_vector((unsigned(W(73)) xor unsigned(W(68)) xor unsigned(W(62)) xor unsigned(W(60))) rol 1);
			temp2 <= std_logic_vector((unsigned(W(74)) xor unsigned(W(69)) xor unsigned(W(63)) xor unsigned(W(61))) rol 1);
			temp3 <= std_logic_vector((unsigned(W(75)) xor unsigned(W(70)) xor unsigned(W(64)) xor unsigned(W(62))) rol 1);
			
			W_next(76) <= temp1;
			W_next(77) <= temp2;
			W_next(78) <= temp3;
			
			W_next(79) <= std_logic_vector((unsigned(temp1) xor unsigned(W(71)) xor unsigned(W(65)) xor unsigned(W(63))) rol 1);
		
			next_state <= output;
			
			when output =>
			
			
				W1(0)<=W(0);
				W1(1)<=W(1);
				W1(2)<=W(2);
				W1(3)<=W(3);
				W1(4)<=W(4);
				W1(5)<=W(5);
				W1(6)<=W(6);
				W1(7)<=W(7);
				W1(8)<=W(8);
				W1(9)<=W(9);
				W1(10)<=W(10);
				W1(11)<=W(11);
				W1(12)<=W(12);
				W1(13)<=W(13);
				W1(14)<=W(14);
				W1(15)<=W(15);
				W1(16)<=W(16);
				W1(17)<=W(17);
				W1(18)<=W(18);
				W1(19)<=W(19);
				
				W2(0)<=W(20);
				W2(1)<=W(21);
				W2(2)<=W(22);
				W2(3)<=W(23);
				W2(4)<=W(24);
				W2(5)<=W(25);
				W2(6)<=W(26);
				W2(7)<=W(27);
				W2(8)<=W(28);
				W2(9)<=W(29);
				W2(10)<=W(30);
				W2(11)<=W(31);
				W2(12)<=W(32);
				W2(13)<=W(33);
				W2(14)<=W(34);
				W2(15)<=W(35);
				W2(16)<=W(36);
				W2(17)<=W(37);
				W2(18)<=W(38);
				W2(19)<=W(39);
				
				W3(0)<=W(40);
				W3(1)<=W(41);
				W3(2)<=W(42);
				W3(3)<=W(43);
				W3(4)<=W(44);
				W3(5)<=W(45);
				W3(6)<=W(46);
				W3(7)<=W(47);
				W3(8)<=W(48);
				W3(9)<=W(49);
				W3(10)<=W(50);
				W3(11)<=W(51);
				W3(12)<=W(52);
				W3(13)<=W(53);
				W3(14)<=W(54);
				W3(15)<=W(55);
				W3(16)<=W(56);
				W3(17)<=W(57);
				W3(18)<=W(58);
				W3(19)<=W(59);
				
				W4(0)<=W(60);
				W4(1)<=W(61);
				W4(2)<=W(62);
				W4(3)<=W(63);
				W4(4)<=W(64);
				W4(5)<=W(65);
				W4(6)<=W(66);
				W4(7)<=W(67);
				W4(8)<=W(68);
				W4(9)<=W(69);
				W4(10)<=W(70);
				W4(11)<=W(71);
				W4(12)<=W(72);
				W4(13)<=W(73);
				W4(14)<=W(74);
				W4(15)<=W(75);
				W4(16)<=W(76);
				W4(17)<=W(77);
				W4(18)<=W(78);
				W4(19)<=W(79);
				
				message_sent<='1';
			
			if ( msg_rcv='1' ) then --wait until the message is received from the sha1 core unit
			next_state<= fin;
			
			else
			next_state<= output;
			
			end if;
			
		when fin =>
		
		stop <= '1';
				if start = '0' then
					 
					next_state <= idle;
				else
					next_state <= fin;
				end if;
		
			
	end case;



end process padding;



seq: process(clk, reset)

begin

	IF reset = '1' THEN
        state <= idle;            -- Reset to initial state 
	 
		M	     <= (others => '0'); -- initialize Message register with zeros
		W <= (others=>(others =>'0'));
	
   	ELSIF (clk' event and clk='1') then
		state <= next_state;      -- go to next_state
	
		M <= M_next;
	
		W(0)<= W_next(0);
		W(1)<= W_next(1);
		W(2)<= W_next(2);
		W(3)<= W_next(3);
		W(4)<= W_next(4);
		W(5)<= W_next(5);
		W(6)<= W_next(6);
		W(7)<= W_next(7);
		W(8)<= W_next(8);
		W(9)<= W_next(9);
		W(10)<= W_next(10);
		W(11)<= W_next(11);
		W(12)<= W_next(12);
		W(13)<= W_next(13);
		W(14)<= W_next(14);
		W(15)<= W_next(15);
		W(16)<= W_next(16);
		W(17)<= W_next(17);
		W(18)<= W_next(18);
		W(19)<= W_next(19);
		W(20)<= W_next(20);
		W(21)<= W_next(21);
		W(22)<= W_next(22);
		W(23)<= W_next(23);
		W(24)<= W_next(24);
		W(25)<= W_next(25);
		W(26)<= W_next(26);
		W(27)<= W_next(27);
		W(28)<= W_next(28);
		W(29)<= W_next(29);
		W(30)<= W_next(30);
		W(31)<= W_next(31);
		W(32)<= W_next(32);
		W(33)<= W_next(33);
		W(34)<= W_next(34);
		W(35)<= W_next(35);
		W(36)<= W_next(36);
		W(37)<= W_next(37);
		W(38)<= W_next(38);
		W(39)<= W_next(39);
		W(40)<= W_next(40);
		W(41)<= W_next(41);
		W(42)<= W_next(42);
		W(43)<= W_next(43);
		W(44)<= W_next(44);
		W(45)<= W_next(45);
		W(46)<= W_next(46);
		W(47)<= W_next(47);
		W(48)<= W_next(48);
		W(49)<= W_next(49);
		W(50)<= W_next(50);
		W(51)<= W_next(51);
		W(52)<= W_next(52);
		W(53)<= W_next(53);
		W(54)<= W_next(54);
		W(55)<= W_next(55);
		W(56)<= W_next(56);
		W(57)<= W_next(57);
		W(58)<= W_next(58);
		W(59)<= W_next(59);
		W(60)<= W_next(60);
		W(61)<= W_next(61);
		W(62)<= W_next(62);
		W(63)<= W_next(63);
		W(64)<= W_next(64);
		W(65)<= W_next(65);
		W(66)<= W_next(66);
		W(67)<= W_next(67);
		W(68)<= W_next(68);
		W(69)<= W_next(69);
		W(70)<= W_next(70);
		W(71)<= W_next(71);
		W(72)<= W_next(72);
		W(73)<= W_next(73);
		W(74)<= W_next(74);
		W(75)<= W_next(75);
		W(76)<= W_next(76);
		W(77)<= W_next(77);
		W(78)<= W_next(78);
		W(79)<= W_next(79);
					 
    END IF;    
end process seq;


end behavior;

------------------------
-- SHA-1 Core
--adspirop@gmail.com
--
-------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.types.ALL;


entity sha1core is 
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
		
end sha1core;

		
architecture pipelined of sha1core is

--SHA-1 constants and initial values as they are defined in FIPS 180-2 
constant H0_init : word_t := "01100111010001010010001100000001"; -- 0x67452301
constant H1_init : word_t := "11101111110011011010101110001001"; -- 0xefcdab89
constant H2_init : word_t := "10011000101110101101110011111110"; -- 0x98badcfe
constant H3_init : word_t := "00010000001100100101010001110110"; -- 0x10325476
constant H4_init : word_t := "11000011110100101110000111110000"; -- 0xc3d2e1f0

constant K1 : word_t := "01011010100000100111100110011001"; --0x5a827999
constant K2 : word_t := "01101110110110011110101110100001"; --0x6ed9eba1
constant K3 : word_t := "10001111000110111011110011011100"; --0x8f1bbcdc
constant K4 : word_t := "11001010011000101100000111010110"; --0xca62c1d6

--Pipeline registers

type preg is array (0 to 4 ) of word_t;
signal A,B,C,D,E, A_next, B_next, C_next, D_next, E_next: preg; --stage registers 
signal B1,B1_next, C1, C1_next, D1, D1_next: preg; -- duplicated registers for the intermediate values


-- shift registers following the pipelined design
signal S1, S1_next : std_logic_vector (639  downto 0);
signal S2, S2_next : std_logic_vector (1279 downto 0);
signal S3, S3_next : std_logic_vector (1919 downto 0);
signal S4, S4_next : std_logic_vector (2559 downto 0);



type state_type is (init, s_1 );
signal state, next_state: state_type;
type state_type2 is ( init2, s_2);
signal  state2  , next_state2: state_type2;
type state_type3 is ( init3, s_3);
signal  state3  , next_state3: state_type3;
type state_type4 is ( init4, s_4);
signal  state4  , next_state4: state_type4; 
signal count,count_next: std_logic_vector (4 downto 0);

begin 
stage1 : process (A, B1, W1, S1, state, count, message_sent)
	
		
	begin
	
	 A_next(0)<=A(0);
	 A_next(1)<=A(1);
	 A_next(2)<=A(2);
	 A_next(3)<=A(3);
	 A_next(4)<=A(4);
	
	B1_next(0)<=B1(0);
	B1_next(1)<=B1(1);
	B1_next(2)<=B1(2);
	B1_next(3)<=B1(3);
	B1_next(4)<=B1(4);
	
	next_state<=state;
	count_next<=count;
	msg_rcv<='0';
	S1_next<=S1;
	
	 

	case (state) is 
	
	when init =>
	--merging stage0 with stage1
	if (message_sent ='1') then  --wait until the message is ready in the padding unit 
	A_next(0) <= H0_init;
	A_next(1) <= H1_init;
	A_next(2) <= H2_init;
	A_next(3) <= H3_init;
	A_next(4) <= H4_init;
			
	S1_next(639 downto 608)<= W1(0);
	S1_next(607 downto 576)<= W1(1);
	S1_next(575 downto 544)<= W1(2);
	S1_next(543 downto 512)<= W1(3);
	S1_next(511 downto 480)<= W1(4);
	S1_next(479 downto 448)<= W1(5);
	S1_next(447 downto 416)<= W1(6);
	S1_next(415 downto 384)<= W1(7);
	S1_next(383 downto 352)<= W1(8);
	S1_next(351 downto 320)<= W1(9);
	S1_next(319 downto 288)<= W1(10);
	S1_next(287 downto 256)<= W1(11);
	S1_next(255 downto 224)<= W1(12);
	S1_next(223 downto 192)<= W1(13);
	S1_next(191 downto 160)<= W1(14);
	S1_next(159 downto 128)<= W1(15);
	S1_next(127 downto 96) <= W1(16);
	S1_next(95 downto 64)  <= W1(17);
	S1_next(63 downto 32)  <= W1(18);
	S1_next(31 downto 0)   <= W1(19);
	
	msg_rcv<='1';
	next_state<= s_1;
	else 
	next_state <= init;
	end if;
	
	when (s_1) =>

	--stage 1 iterative operation
	--f(b,c,d)= (b and c) xor (not b and d) 
	if ( unsigned(count) < to_unsigned(19,5)) then 
	
		A_next(0) <= std_logic_vector((unsigned( A(0) ) rol 5) + ( ( unsigned(A(1)) and unsigned(A(2)) ) xor ( (not unsigned(A(1))) and unsigned(A(3)) )  ) + unsigned(A(4)) + unsigned(K1) + unsigned(S1(639 downto 608)) );
		A_next(1) <= A(0);
		A_next(2) <= std_logic_vector(unsigned( A(1) ) rol 30 );
		A_next(3) <= A(2);
		A_next(4) <= A(3);
		
		S1_next<= S1(607 downto 0) & "00000000000000000000000000000000"; -- shift S1 register 32 bits
		 
		count_next <= std_logic_vector(unsigned(count) + to_unsigned(1,5) );
		next_state <= s_1;
		
	else --pass values to next stage 
		B1_next(0) <= std_logic_vector((unsigned( A(0) ) rol 5) + ( ( unsigned(A(1)) and unsigned(A(2)) ) xor ( (not unsigned(A(1))) and unsigned(A(3)) )  ) + unsigned(A(4)) + unsigned(K1) + unsigned(S1(639 downto 608)) );
		B1_next(1) <=  A(0);
		B1_next(2) <= std_logic_vector(unsigned( A(1) ) rol 30 );
		B1_next(3) <= A(2);
		B1_next(4) <= A(3);
		S1_next<= S1(607 downto 0) & "00000000000000000000000000000000";
		 
		count_next<= (others =>'0');
		next_state <= init;
	end if;
	end case;
	
end process stage1;

stage2 : process(B, C, B1,C1,W2, S2, count,state2,message_sent)
	begin
	
    B_next(0)<=B(0);
	B_next(1)<=B(1);
	B_next(2)<=B(2);
	B_next(3)<=B(3);
	B_next(4)<=B(4);
	
	C1_next(0)<=C1(0);
	C1_next(1)<=C1(1);
	C1_next(2)<=C1(2);
	C1_next(3)<=C1(3);
	C1_next(4)<=C1(4);
	S2_next<=S2;
	next_state2<=state2;
	case (state2) is
	
	when (init2) =>
	if (message_sent ='1') then
	
	S2_next(639 downto 608)<= W2(0);
	S2_next(607 downto 576)<= W2(1);
	S2_next(575 downto 544)<= W2(2);
	S2_next(543 downto 512)<= W2(3);
	S2_next(511 downto 480)<= W2(4);
	S2_next(479 downto 448)<= W2(5);
	S2_next(447 downto 416)<= W2(6);
	S2_next(415 downto 384)<= W2(7);
	S2_next(383 downto 352)<= W2(8);
	S2_next(351 downto 320)<= W2(9);
	S2_next(319 downto 288)<= W2(10);
	S2_next(287 downto 256)<= W2(11);
	S2_next(255 downto 224)<= W2(12);
	S2_next(223 downto 192)<= W2(13);
	S2_next(191 downto 160)<= W2(14);
	S2_next(159 downto 128)<= W2(15);
	S2_next(127 downto 96) <= W2(16);
	S2_next(95 downto 64)  <= W2(17);
	S2_next(63 downto 32)  <= W2(18);
	S2_next(31 downto 0)   <= W2(19);
	
	B_next(0)<=B1(0);
	B_next(1)<=B1(1);
	B_next(2)<=B1(2);
	B_next(3)<=B1(3);
	B_next(4)<=B1(4);
	--msg_rcv<='1';
	next_state2<= s_2;
	else 
	next_state2<= init2;
	end if;
	
	when(s_2) =>
	--stage 2 iterative operation
	--f(b,c,d)= b xor c xor d
	if ( unsigned(count )< to_unsigned(19,5)) then 
	
		B_next(0) <= std_logic_vector((unsigned( B(0) ) rol 5) + (unsigned( B(1) ) xor unsigned( B(2) ) xor unsigned(B(3)) ) + unsigned(B(4)) +unsigned(K2) + unsigned(S2(1279 downto 1248)) );
		B_next(1) <= B(0);
		B_next(2) <= std_logic_vector(unsigned( B(1) ) rol 30 );
		B_next(3) <= B(2);
		B_next(4) <= B(3);
		
		S2_next<= S2(1247 downto 0) & "00000000000000000000000000000000";
		next_state2 <=s_2;
	else 
		C1_next(0) <=  std_logic_vector((unsigned( B(0) ) rol 5) + (unsigned( B(1) ) xor unsigned( B(2) ) xor unsigned(B(3))) + unsigned(B(4)) +unsigned(K2) + unsigned(S2(1279 downto 1248)) );
		C1_next(1) <=  B(0);
		C1_next(2) <= std_logic_vector(unsigned( B(1) ) rol 30 );
		C1_next(3) <= B(2);
		C1_next(4) <= B(3);
		S2_next<= S2(1247 downto 0) & "00000000000000000000000000000000";
		next_state2 <=init2 ;
	end if;
	
	end case;
	
end process stage2;

stage3 : process(C, D,C1,D1,  W3, S3, count,state3,message_sent)
	begin
	C_next(0)<=C(0);
	C_next(1)<=C(1);
	C_next(2)<=C(2);
	C_next(3)<=C(3);
	C_next(4)<=C(4);
	
	D1_next(0)<=D1(0);
	D1_next(1)<=D1(1);
	D1_next(2)<=D1(2);
	D1_next(3)<=D1(3);
	D1_next(4)<=D1(4);
	S3_next <= S3;
	next_state3<=state3;
	
	case (state3) is 
	
	when (init3)=>
	if (message_sent ='1') then
	
	S3_next(639 downto 608)<= W3(0);
	S3_next(607 downto 576)<= W3(1);
	S3_next(575 downto 544)<= W3(2);
	S3_next(543 downto 512)<= W3(3);
	S3_next(511 downto 480)<= W3(4);
	S3_next(479 downto 448)<= W3(5);
	S3_next(447 downto 416)<= W3(6);
	S3_next(415 downto 384)<= W3(7);
	S3_next(383 downto 352)<= W3(8);
	S3_next(351 downto 320)<= W3(9);
	S3_next(319 downto 288)<= W3(10);
	S3_next(287 downto 256)<= W3(11);
	S3_next(255 downto 224)<= W3(12);
	S3_next(223 downto 192)<= W3(13);
	S3_next(191 downto 160)<= W3(14);
	S3_next(159 downto 128)<= W3(15);
	S3_next(127 downto 96) <= W3(16);
	S3_next(95 downto 64)  <= W3(17);
	S3_next(63 downto 32)  <= W3(18);
	S3_next(31 downto 0)   <= W3(19);
	C_next(0)<=C1(0);
	C_next(1)<=C1(1);
	C_next(2)<=C1(2);
	C_next(3)<=C1(3);
	C_next(4)<=C1(4);
	
	
	--msg_rcv<='1';
	next_state3<= s_3;
	else 
	next_state3 <= init3 ;
	end if;
	
	when (s_3) =>
		--stage 3 iterative operation
	--f(b,c,d)= (b and c) xor (b and d) xor  (c and d)
	if ( unsigned(count) < to_unsigned(19,5)) then 
	
		C_next(0) <= std_logic_vector((unsigned( C(0) ) rol 5) +( (unsigned(C(1)) and unsigned(C(2)) ) xor (unsigned(C(1)) and unsigned(C(3))) xor (unsigned(C(2)) and unsigned(C(3))) ) + unsigned(C(4)) +unsigned(K3) + unsigned(S3(1919 downto 1888)) );
		C_next(1) <= C(0);
		C_next(2) <= std_logic_vector(unsigned( C(1) ) rol 30 );
		C_next(3) <= C(2);
		C_next(4) <= C(3);
		
		S3_next<= S3(1887 downto 0) & "00000000000000000000000000000000";
		next_state3 <= s_3;
		
	else 
		D1_next(0) <= std_logic_vector((unsigned( C(0) ) rol 5) +((unsigned(C(1)) and unsigned(C(2))) xor (unsigned(C(1)) and unsigned(C(3))) xor (unsigned(C(2)) and unsigned(C(3))) ) + unsigned(C(4)) +unsigned(K3) + unsigned(S3(1919 downto 1888)) );
		D1_next(1) <=  C(0);
		D1_next(2) <= std_logic_vector(unsigned( C(1) ) rol 30 );
		D1_next(3) <= C(2);
		D1_next(4) <= C(3);
		S3_next<= S3(1887 downto 0) & "00000000000000000000000000000000";
		next_state3<=init3 ;
		
	end if;
	end case;
end process stage3;

stage4: process(D, E, D1, W4, S4, count,state4,message_sent )
	begin
	D_next(0)<=D(0);
	D_next(1)<=D(1);
	D_next(2)<=D(2);
	D_next(3)<=D(3);
	D_next(4)<=D(4);
	 E_next(0)<=E(0);
	 E_next(1)<=E(1);
	 E_next(2)<=E(2);
	 E_next(3)<=E(3);
	 E_next(4)<=E(4);
	S4_next <= S4;
	next_state4<= state4;
	case (state4) is 
	
	when (init4)=>
	
	if (message_sent ='1') then
 
	S4_next(639 downto 608)<= W4(0);
	S4_next(607 downto 576)<= W4(1);
	S4_next(575 downto 544)<= W4(2);
	S4_next(543 downto 512)<= W4(3);
	S4_next(511 downto 480)<= W4(4);
	S4_next(479 downto 448)<= W4(5);
	S4_next(447 downto 416)<= W4(6);
	S4_next(415 downto 384)<= W4(7);
	S4_next(383 downto 352)<= W4(8);
	S4_next(351 downto 320)<= W4(9);
	S4_next(319 downto 288)<= W4(10);
	S4_next(287 downto 256)<= W4(11);
	S4_next(255 downto 224)<= W4(12);
	S4_next(223 downto 192)<= W4(13);
	S4_next(191 downto 160)<= W4(14);
	S4_next(159 downto 128)<= W4(15);
	S4_next(127 downto 96) <= W4(16);
	S4_next(95 downto 64)  <= W4(17);
	S4_next(63 downto 32)  <= W4(18);
	S4_next(31 downto 0)   <= W4(19);
	D_next(0)<=D1(0);
	D_next(1)<=D1(1);
	D_next(2)<=D1(2);
	D_next(3)<=D1(3);
	D_next(4)<=D1(4);
	
	--msg_rcv<='1';
	next_state4<= s_4;
	else 
	next_state4 <= init4 ;
	end if;
	
	when (s_4) => 
	--stage 4 iterative operation
	--f(b,c,d)= b xor c xor d
	if ( unsigned(count) < to_unsigned(19,5)) then 
	
		D_next(0) <= std_logic_vector((unsigned( D(0) ) rol 5) + (unsigned( D(1) ) xor unsigned( D(2) ) xor unsigned(D(3))) + unsigned(D(4)) +unsigned(K4) + unsigned(S4(2559 downto 2528)) );
		D_next(1) <= D(0);
		D_next(2) <= std_logic_vector(unsigned( D(1) ) rol 30 );
		D_next(3) <= D(2);
		D_next(4) <= D(3);
		
		S4_next<= S4(2527 downto 0) & "00000000000000000000000000000000";
		next_state4<= s_4;
	else 
		E_next(0) <= std_logic_vector((unsigned( D(0) ) rol 5) + (unsigned( D(1) ) xor unsigned( D(2) ) xor unsigned(D(3))) + unsigned(D(4)) + unsigned(K4) + unsigned(S4(2559 downto 2528)) );
		E_next(1) <= D(0);
		E_next(2) <= std_logic_vector(unsigned( D(1) ) rol 30 );
		E_next(3) <= D(2);
		E_next(4) <= D(3);
		
		S4_next<= S4(2527 downto 0) & "00000000000000000000000000000000";
		next_state4 <= init4;
	end if;
	end case;
	
end process stage4;

output : process (E)
begin
	
	
	
	HASH_VALUE <= STD_LOGIC_VECTOR( (unsigned(E(0)) + unsigned(H0_init)) &  (unsigned(E(1)) + unsigned(H1_init)) &  (unsigned(E(2)) + unsigned(H2_init)) &  (unsigned(E(3)) + unsigned(H3_init)) &  (unsigned(E(4)) + unsigned(H4_init)) );
	
end process output;

seq:process (clk, reset)
begin
	IF reset = '1' THEN
        state <= init;            -- Reset to initial state 
		state2 <= init2;
		state3 <= init3;
		state4 <= init4;
		
			S1 <= (others =>'0');
			S2 <= (others =>'0');
			S3 <= (others =>'0');
			S4 <= (others =>'0');
			count <= (others => '0');
			A <= (others=>(others=>'0'));
			B <= (others=>(others=>'0'));
			C <= (others=>(others=>'0'));
			D <= (others=>(others=>'0'));
			E <= (others=>(others=>'0'));
		 
   	ELSIF (clk' event and clk='1') then
	
		state <= next_state;      -- go to next_state
		state2<=next_state2;
		state3<= next_state3;
		state4<=next_state4;
			count<=count_next;
			A(0) <= A_next(0);
			A(1) <= A_next(1);
			A(2) <= A_next(2);
			A(3) <= A_next(3);
			A(4) <= A_next(4);
			
			B(0) <= B_next(0);
			B(1) <= B_next(1);
			B(2) <= B_next(2);
			B(3) <= B_next(3);
			B(4) <= B_next(4);
			
			B1(0) <= B1_next(0);
			B1(1) <= B1_next(1);
			B1(2) <= B1_next(2);
			B1(3) <= B1_next(3);
			B1(4) <= B1_next(4);
			
			C(0) <= C_next(0);
			C(1) <= C_next(1);
			C(2) <= C_next(2);
			C(3) <= C_next(3);
			C(4) <= C_next(4);
			
			C1(0) <= C1_next(0);
			C1(1) <= C1_next(1);
			C1(2) <= C1_next(2);
			C1(3) <= C1_next(3);
			C1(4) <= C1_next(4);
			
			D(0) <= D_next(0);
			D(1) <= D_next(1);
			D(2) <= D_next(2);
			D(3) <= D_next(3);
			D(4) <= D_next(4);
			
			D1(0) <= D1_next(0);
			D1(1) <= D1_next(1);
			D1(2) <= D1_next(2);
			D1(3) <= D1_next(3);
			D1(4) <= D1_next(4);
			
			E(0) <= E_next(0);
			E(1) <= E_next(1);
			E(2) <= E_next(2);
			E(3) <= E_next(3);
			E(4) <= E_next(4);
			
			S1 <= S1_next;
			S2 <= S2_next;
			S3 <= S3_next;
			S4 <= S4_next;
    END IF;    
	
end process seq;

end pipelined;

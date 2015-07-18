-- -----------------------------------------------------------------------------
--
--  Title      :  Useful types and constants in a nice package.
--             :
--  Developers :  Jonas Benjamin Borch - s052435@student.dtu.dk
--             :
--  Purpose    :  This design contains a package with usefull types and 
--             :  constants. 
--             :
--  Revision   :  1.0  22-08-08  Initial version
--             :
--  Special    :   
--  thanks to  :  Niels Haandbæk -- c958307@student.dtu.dk
--             :  Michael Kristensen - c973396@student.dtu.dk
--             :  Hans Holten-Lund - hahl@imm.dtu.dk
--              
-- -----------------------------------------------------------------------------

--------------------------------------------------------------------------------
--    Type name |  MIPS name | size in bits 
--        bit_t |     bit    | 1
--       byte_t |    byte    | 8
--   halfword_t |  halfword  | 16
--       word_t |    word    | 32
-- doubleword_t | doubleword | 64
-- The constants can be used to set all bits in a signal or variable of type 
-- byte_t, halfword_t, word_t and doubleword_t to either '0', '1', 'X' or 'Z'.
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

PACKAGE types IS
    SUBTYPE bit_t           IS std_logic;
    SUBTYPE byte_t          IS std_logic_vector(7 DOWNTO 0);
    SUBTYPE halfword_t      IS std_logic_vector(15 DOWNTO 0);
    SUBTYPE word_t          IS std_logic_vector(31 DOWNTO 0);
    SUBTYPE doubleword_t    IS std_logic_vector(63 DOWNTO 0);
    
    CONSTANT byte_zero:     byte_t := "00000000";
    CONSTANT byte_one:      byte_t := "11111111";
    CONSTANT byte_x:        byte_t := "XXXXXXXX";
    CONSTANT byte_z:        byte_t := "ZZZZZZZZ";
    
    CONSTANT halfword_zero: halfword_t := byte_zero & byte_zero;
    CONSTANT halfword_one:  halfword_t := byte_one & byte_one;
    CONSTANT halfword_x:    halfword_t := byte_x & byte_x;
    CONSTANT halfword_z:    halfword_t := byte_z & byte_z;
    
    CONSTANT word_zero:     word_t := halfword_zero & halfword_zero;
    CONSTANT word_one:      word_t := halfword_one & halfword_one;
    CONSTANT word_x:        word_t := halfword_x & halfword_x;
    CONSTANT word_z:        word_t := halfword_z & halfword_z;
    
    CONSTANT doubleword_zero:   doubleword_t := word_zero & word_zero;
    CONSTANT doubleword_one:    doubleword_t := word_one & word_one;
    CONSTANT doubleword_x:      doubleword_t := word_x & word_x;
    CONSTANT doubleword_z:      doubleword_t := word_z & word_z;
	
	
    Subtype W		           is std_logic_vector(31 downto 0);
    Type    schedule_var       is array ( 0 to 19) of W;
  

END types;

PACKAGE BODY types IS

END types;


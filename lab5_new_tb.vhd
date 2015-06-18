-- lab5_new Testbench.  A test bench is a file that describes the commands that should
-- be used when simulating the design.  The test bench does not describe any hardware,
-- but is only used during simulation.  In Lab 2, you can use this test bench directly,
-- and do *not need to modify it* (in later labs, you will have to write test benches).
-- Therefore, you do not need to worry about the details in this file (but you might find
-- it interesting to look through anyway).

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

-- Testbenches don't have input and output ports.  We'll talk about that in class
-- later in the course.

entity lab5_new_tb is
end lab5_new_tb;


architecture stimulus of lab5_new_tb is

	--Declare the device under test (DUT)
	component lab5_new is

	  port(CLOCK_50          : in  std_logic;
      KEY                  : in  std_logic_vector(3 downto 0);
      SW                   : in  std_logic_vector(17 downto 0);
      LEDG                 : out std_logic_vector(7 downto 0);
      colour_out            : out std_logic_vector(2 downto 0);
      x_out                 : out  std_logic_vector(7 downto 0);
      y_out                 : out  std_logic_vector(6 downto 0);
      plot_out              : out  std_logic);
 
	end component;

	--Signals that connect to the ports of the DUT. The inputs would be 
	--driven inside the testbench according to different test cases, and
	--the output would be monitored in the waveform viewer.

    --Input/Output mapping signals
    signal clk: std_logic := '0';
    signal key : std_logic_vector(3 downto 0);
    signal sw : std_logic_vector(8 downto 0);
    signal led_out : std_logic_vector(7 downto 0);
    signal colour_out : std_logic_vector(2 downto 0);
    signal x_out : std_logic_vector(7 downto 0);
    signal y_out : std_logic_vector(6 downto 0);
    signal plot_out : std_logic
    
    --Middleware Signals
      --KEY Signals
    signal resetb : std_logic := '1';
    
      --SW Signals
    signal p1_goalie : std_logic := '0';
    signal p1_fwd : std_logic := '0';
    signal p2_goalie : std_logic := '0';
    signal p2_fwd : std_logic := '0';
        	
    --Records/Arrays for testing
    type record_name is
      output_record
        led : std_logic_vector(7 downto 0);
        colour : std_logic_vector(2 downto 0);
        x : std_logic_vector(7 downto 0);
        y : std_logic_vector(6 downto 0);
        plot : =  std_logic;
      end record;
    
    type record_name is
      input_record
        key : in  std_logic_vector(3 downto 0);
        sw  : in  std_logic_vector(17 downto 0);
      end record;
    
    type input_record_array is array (0 to 10) of input_record; 
    type output_record_array is array (0 to 10) of output_record; 

    signal s_input_sequence : input_record_array;
    signal s_output_sequence : output_record_array;

	--Declare a constant of type 'time'. This would be used to cause delay
  -- between clock edges

  --Period of 50MHz Clock
	constant PERIOD : time := 20ns;

begin

	key <= resetb & "00" & "00" & "00";
	sw <= p2_fwd & p2_goalie & "0000 0000 0000 00" & p2_fwd & p2_goalie;

	DUT: lab5_new 
	  port map (
      CLOCK_50 => clk,
      key => key,
      sw => sw,
      ledg => out_led,
      colour_out => colour_out,
      x_out x_out,
      y_out => y_out,
      plot_out => plot_out
    );
  
  
  main_test_process: process is

    procedure test_sequence(
        input_sequence: std_logic_vector;
        expected_output_sequence: std_logic_vector
    ) is begin
        for i in input_sequence'range loop
            x <= input_sequence(i);
            wait until rising_edge(clk);
            assert z = expected_output_sequence(i);
        end loop;
    end;

begin

    test_sequence( input_sequence => "000", expected_output_sequence => "000");
    test_sequence( input_sequence => "001", expected_output_sequence => "000");
    --  (add any other input sequences here...)
    test_sequence( input_sequence => "110", expected_output_sequence => "001");

    std.env.finish;

end process;

end stimulus;

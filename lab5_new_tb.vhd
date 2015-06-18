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
	constant HALF_PERIOD : time := 10ns;

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
  
  -- CLOCK STIMULI
	CLOCK: process
	begin
		CLK <= not clk after HALF_PERIOD ns;
		wait for 2*HALF_PERIOD ns;
	end process; 
	
  main_test: process is

    procedure test_sequence(
        input_sequence: input_record_array;
        expected_output_sequence: output_record_array
    ) is begin
        for i in input_sequence'range loop
            x <= input_sequence(i);
            wait until rising_edge(clk);
            assert colour_out = expected_output_sequence(i).colour;
            --assert x_out = expected_output_sequence(i).x;
            --assert y_out = expected_output_sequence(i).y;
            assert plot_out = expected_output_sequence(i).plot;
        end loop;
    end;
    
    procedure clear_screen() is 
    begin
    
			--Press Reset
			resetb <= '0';
			wait until rising_edge(clk);
			
			--Clear Screen Initial State 
			p2_fwd <= '0';
			p2_goalie <= '0';
			p1_fwd <= '0';
			p2_goalie <= '0';
			resetb <= '1';
			wait until rising_edge(clk);
			
			assert x_out = "00000000";
      assert y_out = "0000000";
      assert plot_out = '1';
      assert colour_out = "000";
      wait until rising_edge(clk);
			
			for i_y in 0 to 119 loop
				for i_x in 1 to 159 loop
					assert plot_out = '1';
					-- assert x_out = std_logic_vector(i_x);
					-- assert y_out = std_logic_vector(i_y);
					assert colour_out = "000";
					wait until rising_edge(clk);
				end loop;
			end loop;
    end;
    
    procedure draw_walls() is 
    begin
    
			--Check we are starting in correct state
			assert plot_out = '1';
			assert colour_out = "111"; -- make sure colour of walls is white
			
			-- make sure we start at (5,5)
			assert x_out = "00000101"; 
			assert y_out = "0000101";
		
	
			--Draw top wall
			for i in 5 to 154 loop
				assert plot_out = '1';
				-- assert x_out = std_logic_vector(i);
				-- assert y_out = "0000101";
				assert colour_out = "111";
				wait until rising_edge(clk);
			end loop;
			
			-- make sure we start at (5,155)
			assert x_out = "00000101"; 
			assert y_out = "1110011";
			
			--Draw bottom wall
			for i in 5 to 154 loop
				assert plot_out = '1';
				assert x_out = "00000101";
				if(i >= 54 and i <= 66) then
					assert colour_out = "001";
				elsif(i >= 115) then
					assert colour_out = "
				-- assert x_out = std_logic_vector(i);
				-- assert y_out = "1110011";
				assert colour_out = "111";
				wait until rising_edge(clk);
			end loop;
    end;
    	

begin

		--Test #1: Move All Paddles DOWN
		
		--Initialization Procedure
		clear_screen();
		draw_walls()
		
		
		--TEST s1g STATE (DRAW PLYR1 GOALIE)
			
			--Initialize s1g state
		p2_fwd <= '0';
		p2_goalie <= '0';
		p1_fwd <= '0';
		p2_goalie <= '0';
		
		--Check to make sure we start drawing from (5,6)
		assert y_out = "0000110";
		assert x_out = "00000101";
		assert colour = "000";
		assert plot = '1';
		wait until rising_edge(clk);
		
		--Run s1g state (DRAW PADDLE1)
		for i in 115 downto 7 loop
			assert plot = '1';
			if(i >= 54 and y_tmp <= 66) then
				--t1g = 54
				assert colour = "001";
      else 
      	assert colour = "000";
			end if;
			
			wait until rising_edge(clk);
		end loop;
		--t1g = 55

    
    --TEST s1f STATE (DRAW PLYR1 FWD)
    assert x_tmp = "01000011";
    assert y_out = "0000110";
    assert colour = "000";
    assert plot = '1';
    wait until rising_edge(clk);

		--RUN s1f STATE (DRAW PLYR1 FWD)
		for i in 115 downto 7 loop
			assert plot = '1';
			if(i >= 54 and y_tmp <= 66) then
				--t1f = 54
				assert colour = "001";
      else 
      	assert colour = "000";
			end if;
			
			wait until rising_edge(clk);
		end loop;
		--t1f = 55
		
		
		--TEST s1f STATE (DRAW PLYR2 FWD)
    assert x_tmp = "01000011";
    assert y_out = "0000110";
    assert colour = "000";
    assert plot = '1';
    wait until rising_edge(clk);

		--RUN s1f STATE (DRAW PLYR1 FWD)
		for i in 115 downto 7 loop
			assert plot = '1';
			if(i >= 54 and y_tmp <= 66) then
				--t1f = 54
				assert colour = "001";
      else 
      	assert colour = "000";
			end if;
			
			wait until rising_edge(clk);
		end loop;
		--t1f = 55
		
		 --TEST s1f STATE (DRAW PLYR1 FWD)
    assert x_tmp = "01000011";
    assert y_out = "0000110";
    assert colour = "000";
    assert plot = '1';
    wait until rising_edge(clk);

		--RUN s1f STATE (DRAW PLYR1 FWD)
    --test_sequence( input_sequence => "000", expected_output_sequence => "000");


    std.env.finish;

end process;

end stimulus;

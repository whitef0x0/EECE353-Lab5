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
      --LEDG                 : out std_logic_vector(7 downto 0);
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
    -- signal led_out : std_logic_vector(7 downto 0);
    signal colour_out : std_logic_vector(2 downto 0);
    signal x_out : std_logic_vector(7 downto 0);
    signal y_out : std_logic_vector(6 downto 0);
    signal plot_out : std_logic
    
    --Component Signals
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
        -- led : std_logic_vector(7 downto 0);
        colour : std_logic_vector(2 downto 0);
        x : std_logic_vector(7 downto 0);
        y : std_logic_vector(6 downto 0);
        plot :  std_logic;
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

	--Colour constants
	constant WALL_COLOUR : std_logic_vector(2 downto 0) := "111";
	constant BACKGROUND_COLOUR : std_logic_vector(2 downto 0) := "000";
	constant P1_COLOUR : std_logic_vector(2 downto 0) := "001";
	constant P2_COLOUR : std_logic_vector(2 downto 0) := "100";
	
	--Position constants
	constant INIT_X_PUCK : std_logic_vector(7 downto 0) := "01010000"; --80
	constant INIT_Y_PUCK : std_logic_vector(7 downto 0) := "0111100"; --60
	
	--constant INIT_X_DRAW : std_logic_vector(7 downto 0) := "00000101"; --5
	--constant INIT_Y_DRAW : std_logic_vector(7 downto 0) := "0000101"; --5
	
begin

	key <= resetb & "00" & "00" & "00";
	sw <= p2_fwd & p2_goalie & "0000 0000 0000 00" & p2_fwd & p2_goalie;

	DUT: lab5_new 
		port map (
      CLOCK_50 => clk,
      key => key,
      sw => sw,
      -- ledg => out_led,
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
    variable t1g, t1f, t2g, t2f: : unsigned(6 downto 0);
		variable puckx : unsigned(7 downto 0) := INIT_X_PUCK; -- 80
    variable pucky : unsigned(6 downto 0) := INIT_Y_PUCK; -- 60
    variable velx : std_logic := '0';
    variable vely : std_logic := '0';

    -- procedure test_sequence(
    --     input_sequence: input_record_array;
    --     expected_output_sequence: output_record_array
    -- ) is begin
    --     for i in input_sequence'range loop
    --         x <= input_sequence(i);
    --         wait until rising_edge(clk);
    --         assert colour_out = expected_output_sequence(i).colour;
    --         --assert x_out = expected_output_sequence(i).x;
    --         --assert y_out = expected_output_sequence(i).y;
    --         assert plot_out = expected_output_sequence(i).plot;
    --     end loop;
    -- end;
    
    procedure clear_screen() is 
    begin

			wait until rising_edge(clk);
			
			assert x_out = "00000000";
      assert y_out = "0000000";
      assert plot_out = '1';
      assert colour_out = BACKGROUND_COLOUR;
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
			assert colour_out = WALL_COLOUR; -- make sure colour of walls is white
			
			-- make sure we start at (5,5)
			assert x_out = "00000101"; 
			assert y_out = "0000101";
		
	
			--Draw top wall
			for i in 5 to 154 loop
				assert plot_out = '1';
				-- assert x_out = std_logic_vector(i);
				-- assert y_out = "0000101";
				assert colour_out = WALL_COLOUR;
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
					assert colour_out = P1_COLOUR;
				elsif(i >= 115) then
					assert colour_out = "
				-- assert x_out = std_logic_vector(i);
				-- assert y_out = "1110011";
				assert colour_out = WALL_COLOUR;
				wait until rising_edge(clk);
			end loop;
    end;
   
		procedure draw_paddles() is 
    begin
	  --STEP #1	
			--test s1g state (DRAW PLYR1 GOALIE)
				
				--Start drawing from (5,6)
			assert x_out = "00000101"; -- 5
			assert y_out = "0000110"; -- 6
			assert colour_out = BACKGROUND_COLOUR;
			assert plot_out = '1';
			wait until rising_edge(clk);
			
				--run s1g state (DRAW PLYR2 GOALIE)
			for i in 7 to 115 loop
				assert plot_out = '1';
				if(i >= 54 and i <= 66) then
					assert colour_out = P1_COLOUR;
	      elsif(i = 115) then
					assert colour_out = WALL_COLOUR;
	      else 
	      	assert colour_out = BACKGROUND_COLOUR;
				end if;
				
				wait until rising_edge(clk);
			end loop;
			t1g := t1g + 1;
	
	  --STEP #2
	    --test s1f state (DRAW PLYR1 FWD)
	    assert x_out = "01000011"; -- 67
	    assert y_out = "0000110"; -- 6
	    assert colour_out = BACKGROUND_COLOUR;
	    assert plot_out = '1';
	    wait until rising_edge(clk);
	
			--run s1f state (DRAW PLYR1 FWD)
			for i in 7 to 115 loop
				assert plot_out = '1';
				if(i >= 54 and i <= 66) then
					assert colour_out = P1_COLOUR;
	      elsif(i = 115) then
					assert colour_out = WALL_COLOUR;
	      else 
	      	assert colour_out = BACKGROUND_COLOUR;
				end if;
				
				wait until rising_edge(clk);
			end loop;
			t1f := t1f + 1;
			
		--STEP #3
			--test s2g state (DRAW PLYR2 GOALIE)
	    assert x_out = "10011010"; -- 154
	    assert y_out = "0000110"; -- 6
	    assert colour_out = BACKGROUND_COLOUR;
	    assert plot_out = '1';
	    wait until rising_edge(clk);
	
				--run s2g state (DRAW PLYR2 GOALIE)
			for i in 7 to 115 loop
				assert plot_out = '1';
				if(i >= 54 and i <= 66) then
					assert colour_out = P2_COLOUR;
				elsif(i = 115) then
					assert colour_out = WALL_COLOUR;
	      else 
	      	assert colour_out = BACKGROUND_COLOUR;
				end if;
				
				wait until rising_edge(clk);
			end loop;
			t2g := t2g + 1;
			
		--STEP #4
			--test s2f state (DRAW PLYR2 FWD)
	    assert x_out = "01011101"; -- 93
	    assert y_out = "0000110"; -- 6
	    assert colour_out = BACKGROUND_COLOUR;
	    assert plot_out = '1';
	    wait until rising_edge(clk);
	
				--run s2g state (DRAW PLYR2 GOALIE)
			for i in 7 to 115 loop
				assert plot_out = '1';
				if(i >= 54 and i <= 66) then
					assert colour_out = P2_COLOUR;
	      elsif(i = 115) then
					assert colour_out = WALL_COLOUR;
	      else 
	      	assert colour_out = BACKGROUND_COLOUR;
				end if;
				
				wait until rising_edge(clk);
			end loop;
			t2f := t2f + 1;
			
		--STEP #5
			--test sgp1 state (INIT PUCK)
			assert plot_out = '1';
	    assert colour_out = BACKGROUND_COLOUR;
	    assert x = INIT_X_PUCK; -- 80
	    assert y = INIT_Y_PUCK; -- 60
	    wait until rising_edge(clk);
	end;
begin

--Test #1: Move All Paddles DOWN
		
	--Test 1 | STEP #1
		
    --Initialize inputs
		p2_fwd <= '0';
		p2_goalie <= '0';
		p1_fwd <= '0';
		p2_goalie <= '0';
		
		--Initialization Procedure
		t1g := "0110110";
    t1f := "0110110";
    t2g := "0110110";
    t2f := "0110110";
    velx := p2_fwd xor p1_fwd;
    velx := p2_goalie xor p1_goalie;
    
    
        
		--Press Reset
		resetb <= '0';
		wait until rising_edge(clk);
		
		--Clear Screen Initial State 
		resetb <= '1';
		clear_screen();
		draw_walls();
		

  
  --Test 1 | STEP #1
		--test sgp2 state (PUCK COLLISION and PUCK DRAW)
		
		
		-- PUCK will move on UPWARD-LEFT trajectory till (26, 6) 
		for i in 0 to 53 loop
		
			--Draw ball
			assert plot_out = '1';
			assert colour_out = WALL_COLOUR;
			assert x = puckx;
			assert y = pucky;
			puckx := puckx - 1;
			pucky := pucky - 1;
			wait until rising_edge(clk);
			
			--Wait until paddle have been updated
			assert plot_out = '0';
			wait until plot_out = '1';
			
			--Wait until paddles have been fully drawn
			for b in 0 to 440 loop
				assert plot_out = '1';
				wait until rising_edge(clk);
			end loop;
			
		end loop;
		
		
		-- PUCK hits TOP wall and bounces off DOWNWARD-LEFT  after (26, 6) 
		assert y = "0000101"; -- 5
		assert x = "00011011"; -- 25
		puckx := puckx - 1;
		pucky := pucky + 1;
		vely := '1';
		wait until rising_edge(clk);
		
		-- PUCK will move on a DOWNWARD-LEFT trajectory till (4, 28) 
		for i in 0 to 21 loop
			assert colour_out = WALL_COLOUR;
			puckx := puckx - 1;
			pucky := pucky + 1;
			wait until rising_edge(clk);
			
			--Wait until paddle have been updated
			assert plot_out = '0';
			wait until plot_out = '1';
			
			--Wait until paddles have been fully drawn
			for b in 0 to 440 loop
				assert plot_out = '1';
				wait until rising_edge(clk);
			end loop;
		end loop;
		
		
		-- PUCK hit RIGHT WALL and bounces off DOWNWARD-RIGHT after (4, 28) 
		-- Player2 scores a point and game resets
		assert y = "0000101"; -- 5
		assert x = "00011011"; -- 25
		puckx := puckx + 1;
		pucky := pucky + 1;
		vely := '1';
		wait until rising_edge(clk);
		
		-- PUCK will be reset to (80,60)
		clear_screen();
		draw_walls();
		draw_paddles();
		assert x = INIT_X_PUCK; -- 80
	  assert y = INIT_Y_PUCK; -- 60
		

    std.env.finish;

end process;

end stimulus;

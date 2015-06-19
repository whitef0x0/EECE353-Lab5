--David Baldwin: 10832137

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab5_new is
  port(CLOCK_50             : in  std_logic;
      KEY                   : in  std_logic_vector(3 downto 0);
      SW                    : in  std_logic_vector(17 downto 0);
      -- LEDG                  : out std_logic_vector(7 downto 0);
      colour_out            : out std_logic_vector(2 downto 0);
      x_out                 : out  std_logic_vector(7 downto 0);
      y_out                 : out  std_logic_vector(6 downto 0);
      plot_out              : out  std_logic
      -- VGA_R, VGA_G, VGA_B  : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
      -- VGA_HS               : out std_logic;
      -- VGA_VS               : out std_logic;
      -- VGA_BLANK            : out std_logic;
      -- VGA_SYNC             : out std_logic;
      -- VGA_CLK              : out std_logic
      );
end lab5_new;

architecture RTL of lab5_new is

    -- component vga_adapter
    --     generic(RESOLUTION : string);
    --     port(
    --         resetn                                          : in std_logic;
    --         clock                                           : in std_logic;
    --         colour                                          : in std_logic_vector(2 downto 0);
    --         x                                               : in  std_logic_vector(7 downto 0);
    --         y                                               : in  std_logic_vector(6 downto 0);
    --         plot                                            : in  std_logic;
    --         VGA_R, VGA_G, VGA_B                             : out std_logic_vector(9 downto 0);
    --         VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK    : out std_logic);
    -- end component;
            
            
    signal x        : std_logic_vector(7 downto 0) := "00000000";
    signal y        : std_logic_vector(6 downto 0) := "0000000";
    signal colour   : std_logic_vector(2 downto 0) := "000";
    signal plot     : std_logic := '0';
            
begin

    -- vga_u0 : vga_adapter
    --     generic map(RESOLUTION => "160x120")
    --     port map(resetn     => KEY(3),
    --             clock       => CLOCK_50,
    --             colour      => colour,
    --             x           => x,
    --             y           => y,
    --             plot        => plot,
    --             VGA_R       => VGA_R,
    --             VGA_G       => VGA_G,
    --             VGA_B       => VGA_B,
    --             VGA_HS      => VGA_HS,
    --             VGA_VS      => VGA_VS,
    --             VGA_BLANK   => VGA_BLANK,
    --             VGA_SYNC    => VGA_SYNC,
    --             VGA_CLK     => VGA_CLK);
    
    x_out <= x;
    y_out <= y;
    plot_out <= plot;
    colour_out <= colour;

    process(CLOCK_50, KEY(3))
        type state_types is (sr, sb, sginit, sg1g, sg1f, sg2g, sg2f, sgp1, sgp2, sgpause, sgdone);
        variable state : state_types := sr;
        variable clk : unsigned(21 downto 0) := "0000000000000000000000";
        variable max_clk : unsigned(21 downto 0) := "1111111111111111111111";
        variable x_tmp : unsigned(7 downto 0) := "00000000";
        variable y_tmp : unsigned(6 downto 0) := "0000000";
        variable t1g, t1f, t2g, t2f : unsigned(6 downto 0);
        variable puckx : unsigned(7 downto 0) := "01010000";
        variable pucky : unsigned(6 downto 0) := "0111100";
        variable velx : std_logic := '0';
        variable vely : std_logic := '0';
    begin
        if (KEY(3) = '0') then
            state := sgp1;
            x_tmp := "00011010";
            y_tmp := "0000101";
            puckx := "00011010";
            pucky := "0000110";
            velx := sw(17) xor sw(0);
            vely := sw(16) xor sw(1);
        elsif (rising_edge(CLOCK_50)) then
            case state is
                when sr =>
                    colour <= "000";
                    plot <= '0';
                    x_tmp := "00000000";
                    y_tmp := "0000000";
                    puckx := "01010000";
                    pucky := "0111100";
                    
                    --THIS ISN'T CORRECT WAY TO INITIALIZE OUR VELOCITY
                    velx := sw(17) xor sw(0);
                    vely := sw(16) xor sw(1);
                    
                    max_clk := (others => '1');
                    state := sb;
                when sb =>
                    plot <= '1';
                    colour <= "000";
                    y <= std_logic_vector(y_tmp);
                    x <= std_logic_vector(x_tmp);
                    x_tmp := x_tmp + 1;
                    if (x_tmp = 160) then
                        x_tmp := "00000000";
                        y_tmp := y_tmp + 1;
                        if (y_tmp = 120) then
                            x_tmp := "00000101"; -- 5
                            y_tmp := "0000101"; -- 5
                            state := sginit;
                        end if;
                    end if;
                when sginit =>
                    plot <= '1';
                    colour <= "111";
                    y <= std_logic_vector(y_tmp);
                    x <= std_logic_vector(x_tmp);
                    x_tmp := x_tmp + 1;
                    if (x_tmp = 155) then
                        x_tmp := "00000101";
                        if (y_tmp = 115) then
                            t1g := "0110110";
                            t1f := "0110110";
                            t2g := "0110110";
                            t2f := "0110110";
                            y_tmp := "0000101";
                            state := sg1g;
                        else
                            y_tmp := "1110011"; -- 120 - 5 = 115
                        end if;
                    end if;
                when sg1g =>
                    plot <= '1';
                    x_tmp := "00000101";
                    y_tmp := y_tmp + 1;
                    if (y_tmp >= t1g and y_tmp <= t1g + 12 and y_tmp < 115) then
                        colour <= "001";
                    elsif (y_tmp >= 115) then
                        if (sw(17) = '1') then
                            if (t1g > 6) then
                                t1g := t1g - 1;
                            end if;
                        else
                            if (t1g < 102) then
                                t1g := t1g + 1;
                            end if;
                        end if;
                        y_tmp := "0000101";
                        colour <= "111";
                        state := sg1f;
                    else
                        colour <= "000";
                    end if;
                    y <= std_logic_vector(y_tmp);
                    x <= std_logic_vector(x_tmp);
                when sg1f =>
                    plot <= '1';
                    x_tmp := "01000011";
                    y_tmp := y_tmp + 1;
                    if (y_tmp >= t1f and y_tmp <= t1f + 12 and y_tmp < 115) then
                        colour <= "001";
                    elsif (y_tmp >= 115) then
                        if (sw(16) = '1') then
                            if (t1f > 6) then
                                t1f := t1f - 1;
                            end if;
                        else
                            if (t1f < 102) then
                                t1f := t1f + 1;
                            end if;
                        end if;
                        y_tmp := "0000101";
                        colour <= "111";
                        state := sg2g;
                    else
                        colour <= "000";
                    end if;
                    y <= std_logic_vector(y_tmp);
                    x <= std_logic_vector(x_tmp);
                when sg2g =>
                    plot <= '1';
                    x_tmp := "10011010";
                    y_tmp := y_tmp + 1;
                    if (y_tmp >= t2g and y_tmp <= t2g + 12 and y_tmp < 115) then
                        colour <= "100";
                    elsif (y_tmp >= 115) then
                        if (sw(0) = '1') then
                            if (t2g > 6) then
                                t2g := t2g - 1;
                            end if;
                        else
                            if (t2g < 102) then
                                t2g := t2g + 1;
                            end if;
                        end if;
                        y_tmp := "0000101";
                        colour <= "111";
                        state := sg2f;
                    else
                        colour <= "000";
                    end if;
                    y <= std_logic_vector(y_tmp);
                    x <= std_logic_vector(x_tmp);
                when sg2f =>
                    plot <= '1';
                    x_tmp := "01011101";
                    y_tmp := y_tmp + 1;
                    if (y_tmp >= t2f and y_tmp <= t2f + 12 and y_tmp < 115) then
                        colour <= "100";
                    elsif (y_tmp >= 115) then
                        if (sw(1) = '1') then
                            if (t2f > 6) then
                                t2f := t2f - 1;
                            end if;
                        else
                            if (t2f < 102) then
                                t2f := t2f + 1;
                            end if;
                        end if;
                        colour <= "111";
                        state := sgp1;
                    else
                        colour <= "000";
                    end if;
                    y <= std_logic_vector(y_tmp);
                    x <= std_logic_vector(x_tmp);
                when sgp1 =>
                    plot <= '1';
                    colour <= "000";
                    y <= std_logic_vector(pucky);
                    x <= std_logic_vector(puckx);
                    state := sgp2;
                when sgp2 =>
                    --collision detection with walls
                    
                    --DOESN'T SEEM TO INVERT X VELOCITY
                    --ONLY REFRESHES WHEN BALL COLLIDES WITH LEFT OR RIGHT WALL
                    --Checks collision with LEFT wall
                    if (puckx <= 4) then
                        state := sr;
                        --velx: '1';
                    --Checks collision with RIGHT wall
                    elsif (puckx >= 156) then
                        state := sr;
                        --velx: '1';
                    else
                    
                        --Checks collision with TOP wall
                        if (pucky <= 6) then
                            vely := '1';
                        --Checks collision with BOTTOM wall
                        elsif (pucky >= 114) then
                            vely := '0';
                        end if;
                        
                        if (velx = '0') then
                            puckx := puckx - 1;
                        else
                            puckx := puckx + 1;
                        end if;
                        if (vely = '0') then
                            pucky := pucky - 1;
                        else
                            pucky := pucky + 1;
                        end if;
                        
                        --collision detection with paddles
                        --ONLY INVERTS X VELOCITY, NOT THE Y VELOCITY when hitting
                        if (puckx = "00000101" and pucky >= t1g and pucky <= t1g+12) then
                            velx := not velx;
                            if (velx = '0') then
                            
                                --Why is it going by increments of '2' and not of '1'?
                                puckx := puckx - 2;
                            else
                                puckx := puckx + 2;
                            end if;
                        elsif (puckx = "01000011" and pucky >= t1f and pucky <= t1f+12) then
                            velx := not velx;
                            if (velx = '0') then
                            else
                                puckx := puckx + 2;
                            end if;
                        elsif (puckx = "10011010" and pucky >= t2g and pucky <= t2g+12) then
                            velx := not velx;
                            if (velx = '0') then
                                puckx := puckx - 2;
                            else
                                puckx := puckx + 2;
                            end if;
                        elsif (puckx = "01011101" and pucky >= t2f and pucky <= t2f+12) then
                            velx := not velx;
                            if (velx = '0') then
                                puckx := puckx - 2;
                            else
                                puckx := puckx + 2;
                            end if;
                        end if;
                        
                        plot <= '1';
                        colour <= "111";
                        y <= std_logic_vector(pucky);
                        x <= std_logic_vector(puckx);
                        
                        --Go to pause state
                        state := sgpause;
                    end if;
                    
                --Handles updating all game sprites
                when sgpause =>
                    plot <= '0';
                    clk := clk + 1;
                    --initial max_clk is 4194303
                    
                    --Slow down the clock with a counter (from 50MHz)
                    
                    --Refresh screen every 12Hz, 25Hz, 55Hz or 71Hz
                    
                    --First refresh will be 12Hz
                    --Every other refresh (until initialization) will decrease by 2ms until it reaches 71Hz
                    if (clk = max_clk) then
                        --reset clk counter to 0
                        clk := "0000000000000000000000";
                        if (max_clk >= 4000000) then
                            max_clk := max_clk - 100000;
                        elsif (max_clk >= 2000000) then
                            max_clk := max_clk - 10000;
                        elsif (max_clk >= 900000) then
                            max_clk := max_clk - 1000;
                        elsif (max_clk >= 700000) then
                            max_clk := max_clk - 100;
                        end if;
                        -- ledg <= std_logic_vector(max_clk(21 downto 14));
                        
                        --Redraw paddles
                        y_tmp := "0000101"; --set y to 5
                        colour <= "111";
                        state := sg1g;
                    end if;
                when others =>
                    state := sb;
            end case;
        end if;
    end process;

end RTL;




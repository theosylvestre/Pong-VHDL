LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY PONG2 IS 
PORT (
		MAX10_CLK1_50  : in std_logic;
		HEX4, HEX1 : out std_logic_vector(6 downto 0);
		KEY: in std_logic_vector(1 downto 0);
		VGA_VS : buffer std_logic;
		Video_V : buffer std_logic;
		VGA_HS : buffer std_logic;
		Video_H : buffer std_logic;
		GPIO : out std_logic_vector(10 downto 0);
		Retour : buffer std_logic;
		VGA_R : out integer range 0 to 15;
		VGA_G : out integer range 0 to 15;
		VGA_B : out integer range 0 to 15;
		clk_440 : buffer std_logic;
		Arduino_IO4 : buffer std_logic
			);
END PONG2;

ARCHITECTURE algorithme OF PONG2 IS
signal horloge25M : std_logic;
signal Ligne : integer range 0 to 1023;
signal Colonne : integer range 0 to 1023;
signal LIM_GAUCHE : integer range 44 to 44 := 44;
signal LIM_HAUT : integer range 30 to 30 := 30;
signal LIM_DROITE : integer range 684 to 684 := 684;
signal LIM_BAS : integer range 510 to 510 := 510;
signal ligne_bin : std_logic_vector(9 downto 0);


signal LARGEUR_Balle : integer range 31 to 31 := 31;
signal LONGUEUR_Balle : integer range 31 to 31 := 31;
signal LARGEUR_Raquette : integer range 100 to 100 := 100;
signal LONGUEUR_Raquette : integer range 30 to 30 := 30;


signal posX_Balle : integer range 0 to 640 := 300; 
signal posY_Balle : integer range 0 to 480 := 100; 
signal posX_Raquette1 : integer range 0 to 44 := 44; 
signal posY_Raquette1 : integer range 0 to 480 := 100; 
signal posX_Raquette2 : integer range 0 to 653 := 653; 
signal posY_Raquette2 : integer range 0 to 480 := 100; 

signal Vx_Balle : integer range -5 to 5 := 5;
signal Vy_Balle : integer range -2 to 2 := 2;
signal Vy_Raquette1 : integer range -3 to 3 := 0;
signal Vy_Raquette2 : integer range -3 to 3 := 0;

signal score1 : integer range 0 to 9 := 0;
signal score2 : integer range 0 to 9 := 0;

signal r : std_logic_vector(16 downto 0); 

BEGIN 
	
	div_2 : PROCESS(MAX10_CLK1_50)
	BEGIN  
		if rising_edge(MAX10_CLK1_50) then
			horloge25M <= not horloge25M;
			GPIO(1) <= horloge25M;
		end if;
		GPIO(0) <= MAX10_CLK1_50;
	END PROCESS div_2;
		
	
	balayage_horizontal : PROCESS(horloge25M)
	BEGIN  
		if rising_edge(horloge25M) then
			if (Colonne < 800) then 
				Colonne <= Colonne + 1;
			else
				Colonne <= 0;
			end if;
			
			case Colonne is
				when 0 => VGA_HS <= '1';
				when 703 => VGA_HS <= '0';
				when 44 => Video_H <= '1';
				when 684 => Video_H <= '0';
				when others => VGA_HS <= VGA_HS;
			end case;
			Retour <= Video_V AND Video_H; 
		end if;
		GPIO(2) <= VGA_HS;
		GPIO(3) <= Video_H;
	END PROCESS balayage_horizontal;
	
	
	balayage_vertical : PROCESS(VGA_HS)
	BEGIN  
		if rising_edge(VGA_HS) then
			if(Ligne < 525) then
				Ligne <= Ligne + 1;
			else 
				Ligne <= 0;
			end if;
			
			case Ligne is
				when 0 => VGA_VS <= '1';
				when 523 => VGA_VS <= '0';
				when 30 => Video_V <= '1';
				when 510 => Video_V <= '0';
				when others => Video_V <= Video_V;
			end case;
			
		end if;
		GPIO(4) <= VGA_VS;
		GPIO(5) <= Video_V;
		
	END PROCESS balayage_vertical;
	

	couleurs : PROCESS(Ligne, Colonne)
	BEGIN
	   ligne_bin <= std_logic_vector(to_unsigned(Ligne, 10));
		if (Retour = '1') then
			VGA_R <= 0;
			VGA_G <= 0;
			VGA_B <= 0;
			
			if((Colonne >= LIM_GAUCHE - (LIM_GAUCHE / 4) + ((LIM_DROITE - LIM_GAUCHE) / 2)) AND (Colonne <= LIM_GAUCHE + (LIM_GAUCHE / 4) + ((LIM_DROITE - LIM_GAUCHE) / 2))) then
				if(ligne_bin(5)='1') then
					VGA_R <= 15;
					VGA_G <= 15;
					VGA_B <= 15;
				end if;
			end if;
			
			if(Ligne >= posY_Balle AND Ligne <= posY_Balle + LARGEUR_Balle) then
				if(Colonne >= posX_Balle AND Colonne <= posX_Balle + LONGUEUR_Balle) then
					VGA_R <= 15;
					VGA_G <= 15;
					VGA_B <= 15;
				end if;
			end if;
			
			if(Ligne >= posY_Raquette1 AND Ligne <= posY_Raquette1 + LARGEUR_Raquette) then
				if(Colonne >= posX_Raquette1 AND Colonne <= posX_Raquette1 + LONGUEUR_Raquette) then
					VGA_R <= 15;
					VGA_G <= 15;
					VGA_B <= 15;
				end if;
			end if;
			
			if(Ligne >= posY_Raquette2 AND Ligne <= posY_Raquette2 + LARGEUR_Raquette) then
				if(Colonne >= posX_Raquette2 AND Colonne <= posX_Raquette2 + LONGUEUR_Raquette) then
					VGA_R <= 15;
					VGA_G <= 15;
					VGA_B <= 15;
				end if;
			end if;
			
 		else
			VGA_R <= 0;
			VGA_G <= 0;
			VGA_B <= 0;
		end if;	
	END PROCESS couleurs;
	
	
	position : PROCESS(VGA_VS)
	BEGIN
		if rising_edge(VGA_VS) then
			posx_Balle <= posX_Balle + Vx_Balle;
			posy_Balle <= posY_Balle + Vy_Balle;
			
			if((posY_Raquette1 + vY_Raquette1 <= LIM_BAS - LARGEUR_RAQUETTE) AND (posY_Raquette1 + vY_Raquette1 >= LIM_HAUT)) then  
				posY_Raquette1 <= posY_Raquette1 + vY_Raquette1;
			end if;
			
			if(Vx_Balle > 0) then
				if((posY_Raquette2 + 2 <= LIM_BAS - LARGEUR_RAQUETTE) AND (posY_Raquette2 + 2 >= LIM_HAUT) AND (posy_Balle > posy_Raquette2)) then  
					posY_Raquette2 <= posY_Raquette2 + 2;
				end if;
				if((posY_Raquette2 -2  <= LIM_BAS - LARGEUR_RAQUETTE) AND (posY_Raquette2 -2  >= LIM_HAUT) AND (posy_Balle < posy_Raquette2)) then 
					posY_Raquette2 <= posY_Raquette2 - 2;
				end if;
			else
				if((posY_Raquette2 + Vy_Raquette1 <= LIM_BAS - LARGEUR_RAQUETTE) AND (posY_Raquette2 + Vy_Raquette1 >= LIM_HAUT)) then
					posY_Raquette2 <= posY_Raquette2 + Vy_Raquette1;
				end if;
			end if;
			
			
			if((posX_Balle >= LIM_DROITE - LONGUEUR_BALLE AND Vx_Balle > 0)) then
				posX_Balle <= 300;
				if(score1 < 9) then
					score1 <= score1 + 1;
				else 
					score1 <= 0;
					score2 <= 0;
				end if;
			end if;
			
			if((posX_Balle <= LIM_GAUCHE AND Vx_Balle < 0)) then
				posX_Balle <= 300;
				if(score2 < 9) then
					score2 <= score2 + 1;
				else 
					score1 <= 0;
					score2 <= 0;
				end if;
			end if;
			
			if((posY_Balle >= LIM_BAS - LARGEUR_BALLE AND Vy_Balle > 0) OR (posY_Balle <= LIM_HAUT AND Vy_Balle < 0)) then
				Vy_Balle <= -Vy_Balle;
			end if;
			
			if((posX_Balle >= posX_Raquette2 - LONGUEUR_BALLE) AND Vx_Balle > 0) then
				if((posY_Balle >= posY_Raquette2 - LARGEUR_BALLE) AND (posY_Balle <= posY_Raquette2 +  LARGEUR_RAQUETTE)) then
					Vx_Balle <= -Vx_Balle;
				end if;
			end if;
			
			if((posX_Balle <= posX_Raquette1 + LONGUEUR_RAQUETTE) AND Vx_Balle < 0) then
				if((posY_Balle > posY_Raquette1 - LARGEUR_BALLE) AND (posY_Balle < posY_Raquette1 + LARGEUR_RAQUETTE)) then
					Vx_Balle <= -Vx_Balle;				
				end if;
			end if;
			
			case KEY is
				when "01" => Vy_Raquette1 <= 3;
				when "10" => Vy_Raquette1 <= -3;
				when others => Vy_Raquette1 <= 0;
			end case;
		end if;
	END PROCESS position;
	
	
	score : PROCESS(score1, score2)
	BEGIN
		case score1 is
			when 0 => HEX4 <= "1000000";
			when 1 => HEX4 <= "1111001";
			when 2 => HEX4 <= "0100100";
			when 3 => HEX4 <= "0110000";
			when 4 => HEX4 <= "0011001";
			when 5 => HEX4 <= "0010010";
			when 6 => HEX4 <= "0000010";
			when 7 => HEX4 <= "1111000";
			when 8 => HEX4 <= "0000000";
			when 9 => HEX4 <= "0010000";
			when others => HEX4 <= "1111111";
		end case;
			
		case score2 is
			when 0 => HEX1 <= "1000000";
			when 1 => HEX1 <= "1111001";
			when 2 => HEX1 <= "0100100";
			when 3 => HEX1 <= "0110000";
			when 4 => HEX1 <= "0011001";
			when 5 => HEX1 <= "0010010";
			when 6 => HEX1 <= "0000010";
			when 7 => HEX1 <= "1111000";
			when 8 => HEX1 <= "0000000";
			when 9 => HEX1 <= "0010000";
			when others => HEX1 <= "1111111";
		end case;
	END PROCESS score;
	
	son : PROCESS(MAX10_CLK1_50)
	BEGIN  
		if rising_edge(MAX10_CLK1_50) then
				if r=100000 then r <= conv_std_logic_vector(0,17);
					else r <= r+1;
				end if;
			if r < 50000 then
					clk_440 <= '1'; 
			else clk_440 <= '0';
			end if;
		Arduino_IO4 <= clk_440;
		end if;
		END PROCESS son;
END algorithme;
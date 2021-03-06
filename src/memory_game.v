module memory_game(clk, rst, enable, bIn, switchIn, gameTimeout, // inputs
				   score, redLight, g1, g2, g3, endGame, timerEnable, reconfig, g4, gameWait); // outputs

	input clk, rst, enable, bIn, gameTimeout; // gameTimeout ends the game when timer reaches 0, button input
	input[15:0] switchIn; // input switches
	
	output reg g1, g2, g3, g4, endGame, timerEnable, reconfig; // green leds to track which pairs you got right, end game
	output reg[3:0] score;
	output reg[15:0] redLight; // turns on red LEDs to match

	reg oneSecEnable, enablePairs;
	reg[15:0] num1, num2, num3; // 3 pair sets

	reg[3:0] state;
	parameter[3:0] GAMEWAIT = 0, INIT = 1, RETRIEVE = 2, FLASH1 = 3, FLASH2 = 4, FLASH3 = 5,
				   PAIR1 = 6, PAIR2 = 7, PAIR3 = 8, GAMEEND = 9;

	wire oneSecTimeout, endPairs;
	wire [3:0] A, B, C, D, E, F;

	wire [3:0] counter;

	output reg gameWait;

	memoryPairs memPairs(clk, rst, enablePairs, A, B, C, D, E, F, endPairs);
	one_second_timer oneSecondTimer(clk, rst, oneSecEnable, oneSecTimeout, 0);

	always @(posedge clk)
		begin
			if(!rst)
				begin
					gameWait <= 1;
					state <= GAMEWAIT;
					redLight <= 16'b0000_0000_0000_0000;
					g1 <= 0;
					g2 <= 0;
					g3 <= 0;
					score <= 0;
					oneSecEnable <= 0;
					endGame <= 0;
					enablePairs <= 0;
					timerEnable <= 0;
					reconfig <= 0;
				end
			else if(enable)
				begin
					case(state)
						GAMEWAIT:
							begin
								score <= 0;
								gameWait <= 1;
								timerEnable <= 0;
								reconfig <= 1;
								if(bIn)
									state <= INIT;
								else
									state <= GAMEWAIT;
							end
						INIT:
							begin
								gameWait <= 0;
								reconfig <= 0;
								endGame <= 0;
								timerEnable <= 1;
								g1 <= 0;
								g2 <= 0;
								g3 <= 0;
								g4 <= 1;
								enablePairs <= 1;
								if(gameTimeout)
									state <= GAMEEND;
								else
									begin
										state <= RETRIEVE;									
									end
							end
						RETRIEVE:
							begin
								if(gameTimeout)
									state <= GAMEEND;
								else
									begin
										enablePairs <= 0;
										if(endPairs)
											begin
												num1 = 16'b0000_0000_0000_0000;
												num1[A] = 1'b1;
												num1[F] = 1'b1;
												num2 = 16'b0000_0000_0000_0000;
												num2[B] = 1'b1;
												num2[E] = 1'b1;
												num3 = 16'b0000_0000_0000_0000;
												num3[C] = 1'b1;
												num3[D] = 1'b1;
												enablePairs <= 0;
												state <= FLASH1;
											end
										else
											state <= RETRIEVE;
									end
							end
						FLASH1:
							begin
								if(gameTimeout)
									state <= GAMEEND;
								else
									begin
										oneSecEnable <= 1;
										redLight[A] <= 1'b1;
										redLight[F] <= 1'b1;
										if(oneSecTimeout)
											begin
												redLight <= 16'b0000_0000_0000_0000;
												oneSecEnable <= 0;
												state <= FLASH2;
											end
										else
											state <= FLASH1;				
									end
							end
						FLASH2:
							begin
								if(gameTimeout)
									state <= GAMEEND;
									else
										begin
											oneSecEnable <= 1;
											redLight[B] <= 1'b1;
											redLight[E] <= 1'b1;
											if(oneSecTimeout)
												begin
													redLight <= 16'b0000_0000_0000_0000;
													oneSecEnable <= 0;
													state <= FLASH3;
												end
											else
												state <= FLASH2;
										end
							end
						FLASH3:
							begin
								if(gameTimeout)
									state <= GAMEEND;
									else
										begin
											oneSecEnable <= 1;
											redLight[C] <= 1'b1;
											redLight[D] <= 1'b1;
											if(oneSecTimeout)
												begin
													redLight <= 16'b0000_0000_0000_0000;
													oneSecEnable <= 0;
													state <= PAIR1;
												end
											else
												state <= FLASH3;
										end
							end
						PAIR1:
							begin
								if(gameTimeout)
									state <= GAMEEND;
								else
									begin
										if(bIn)
											begin
												if(num1 == switchIn)
													begin
														g1 <= 1;
														state <= PAIR2;
													end
												else
													state <= PAIR1;
											end
										else
											state <= PAIR1;
									end
							end
						PAIR2:
							begin
								if(gameTimeout)
									state <= GAMEEND;
								else
									begin
										if(bIn)
											begin
												if(num2 == switchIn)
													begin
														g2 <= 1;
														state <= PAIR3;
													end
												else
													state <= PAIR2;
											end
										else
											state <= PAIR3;
									end
							end
						PAIR3:
							begin
								if(gameTimeout)
									state <= GAMEEND;
								else
									begin
										if(bIn)
											begin
												if(num3 == switchIn)
													begin
														g3 <= 1;
														score <= score + 1;
														state <= INIT;
													end
												else
													begin
														state <= PAIR3;
													end
											end
										else 
											state <= PAIR3;
									end
							end
						GAMEEND:
							begin
								timerEnable <= 0;
								endGame <= 1;
								state <= GAMEWAIT;
								redLight <= 0;
							end
					endcase
				end
		end

endmodule
/********************************
 * Colton Prettyman				*
 * Advanced Arch&Org 460 EW		*
 * Professor Kosuke Immamura	*
 * Final Project				*
 * 12-06-2013					*
 ********************************/

module VGADriver(R, G, B, Vsync, Hsync, sysclk,curnum0, curnum1, curnum2, curnum3, KeyData);

input sysclk;
input[7:0] KeyData;
output[3:0] curnum0, curnum1, curnum2, curnum3;
reg[3:0] curnum0, curnum1, curnum2, curnum3;
output[3:0] R, G, B;
reg[3:0] R, G, B;
output Vsync, Hsync;
reg Vsync, Hsync;
reg iclk;
reg[31:0] Vcount;
reg[31:0] Hcount;
reg aclk;
reg[31:0] count;

// This will be my animation stuff for the paddle
reg[31:0]  dx = 0;
reg[31:0]  dy = 0;
reg[31:0] X_top = 304;
reg[31:0] Y_top = 445;
reg[31:0] X_width = 30;
reg[31:0] Y_width = 30;
reg[31:0] A_inc=0;

// This will be the animation stuff for the ball
// vf = vi + at
reg[31:0] dxb = 1;
reg[31:0] dyb = 0;
reg[31:0] X_topb = 304;
reg[31:0] Y_topb = 300;
reg[31:0] X_widthb = 30;
reg[31:0] Y_widthb = 30;
reg[31:0] A_incb=0;
reg[31:0] timeb = 75;
reg[31:0] gravityb = 5;

// This is the left and right goal post stuff
reg [31:0] X_toplg = 0;
reg [31:0] X_widthg = 10;
reg [31:0] Y_widthg = 30;
reg[31:0] X_toprg = 630;
reg[31:0] Y_topg = 0;

// Here is the center object. 
reg[31:0] X_topc = 220;
reg[31:0] X_widthc = 200;
reg[31:0] Y_topc = 180;
reg[31:0] Y_widthc = 20;

// Win animation logIC
reg win = 0;
reg[31:0] displaycount=0;
reg[31:0] displaywin=9000000; //The time to display the win animation
// need to make the score attached to the 7 segment display

always@(posedge sysclk)
begin
	iclk = ~iclk;
end

always@(posedge sysclk)
begin
	
	if( count > 20000 )
	begin
		aclk = ~aclk;
	end
	else
		count = count +1;
	
end

always@(posedge iclk )
begin
	
	// Toggle our colors
	if( Vcount < 480 && Hcount < 640 )
		begin
		
		if( win == 0 )
		begin
				/* w = 0x01d;
				*  a = 0x01c;
				*  d = 0x023;
				*  s = 0x01b; */
			
			if( KeyData == 8'b00011100) // a is pressed move left
				dx = -1;
			if( KeyData == 8'b00100011) // d is pressed move right
				dx = 1;
			if( KeyData == 8'b00011101) // w is pressed move up
				dy = -1;
			if( KeyData == 8'b00011011) // s is pressed move down
				dy = 1;
				
			if( KeyData == 8'b11110000) // space key pressed stop movement
			begin
				dx = 0;
				dy = 0;
			end
			
			if( ((X_top + X_width + dx) >= 639 || (X_top+dx <= 0)) ) // x coordinates out of bounds
					dx = 0;
		
			if( ((Y_top + Y_width + dy) >= 479 || (Y_top+dy <= 0)) ) // y coordinates out of bounds
					dy = 0;
			
			if( ((X_topb + X_widthb + dxb) >= 639 || (X_topb+dxb <= 0)) ) // x coordinates out of bounds
					dxb = dxb*-1;
			
			if( ((Y_topb + Y_widthb + dyb) >= 479 || (Y_topb+dyb <= 0)) ) // y coordinates out of bounds
					dyb = dyb*-1;
			// Handle the case when the ball is pushed outside of the game
			if( (Y_topb + Y_widthb +dyb < 5)||(Y_topb +dyb > 475)|| (X_topb + X_widthb +dxb < 5)|| (X_topb+dxb > 635 ) )
			begin
					X_topb = 304;
					Y_topb = 400;
					dxb = -1;
			end
		
			/***************************BEGIN GAME LOGIC****************************************************/
			// If a collision between goal posts increment the score and reset the game
			
			//Check y collision of goal post...coming from below
			if( (Y_topb > Y_topg) && (Y_topb < Y_topg+Y_widthg/10))
			begin
				//Check x collision of goal post...in between goal post
				if( (X_topb > X_toplg+X_widthg) && (X_topb+X_widthb < X_toprg) )
				begin
					// start win animation	
					// make the goals closer
					X_toplg = X_toplg + 5;
					X_toprg = X_toprg - 5;
					// reset the ball data
						X_top = 304;
						Y_top = 445;
						X_topb = 304;
						Y_topb = 300;
						dy = 0;
						dx = 0;
						dyb = 0;
						dxb = -1;
						
						// Do 7 segment display score counting
						curnum0 = curnum0 +1;
			
						if( curnum0 >= 10)	
							begin 
								curnum0 = 0;
								curnum1 = curnum1 +1;
							end
						if(curnum1 >= 10)
							begin
								curnum1 = 0;
								curnum2 = curnum2 +1;
							end
			
						if( curnum2 >= 10)
							begin
								curnum2 = 0;
								curnum3 = curnum3 + 1;
							end
			
						if( curnum3 >= 10 )
							begin
								curnum3 = 0;
						end
						
						// User how close the paddles are together to determine a win
						if( (X_widthb+10) > ( X_toprg - (X_toplg + X_width)))
						begin
							// The user has won!! win animation
							win = 1;
						end
				end
			end
			/***************************END GAME LOGIC****************************************************/
			
			/***************************BEGIN COLLISION DETECTION*************************************/
			//The ball has collided the paddle from the y direction
			if( ((Y_topb +dyb >= Y_top && Y_topb+dyb <= (Y_top+Y_width) )) ||
						((Y_topb+Y_width+dyb) >= Y_top) && ((Y_topb+Y_width +dyb <= Y_top+Y_width)) ) // y coordinates out of bounds
			begin
					if( ((X_topb+dxb >= X_top && X_topb+dxb <= (X_top+X_width) )) ||
						((X_topb+X_width+dxb) >= X_top) && ((X_topb+X_width+dxb <= X_top+X_width)) )
						begin
						
							if( dyb == 0)
								dyb = dy;
							else
								dyb = dyb*-1;
						//	dxb = dx;
		
								/*if( ((Y_topb + Y_widthb + dyb) >= 479 || (Y_topb+dyb <= 0)) ) // y coordinates out of bounds
								begin
									dxb = 1;
									dyb = 0;
								end*/
								end
			end		
			//The ball has collided the from the x direction
			if( ((X_topb+dxb >= X_top && X_topb+dxb <= (X_top+X_width) )) ||
						((X_topb+X_width+dxb) >= X_top) && ((X_topb+X_width+dxb <= X_top+X_width)) )	 
			begin
					if( ((Y_topb +dyb >= Y_top && Y_topb+dyb <= (Y_top+Y_width) )) ||
						((Y_topb+Y_width+dyb) >= Y_top) && ((Y_topb+Y_width +dyb <= Y_top+Y_width)) )
						begin
							
							if( dxb == 0)
								dxb = dx;
							else
								dxb = dxb*-1;
								
							//dyb = dy;
							
							/*if( ((X_topb + X_widthb + dxb) >= 639 || (X_topb+dxb <= 0)) ) // x coordinates out of bounds
							begin
								dxb = 0;
								dyb = 1;
							end*/
						end
			end
			
			// The ball has collided with the left goal post from the y direction
			if( ((Y_topb +dyb >= Y_topg && Y_topb+dyb <= (Y_topg+Y_widthg) )) ||
						((Y_topb+Y_width+dyb) >= Y_topg) && ((Y_topb+Y_width +dyb <= Y_topg+Y_widthg)) ) // y coordinates out of bounds
			begin
					if( ((X_topb+dxb >= X_toplg && X_topb+dxb <= (X_toplg+X_widthg) )) ||
						((X_topb+X_width+dxb) >= X_toplg) && ((X_topb+X_width+dxb <= X_toplg+X_widthg)) )
						begin
							dyb = dyb*-1;
						end
			end
			//The ball has collided with the left goal post from the x direction
			if( ((X_topb+dxb >= X_toplg && X_topb+dxb <= (X_toplg+X_widthg) )) ||
						((X_topb+X_width+dxb) >= X_toplg) && ((X_topb+X_width+dxb <= X_toplg+X_widthg)) )	 
			begin
					if( ((Y_topb +dyb >= Y_topg && Y_topb+dyb <= (Y_topg+Y_widthg) )) ||
						((Y_topb+Y_width+dyb) >= Y_topg) && ((Y_topb+Y_width +dyb <= Y_topg+Y_widthg)) )
						begin
							dxb = dxb*-1;
						end
			end
			
				// The ball has collided with the right goal post from the y direction
			if( ((Y_topb +dyb >= Y_topg && Y_topb+dyb <= (Y_topg+Y_widthg) )) ||
						((Y_topb+Y_width+dyb) >= Y_topg) && ((Y_topb+Y_width +dyb <= Y_topg+Y_widthg)) ) // y coordinates out of bounds
			begin
					if( ((X_topb+dxb >= X_toprg && X_topb+dxb <= (X_toprg+X_widthg) )) ||
						((X_topb+X_width+dxb) >= X_toprg) && ((X_topb+X_width+dxb <= X_toprg+X_widthg)) )
						begin
							dyb = dyb*-1;
						end
			end
			//The ball has collided with the right goal post from the x direction
			if( ((X_topb+dxb >= X_toprg && X_topb+dxb <= (X_toprg+X_widthg) )) ||
						((X_topb+X_width+dxb) >= X_toprg) && ((X_topb+X_width+dxb <= X_toprg+X_widthg)) )	 
			begin
					if( ((Y_topb +dyb >= Y_topg && Y_topb+dyb <= (Y_topg+Y_widthg) )) ||
						((Y_topb+Y_width+dyb) >= Y_topg) && ((Y_topb+Y_width +dyb <= Y_topg+Y_widthg)) )
						begin
							dxb = dxb*-1;
						end
			end
			
			//The ball has collided with the center object from the y direction
			if( ((Y_topb +dyb >= Y_topc && Y_topb+dyb <= (Y_topc+Y_widthc) )) ||
						((Y_topb+Y_width+dyb) >= Y_topc) && ((Y_topb+Y_width +dyb <= Y_topc+Y_widthc)) ) // y coordinates out of bounds
			begin
					if( ((X_topb+dxb >= X_topc && X_topb+dxb <= (X_topc+X_widthc) )) ||
						((X_topb+X_width+dxb) >= X_topc) && ((X_topb+X_width+dxb <= X_topc+X_widthc)) )
						begin
						
							/*if( dyb == 0)
								dyb = dy;
							else
								dyb = dyb*-1;
							end*/
							
							dyb = dyb *-1;
							dxb = dxb *-1;
							//if( dxb == 0)
							//	dxb = 1;
						//	dxb = dxb * -1;
						end
			end		
			//The ball has collided the from the x direction
			if( ((X_topb+dxb >= X_topc && X_topb+dxb <= (X_topc+X_widthc) )) ||
						((X_topb+X_width+dxb) >= X_topc) && ((X_topb+X_width+dxb <= X_topc+X_widthc)) )	 
			begin
					if( ((Y_topb +dyb >= Y_topc && Y_topb+dyb <= (Y_topc+Y_widthc) )) ||
						((Y_topb+Y_width+dyb) >= Y_topc) && ((Y_topb+Y_width +dyb <= Y_topc+Y_widthc)) )
						begin
							
							/*if( dxb == 0)
								dxb = dx;
							else
								dxb = dxb*-1;*/
								
								dxb = dxb *-1;
								dyb = dyb *-1;
						//	if( dyb == 1)
							//	dyb = 1;
								
						//	dyb = dyb * -1;
						end
			end
		
			/***************************END COLLISION DETECTION*************************************/
			
			/***************************BEGIN DRAWING OBJECTS TO THE SCREEN*************************/
			// Only increment after we drew the whole picture.
			// X_inc/Y_inc keeps track of draw counts for a static image...
			// It makes sure the whole image is drawn before adding dx and dy values
			// In this way skewing is prevented for moving objects. 
				if( A_inc >= X_width*Y_width*100)
					begin
						X_top = X_top + dx;
						Y_top = Y_top + dy;
						A_inc = 0; 
					end
				else	
					A_inc = A_inc + 1;
				
				// Drawing the ball
				if( A_incb >= X_widthb*Y_widthb*timeb)
					begin
					// Do calculations on the gravity->velocity->dx/dy values of the ball
					//	timeb = timeb-dyb*gravityb;
						
						X_topb = X_topb + dxb;
						Y_topb = Y_topb + dyb;
						A_incb = 0; 
					end
				else	
					A_incb = A_incb + 1;
					
			// Draw the background first
			R <= 4'b1100;
			G <= 4'b1100;
			B <= 4'b1100;
					
				// Draw left boundary line
			if(Hcount >= 0 && Hcount < 5)
				begin
						R <= 4'b1001;
						G <= 4'b1100;
						B <= 4'b1111;
				end
				
				//Draw right boundary line
			if( Hcount > 635 && Hcount < 640 )
			begin
						R <= 4'b1001;
						G <= 4'b1100;
						B <= 4'b1111;
			end
				// Draw top boundary line
			if( Vcount >= 0 && Vcount < 5)
				begin
						R <= 4'b1001;
						G <= 4'b1100;
						B <= 4'b1111;
				end
				// Draw bottom boundary line
			if( Vcount > 475 && Vcount < 480)
				begin
						R <= 4'b1001;
						G <= 4'b1100;
						B <= 4'b1111;
				end
				
				// Draw the left goal post
			if( Hcount > X_toplg && Hcount < X_toplg + X_widthg )
			begin
				if( Vcount > Y_topg && Vcount < Y_topg + Y_widthg )
				begin
						R <= 4'b1111;
						G <= 4'b1111;
						B <= 4'b0000;
				end
			end
			
			// Draw the right goal post
				if( Hcount > X_toprg && Hcount < X_toprg + X_widthg )
				begin
					if( Vcount > Y_topg && Vcount < Y_topg + Y_widthg )
					begin
						R <= 4'b1111;
						G <= 4'b1111;
						B <= 4'b0000;
					end
			end
			
			if( (Vcount > Y_topc && Vcount < (Y_widthc + Y_topc) ) && (Hcount > X_topc && Hcount < (X_widthc + X_topc) ) )
			begin
					R <= 4'b1111;
					G <= 4'b0000;
					B <= 4'b0000;
			end
			// Draw the player here
			if( (Vcount > Y_top && Vcount < (Y_width + Y_top) ) && (Hcount > X_top && Hcount < (X_width + X_top) ) )
				begin
						R <= 4'b1001;
						G <= 4'b1111;
						B <= 4'b1111;
				end
				// Draw the ball here
			if( (Vcount > Y_topb && Vcount < (Y_widthb + Y_topb) ) && (Hcount > X_topb && Hcount < (X_widthb + X_topb) ) )
				begin
						R <= 4'b1111;
						G <= 4'b0110;
						B <= 4'b0000;
				end
				
			
			
		end	// end draw bound if statement. 640x480
		else // end no win
			begin
				if( displaycount > displaywin)
				begin
						win = 0;
						displaycount =0;
						X_toplg = 0;
						X_toprg = 630;
						// reset the balls and user
						X_top = 304;
						Y_top = 445;
						X_topb = 304;
						Y_topb = 300;
						dy = 0;
						dx = 0;
						dyb = 0;
						dxb = 1;
						curnum0 = 4'b0000;
						curnum1 = 4'b0000;
						curnum2 = 4'b0000;
						curnum3 = 4'b0000;
				end
				else
				begin
					displaycount = displaycount +1;
					R <= 4'b1111;
					G <= 4'b1111;
					B <= 4'b1111;
				end
			end //end win
		end
	else 	// outside the draw boundary...turn colors off
		begin
			R <= 4'b0000;
			G <= 4'b0000;
			B <= 4'b0000;
		end
		/***************************END DRAWING OBJECTS TO THE SCREEN*************************/
		
		
		/************************************BEGIN VGA ADJUSTMENTS HERE*********************************/
	// End Horiz. Front Porch
	if( Hcount > 655 && Hcount < 752 )
	begin
		 Hsync = 0;
	end
	else
		Hsync = 1;
	
	// End Horiz. Back porch
	if( Hcount >= 800 )
	begin
		Hcount = 0;
		Vcount = Vcount + 1;
	end
	
	//End vertical Front Porch
	if( Vcount > 490 && Vcount < 492)
	begin
		 Vsync = 0;
	end
	else // End vertical Front Porch
		Vsync = 1;
	
	//End vertical Back porch
	if( Vcount >= 525)
	begin
		Vcount = 0;
	end
	
	Hcount = Hcount + 1;
	
	/************************************END VGA ADJUSTMENTS HERE*********************************/
end
endmodule

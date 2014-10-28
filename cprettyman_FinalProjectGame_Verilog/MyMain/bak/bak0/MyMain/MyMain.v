/******************************************
* Colton Prettyman 								*
* Final Project									*
* Professor Kosuke Immamura					*					
* Advanced Architecture And Organization	*
* 11-25-2013										*
*******************************************/
module MyMain( R, G, B,Vsync, Hsync, kyClk, kyData, clk, led, kd);

output[3:0] R, G, B;
output Vsync, Hsync;
input kyClk, kyData, clk;
output led;
output kd;

assign led = Display;
assign kd = KeyData;

Keyboard KBD(Display, KeyData, kyClk, kyData, clk);
VGADriver   VGAD( R, G, B, Vsync, Hsync, clk, Display, KeyData);


endmodule


// Keyboard Module. 
module Keyboard( Display, keydata, kyClk, kyData, clk);

input kyClk, kyData, clk;
output Display;
output keydata;
reg Display;

reg[7:0] keydata;
reg[31:0] cycles;
reg[7:0] inputbuffer;
reg gotStart;
reg[31:0] count;
reg newKbClk;
reg [20:0] countKb;
reg[10:0] element;

//internal clock generator
//cleans up the keyboard clock
 always@(posedge clk)
 begin
	countKb = {countKb[20:0], kyClk}; // shift register.... push on on one falls off
	if(countKb == 4'hffff)
	begin
		newKbClk = 1;
	end
	else
	if(countKb == 4'h0000)
		newKbClk = 0;
	else
		newKbClk = newKbClk;

 end//end clock generator

always@(negedge newKbClk)
begin
	
	if( (kyData == 0) )
	begin 
		 gotStart = 1;
	end
	
   if ( (gotStart == 1) && (cycles < 9) && (cycles > 0))
	begin
		inputbuffer[element] = kyData;
		element = element +1;
	end
	
	
	
	if(cycles >= 10 )
	begin		
		cycles = 0;
		gotStart = 0;
		element = 0;
		
		/*if( inputbuffer == 0xF0 )
		begin
			// Deal with keyup here
		end
		else if( inputbuffer == 0xE0 )
		begin
			// Deal with extended keys here
		end
		else	// It must be regular key data
			begin
				keydata = inputbuffer;
			end */
			keydata = inputbuffer;
		
		// Set to display a color here. 
		Display = ~Display;
		end
	else
		cycles = cycles + 1;
end
endmodule


module VGADriver(R, G, B, Vsync, Hsync, sysclk, Display, KeyData);

input sysclk;
input Display;
input KeyData;
output[3:0] R, G, B;
reg[3:0] R, G, B;
output Vsync, Hsync;
reg Vsync, Hsync;
reg iclk;
reg[31:0] Vcount;
reg[31:0] Hcount;
reg aclk;
reg[31:0] count;

// This will be my animation stuff.
reg[31:0]  dx = 1;
reg[31:0]  dy = 1;
reg[31:0] X_top = 0;
reg[31:0] Y_top = 0;
reg[31:0] X_width = 30;
reg[31:0] Y_width = 30;
reg[31:0] A_inc=0;

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
		
			// Check for X out of bounds
			if( ((X_top + X_width) >= 639 ))
					dx = -1;
			if( X_top <= 0)
					dx = 1;
			// Check for Y out of bounds
			if( ((Y_top + Y_width) >= 479 ) )
				dy = -1;
			if( (Y_top <= 0))
				dy = 1;
			
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
				
			// Draw the background first
			R <= 4'b0000;
			G <= 4'b0000;
			B <= 4'b1111;
		
			if( Display == 0 ) //  A key has been pressed....change the color
					begin
						R <= 4'b1111;
						G <= 4'b0000;
						B <= 4'b1111;
					end
					
				// Draw the center line
			if(Hcount > 315 && Hcount < 325)
				begin
						R <= 4'b1111;
						G <= 4'b1111;
						B <= 4'b1111;
				end
			// Draw the ball here
			if( (Vcount > Y_top && Vcount < (Y_width + Y_top) ) && (Hcount > X_top && Hcount < (X_width + X_top) ) )
				begin
						R <= 4'b0000;
						G <= 4'b1111;
						B <= 4'b0000;
				end
				
		
	end	// end draw bound if statement. 640x480
	else 	// outside the draw boundary...turn colors off
		begin
			R <= 4'b0000;
			G <= 4'b0000;
			B <= 4'b0000;
		end
		
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
end
endmodule











/********************************
 * Colton Prettyman				*
 * Advanced Arch&Org 460 EW		*
 * Professor Kosuke Immamura	*
 * Final Project				*
 * 12-06-2013					*
 ********************************/

// Keyboard Module. 
module Keyboard(KeyData, kyClk, kyData, clk);

input kyClk, kyData, clk;
output[7:0] KeyData;
reg[7:0] KeyData;
reg[7:0] tempdata;
reg[31:0] cycles;
reg gotStart;
reg[31:0] count;
reg newKbClk;
reg [20:0] countKb;
reg[10:0] element;
reg keyup=0;

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
		tempdata[element] = kyData;
		element = element +1;
	end
	
	
	
	if(cycles >= 10 )
	begin		
		cycles = 0;
		gotStart = 0;
		element = 0;
		end
	else
		cycles = cycles + 1;
end

always@(negedge gotStart)
begin
// do assigning from tempdata to KeyData here. 
// the data = f0
if( tempdata == 8'b11110000 )
begin
	keyup = 1;
	KeyData = 8'b11110000;
end

else if( keyup == 0 && tempdata != 8'b11110000 )
begin
	KeyData = tempdata;
end
else
begin
	KeyData = 8'b11110000;
	keyup = 0;
end

end
endmodule

/********************************
 * Colton Prettyman				*
 * Advanced Arch&Org 460 EW		*
 * Professor Kosuke Immamura	*
 * Final Project				*
 * 12-06-2013					*
 ********************************/
module MyMain( R, G, B,Vsync, Hsync,Display0, Display1, Display2, Display3, kyClk, kyData, clk,kd, c0, c1, c2, c3);

output[3:0] R, G, B;
output Vsync, Hsync;
input kyClk, kyData, clk;
output[7:0] kd;
wire[7:0] KeyData;

output[ 6:0 ] Display0, Display1, Display2,Display3;
wire[3:0] curnum0, curnum1, curnum2, curnum3;
output[3:0] c0, c1, c2, c3;

assign kd = KeyData;
assign  c0 = curnum0;
assign c1 = curnum1;
assign c2 = curnum2;
assign c3 = curnum3;

SegmentDriver SegmD0(Display0, curnum0);
SegmentDriver SegmD1(Display1, curnum1);
SegmentDriver SegmD2(Display2, curnum2);
SegmentDriver SegmD3(Display3, curnum3);

Keyboard KBD(KeyData, kyClk, kyData, clk);
VGADriver   VGAD( R, G, B, Vsync, Hsync, clk, curnum0, curnum1, curnum2, curnum3, KeyData);


endmodule
















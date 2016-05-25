`timescale 1ns / 1ps
module delay #(
	parameter DW = 32,
	parameter DEL = 12
	)(
    input clk,
    input  [DW	-1:0] i_d,	
	output [DW	-1:0] o_d
    );
 // Check DEL parameter		
 initial begin 	if (DEL<0)	 $error ("DEL must be positive!"); end
 
// Shift reg atleast 1 data, to prevent exeptions
  reg [DEL + 1 -1:0][DW-1:0] r_arr_d ;

  always @ (posedge clk) begin	
	r_arr_d	[0] <= i_d;
	r_arr_d[DEL + 1 -1:1] <= r_arr_d[DEL + 1 -2:0];
  end								   
 
 // If zero, bypass, else assign reg value
 assign  o_d = (DEL>0) ? r_arr_d [DEL-1] : i_d;  
    
endmodule

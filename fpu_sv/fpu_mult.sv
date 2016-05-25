`timescale 1ns / 1ps  
//-------------------------
//-- Floating point multiplications
//--------------------------
import fpu_pack::*;
module fpu_mult(
    input  clk,
    input  real_t i_a,
    input  real_t i_b,
    output real_t o_c
    );
 import fpu_pack::*; 	
 
 
real_ext_t 	raw_mult	;
real_ext_t	norm_mult	; 
real_t 		rez_mult	; 
//--------------------------------------
// 	Raw multiplication
//-------------------------------------
always @ (posedge clk) begin	
 	raw_mult.sign <= i_a.sign ^ i_b.sign  					; // 1..0
 	raw_mult.expn <= i_a.expn + i_b.expn - EXP_BASE         ; // [-127.. 385]  E(0+0-127	
	raw_mult.frac <= {1'b1, i_a.frac} * {1'b1, i_b.frac}	; // Fill with 1 and multiply
end		  
//---------------------------------
// Saturate number to 1 max signed bit
//---------------------------------	   
// 1.000.. * 1.000.. = 01.0000
// 1.111.. * 1.111.. = 11.1111
// So we if   MSB is 1, then normalize, 
// else keep as it is
always @ (posedge clk) begin
	norm_mult.sign <= raw_mult.sign		 ;
	if (raw_mult.frac[BW_FRAC_EXT-1]) begin
	 	norm_mult.frac <= raw_mult.frac >> 1 ;
		norm_mult.expn <= raw_mult.expn +  1 ; 
	end  else begin
		norm_mult.frac <= raw_mult.frac ;
		norm_mult.expn <= raw_mult.expn ;	
	end
end
//---------------------------------
// Truncate number
//---------------------------------
always 	@ (posedge clk) begin
	rez_mult.sign <=norm_mult.sign;
	if (norm_mult.expn < 0) begin // Too small
		rez_mult.expn <= '{default:0}; // Set to zero  
		rez_mult.frac <= '{default:0};
	end 	else if (norm_mult.expn > (2**BW_EXPN-1)) begin
		rez_mult.expn <= '{default:1}; // Set to inifinite
		rez_mult.frac <= '{default:0};
	end	 else begin // Acceptable number	
		rez_mult.expn <=  norm_mult.expn [BW_EXPN-1:0];
		rez_mult.frac <=  norm_mult.frac [ MSB_FRAC_EXT:LSB_FRAC_EXT ] + norm_mult.frac[LSB_FRAC_EXT-1]; 
	end
end	
//--------------------------------------
//-- Delay output
//--------------------------------------
 delay #(.DW(BW_DATA),.DEL(LAT_OUT_MULT)
) U_c_delay (
	.clk(clk),
	.i_d ( rez_mult	 ),
	.o_d ( o_c 	)
);
//------------------------------
// Debug
//------------------------------
real a,b,c;
assign a = $bitstoshortreal ( i_a );
assign b = $bitstoshortreal ( i_b );
assign c = $bitstoshortreal ( rez_mult );
 
endmodule

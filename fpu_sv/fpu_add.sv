`timescale 1ns / 1ps
import fpu_pack::*;
module fpu_add
	(
    input  clk,
    input  real_t i_a,
    input  real_t i_b,
    output real_t o_c
    );
//--------------------------
// Start module
//-------------------------
import fpu_pack::*;	  
real_t r_ia,r_ib;
reg compare_sw;

//---------------------
//-- Wires and registers
//--------------------
real_add_t r_ad0	;
real_add_t r_ad1	;
real_add_t r_ad0_s0	;
real_add_t r_ad1_s0	; 
real_add_t rez_un	;
real_add_t rez_un_d ;
real_add_t rez_norm	;  

real_t rez_trunc	;
//-----------------------------------	
// 1. Check which number is greater	   
//-----------------------------------	
reg [BW_EXPN-1:0]  r_expn_delta;  
always @ (posedge clk) begin
	r_ia<=i_a;
	r_ib<=i_b;
	if (i_a.expn < i_b.expn)
		compare_sw<=1;
	else if (i_a.expn > i_b.expn)
		compare_sw<=0;
	else if ((i_a.expn == i_b.expn)&&(i_a.frac<i_b.frac))
		compare_sw<=1;
	else
		compare_sw<=0;
end

//-----------------------------------	
// 2. Ad0 is always >= ad1 (to make futher calculations easier)  
//-----------------------------------	
always @ (posedge clk) begin 
	
	// Bad code style, replace with functions
	if (compare_sw == 0) begin
		r_ad0.expn <= r_ia.expn;
		r_ad0.mant <= {1'b1,r_ia.frac};
		r_ad0.sign <= r_ia.sign;
		
		r_ad1.expn <= r_ib.expn;
		r_ad1.mant <= {1'b1,r_ib.frac};
		r_ad1.sign <= r_ib.sign;

		r_expn_delta <= r_ia.expn - r_ib.expn;
	end else  begin
		r_ad1.expn <= r_ia.expn;
		r_ad1.mant <= {1'b1,r_ia.frac};
		r_ad1.sign <= r_ia.sign;
		
		r_ad0.expn <= r_ib.expn;
		r_ad0.mant <= {1'b1,r_ib.frac};
		r_ad0.sign <= r_ib.sign;

		r_expn_delta <= r_ib.expn - r_ia.expn;
	end
end	 											  

//------------------------------------------------
// 3. Shift less mantissa up, or keep same
//------------------------------------------------
always @(posedge clk) begin	 
	r_ad0_s0 <= r_ad0;
	r_ad1_s0 <= r_ad1;
	if (r_expn_delta < BW_FRAC) begin
		r_ad1_s0.mant <= r_ad1.mant >> r_expn_delta;
		r_ad1_s0.expn <= r_ad1.expn + r_expn_delta;
	end else begin
		r_ad1_s0.mant <= '{default:0}; 
		r_ad1_s0.expn <= '{default:0};
	end
end	  

//-------------------------------------------------
//-- 4. Get unnormolized result
//-------------------------------------------------
always @(posedge clk) begin	
	if (r_ad0_s0.sign == r_ad1_s0.sign) 
    	rez_un.mant <= r_ad0_s0.mant + r_ad1_s0.mant;
	else  // Never overflow, because ad0>=ad1
		rez_un.mant <= r_ad0_s0.mant - r_ad1_s0.mant;

	rez_un.expn <= r_ad0_s0.expn;
	rez_un.sign <= r_ad0_s0.sign;
end
//--------------------------------------------------
// 5. Normalize number for leading one
//---------------------------------------------------
fpu_normalize #(
.BW_FRAC	 (BW_FRAC_ADD	), 
.BW_EXPN  	 (BW_EXPN_ADD	),
.SET_MSB_BIT (BW_FRAC+1-1	),
.SET_BW_EXPN (BW_EXPN		)
) 
sum_normalize(
	.clk(clk),
	.i_frac ( rez_un.mant 		),
	.i_expn ( rez_un.expn 		), 
	.i_sign ( rez_un.sign		),
	
	.o_frac ( rez_norm.mant		),
	.o_expn ( rez_norm.expn		),
	.o_sign	( rez_norm.sign		)
);
//--------------------------------------------------
// 6. Truncate result
//---------------------------------------------------
always 	@ (posedge clk) begin
	rez_trunc.sign <= rez_norm.sign;
	rez_trunc.frac <= rez_norm.mant[BW_FRAC-1:0];
	rez_trunc.expn <= rez_norm.expn[BW_EXPN-1:0];
end	 
//-------------------------------------------------------
//-- 7. Delay output
//-------------------------------------------------------
 delay #(.DW(BW_DATA),.DEL(LAT_OUT_ADD)
) U_c_delay (
	.clk(clk),
	.i_d ( rez_trunc	 ),
	.o_d ( o_c			 )
);

//------------------------------
// Debug
//------------------------------
real a,b,c;
assign a = $bitstoshortreal ( i_a       );
assign b = $bitstoshortreal ( i_b       );
assign c = $bitstoshortreal ( rez_trunc );
endmodule

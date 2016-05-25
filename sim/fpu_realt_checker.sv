import fpu_pack::*;
module fpu_realt_checker #
	( parameter N_REZ  = 3,
	  parameter N_ARG  = 2
	) (
    input clk,
    input  real_t [ N_REZ  -1:0] i_rez_sim,	 
	input  real_t [ N_REZ  -1:0] i_rez_rtl
	);
import fpu_pack::*;


real_t [ N_REZ  -1:0] delta;
//----------------------------------------------
//-- Parsing fields of structure to get delta
//-----------------------------------------------
genvar j;
generate
	for (j=0;j<N_REZ; j++) begin
		assign delta[j].sign = i_rez_sim[j].sign ^ i_rez_rtl[j].sign;
		assign delta[j].expn = $unsigned( i_rez_sim[j].expn - i_rez_rtl[j].expn);
		assign delta[j].frac = $unsigned( i_rez_sim[j].frac - i_rez_rtl[j].frac);
	end	
endgenerate
//----------------------------------------------
//-- Display results
//-----------------------------------------------
integer i;
localparam DISP_EN = 0;
localparam ERR_EN  = 0;
always @(posedge clk) begin
	for (i=0; i<N_REZ; i++) begin	 
		if ((delta[i].expn > 0) || (delta[i].frac>1) || (delta[i].sign>0)) begin
			if (DISP_EN) 	$display (" RTL: SIGN: %d EXPN %d FRAC : %h ",i_rez_rtl[i].sign,i_rez_rtl[i].expn,i_rez_rtl[i].frac);
			if (DISP_EN) 	$display (" SIM: SIGN: %d EXPN %d FRAC : %h ",i_rez_sim[i].sign,i_rez_sim[i].expn,i_rez_sim[i].frac);
			if (ERR_EN )	$error ("Error occured, see log");
		end	
	end 	
end

	
endmodule

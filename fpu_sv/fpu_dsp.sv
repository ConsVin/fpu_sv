`timescale 1ns / 1ps
import fpu_pack::*;
module fpu_dsp(
    input clk,
	input  i_valid,
    input  real_t i_a,
    input  real_t i_b,
    input  real_t i_c,
    output real_t o_z, 
	output real_t o_prod,
    output o_valid
	);	  
	
//----------------------------
//-- Valid bypass
//----------------------------
  delay #(.DW(1),.DEL(DSP_LATENCY)
) U_valid_delay (
	.clk(clk),
	.i_d ( i_valid	),
	.o_d ( o_valid	)
);
//----------------------------
//-- Real multiplication
//----------------------------
real_t w_prod		;
real_t w_prod_del	;  
real_t w_c_del	; 

fpu_mult U_fpu_mult (
	.clk ( clk		),
	.i_a ( i_a	  	),
	.i_b ( i_b	  	),
	.o_c ( w_prod 	)
);	   

 delay #(.DW(BW_DATA),.DEL(LAT_ADD)
) U_prod_delay (
	.clk(clk),
	.i_d ( w_prod	),
	.o_d ( o_prod	)
);

//----------------------------
//-- Real add
//----------------------------


delay #(.DW(BW_DATA),.DEL(LAT_MULT)
) U_c_delay (
	.clk(clk),
	.i_d ( i_c	 ),
	.o_d ( w_c_del)
);

fpu_add U_FPU_ADD (.clk(clk),
	.i_a ( w_prod	),
	.i_b ( w_c_del	),
	.o_c ( o_z		)
); 
//-------------------------------
// 		DEBUG WIRES
//-------------------------------
real a_real	;
real b_real	;
real prod_real ; 
real c_real	;
real sum_real ;
assign c_real    =  $bitstoshortreal ( w_c_del 	);
assign a_real    =  $bitstoshortreal ( i_a		);
assign b_real    =  $bitstoshortreal ( i_b		);
assign prod_real =  $bitstoshortreal ( w_prod	); 
assign sum_real  =  $bitstoshortreal ( o_z		);

real_t o_z_reg;
always @(posedge clk) begin
    o_z_reg<=o_z;
    if (o_z_reg != o_z)
        $display ("%f ",sum_real); 
end



    
endmodule

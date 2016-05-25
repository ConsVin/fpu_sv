import fpu_pack::*;
module fpu_dsp_SIM #
	( parameter N_IN  = 3,
	  parameter N_OUT = 2,
	  parameter DELAY = 3
	) (
    input clk,
    input   real_t [ N_IN  -1:0] i_bus,
    output  real_t [ N_OUT -1:0] o_bus  
	);
import fpu_pack::*;

// Calculate values
shortreal   inp_sreal	[N_IN  -1:0]	;
shortreal   out_sreal	[N_OUT -1:0]	;
genvar j;	
generate
for (j=0; j<N_IN; j++) 
	assign inp_sreal[j] = $bitstoshortreal (i_bus[j]);		  
endgenerate
//=========================================================
assign 	out_sreal [1] = shortreal'(inp_sreal[0] * inp_sreal[1]);
assign 	out_sreal [0] = shortreal'( (inp_sreal[0] * inp_sreal[1])+inp_sreal[2] );
//=========================================================
// Back to bits
real_t [N_OUT-1:0] w_out_bus		;
real_t [N_OUT-1:0] w_out_bus_del	;	 
generate
for (j=0; j<N_OUT; j++)  	
	assign w_out_bus[j] = $shortrealtobits ( out_sreal[j] );	
endgenerate

delay #(.DW(N_OUT*BW_DATA),.DEL(DELAY)
) U_c_delay (
	.clk ( clk				),
	.i_d ( w_out_bus	 	),
	.o_d ( o_bus			)
);
endmodule
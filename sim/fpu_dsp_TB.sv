//-----------------------------------------------------------------------------
//
// Title       : fpu_dsp_tb
// Design      : FPU
// Author      : Const
// Company     : Home
//
//-----------------------------------------------------------------------------
//
// File        : fpu_dsp_TB.v
// Generated   : Sat May 14 12:17:12 2016
// From        : D:\fpga\Workplace_FPU\FPU\src\sim\fpu_dsp_TB_settings.txt
// By          : tb_verilog.pl ver. ver 1.2s
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ps / 1ps
module fpu_dsp_tb;

 import fpu_pack::*;
//Internal signals declarations:
reg clk;  
always begin clk = 1; forever #5 clk = ~clk; 
end 				 

parameter N_ARG = 3;
parameter N_REZ = 2;

real_t [ N_ARG  -1:0] arg	    ;
real_t [ N_REZ  -1:0] rez_sim	;
real_t [ N_REZ  -1:0] rez_rtl	;

//-----------------------------
//-	Real numbers sequnce generator
//-----------------------------
fpu_realt_generator #(.N_ARG(N_ARG)) 
	u_stimulus (.clk(clk),.o_args(arg));

//-----------------------------
// 		RTL Unit under test
//-----------------------------
fpu_dsp UUT (
	.clk 	( clk		 ),
	.i_a 	( arg [0]	 ),
	.i_b 	( arg [1]	 ),
	.i_c 	( arg [2]	 ),
	.o_z 	( rez_rtl[0] ),
	.o_prod	( rez_rtl[1] )	
); 				  
//----------------------------------
//--   Simulation model of UUT
//----------------------------------
fpu_dsp_SIM 
#(	.N_IN	( N_ARG),
	.N_OUT	( N_REZ),
	.DELAY	(DSP_LATENCY)
) U_fpu_dsp_SIM 
	(	.clk(clk),
		.i_bus(arg),
		.o_bus(rez_sim)
	);
	
//----------------------------------
//--   Check Results
//----------------------------------
fpu_realt_checker U_fpu_realt_checker 
(	.clk(clk),
	.i_rez_sim ( rez_sim ),
	.i_rez_rtl ( rez_rtl )
//	.i_args(i_args)
);	

endmodule

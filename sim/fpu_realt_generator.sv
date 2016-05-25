//-----------------------------------------
//--
//-- 	Generate Random Real numbers	   
//--    Add manualy here INF, Zero or NaN numbers
//--
//-----------------------------------------
import fpu_pack::*;
module fpu_realt_generator #
	(  parameter N_ARG  = 2
	) (
    input clk,
    output real_t [ N_ARG  -1:0] o_args  
	);
import fpu_pack::*;

shortreal o_sreal [N_ARG-1:0];

parameter N_STIM = 5;
shortreal  stim_real [N_STIM-1:0][N_ARG-1:0];
initial begin

repeat(20)@(posedge clk);  

stim_real[0] = '{ 8.12,   -1.14, 2.41};
stim_real[1] = '{-1.142,   3.982, -2.22};
stim_real[2] = '{0.43245,  8.2347, -7.882};
stim_real[3] = '{  1.824,   32.8134, -12.843};
stim_real[4] = '{7777.7, 4444.444, -812.033323};


for (int i=0; i<N_STIM; i++) begin
    for (int j=0; j<N_ARG; j++) 
       o_args[j] <= $shortrealtobits(  stim_real [i][j]);
    repeat(20)@(posedge clk); 
end

repeat(200)@(posedge clk); 
$finish;
while (1) begin	
	o_args[0] <= {$random}; 
	o_args[1] <= {$random};    
	o_args[2] <= {$random};	
	repeat(20)@(posedge clk); 

end

end

endmodule

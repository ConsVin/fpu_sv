//-------------------------------------
// Unit normalize floating point number 
// to get leading 1 in desirable place
//--------------------------------------
module fpu_normalize #(
	parameter BW_FRAC   	=  23, // Width of input mantissa
	parameter BW_EXPN   	=   9, // Width of input exponenta
	parameter SET_MSB_BIT 	=  22, // Where to set leading one
	parameter SET_BW_EXPN  	=   8  // Limit EXPN
	)(
    input  clk,
   	
	input  		[ BW_FRAC-1:0] 	i_frac	,
	input  		[ BW_EXPN-1:0] 	i_expn	,
	input 				  		i_sign	,	
	
	output reg 	[ BW_FRAC-1:0] 	o_frac	,
	output reg 	[ BW_EXPN-1:0] 	o_expn	,
	output reg				  	o_sign	// by-pass	
	);
localparam MAX_EXPN = 2**SET_BW_EXPN-1;
reg [$clog2(BW_FRAC)-1:0] r_n_max_one;	
wire [$clog2(BW_FRAC)-1:0] shift_dwn;
wire [$clog2(BW_FRAC)-1:0] shift_up;

reg 				r_all_zero;	 
reg [ BW_FRAC-1:0] 	r_frac ;
reg [ BW_EXPN-1:0] 	r_expn ; 
reg					r_sign ;
reg [ BW_FRAC-1:0] 	r1_frac ;
reg [ BW_EXPN-1:0] 	r1_expn ; 
reg					r1_sign ;
//--------------------------------
//-- Trying to fing one in mantissa
//--------------------------------
always @(posedge clk) begin
	for (int i=0; i<BW_FRAC; i++) begin
		if (i_frac[i]) r_n_max_one<=i;	
	end	
	r_all_zero <= ~|(i_frac); 
	r_frac <= i_frac;
	r_expn <= i_expn;
	r_sign <= i_sign;
end		
assign shift_dwn = r_n_max_one - SET_MSB_BIT ;
assign shift_up  = SET_MSB_BIT - r_n_max_one ;

//-----------------------------------------------------------
//-- Shift up or down mantissa with eq. change of exponenta
//------------------------------------------------------------
always @(posedge clk) begin
	if (r_n_max_one >= SET_MSB_BIT ) begin // Shift DOWN
		r1_frac <= r_frac >> shift_dwn;	
		r1_expn <= r_expn +  shift_dwn;
		end
	else begin
		r1_frac <= r_frac << shift_up;	
		r1_expn <= r_expn -  shift_up;
	end	
	r1_sign <= r_sign;
end
//-----------------------------------------------------------
//-- Check output, set to inf of 0 if need to
//------------------------------------------------------------
wire w_is_neg, w_is_ovfl;
assign 	w_is_neg  = (r1_expn < 0		 );
assign 	w_is_ovfl = (r1_expn > MAX_EXPN  );

always @(posedge clk) begin
	o_sign <= r1_sign;
  	if (w_is_neg) begin
		o_frac <= '{default:0};// Set to zero
  		o_expn <= '{default:0};
	end
	else if (w_is_ovfl) begin  // Set to infinite
		o_frac <= '{default:0};
  		o_expn <= '{default:1};
 	end
	
	else begin
		o_frac <= r1_frac;
  		o_expn <= r1_expn;
 	end
end



endmodule	

//-------------------------
// Constants and functions for 
// Floating Point Unit calculator
//-------------------------
package fpu_pack;	   
	// Set of parameters for ShortReals
	parameter BW_SIGN =  1;
	parameter BW_EXPN =  8;
	parameter BW_FRAC = 23; 
	
	parameter EXP_BASE = (2** (BW_EXPN-1))-1;
	parameter BW_DATA = BW_SIGN+BW_EXPN+BW_FRAC;

	// Real Number data structure
	typedef struct packed { 
	    bit 	     [ BW_SIGN  -1:0] sign ;
	    bit unsigned [ BW_EXPN  -1:0] expn ;
	    bit unsigned [ BW_FRAC  -1:0] frac ;
	} real_t;
	
	// Create extended structure for multiplication
	parameter BW_EXPN_EXT =  BW_EXPN + 1 + 1; // One is sign, one is for overflow
	parameter BW_FRAC_EXT = (BW_FRAC + 1) *2 ; // Mult number	  
	parameter MSB_FRAC_EXT = BW_FRAC_EXT -2 -1; // (-2) trunc ceil part, keep mant, (-1) because from 0.1.2..
	parameter LSB_FRAC_EXT = MSB_FRAC_EXT - BW_FRAC  + 1; // LSB of mantissa
	
	typedef struct packed { 
	    bit 		 [BW_SIGN  	 	-1:0] sign ;
	    bit signed   [BW_EXPN_EXT  	-1:0] expn ;
	    bit unsigned [BW_FRAC_EXT	-1:0] frac ;
	} real_ext_t;  
	
	parameter LAT_OUT_MULT = 4;
	
	
	parameter BW_EXPN_ADD =BW_EXPN+1+1;
	parameter BW_FRAC_ADD =BW_FRAC+1+1;
	
	// Create extended type for add
	typedef struct packed { 
    bit 		 [BW_SIGN 	  -1:0] sign ;
    bit unsigned [BW_EXPN_ADD -1:0] expn ;
    bit   signed [BW_FRAC_ADD -1:0] mant ; // One for one for fillment
	} real_add_t; 	
	
	parameter LAT_OUT_ADD = 4;
	
	// Key parameters for Latencies
	parameter LAT_ADD 		= 12;  					// Latency of ADD unit
	parameter LAT_MULT 		= LAT_OUT_MULT+3; 		// Latency of MULT unit
	parameter DSP_LATENCY 	= LAT_ADD + LAT_MULT ;  // Latency of Top Level DSP Unit

	
endpackage
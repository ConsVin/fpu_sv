SetActiveLib -work
#Compiling UUT module design files
comp -include $dsn\src\fpu_sv\fpu_dsp.sv
comp -include "$dsn\src\sim\fpu_dsp_TB.sv"
asim +access +r fpu_dsp_tb


#End simulation macro

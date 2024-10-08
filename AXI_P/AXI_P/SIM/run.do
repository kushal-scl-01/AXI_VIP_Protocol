vlib work
vlog ../TEST/package.sv ../TOP/top.sv +incdir+../ENV/AXI_MASTER +incdir+../ENV/AXI_SLAVE +incdir+../ENV +incdir+../TEST
vsim -voptargs=+acc -suppress 12003 work.top +UVM_TESTNAME=${1} -sv_seed ${2} 
do wave.do
run -all


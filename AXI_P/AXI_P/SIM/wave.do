onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group Global_CLK_RST /top/aclk
add wave -noupdate -group Global_CLK_RST /top/aresetn
add wave -noupdate -group MAS_AW_CHN /top/vintf_mas/awid
add wave -noupdate -group MAS_AW_CHN /top/vintf_mas/awaddr
add wave -noupdate -group MAS_AW_CHN /top/vintf_mas/awlen
add wave -noupdate -group MAS_AW_CHN /top/vintf_mas/awsize
add wave -noupdate -group MAS_AW_CHN /top/vintf_mas/awburst
add wave -noupdate -group MAS_AW_CHN /top/vintf_mas/awvalid
add wave -noupdate -group MAS_AW_CHN /top/vintf_mas/awready
add wave -noupdate -group MAS_W_CHN /top/vintf_mas/wid
add wave -noupdate -group MAS_W_CHN /top/vintf_mas/wdata
add wave -noupdate -group MAS_W_CHN -radix binary /top/vintf_mas/wstrb
add wave -noupdate -group MAS_W_CHN /top/vintf_mas/wlast
add wave -noupdate -group MAS_W_CHN /top/vintf_mas/wvalid
add wave -noupdate -group MAS_W_CHN /top/vintf_mas/wready
add wave -noupdate -group MAS_B_CHN /top/vintf_mas/bid
add wave -noupdate -group MAS_B_CHN /top/vintf_mas/bresp
add wave -noupdate -group MAS_B_CHN /top/vintf_mas/bvalid
add wave -noupdate -group MAS_B_CHN /top/vintf_mas/bready
add wave -noupdate -group MAS_AR_CHN /top/vintf_mas/arid
add wave -noupdate -group MAS_AR_CHN /top/vintf_mas/araddr
add wave -noupdate -group MAS_AR_CHN /top/vintf_mas/arlen
add wave -noupdate -group MAS_AR_CHN /top/vintf_mas/arsize
add wave -noupdate -group MAS_AR_CHN /top/vintf_mas/arburst
add wave -noupdate -group MAS_AR_CHN /top/vintf_mas/arvalid
add wave -noupdate -group MAS_AR_CHN /top/vintf_mas/arready
add wave -noupdate -group MAS_R_CHN /top/vintf_mas/rid
add wave -noupdate -group MAS_R_CHN /top/vintf_mas/rdata
add wave -noupdate -group MAS_R_CHN /top/vintf_mas/rresp
add wave -noupdate -group MAS_R_CHN /top/vintf_mas/rlast
add wave -noupdate -group MAS_R_CHN /top/vintf_mas/rvalid
add wave -noupdate -group MAS_R_CHN /top/vintf_mas/rready
add wave -noupdate -group SLV_AW_CHN /top/vintf_slv/awid
add wave -noupdate -group SLV_AW_CHN /top/vintf_slv/awaddr
add wave -noupdate -group SLV_AW_CHN /top/vintf_slv/awlen
add wave -noupdate -group SLV_AW_CHN /top/vintf_slv/awsize
add wave -noupdate -group SLV_AW_CHN /top/vintf_slv/awburst
add wave -noupdate -group SLV_AW_CHN /top/vintf_slv/awvalid
add wave -noupdate -group SLV_AW_CHN /top/vintf_slv/awready
add wave -noupdate -group SLV_W_CHN /top/vintf_slv/wid
add wave -noupdate -group SLV_W_CHN /top/vintf_slv/wdata
add wave -noupdate -group SLV_W_CHN /top/vintf_slv/wstrb
add wave -noupdate -group SLV_W_CHN /top/vintf_slv/wlast
add wave -noupdate -group SLV_W_CHN /top/vintf_slv/wvalid
add wave -noupdate -group SLV_W_CHN /top/vintf_slv/wready
add wave -noupdate -group SLV_B_CHN /top/vintf_slv/bid
add wave -noupdate -group SLV_B_CHN /top/vintf_slv/bresp
add wave -noupdate -group SLV_B_CHN /top/vintf_slv/bvalid
add wave -noupdate -group SLV_B_CHN /top/vintf_slv/bready
add wave -noupdate -group SLV_AR_CHN /top/vintf_slv/arid
add wave -noupdate -group SLV_AR_CHN /top/vintf_slv/araddr
add wave -noupdate -group SLV_AR_CHN /top/vintf_slv/arlen
add wave -noupdate -group SLV_AR_CHN /top/vintf_slv/arsize
add wave -noupdate -group SLV_AR_CHN /top/vintf_slv/arburst
add wave -noupdate -group SLV_AR_CHN /top/vintf_slv/arvalid
add wave -noupdate -group SLV_AR_CHN /top/vintf_slv/arready
add wave -noupdate -group SLV_R_CHN /top/vintf_slv/rid
add wave -noupdate -group SLV_R_CHN /top/vintf_slv/rdata
add wave -noupdate -group SLV_R_CHN /top/vintf_slv/rresp
add wave -noupdate -group SLV_R_CHN /top/vintf_slv/rlast
add wave -noupdate -group SLV_R_CHN /top/vintf_slv/rvalid
add wave -noupdate -group SLV_R_CHN /top/vintf_slv/rready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {15 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 159
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1763 ns} {2029 ns}

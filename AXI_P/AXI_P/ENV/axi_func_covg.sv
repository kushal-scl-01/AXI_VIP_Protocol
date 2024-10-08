`ifndef AXI_FUNCTIONAL_COVERAGE_SV
`define AXI_FUNCITONAL_COVERAGE_SV

covergroup toggle_cov with function sample(input a);
	option.per_intance = 1;
	toggle_cp : coverpoint a {
		bins toggle_0_to_1 = (0 => 1);
		bins toggle_1_to_0 = (1 => 0);
	}
endgroup 

//It encapsulates the uvm_analysis_export and associated virtual write method 
//analysis export for recieving transactions from a connected analysis export 
class axi_func_covg extends uvm_subscriber #(axi_master_seq_item);
	
	//factory registration 
	`uvm_component_utils(axi_func_covg)

	//event for sample the coverage 
	event cov_event;

	//handle of sew_item 
	axi_master_seq_item seq_item_h;

	uvm_analysis_imp #(axi_master_seq_item,axi_func_covg) cov_mas_export;

	toggle_cov awid_toggle[4];
	toggle_cov awsize_toggle[3];
	toggle_cov awlen_toggle[4];
//	toggle_cov awburst_toggle[2];
	toggle_cov awaddr_toggle[`ADDR_WIDTH];
	toggle_cov wdata_toggle[`DATA_WIDTH];
	toggle_cov wid_toggle[4];
	toggle_cov wstrb_toggle[`DATA_WIDTH/8];
	toggle_cov bid_toggle[4];
	toggle_cov arid_toggle[4];
	toggle_cov arsize_toggle[3];
	toggle_cov arlen_toggle[4];
	//toggle_cov arburst_toggle[2];
	toggle_cov araddr_toggle[`ADDR_WIDTH];
	toggle_cov rid_toggle[4];
	toggle_cov rdata_toggle[`DATA_WIDTH];

	//covergroup 
	covergroup cvg_grp;

		axi_awlen_coverpoint : coverpoint seq_item_h.awlen {
			bins awlen_bins[3] = {[0:$]};
		}

		axi_arlen_coverpoint : coverpoint seq_item_h.arlen {
			bins arlen_bins[3] = {[0:$]};
		}

		axi_awsize_coverpoint : coverpoint seq_item_h.awsize {
			bins awsize_bins[3] = {[0:$]};
		}

		axi_arsize_coverpoint : coverpoint seq_item_h.arsize {
			bins arsize_bins[3] = {[0:$]};
		}

		axi_awburst_coverpoint : coverpoint seq_item_h.write_burst_type_e {
			bins awburst_fixed_bin = {FIXED};
			bins awburst_incr_bin = {INCR};
			bins awburst_wrap_bin = {WRAP};
		}

		axi_arburst_coverpoint : coverpoint seq_item_h.read_burst_type_e {
			bins arburst_fixed_bin = {FIXED};
			bins arburst_incr_bin = {INCR};
			bins arburst_wrap_bin = {WRAP};
		}

		axi_bresp_coverpoint : coverpoint seq_item_h.write_resp_type_e {
			bins bresp_okay_bin = {OKAY};
			bins bresp_error_bin = {ERROR};
		}

		axi_rresp_coverpoint : coverpoint seq_item_h.read_resp_type_e {
			bins rresp_okay_bin = {OKAY};
			bins rresp_error_bin = {ERROR};
		}

	endgroup
	
	//constructor 
	function new(string name = "axi_func_covg",uvm_component parent);
		super.new(name,parent);
		seq_item_h = seq_item::type_id::create("seq_item_h"); 	
		cvg_grp = new(); 	//creating covergroup 

		foreach(awid_toggle[i]) awid_toggle[i] = new;
		foreach(awsize_toggle[i]) awsize_toggle[i]=new;
		foreach(awlen_toggle[i]) awlen_toggle[i]=new;
		foreach(awaddr_toggle[i]) awaddr_toggle[i]=new;
		foreach(wdata_toggle[i]) wdata_toggle[i]=new;
		foreach(wid_toggle[i]) wid_toggle[i]=new;
		foreach(wstrb_toggle[i]) wstrb_toggle[i]=new;
		foreach(bid_toggle[i]) bid_toggle[i]=new;
		foreach(arid_toggle[i]) arid_toggle[i]=new;
		foreach(arsize_toggle[i]) arsize_toggle[i]=new;
		foreach(arlen_toggle[i]) arlen_toggle[i]=new;
		foreach(araddr_toggle[i]) araddr_toggle[i]=new;
		foreach(rid_toggle[i]) rid_toggle[i]=new;
		foreach(rdata_toggle[i]) rdata_toggle[i]=new;

	endfunction

	//write method which is encapsulted in uvm_subscriber 
	virtual function void write(axi_master_seq_item tr);
		`uvm_info("FUNC_COVG","Packet Recieved at Function coverage",UVM_LOW)
		this.seq_item_h = axi_master_seq_item::type_id::create("seq_item_h");
		this.seq_item_h.copy(tr);

		foreach(awid_toggle[i]) awid_toggle[i].sample(seq_item_h.AWID[i]);
		foreach (awaddr_toggle[i]) awaddr_toggle[i].sample(seq_item_h.start_write_addr[i]);
		foreach (awsize_toggle[i]) awsize_toggle[i].sample(seq_item_h.awsize);
		foreach (awlen_toggle[i]) awlen_toggle[i].sample(seq_item_h.awlen);
		
		foreach (seq_item_h.wdata[i]) begin
	 		for(int j=0; j<$size(seq_item_h.wdata[i]);j++) begin 
	 			wdata_toggle[j].sample(seq_item_h.wdata[i][j]);
	 		end 
	 	end 

		foreach (seq_item_h.wstrb[i]) begin
	 		for(int j=0; j<$size(seq_item_h.wstrb[i]);j++) begin 
	 			wstrb_toggle[j].sample(seq_item_h.wstrb[i][j]);
	 		end 
	 	end 


		foreach (wid_toggle[i]) wid_toggle[i].sample(seq_item_h.WID[i]);
		//wstrb queue 
		foreach(bid_toggle[i]) bid_toggle[i].sample(seq_item_h.BID[i]);
		foreach(arid_toggle[i]) arid_toggle[i].sample(seq_item_h.ARID);
		foreach(arsize_toggle[i]) arsize_toggle[i].sample(seq_item_h.arsize[i]);
		foreach(arlen_toggle[i]) arlen_toggle[i].sample(seq_item_h.arlen[i]);
		foreach(araddr_toggle[i]) araddr_toggle[i].sample(seq_item_h.start_read_addr[i]);
		foreach(rid_toggle[i]) rid_toggle[i].sample(seq_item_h.RID[i]);
		foreach(rdata_toggle[i]) rdata_toggle[i].sample(seq_item_h.rdata[i]);

			haddr_toggle[i].sample(tr.awaddr[i]);
		end 

		foreach (awdata_toggle[i]) begin 
			awdata_toggle[i].sample(tr.awdata[i]);
		end 

		foreach (araddr_toggle[i]) begin 
			araddr_toggle[i].sample(tr.araddr[i]);
		end 

		foreach (ardata_toggle[i]) begin 
			ardata_toggle[i].sample(tr.ardata[i]);
		end 

	endfunction

endclass

`endif 

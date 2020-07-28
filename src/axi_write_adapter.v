// AXI 总线协议写入部分适配器
// 对外暴露 AXI 写通道 master interface
`include "defines.v"
module axi_write_adapter(
         input
         wire clk, reset,
         // write address channel signals
         output
         wire[3:0]   awid,
         wire[31:0]  awaddr,
         wire[3:0]   awlen,
         wire[2:0]   awsize,
         wire[1:0]   awburst,
         wire[1:0]   awlock,
         wire[3:0]   awcache,
         wire[2:0]   awprot,
         output wire         awvalid,
         input wire    awready,

         // write data channel signals
         output
         wire[3:0]    wid,
         wire[31:0]   wdata,
         wire[3:0]   wstrb,
         output wire        wlast,
         wire        wvalid,
         input       wready,

         // write response channel signals
         input
         wire[3:0]   bid,
         wire[1:0]   bresp,
         input wire        bvalid,
         output
         wire        bready,

         // from/to mem
         input
         wire[`RegBus]      data,
         input wire         we,
         wire[`RegBus]      address,
         wire[3:0]          select,

         // if mem write is done.
         // only take affect when there is a write request,
         // which means should be used together with write enable.
         output wire        mem_write_done
       );

// reg write_channel_state;

assign awid = 4'b0;
assign wid = 4'b0;

// 4.2
assign awlen = 4'b0;
// 4.3 4 Bytes
// TODO?
assign awsize = 3'b010;
// 4.4
assign awburst = 2'b0;
// 2.3
assign wlast = 1'b1;
// 6.1
assign awlock = 2'b0;
// 9.2
assign wstrb = select;
// 5.1
assign awcache = 4'b0;
// 5.2
assign awprot = 3'b000;
assign wdata = data;


assign awaddr =  (address[31:29] == 3'b100 ||
                  address[31:29] == 3'b101
                 )? { 3'b0,address[28:0]} : address;
// ignore the BRESP because we always accept it

// save
reg awvalid_done;
reg wvalid_done;

// only when AXI is Free, we can regard a write enable as a valid signal,
// otherwise it maybe be rised only because we freeze the stream
// (which we should not repeat send valid signal)
assign awvalid = ((we == 1'b1) && (awvalid_done == 1'b0))? 1'b1: 1'b0;
assign wvalid = ((we == 1'b1) && (wvalid_done == 1'b0))? 1'b1: 1'b0;

// awvalid_done
always @(posedge clk ) begin
  if (reset == `RstEnable) begin
    awvalid_done <= 1'b0;
  end else if ( we && awvalid && awready) begin
    awvalid_done <= 1'b1;
  end else if ( we ) begin
    // do nothing
  end else begin
    awvalid_done <= 1'b0;
  end
end

// wvalid_done
always @(posedge clk ) begin
  if (reset == `RstEnable) begin
    wvalid_done <= 1'b0;
  end else if ( we && wvalid && wready) begin
    wvalid_done <= 1'b1;
  end else if ( we ) begin
    // do nothing
  end else begin
    wvalid_done <= 1'b0;
  end
end



// set it to high according to 3.1.2
assign bready = 1'b1;
assign mem_write_done = bvalid;

// always @(posedge clk)
//   begin
//     if(reset == `RstEnable)
//       begin
//         write_channel_state <= `WriteFree;
//       end
//     else if(we == `Valid && write_channel_state == `WriteFree && awready == `Ready && wready == `Ready)
//       begin
//         write_channel_state <= `WriteBusy;
//       end
//     else if(bvalid == `Valid && write_channel_state == `WriteBusy)
//       begin
//         write_channel_state <= `WriteFree;
//       end

//   end


endmodule // axi_write_adapter

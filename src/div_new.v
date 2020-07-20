`include "defines.v"
module div(
    input wire clk, wire rst,
    input
    wire    signed_div_i,
    wire [31:0] opdata1_i,
    wire [31:0] opdata2_i,
    input
    wire        start_i,
    wire        annul_i,

    output
    wire [63:0]  result_o,
    wire         ready_o
);

parameter div_cycles = 32;

wire [31:0] abs_opa1;
wire [31:0] abs_opa2;

wire [31:0] tmp_quotient;
wire [32:0] tmp_remain;

wire [31:0] dquotient;
wire [31:0] remain;

wire div_done;
reg [div_cycles:0] div_stage;

div_uu #(.z_width(64)) div_uu0(
    .clk(clk),
    .ena(start_i),
    .z({32'h0, abs_opa1}),
    .d(abs_opa2),
    .q(tmp_quotient),
    .s(tmp_remain),
    .div0(),
    .ovf()
);

assign abs_opa1 = (!signed_div_i||!opdata1_i[31])? opdata1_i:-opdata1_i;
assign abs_opa2 = (!signed_div_i||!opdata2_i[31])? opdata2_i:-opdata2_i;

assign div_done = div_stage[0];
assign dquotient = (!signed_div_i || !(opdata1_i[31]^opdata2_i[31]))? tmp_quotient: -tmp_quotient;
assign dremain = (!signed_div_i || !(opdata1_i[31]^tmp_remain[31]))? tmp_remain : -tmp_remain;

assign ready_o = div_done;
assign result_o = {dremain, dquotient};

always @(posedge clk) begin
   if (rst == `RstEnable||annul_i== 1'b0) begin
       div_stage <= 1'b0;
   end
   else if(!start_i) begin
       div_stage <= 1'b0;
   end
   else if(div_stage != 1'b0)begin
       div_stage <= div_stage >> 1;
   end
   else begin
       div_stage <= 1'b1 << (div_cycles-1);
   end
end

endmodule
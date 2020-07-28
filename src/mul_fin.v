`include"defines.v"
module mul_fin(
    input wire clk, wire rst,
    input
    wire signed_mul_i,
    wire[31:0] opdata1_i,
    wire[31:0] opdata2_i,
    input
    wire start_i,
    
    output
    reg[63:0] result_o,
    reg ready_o
);
wire[63:0] hilo_temp;
wire[63:0] hilo_temp_unsigned;
reg[2:0] state;
mult_gen_0 mul0(
    .CLK(clk),
    .A(opdata1_i),
    .B(opdata2_i),
    .P(hilo_temp)
);
mult_gen_1 mul1(
    .CLK(clk),
    .A(opdata1_i),
    .B(opdata2_i),
    .P(hilo_temp_unsigned)
);

always @(posedge clk)
    begin
        if(rst == `RstEnable)
        begin
           state <= `Mul_1;
           ready_o <=`DivResultNotReady;
           result_o <= {`ZeroWord,`ZeroWord}; 
        end
        else if(start_i==1'b1)
        begin
            case(state)
             `Mul_1:
             begin
                 state<=`Mul_2;
                 ready_o<=`DivResultNotReady;
             end
             `Mul_2:
             begin
                 state<=`Mul_3;
                 ready_o<=`DivResultNotReady;
             end
             `Mul_3:
             begin
                 state<=`Mul_4;
                 ready_o<=`DivResultNotReady;
             end
             `Mul_4:
             begin
                state<=`Mul_5;
                ready_o<=`DivResultNotReady;
             end
             `Mul_5:
             begin
                state<=`Mul_6;
                ready_o<=`DivResultNotReady;
             end
             `Mul_6:
             begin
                 state<=`Mul_1;
                 ready_o <=`DivResultReady;
                 if(signed_mul_i==1'b1)
                 begin
                    result_o<=hilo_temp;
                 end
                 else
                 begin
                    result_o<=hilo_temp_unsigned;
                 end
             end
             default:
             begin
             end
             endcase
        end
        else
        begin
            ready_o <=`DivResultNotReady;
            result_o <= {`ZeroWord,`ZeroWord}; 
        end
    end
endmodule

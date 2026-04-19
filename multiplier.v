`timescale 1ns/1ps

module multiplier (
    input  wire [31:0] A,
    input  wire [31:0] B,
    output reg  [31:0] OUT
);
    wire signA = A[31];
    wire [7:0] expA = A[30:23];
    wire [22:0] fracA = A[22:0];

    wire signB = B[31];
    wire [7:0] expB = B[30:23];
    wire [22:0] fracB = B[22:0];

    wire [23:0] M1 = (expA == 8'd0) ? {1'b0, fracA} : {1'b1, fracA};
    wire [23:0] M2 = (expB == 8'd0) ? {1'b0, fracB} : {1'b1, fracB};

    wire A_is_zero = (expA == 8'd0 && fracA == 23'd0);
    wire B_is_zero = (expB == 8'd0 && fracB == 23'd0);

    wire A_is_inf  = (expA == 8'hFF && fracA == 23'd0);
    wire B_is_inf  = (expB == 8'hFF && fracB == 23'd0);

    wire A_is_nan  = (expA == 8'hFF && fracA != 23'd0);
    wire B_is_nan  = (expB == 8'hFF && fracB != 23'd0);

    wire [47:0] prod48 = M1 * M2; // 24x24 -> 48 bits

    reg        sign_out;
    reg signed [10:0] exp_temp;
    reg [22:0] frac_out;
    reg [47:0] prod_reg;
    reg [7:0]  exp_final;
    reg        is_nan_out;
    reg        is_inf_out;
    reg        is_zero_out;

    always @(*) begin
        sign_out    = signA ^ signB;
        prod_reg    = prod48;
        exp_temp    = 0;
        exp_final   = 8'd0;
        frac_out    = 23'd0;
        is_nan_out  = 1'b0;
        is_inf_out  = 1'b0;
        is_zero_out = 1'b0;

   
        if (A_is_nan || B_is_nan) begin
            is_nan_out = 1'b1;
   
            OUT = {1'b0, 8'hFF, 23'h400000}; // 0x7FC00000 quiet NaN
        end
        else if ((A_is_inf && B_is_zero) || (B_is_inf && A_is_zero)) begin
       
            is_nan_out = 1'b1;
            OUT = {1'b0, 8'hFF, 23'h400000}; // qNaN
        end
        else if (A_is_inf || B_is_inf) begin
           
            is_inf_out = 1'b1;
            OUT = {sign_out, 8'hFF, 23'd0}; // +/- INF
        end
        else if (A_is_zero || B_is_zero) begin
           
            is_zero_out = 1'b1;
            OUT = {sign_out, 8'd0, 23'd0}; // signed zero
        end
        else begin
          
            exp_temp = $signed({1'b0, expA}) + $signed({1'b0, expB}) - 11'sd127;

           
            prod_reg = prod48;

         
            if (prod_reg[47] == 1'b1) begin
               
                exp_temp = exp_temp + 1;
               
                frac_out = prod_reg[46:24];
            end else begin
               
                frac_out = prod_reg[45:23];
            end

            
            if (exp_temp >= 11'sd255) begin
             
                is_inf_out = 1'b1;
                OUT = {sign_out, 8'hFF, 23'd0};
            end
            else if (exp_temp <= 11'sd0) begin

                is_zero_out = 1'b1;
                OUT = {sign_out, 8'd0, 23'd0};
            end
            else begin
                
                exp_final = exp_temp[7:0];
                OUT = {sign_out, exp_final, frac_out};
            end
        end
    end

endmodule

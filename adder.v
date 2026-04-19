`timescale 1ns/1ps

module adder (
    input  wire [31:0] A,
    input  wire [31:0] B,
    output reg  [31:0] OUT
);

    wire        signA = A[31];
    wire [7:0]  expA  = A[30:23];
    wire [22:0] fracA = A[22:0];

    wire        signB = B[31];
    wire [7:0]  expB  = B[30:23];
    wire [22:0] fracB = B[22:0];

    wire [23:0] mantA = (expA == 0) ? {1'b0, fracA} : {1'b1, fracA};
    wire [23:0] mantB = (expB == 0) ? {1'b0, fracB} : {1'b1, fracB};

    wire A_larger_exp      = (expA >= expB);
    wire [7:0] exp_big     = A_larger_exp ? expA : expB;
    wire [7:0] exp_small   = A_larger_exp ? expB : expA;

    wire [23:0] mant_big   = A_larger_exp ? mantA : mantB;
    wire [23:0] mant_small = A_larger_exp ? mantB : mantA;

    wire sign_big   = A_larger_exp ? signA : signB;
    wire sign_small = A_larger_exp ? signB : signA;

    wire [7:0] diff_raw = exp_big - exp_small;
    wire [4:0] shift    = (diff_raw > 8'd24) ? 5'd24 : diff_raw[4:0];

    wire [23:0] mant_small_shift =
        (shift == 0) ? mant_small :
        (shift >= 24) ? 24'd0 :
        (mant_small >> shift);

    reg [24:0] add_res;
    reg [24:0] sub_res;

    reg [23:0] mant_final;
    reg [7:0]  exp_final;
    reg        sign_final;

    reg [4:0]  leading_pos;
    reg [4:0]  shift_left;
    reg [24:0] temp_shifted;
    reg found;

    integer i;
    always @(*) begin

        add_res     = 0;
        sub_res     = 0;
        mant_final  = 0;
        exp_final   = 0;
        sign_final  = 0;
        leading_pos = 0;
        shift_left  = 0;
        temp_shifted = 0;
        found = 0;
        if (signA == signB) begin
            add_res = {1'b0, mant_big} + {1'b0, mant_small_shift};
            sign_final = sign_big;
            if (add_res[24]) begin
                temp_shifted = add_res >> 1;
                exp_final = exp_big + 1;
                mant_final = temp_shifted[23:0];
            end else begin
                exp_final = exp_big;
                mant_final = add_res[23:0];
            end
        end
        else begin
            if ({1'b0, mant_big} >= {1'b0, mant_small_shift}) begin
                sub_res = {1'b0, mant_big} - {1'b0, mant_small_shift};
                sign_final = sign_big;
            end else begin
                sub_res = {1'b0, mant_small_shift} - {1'b0, mant_big};
                sign_final = sign_small;
            end
            if (sub_res == 25'd0) begin
                OUT = 32'd0;
            end else begin
                leading_pos = 0;
                found = 0;
                for (i = 24; i >= 0; i = i - 1) begin
                    if (!found && sub_res[i]) begin
                        leading_pos = i[4:0];
                        found = 1;
                    end
                end
                if (leading_pos >= 23)
                    shift_left = 0;
                else
                    shift_left = 23 - leading_pos;
                temp_shifted = sub_res << shift_left;
                mant_final = temp_shifted[23:0];
                exp_final  = (exp_big > shift_left) ? (exp_big - shift_left) : 8'd0;
            end
        end
        OUT[31]    = sign_final;
        OUT[30:23] = exp_final;
        OUT[22:0]  = mant_final[22:0];
    end

endmodule

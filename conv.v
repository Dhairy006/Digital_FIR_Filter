`timescale 1ps/1fs

module conv;
    parameter NUM_COEFFS  = 35;
    parameter NUM_SAMPLES = 1024;

    reg [31:0] coeffs   [0:NUM_COEFFS-1];
    reg [31:0] input_x  [0:NUM_SAMPLES-1];
    reg [31:0] y_out    [0:NUM_SAMPLES-1];

    reg  [31:0] mult_A;
    reg  [31:0] mult_B;
    wire [31:0] mult_OUT;

    reg  [31:0] add_A;
    reg  [31:0] add_B;
    wire [31:0] add_OUT;

    integer n, k, idx;
    integer fh;
    reg [31:0] accum;

    multiplier M1(
        .A(mult_A),
        .B(mult_B),
        .OUT(mult_OUT)
    );

    adder A1(
        .A(add_A),
        .B(add_B),
        .OUT(add_OUT)
    );

    initial begin
        $display("\n--- FIR CONVOLUTION TESTBENCH STARTED ---\n");

        fh = $fopen("coeffs.mem","r");
        if (fh == 0) begin
            $display("ERROR: coeffs.mem not found.");
            $finish;
        end
        $fclose(fh);
        $readmemh("coeffs.mem", coeffs);
        $display("Loaded coeffs.mem");

        fh = $fopen("input_noisy.mem","r");
        if (fh == 0) begin
            $display("ERROR: input_noisy.mem not found.");
            $finish;
        end
        $fclose(fh);
        $readmemh("input_noisy.mem", input_x);
        $display("Loaded input_noisy.mem\n");

        for (n = 0; n < NUM_SAMPLES; n = n + 1) begin
            accum = 32'h00000000;

            for (k = 0; k < NUM_COEFFS; k = k + 1) begin
                idx = n - k;

                if (idx < 0)
                    mult_B = 32'h00000000;
                else
                    mult_B = input_x[idx];

                mult_A = coeffs[k];

                #1;

                add_A = accum;
                add_B = mult_OUT;

                #1;

                accum = add_OUT;
            end

            y_out[n] = accum;
        end

        $display("\n=== FILTER OUTPUT (Copy-Paste This) ===\n");

        for (n = 0; n < NUM_SAMPLES; n = n + 1) begin
            $display("%08h", y_out[n]);
        end

        $display("\n=== END OF OUTPUT ===\n");

        $finish;
    end

endmodule

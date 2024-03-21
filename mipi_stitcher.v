`timescale 1ns / 1ps
module mipi_stitcher (
    input wire clk,           // Clock input
    input wire rst,           // Reset input
    input wire [7:0] mipi_a,  // MIPI Signal A (8-bit data)
    input wire mipi_a_valid,  // Valid signal for MIPI Signal A
    input wire [7:0] mipi_b,  // MIPI Signal B (8-bit data)
    input wire mipi_b_valid,  // Valid signal for MIPI Signal B
    output reg [15:0] mipi_out,// Stitched MIPI Signal (16-bit data)
    output reg mipi_out_valid  // Valid signal for stitched MIPI Signal
);

// Internal signals
reg [1:0] state;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= 2'b00;
        mipi_out <= 16'h0000;
        mipi_out_valid <= 1'b0;
    end else begin
        case (state)
            2'b00: begin // Waiting for valid signal from MIPI A
                if (mipi_a_valid) begin
                    mipi_out[7:0] <= mipi_a;
                    state <= 2'b01;
                end
            end
            2'b01: begin // Waiting for valid signal from MIPI B
                if (mipi_b_valid) begin
                    mipi_out[15:8] <= mipi_b;
                    mipi_out_valid <= 1'b1;
                    state <= 2'b10;
                end
            end
            2'b10: begin // Output valid signal for one cycle
                mipi_out_valid <= 1'b0;
                state <= 2'b00;
            end
        endcase
    end
end

endmodule


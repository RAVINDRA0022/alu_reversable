`timescale 1ns / 1ps

module alu_reversible( 
    input [31:0] A, B,         
    input [1:0] sel,           
    input Cin,                 
    output [31:0] F,         
    output Cout
);
    wire [31:0] carry;          
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin: alu_bits
            one_bit_reversible_alu ALU (
                .A(A[i]),
                .B(B[i]),
                .C((i == 0) ? Cin : carry[i-1]),
                .sel(sel),
                .out(F[i]),
                .cout(carry[i])
            );
        end
    endgenerate
    assign Cout = carry[31];
endmodule

module feynman_gate(input A, B, output P, Q);
    assign P = A;
    assign Q = A ^ B;
endmodule

module peres_gate(input A, B, C, output P, Q, R);        
    assign P = A;
    assign Q = A ^ B;
    assign R = (A & B) ^ C;
endmodule

module toffoli_gate(input A, B, C, output P, Q, R);
    assign P = A;
    assign Q = B;
    assign R = C ^ (A & B);
endmodule

module fredkin_gate(input A, B, C, output P, Q, R);
    assign P = A;
    assign Q = (A) ? C : B;
    assign R = (A) ? B : C;
endmodule

module one_bit_reversible_alu(
    input A, B, C, 
    input [1:0] sel, 
    output out, 
    output cout
);
    wire and_operator, or_operator, xor_operator, sum;

    assign and_operator = A & B;
    assign or_operator  = A | B;

    wire feynman_out;
    feynman_gate FG (.A(A), .B(B), .P(), .Q(feynman_out));

    wire p1, p2, p3;
    peres_gate PG (.A(A), .B(B), .C(C), .P(p1), .Q(p2), .R(p3));
    assign sum  = p2;
    assign cout = p3;

    assign out = (sel == 2'b00) ? and_operator : 
                 (sel == 2'b01) ? or_operator  :
                 (sel == 2'b10) ? feynman_out  :
                 sum;
endmodule

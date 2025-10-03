module getNextState (
    input [2:0] currentState,
    output [2:0] nextState
);
wire q0, q1, q2;
wire out_q0, out_q1, out_q2;
assign q0 = currentState[0];
assign q1 = currentState[1];
assign q2 = currentState[2];
assign out_q0 = q0 ^ 1'b1;
assign out_q1 = q1 ^ q0;
assign out_q2 = q2 ^ q1;
assign nextState = {out_q2,out_q1,out_q0};    
endmodule

module threeBitCounter (
    input clk,
    input reset,
    output reg [2:0] count  
);
wire [2:0] next_wire; 
getNextState lol (
    .currentState(count),
    .nextState(next_wire)
);
always @(posedge clk)
begin
    if(reset) 
        count <= 3'b000;
    else
    count <= next_wire;
end
endmodule

module counterToLights (
    input [2:0] count,
    output [2:0] rgb
);
wire x,y,z;
wire a,b,c;
assign x = count[2];
assign y = count[1];
assign z = count[0];
assign c = (y&(~z))|(x&(~y)&z)|((~x)&(~z));
assign b = ((~x)&(~y))|((~y)&(~z))|((~z)&(~x));
assign a = ((~y)&(~z))|((~x)&z);
assign rgb = {a,b,c};
endmodule

module rgbLighter (
    input clk,
    input reset,
    output reg [2:0] rgb
);
wire [2:0] count;
wire [2:0] rgba;
threeBitCounter tbc(
    .clk(clk),
    .reset(reset),
    .count(count)
);
counterToLights ctl (
    .count(count),
    .rgb(rgba)
);
always @(*) begin
    rgb <= rgba ;
end
endmodule

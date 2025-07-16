module ahb_slave(
    input hclk,
    input hresetn,
    input hreadyin,
    input hwrite,
    input [1:0] htrans,
    input [31:0] haddr,
    input [31:0] hwdata,
    output reg valid,
    output reg [2:0] temp_selx,
    output reg [31:0] haddr1,
    output reg [31:0] haddr2,
    output reg [31:0] hwdata1,
    output reg [31:0] hwdata2,
    output reg hwritereg
);

// Valid signal logic
always @(*) begin
    if (!hresetn)
        valid = 1'b0;
    else if (hreadyin && (htrans == 2'b10 || htrans == 2'b11) && 
             (haddr >= 32'h80000000 && haddr < 32'h8c000000))
        valid = 1'b1;
    else
        valid = 1'b0;
end

// temp_selx signal logic
always @(*) begin
    if (!hresetn)
        temp_selx = 3'b000;
    else if (haddr >= 32'h80000000 && haddr < 32'h84000000)
        temp_selx = 3'b001;
    else if (haddr >= 32'h84000000 && haddr < 32'h88000000)
        temp_selx = 3'b010;
    else if (haddr >= 32'h88000000 && haddr < 32'h8c000000)
        temp_selx = 3'b100;
    else
        temp_selx = 3'b000;
end

// Address pipeline
always @(posedge hclk) begin
    if (!hresetn) begin
        haddr1 <= 32'b0;
        haddr2 <= 32'b0;
    end else begin
        haddr1 <= haddr;
        haddr2 <= haddr1;
    end
end

// Data pipeline
always @(posedge hclk) begin
    if (!hresetn) begin
        hwdata1 <= 32'b0;
        hwdata2 <= 32'b0;
    end else begin
        hwdata1 <= hwdata;
        hwdata2 <= hwdata1;
    end
end

// control pipeline
always @(posedge hclk) begin
    if (!hresetn)
        hwritereg <= 1'b0;
    else
        hwritereg <= hwrite;
end

endmodule

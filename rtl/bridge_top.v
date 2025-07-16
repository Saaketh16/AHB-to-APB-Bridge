module bridge_top(
    input Hclk,
    input Hresetn,
    input Hwrite,
    input Hreadyin,
    input [31:0] Hwdata,
    input [31:0] Haddr,
    input [31:0] Prdata,
    input [1:0] Htrans,
    output Penable,
    output Pwrite,
    output Hreadyout,
    output [1:0] Hresp,
    output [2:0] Pselx,
    output [31:0] Paddr,
    output [31:0] Pwdata,
    output [31:0] Hrdata);

// Intermediate Signals

wire valid;
wire [31:0] Haddr1,Haddr2,Hwdata1,Hwdata2;
wire Hwritereg;
wire [2:0] tempselx;
assign Hresp = 2'b00;
assign Hrdata = Prdata;

// Module Instantiations

// AHB Slave Instantiation
    ahb_slave ahbSlave (
        .hclk(Hclk),
        .hresetn(Hresetn),
        .hreadyin(Hreadyin),
        .hwrite(Hwrite),
        .htrans(Htrans),
        .haddr(Haddr),
        .hwdata(Hwdata),
        .valid(valid),
        .temp_selx(tempselx),
        .haddr1(Haddr1),
        .haddr2(Haddr2),
        .hwdata1(Hwdata1),
        .hwdata2(Hwdata2),
        .hwritereg(Hwritereg));

// APB Controller Instantiation
    apb_controller apbControl (
        .Hclk(Hclk),
        .Hresetn(Hresetn),
        .valid(valid),
        .Hwrite(Hwrite),
        .Hwritereg(Hwritereg),
        .Hwdata(Hwdata),
        .Haddr(Haddr),
        .Haddr1(Haddr1),
        .Haddr2(Haddr2),
        .Hwdata1(Hwdata1),
        .Hwdata2(Hwdata2),
        .Prdata(Prdata),
        .tempselx(tempselx),
        .Pwrite(Pwrite),
        .Penable(Penable),
        .Hreadyout(Hreadyout),
        .Pselx(Pselx),
        .Paddr(Paddr),
        .Pwdata(Pwdata));

endmodule

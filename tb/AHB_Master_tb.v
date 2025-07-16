module tb_AHB_Master;

  // Inputs to DUT
  reg Hclk;
  reg Hresetn;
  reg [1:0] Hresp;
  reg [31:0] Hrdata;
  reg Hreadyout;

  // Outputs from DUT
  wire Hwrite;
  wire Hreadyin;
  wire [1:0] Htrans;
  wire [31:0] Hwdata;
  wire [31:0] Haddr;

  // Instantiate the DUT
  AHB_Master DUT (
    .Hclk(Hclk),
    .Hresetn(Hresetn),
    .Hresp(Hresp),
    .Hrdata(Hrdata),
    .Hwrite(Hwrite),
    .Hreadyin(Hreadyin),
    .Htrans(Htrans),
    .Hwdata(Hwdata),
    .Haddr(Haddr),
    .Hreadyout(Hreadyout)
  );

  // Clock Generation
  initial begin
    Hclk = 1'b0;
    forever #5 Hclk = ~Hclk;
  end

  // Stimulus
  initial begin
    // Initialize inputs
    Hresetn    = 1'b0;
    Hresp      = 2'b00;
    Hrdata     = 32'h0000_0000;
    Hreadyout  = 1'b1;

    // Apply reset
    #10 Hresetn = 1'b1;

    // === Call single_write Task ===
    #10 DUT.single_write();

    // === Call single_read Task ===
    #20 DUT.single_read();

    // Finish Simulation
    #50 $finish;
  end

endmodule

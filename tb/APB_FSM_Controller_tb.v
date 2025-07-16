module APB_FSM_Controller_tb;

  // Inputs
  reg Hclk;
  reg Hresetn;
  reg valid;
  reg Hwrite;
  reg Hwritereg;
  reg [31:0] Hwdata;
  reg [31:0] Haddr;
  reg [31:0] Haddr1;
  reg [31:0] Haddr2;
  reg [31:0] Hwdata1;
  reg [31:0] Hwdata2;
  reg [31:0] Prdata;
  reg [2:0] tempselx;

  // Outputs
  wire Pwrite;
  wire Penable;
  wire Hreadyout;
  wire [2:0] Pselx;
  wire [31:0] Paddr;
  wire [31:0] Pwdata;

  // Instantiate the DUT
  APB_FSM_Controller DUT (
    .Hclk(Hclk),
    .Hresetn(Hresetn),
    .valid(valid),
    .Haddr1(Haddr1),
    .Haddr2(Haddr2),
    .Hwdata1(Hwdata1),
    .Hwdata2(Hwdata2),
    .Prdata(Prdata),
    .Hwrite(Hwrite),
    .Haddr(Haddr),
    .Hwdata(Hwdata),
    .Hwritereg(Hwritereg),
    .tempselx(tempselx),
    .Pwrite(Pwrite),
    .Penable(Penable),
    .Pselx(Pselx),
    .Paddr(Paddr),
    .Pwdata(Pwdata),
    .Hreadyout(Hreadyout)
  );

  // Clock generation
  initial begin
    Hclk = 1'b0;
    forever #5 Hclk = ~Hclk;
  end

  // Stimulus
  initial begin
    // Initialize all inputs
    Hresetn    = 1'b0;
    valid      = 1'b0;
    Hwrite     = 1'b0;
    Hwritereg  = 1'b0;
    Haddr      = 32'h00000000;
    Hwdata     = 32'h00000000;
    Haddr1     = 32'h00000000;
    Haddr2     = 32'h00000000;
    Hwdata1    = 32'h00000000;
    Hwdata2    = 32'h00000000;
    Prdata     = 32'h00000000;
    tempselx   = 3'b000;

    // Apply reset
    #10 Hresetn = 1'b1;

    // === WRITE Operation ===
    #10;
    Haddr      = 32'h0000000A;
    Hwdata     = 32'hAAAA_BBBB;
    Haddr1     = 32'h0000000A;
    Hwdata1    = 32'hAAAA_BBBB;
    Haddr2     = 32'h00000010;
    Hwdata2    = 32'hCCCC_DDDD;
    tempselx   = 3'b001;
    valid      = 1'b1;
    Hwrite     = 1'b1;
    Hwritereg  = 1'b1;

    // Hold write signal for one cycle
    #10 valid = 1'b0;

    // === READ Operation ===
    #20;
    Haddr      = 32'h00000004;
    tempselx   = 3'b010;
    valid      = 1'b1;
    Hwrite     = 1'b0;
    Hwritereg  = 1'b0;

    // End read cycle
    #10 valid = 1'b0;

    // === Finish Simulation ===
    #50 $finish;
  end

endmodule

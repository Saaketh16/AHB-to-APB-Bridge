module APB_Interface_tb;

  // Inputs
  reg Pwrite;
  reg Penable;
  reg [2:0] Pselx;
  reg [31:0] Pwdata;
  reg [31:0] Paddr;

  // Outputs
  wire Pwriteout;
  wire Penableout;
  wire [2:0] Pselxout;
  wire [31:0] Pwdataout;
  wire [31:0] Paddrout;
  wire [31:0] Prdata;

  // Instantiate the DUT
  APB_Interface dut (
    .Pwrite(Pwrite),
    .Penable(Penable),
    .Pselx(Pselx),
    .Pwdata(Pwdata),
    .Paddr(Paddr),
    .Pwriteout(Pwriteout),
    .Penableout(Penableout),
    .Pselxout(Pselxout),
    .Pwdataout(Pwdataout),
    .Paddrout(Paddrout),
    .Prdata(Prdata)
  );

  // Stimulus
  initial begin
    
  // Initialize inputs
    Pwrite  = 1'b0;
    Penable = 1'b0;
    Pselx   = 3'b000;
    Pwdata  = 32'h0000_0000;
    Paddr   = 32'h0000_0000;

    // Read Operation
    #10;
    Pwrite  = 1'b0;
    Penable = 1'b1;
    Pselx   = 3'b001;
    Paddr   = 32'h0000_0010;

    #10;
    Penable = 1'b0;

    // Write Operation
    #10;
    Pwrite  = 1'b1;
    Penable = 1'b1;
    Pselx   = 3'b010;
    Paddr   = 32'h0000_0020;
    Pwdata  = 32'hDEAD_BEEF;

    #10;
    Penable = 1'b0;

    // Idle State
    #10;
    Pwrite  = 1'b0;
    Penable = 1'b0;

    // Finish simulation
    #20 $finish;
  end

endmodule

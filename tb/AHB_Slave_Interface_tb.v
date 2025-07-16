module ahb_slave_interface_tb();

  // Clock and control signals
  reg hclk;
  reg hresetn;
  reg hwrite;
  reg hreadyin;
  reg [1:0] htrans;
  reg [31:0] haddr;
  reg [31:0] hwdata;

  wire valid;
  wire [2:0] temp_selx;
  wire [31:0] haddr1, haddr2;
  wire [31:0] hwdata1, hwdata2;

  // Instantiate the DUT (Design Under Test)
  ahb_slave_interface DUT (
    .hclk(hclk),
    .hresetn(hresetn),
    .hwrite(hwrite),
    .hreadyin(hreadyin),
    .htrans(htrans),
    .haddr(haddr),
    .valid(valid),
    .temp_selx(temp_selx),
    .haddr1(haddr1),
    .haddr2(haddr2),
    .hwdata(hwdata),
    .hwdata1(hwdata1),
    .hwdata2(hwdata2)
  );

  // Clock generation
  initial begin
    hclk = 1'b0;
    forever #5 hclk = ~hclk;
  end

  // Reset task
  task r;
    begin
      @(negedge hclk);
      hresetn = 1'b0;
      @(negedge hclk);
      hresetn = 1'b1;
    end
  endtask

  // Control task: hwrite, hreadyin, htrans
  task in(input a, b, input [1:0] c);
    begin
      hwrite = a;
      hreadyin = b;
      htrans = c;
    end
  endtask

  // Address + Data input task
  task inp(input [31:0] ad, da);
    begin
      haddr = ad;
      hwdata = da;
    end
  endtask

  // APB Controller Module (FSM logic)
  module apb_controller (
    input hclk, hresetn,
    input hwrite, hwritereg,
    input [31:0] haddr, haddr1, haddr2, hwdata, hwdata1
  );

    parameter ST_IDLE     = 3'b000,
              ST_WWAIT    = 3'b001,
              ST_WRITE    = 3'b010,
              ST_WRITEP   = 3'b011,
              ST_WENABLE  = 3'b100,
              ST_WENABLEP = 3'b101,
              ST_READ     = 3'b110,
              ST_RENABLE  = 3'b111;

    reg [2:0] ps, ns;

    // Sequential state update
    always @(posedge hclk) begin
      if (!hresetn)
        ps <= ST_IDLE;
      else
        ps <= ns;
    end

    // Combinational next-state logic
    always @(*) begin
      case (ps)
        ST_IDLE:
          if (valid && hwrite)
            ns = ST_WWAIT;
          else if (valid && ~hwrite)
            ns = ST_READ;
          else
            ns = ST_IDLE;

        ST_WWAIT:
          if (valid)
            ns = ST_WRITEP;
          else
            ns = ST_WRITE;

        ST_WRITE:
          if (valid && hwritereg)
            ns = ST_WENABLE;
          else
            ns = ST_IDLE;

        ST_WRITEP:
          ns = ST_WENABLEP;

        ST_WENABLE:
          ns = ST_IDLE;

        ST_WENABLEP:
          if (valid)
            ns = ST_WWAIT;
          else
            ns = ST_IDLE;

        ST_READ:
          if (valid && ~hwritereg)
            ns = ST_RENABLE;
          else
            ns = ST_IDLE;

        ST_RENABLE:
          ns = ST_IDLE;

        default: ns = ST_IDLE;
      endcase
    end

  endmodule

  // Simulation flow
  initial begin
    $monitor("Time=%0t | valid=%b | temp_selx=%b | haddr1=%h | haddr2=%h | hwdata1=%h | hwdata2=%h",
              $time, valid, temp_selx, haddr1, haddr2, hwdata1, hwdata2);

    r();  // Apply reset

    // Stimulus 1: Valid write transaction
    @(negedge hclk); in(1, 1, 2'b10); inp(32'h80000010, 32'hABCD1234);

    // Stimulus 2: Another write to different address
    @(negedge hclk); inp(32'h84000020, 32'h12345678);

    // Stimulus 3: Invalid transaction (IDLE)
    @(negedge hclk); in(0, 0, 2'b00); inp(32'h00000000, 32'h00000000);

    #100 $finish;
  end

endmodule

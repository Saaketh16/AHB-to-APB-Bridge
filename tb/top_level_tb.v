module top_tb();

  reg Hclk, Hresetn;

  // AHB Master <-> Bridge wires
  wire [31:0] Haddr, Hwdata, Hrdata;
  wire [1:0] Htrans, Hresp;
  wire Hwrite, Hreadyin, Hreadyout;

  // Bridge <-> APB wires
  wire [31:0] Paddr, Pwdata, Prdata;
  wire [2:0] Pselx;
  wire Pwrite, Penable;

  // Instantiate AHB Master
  ahb_master ahb (
    .Hclk(Hclk),
    .Hresetn(Hresetn),
    .Hresp(Hresp),
    .Hrdata(Hrdata),
    .Hwrite(Hwrite),
    .Hreadyin(Hreadyin),
    .Hreadyout(Hreadyout),
    .Htrans(Htrans),
    .Hwdata(Hwdata),
    .Haddr(Haddr)
  );

  // Instantiate APB Interface
  apb_interface apb (
    .Pwrite(Pwrite),
    .Penable(Penable),
    .Pselx(Pselx),
    .Paddr(Paddr),
    .Pwdata(Pwdata),
    .Pwriteout(),
    .Pselxout(),
    .Penableout(),
    .Paddrout(),
    .Pwdataout(),
    .Prdata(Prdata)
  );

  // Instantiate Bridge
  bridge_top bridge (
    .Hclk(Hclk),
    .Hresetn(Hresetn),
    .Hwrite(Hwrite),
    .Hreadyin(Hreadyin),
    .Hwdata(Hwdata),
    .Haddr(Haddr),
    .Prdata(Prdata),
    .Htrans(Htrans),
    .Penable(Penable),
    .Pwrite(Pwrite),
    .Hreadyout(Hreadyout),
    .Hresp(Hresp),
    .Pselx(Pselx),
    .Paddr(Paddr),
    .Pwdata(Pwdata),
    .Hrdata(Hrdata)
  );

  // Clock generation
  initial begin
    Hclk = 1'b0;
    forever #10 Hclk = ~Hclk;
  end

  // Reset task
  task reset();
  begin
    @ (negedge Hclk);
    Hresetn = 1'b0;
    @ (negedge Hclk);
    Hresetn = 1'b1;
  end
  endtask

  // Simulation sequence
initial begin
    reset();
    ahb.single_write();
    ahb.single_read();
    //$stop;
  end
endmodule

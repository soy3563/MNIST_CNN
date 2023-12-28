`define FTIME 30000000
`define headersize 436*8
`define imageSize 28*28
module tb_testbench();
reg CLK, RESETB;
reg [7:0] DATA;
wire [12543:0] OUTPUT;
wire VALID;
integer fp,out_p,i;

cnn c1(
    .axi_clk(CLK),
    .axi_rst_n(RESETB),
    .i_data_valid(1'b1),
    .i_data(DATA),
    .o_data_valid(VALID),
    .o_convoledData(OUTPUT) //32*7*7*8
);


initial begin
    CLK     = 1'b0;
    RESETB  = 1'b0;
    #10 fp = $fopen("mnist_image_0.bmp", "rb");
    #10 out_p = $fopen("conv_result.txt","wb")
    #`FTIME;
    $fclose(fp);
    $fclose(out_p);
    $finish;
end


// test condition
initial begin
    for(i=0;i<headersize;i=i+1)begin
        $fscanf(fp,"%c",DATA);
    end
    for(i=0;i<4*28;i=i+1)
    begin
        @(posedge clk);
        $fscanf(file,"%c",DATA);
        imgDataValid <= 1'b1;
    end
    sentSize = 4*28;
    @(posedge clk);
    imgDataValid <= 1'b0;
    while(sentSize < `imageSize)
    begin
        @(posedge intr);
        for(i=0;i<28;i=i+1)
        begin
            @(posedge clk);
            $fscanf(fp,"%c",imgData);
            imgDataValid <= 1'b1;    
        end
        @(posedge clk);
        imgDataValid <= 1'b0;
        sentSize = sentSize+28;
    end
    @(posedge clk);
    imgDataValid <= 1'b0;

    
    $fclose(fp);
 end
 
 always @(posedge clk)
 begin
     if(outDataValid)
     begin
         $fwrite(file1,"%c",outData);
         receivedData = receivedData+1;
     end 
     if(receivedData == `imageSize)
     begin
        $fclose(file1);
        $stop;
     end
 end
       
end

always begin
    #50 CLK = ~CLK; // 100ns period pulse
end

initial begin
    $dumpfile("tb_testbench_out.vcd");
    $dumpvars(0, tb_testbench);  
end

endmodule


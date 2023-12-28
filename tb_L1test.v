`define FTIME 30000000
`define headersize 436*8
`define imageSize 28*28
module tb_L1test();
reg clk, resetb;
reg [7:0] data;
reg [7:0] header;
reg [7:0] imgData [27:0][27:0]; //27:0 >> row index, 열을 뒤집어야되니까 들어오는 데이터를 가장 아래 행에 채우면서 올리는 방식으로진행할 생각
wire [127:0] outData;
wire [15:0] valid;
integer fp,out_p,i,j;
reg [14*14*16-1:0] recvCnt;
wire intr;
reg imgDataVaild;
reg [7:0] tmp;

cnn c1(
    .axi_clk(clk),
    .axi_rst_n(resetb),
    .i_data_valid(imgDataVaild),
    .i_data(data),
    .o_data_valid(valid),
    .o_convoledData(outData), //32*7*7*8
    .o_intr(intr)
);


initial begin
    clk     = 1'b0;
    resetb  = 1'b0;
    #10 fp = $fopen("mnist_image_0.bmp", "rb");
    #10 out_p = $fopen("convoledData.txt", "wb");
    for(i=0;i<`headersize;i=i+1)begin // header del
        header = $fgetc(fp);
    end
    for(i=0;i<28;i=i+1)begin
        for(j=0;j<28;j=j+1)
            imgData[27-i][j] = $fgetc(fp);// column inversion
    end
    $fclose(fp);
    #`FTIME;
    $finish;
end


// test condition
initial begin
    for(i=0;i<4;i=i+1) begin
        for(i=0;j<28;j=j+1)begin
            @(posedge clk);
            data <= imgData[i][j];
            imgDataVaild <= 1'b1;
        end
    end
    @(posedge clk);
    imgDataVaild <= 1'b0;

    while(i < 28)
    begin
        @(posedge intr);
        for(j=0;j<28;j=j+1)
        begin
            @(posedge clk);
            data <= imgData[i][j];
            imgDataVaild <= 1'b1;    
        end
        @(posedge clk);
        imgDataVaild <= 1'b0;
        i = i+1;
    end
    @(posedge clk);
    imgDataVaild <= 1'b0;
 end
 
 always @(posedge clk)begin
     if(|valid)begin
         $fwriteh(out_p,outData);
         $fwrite(out_p," ");
         recvCnt = recvCnt+1;
         if(recvCnt%14 == 0)begin
            $fwrite(out_p,"\n");
                if(recvCnt%14 == 0)
                    $fwrite(out_p,"\n");
         end
     end 
     if(recvCnt == 14*14*16)begin
        $fclose(out_p);
        $stop;
     end
 end

always begin
    #50 clk = ~clk; // 100ns period pulse
end

initial begin
    $dumpfile("tb_L1test.vcd");
    $dumpvars(0, tb_L1test);  
end

endmodule


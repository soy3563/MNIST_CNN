del *.vcd *.vvp
iverilog -o tb_testbench_out.vvp config.v tb_testbench.v cnn.v conv_L1.v conv_L2.v conv.v lineBuffer.v ctrlL1.v ctrlL2.v 
vvp tb_testbench_out.vvp
gtkwave ./tb_testbench_out.vcd
pause
::vvp 돌리면 vcd 나온다
::tb_testbench 가 뒤에 가야 adder보다 define이 먼저 되도록 해서 ifdef 조건문 탈수 있게 해준다
del *.vcd *.vvp
iverilog -o tb_L1test.vvp config.v tb_L1test.v cnn.v conv_L1.v conv.v lineBuffer.v ctrl.v
vvp tb_L1test.vvp
gtkwave ./tb_L1test.vcd
pause
::vvp 돌리면 vcd 나온다
::tb_testbench 가 뒤에 가야 adder보다 define이 먼저 되도록 해서 ifdef 조건문 탈수 있게 해준다
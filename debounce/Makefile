COMPILE=/opt/iverilog/bin/iverilog
GENWAVE=/opt/iverilog/bin/vvp
# 设置仿真宏变量SIM iverilog可用使用-D参数传递宏定义
SIM=-DSIM=1
all: complie
	${GENWAVE} -n db -lxt2
	
complie: 
	${COMPILE} ${SIM} -o db -y ./ ./src/debounce0.v  ./src/debounce1.v  ./src/debounce.v ./src/debounce2.v tb_debounce.v

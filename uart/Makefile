COMPILE=/opt/iverilog/bin/iverilog
GENWAVE=/opt/iverilog/bin/vvp
SRC=./src
LIBS=${SRC}/fifo.v
# 设置仿真宏变量SIM iverilog可用使用-D参数传递宏定义
# 0 - vivado;
# 1 - iveriolg;
SIM=-DSIM=1
# u1_src=$(subst $(LIBDIR),$(ODIR), $(subst .c,.o,  $(wildcard $(LIBDIR)/*.c)))

u1: u1_tb_loopback.o
	${GENWAVE} -n $< -lxt2

# $(ODIR)/%.o: $(LIBDIR)/%.c
# 	$(CC) -g -c -o $@ $< -I$(LIBDIR)
u1_tb_loopback.o: ${LIBS} ./src/u1_*.v  u1_tb_loopback.v 
	${COMPILE} ${SIM} ${VAR} -o $@ -y ./  $^

.PHONY:clean
clean:
	rm u1_tb_loopback.o u1_tb_loopback.vcd
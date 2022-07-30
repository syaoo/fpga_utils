COMPILE=/opt/iverilog/bin/iverilog
GENWAVE=/opt/iverilog/bin/vvp
all: complie
	${GENWAVE} -n db -lxt2
	
complie: 
	${COMPILE} -o db -y ./ ./src/debounce0.v  ./src/debounce1.v  ./src/debounce.v ./src/debounce2.v tb_debounce.v

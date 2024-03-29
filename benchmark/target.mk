all: lib

lib:
	make -C $(BENCHMARK_HOME)/lib

reduce: lib
	cp $(SRC).origin.c $(SRC)
	$(CC) -w $(SRC) -o $(ORIGIN_BIN) $(CFLAGS) $(LFLAGS)
	chisel ./$(ORACLE) $(SRC)
	cp $(SRC).chisel.c $(SRC).reduced.c

clean:
	rm -f $(NAME).origin $(NAME).reduced $(NAME).c

distclean: clean
	rm -rf chisel-out

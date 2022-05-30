CC = clang
CFLAGS = -framework Cocoa -O3
TARGET = untap
PREFIX = /usr/local

$(TARGET): main.m
	$(CC) $< $(CFLAGS) -o $@

.PHONY: clean install

clean:
	$(RM) $(TARGET)

install:
	cp $(TARGET) $(PREFIX)/bin
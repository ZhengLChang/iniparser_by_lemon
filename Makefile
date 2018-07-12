#Makefile
CC=gcc
INCLUDE=
LIB=-lpthread -lcrypto -liconv
#CFLAGS=-g -Wall -Werror -D_REENTRANT -D_GNU_SOURCE ${LIB} ${INCLUDE}
CFLAGS=-g -D_REENTRANT -D_GNU_SOURCE ${LIB} ${INCLUDE}
#CFLAGS=-g ${LIB} ${INCLUDE}
MainFile=main.c
#OutPut=$(patsubst %.c, %, ${MainFile})
OutPut=iniparser
parserFile=iniparser.y
targetParserFile=$(patsubst %.y, %.c, ${parserFile})
src=
target=$(patsubst %.c, %.o, ${MainFile})
target+=$(patsubst %.c, %.o, ${src})
target+=$(patsubst %.c, %.o, ${targetParserFile})
springcleaning=$(patsubst %.c, %, $(wildcard ./*.c))
springcleaning+=$(patsubst %.c, %.o, $(wildcard ./*.c))
springcleaning+=$(patsubst %.c, %.o, ${src})
springcleaning+=$(OutPut)
springcleaning+=$(targetParserFile)

.PHONY: all clean

all: lemon getParserFile $(OutPut)
$(OutPut):${target} ${targetParserFile}
	$(CC) ${target}  -o $@ ${CFLAGS} ${INCLUDE} 

lemon: lemon.c lempar.c
	gcc lemon.c -o lemon

getParserFile: lemon $(parserFile)
	./lemon $(parserFile)
#clean:
#	-@rm  ${springcleaning}

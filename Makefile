#Note, libonevset is being designed to eventually integrate with libMR (metaRecognition) which has a separate license structure. (but still free for non-commercial use).  Because of that we make its inclusion optional.  If the following directory is defined as none, then its not use, else make it the path to where you have installed libMR (which ideally is a subdirectory called libMR)
LIBMR_DIR = NONE
#LIBMR_DIR = /home/tboult/WORK/libsvm-onevset/libMR


ifeq ($(OS),Windows_NT)
    CFLAGS += -D WIN32
    ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
        CFLAGS += -D AMD64
	LIBSUFFIX = .dll
    endif
    ifeq ($(PROCESSOR_ARCHITECTURE),x86)
        CFLAGS += -D IA32
	LIBSUFFIX = .dll
    endif
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
	ifeq ($(LIBMR_DIR),NONE)
        CFLAGS += -D LINUX -g
	else
        CFLAGS += -D LINUX -Wl,-rpath=$(LIBMR_DIR)/libMR/build/libMR/
	endif
	LIBSUFFIX = .so
    endif
    ifeq ($(UNAME_S),Darwin)
        CFLAGS += -D OSX  -g 
	LIBSUFFIX = .dylib
    endif
endif

CXX ?= g++
#CFLAGS = -Wall -Wconversion -g   

LIBMR_LIB = $(LIBMR_DIR)/libMR/build/libMR/libMR$(LIBSUFFIX)

FORCECXX= -x c++
FORCEO= -x none

CFLAGS += -Wall  -g  
CFLGAS += -O2 -fPIC
SHVER = 2

ifeq ($(LIBMR_DIR),NONE)
all: svm-train svm-predict svm-scale 	
lib: svm.o 
	$(CXX) -shared -dynamiclib svm.o -o libsvm.so.$(SHVER) 

svm-predict: svm-predict.c svm.o 
	$(CXX) $(CFLAGS) $(FORCECXX) svm-predict.c $(FORCEO) svm.o   -o svm-predict -lm
svm-train: svm-train.c svm.o 
	$(CXX) $(CFLAGS) $(FORCECXX) svm-train.c $(FORCEO) svm.o -o svm-train -lm
svm-scale: svm-scale.c 
	$(CXX) $(CFLAGS) $(FORCECXX) svm-scale.c -o svm-scale
svm.o: svm.c svm.h 
	$(CXX) $(CFLAGS) $(FORCECXX) -c svm.c 
clean:
	rm -fr *~ svm.o svm-train svm-predict svm-scale libsvm.so.$(SHVER)  
	rm -rf svm-train.dSYM svm-predict.dSYM svm-scale.dSYM 

else

LIBMR_LIB = $(LIBMR_DIR)/libMR/build/libMR/libMR$(LIBSUFFIX)
 
CFLAGS +=  -Dusing_libMR  -I $(LIBMR_DIR)/libMR 

all: svm-train svm-predict svm-scale $(LIBMR_LIB)

$(LIBMR_LIB): $(LIBMR_DIR)/libMR/MetaRecognition.h $(LIBMR_DIR)/libMR/MetaRecognition.c
	mkdir -p $(LIBMR_DIR)/libMR/build
	cd  $(LIBMR_DIR)/libMR/build; cmake -DCMAKE_BUILD_TYPE=Debug $(LIBMR_DIR); make



lib: svm.o $(LIBMR_LIB)
	$(CXX) -shared -dynamiclib svm.o $(LIBMR_LIB) -o libsvm.so.$(SHVER) 

svm-predict: svm-predict.c svm.o $(LIBMR_LIB)
	$(CXX) $(CFLAGS) svm-predict.c svm.o $(LIBMR_LIB)  -o svm-predict -lm
svm-train: svm-train.c svm.o $(LIBMR_LIB)
	$(CXX) $(CFLAGS) svm-train.c svm.o $(LIBMR_LIB) -o svm-train -lm
svm-scale: svm-scale.c $(LIBMR_LIB)
	$(CXX) $(CFLAGS) svm-scale.c $(LIBMR_LIB) -o svm-scale
svm.o: svm.c svm.h 
	$(CXX) $(CFLAGS) -c svm.c 
clean:
	rm -fr *~ svm.o svm-train svm-predict svm-scale libsvm.so.$(SHVER) $(LIBMR_DIR)/libMR/build
endif


.PHONY: testscript

testscript: 
	echo "if all goes well the "diffs" commands will have no output;" > /dev/null
	rm -f onevtest/onevset.train onevtest/onevset.test;
	onevtest/onevtest.sh

test:	svm-train svm-predict onevtest/iris.tr onevtest/iris.t testscript
	
#	rm -f junk onevset.test onevset.train iris-m*

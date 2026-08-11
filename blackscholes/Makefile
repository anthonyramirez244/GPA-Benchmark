#===============================================================================
# User Options
#===============================================================================

# Compiler can be set below, or via environment variable
CC        = nvcc
OPTIMIZE  = yes
DEBUG     = no
ARCH      = sm_86
LAUNCHER  =

#===============================================================================
# Program name & source code list
#===============================================================================

program = blackscholes

cu_source  = BlackScholes.cu
cpp_source = BlackScholes_gold.cpp

cu_obj  = $(cu_source:.cu=.o)
cpp_obj = $(cpp_source:.cpp=.o)
obj     = $(cu_obj) $(cpp_obj)

#===============================================================================
# Sets Flags
#===============================================================================

# Standard Flags
CFLAGS := $(EXTRA_CFLAGS) -std=c++17 -I Common -Xcompiler -Wall -lineinfo -arch=$(ARCH)

# Linker Flags
LDFLAGS = -lm

# Debug Flags
ifeq ($(DEBUG),yes)
  CFLAGS += -g
  LDFLAGS  += -g
endif

# Optimization Flags
ifeq ($(OPTIMIZE),yes)
  CFLAGS += -O3
endif

#===============================================================================
# Targets to Build
#===============================================================================

$(program): $(obj) BlackScholes_kernel.cuh Makefile
	$(CC) $(CFLAGS) $(obj) -o $@ $(LDFLAGS)

%.o: %.cu BlackScholes_kernel.cuh Makefile
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.cpp Makefile
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(program) $(obj)

run: $(program)
	$(LAUNCHER) ./$(program)

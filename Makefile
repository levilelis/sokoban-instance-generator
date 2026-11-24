# Build the beta initial-state generator (binary: bin/LocalSearch).
#
#   make            # downloads Blossom V on first use, then builds bin/LocalSearch
#   make clean      # removes object files and the binary
#   make distclean  # also removes the downloaded Blossom V sources
#
# Requires a C++11 compiler, Boost headers, and curl (for the Blossom V download).
# If Boost is not on the default include path, pass it explicitly, e.g.
#   make BOOST_INC=$(brew --prefix boost)/include

CXX      ?= g++
CXXFLAGS ?= -O3
CXXFLAGS += -fpermissive -std=gnu++11 -w
DEFINES   = -D__lnx__

# Blossom V (Kolmogorov) is used for minimum-cost perfect matching. Its license
# forbids public redistribution, so it is downloaded from the author's site.
BLOSSOM_VERSION = v2.05
BLOSSOM_URL     = https://pub.ist.ac.at/~vnk/software/blossom5-$(BLOSSOM_VERSION).src.tar.gz
BLOSSOM_DIR     = Include/blossom5
BLOSSOM_STAMP   = $(BLOSSOM_DIR)/.downloaded
MEMORY_DIR      = Include/memory
BOOST_INC      ?=

INCLUDES = -ISource -I$(BLOSSOM_DIR) -I$(BLOSSOM_DIR)/MinCost -I$(MEMORY_DIR) \
           $(if $(BOOST_INC),-I$(BOOST_INC))

BLOSSOM_SOURCES = $(addprefix $(BLOSSOM_DIR)/, PMduals.cpp PMexpand.cpp PMinit.cpp \
                    PMinterface.cpp PMmain.cpp PMrepair.cpp PMshrink.cpp misc.cpp MinCost/MinCost.cpp)
SOURCES = $(wildcard Source/*.cpp) $(wildcard $(MEMORY_DIR)/*.cpp) $(BLOSSOM_SOURCES)
OBJECTS = $(SOURCES:.cpp=.o)
TARGET  = bin/LocalSearch

.PHONY: all LocalSearch clean distclean blossom5

all: $(TARGET)
LocalSearch: $(TARGET)

$(TARGET): $(OBJECTS)
	@mkdir -p bin Results
	$(CXX) $(OBJECTS) -o $@ $(LDFLAGS)

# Every object depends on the Blossom V headers being present.
$(OBJECTS): $(BLOSSOM_STAMP)

$(BLOSSOM_SOURCES): $(BLOSSOM_STAMP)

blossom5: $(BLOSSOM_STAMP)

$(BLOSSOM_STAMP):
	@echo "Downloading Blossom V $(BLOSSOM_VERSION) from $(BLOSSOM_URL)"
	@mkdir -p $(BLOSSOM_DIR)
	curl -fsSL $(BLOSSOM_URL) | tar xz -C $(BLOSSOM_DIR) --strip-components=1
	@touch $@

%.o: %.cpp
	$(CXX) -c $(DEFINES) $(CXXFLAGS) $(INCLUDES) $< -o $@

clean:
	rm -f $(OBJECTS) $(TARGET)

distclean: clean
	rm -rf $(BLOSSOM_DIR)

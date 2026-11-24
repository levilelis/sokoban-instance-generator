# Build the beta initial-state generator (binary: bin/LocalSearch).
#
#   make              # default build: orderings based on PDB1, PDB3 and PDB4
#   make BLOSSOM=1    # also enable PDB2-based orderings (downloads Blossom V)
#   make clean        # removes build outputs
#   make distclean    # also removes the downloaded Blossom V sources
#
# Requires a C++11 compiler and Boost headers. If Boost is not on the default
# include path, pass it explicitly, e.g.
#   make BOOST_INC=$(brew --prefix boost)/include

CXX      ?= g++
CXXFLAGS ?= -O3
CXXFLAGS += -fpermissive -std=gnu++11 -w -MMD -MP
DEFINES   = -D__lnx__
BOOST_INC ?=
BLOSSOM  ?= 0

MEMORY_DIR = Include/memory
INCLUDES   = -ISource -I$(MEMORY_DIR) $(if $(BOOST_INC),-I$(BOOST_INC))
SOURCES    = $(wildcard Source/*.cpp) $(wildcard $(MEMORY_DIR)/*.cpp)

# Blossom V (Kolmogorov) computes minimum-cost perfect matchings. It is needed
# only for PDB2 and the mm statistic. Its license allows research use only and
# forbids redistribution, so it is downloaded from the author's site when
# BLOSSOM=1: https://pub.ist.ac.at/~vnk/software.html
BLOSSOM_VERSION = v2.05
BLOSSOM_URL     = https://pub.ist.ac.at/~vnk/software/blossom5-$(BLOSSOM_VERSION).src.tar.gz
BLOSSOM_DIR     = Include/blossom5
BLOSSOM_STAMP   = $(BLOSSOM_DIR)/.downloaded
BLOSSOM_SOURCES = $(addprefix $(BLOSSOM_DIR)/, PMduals.cpp PMexpand.cpp PMinit.cpp \
                    PMinterface.cpp PMmain.cpp PMrepair.cpp PMshrink.cpp misc.cpp MinCost/MinCost.cpp)

ifeq ($(BLOSSOM),1)
  VARIANT   = blossom
  DEFINES  += -DUSE_BLOSSOM
  INCLUDES += -I$(BLOSSOM_DIR) -I$(BLOSSOM_DIR)/MinCost
  SOURCES  += $(BLOSSOM_SOURCES)
  PREREQS   = $(BLOSSOM_STAMP)
else
  VARIANT   = default
  PREREQS   =
endif

BUILD_DIR     = build/$(VARIANT)
OBJECTS       = $(patsubst %.cpp,$(BUILD_DIR)/%.o,$(SOURCES))
VARIANT_STAMP = build/.variant
TARGET        = bin/LocalSearch

.PHONY: all LocalSearch blossom5 clean distclean FORCE

all: $(TARGET)
LocalSearch: $(TARGET)

# Relink whenever the build variant changes.
$(TARGET): $(OBJECTS) $(VARIANT_STAMP)
	@mkdir -p bin Results
	$(CXX) $(OBJECTS) -o $@ $(LDFLAGS)

$(VARIANT_STAMP): FORCE
	@mkdir -p build
	@echo $(VARIANT) | cmp -s - $@ || echo $(VARIANT) > $@

$(BUILD_DIR)/%.o: %.cpp $(PREREQS)
	@mkdir -p $(dir $@)
	$(CXX) -c $(DEFINES) $(CXXFLAGS) $(INCLUDES) $< -o $@

blossom5: $(BLOSSOM_STAMP)

$(BLOSSOM_SOURCES): $(BLOSSOM_STAMP)

$(BLOSSOM_STAMP):
	@echo "Downloading Blossom V $(BLOSSOM_VERSION) from $(BLOSSOM_URL)"
	@echo "Blossom V is licensed for research and evaluation use only; see $(BLOSSOM_DIR)/LICENSE.TXT."
	@mkdir -p $(BLOSSOM_DIR)
	curl -fsSL $(BLOSSOM_URL) | tar xz -C $(BLOSSOM_DIR) --strip-components=1
	@touch $@

clean:
	rm -rf build $(TARGET)

distclean: clean
	rm -rf $(BLOSSOM_DIR)

-include $(OBJECTS:.o=.d)

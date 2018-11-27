ifeq ($(shell uname), Linux)
FC = gfortran
CC = gcc
CXX = g++
else ifeq ($(shell uname), Darwin) 
FC = gfortran-8
CC = gcc-8
CXX = g++-8
endif

FFLAGS = -fPIC -ffree-line-length-none -static-libgfortran
CXXFLAGS=-fPIC -std=c++11

LD=$(FC)
LDLIBS += -lstdc++

PPC=pypolychord
SRC=$(PPC)/src
LIB=$(PPC)/lib
INC=$(PPC)/include


# Object files:
# find all files ending in 90, and change .f90 and .F90 to .o, 
OBJECTS = $(patsubst %.F90,%.o,$(patsubst %.f90,%.o,$(wildcard $(SRC)/*90)))  $(patsubst %.cpp,%.o,$(wildcard $(SRC)/*.cpp))

$(LIB)/libchord.so: $(OBJECTS)
	$(LD) -shared $^ -o $@ $(LDLIBS)


# General rule for building object file (.o)  from fortran files (.f90/.F90)
%.o: %.f90
	$(FC) $(FFLAGS) -c $< -o $@
%.o: %.F90
	$(FC) $(FFLAGS) -c $< -o $@
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -o $@ -c $< -I$(INC)

# Utility targets
.PHONY: clean veryclean

clean:
	$(RM) $(SRC)/*.o $(SRC)/*.mod $(SRC)/*.MOD
	$(RM) *.o *.mod *.MOD
	$(RM) *.pdf

veryclean: clean
	$(RM) $(LIB)/libchord.so
	$(RM) build dist *.egg-info wheelhouse -rf

$(SRC)/abort.o : $(SRC)/utils.o 
$(SRC)/array_utils.o : $(SRC)/abort.o $(SRC)/utils.o 
$(SRC)/calculate.o : $(SRC)/settings.o $(SRC)/utils.o 
$(SRC)/chordal_sampling.o : $(SRC)/calculate.o $(SRC)/random_utils.o $(SRC)/settings.o $(SRC)/utils.o 
$(SRC)/clustering.o : $(SRC)/calculate.o $(SRC)/run_time_info.o $(SRC)/settings.o $(SRC)/abort.o $(SRC)/utils.o 
$(SRC)/feedback.o : $(SRC)/run_time_info.o $(SRC)/settings.o $(SRC)/read_write.o $(SRC)/utils.o 
$(SRC)/generate.o : $(SRC)/mpi_utils.o $(SRC)/abort.o $(SRC)/array_utils.o $(SRC)/feedback.o $(SRC)/read_write.o $(SRC)/calculate.o $(SRC)/random_utils.o $(SRC)/run_time_info.o $(SRC)/settings.o $(SRC)/chordal_sampling.o $(SRC)/utils.o 
$(SRC)/ini.o : $(SRC)/array_utils.o $(SRC)/abort.o $(SRC)/read_write.o $(SRC)/params.o $(SRC)/settings.o $(SRC)/priors.o $(SRC)/utils.o 
$(SRC)/interfaces.o : $(SRC)/mpi_utils.o $(SRC)/read_write.o $(SRC)/params.o $(SRC)/ini.o $(SRC)/mpi_utils.o $(SRC)/nested_sampling.o $(SRC)/random_utils.o $(SRC)/settings.o $(SRC)/utils.o 
$(SRC)/mpi_utils.o : $(SRC)/abort.o $(SRC)/utils.o 
$(SRC)/nested_sampling.o : $(SRC)/generate.o $(SRC)/clustering.o $(SRC)/random_utils.o $(SRC)/chordal_sampling.o $(SRC)/run_time_info.o $(SRC)/feedback.o $(SRC)/read_write.o $(SRC)/settings.o $(SRC)/mpi_utils.o $(SRC)/utils.o 
$(SRC)/params.o : $(SRC)/utils.o 
$(SRC)/priors.o : $(SRC)/abort.o $(SRC)/array_utils.o $(SRC)/params.o $(SRC)/settings.o $(SRC)/utils.o 
$(SRC)/random_utils.o : $(SRC)/mpi_utils.o $(SRC)/utils.o 
$(SRC)/read_write.o : $(SRC)/params.o $(SRC)/priors.o $(SRC)/abort.o $(SRC)/run_time_info.o $(SRC)/settings.o $(SRC)/utils.o 
$(SRC)/run_time_info.o : $(SRC)/calculate.o $(SRC)/random_utils.o $(SRC)/array_utils.o $(SRC)/settings.o $(SRC)/utils.o 
$(SRC)/settings.o : $(SRC)/abort.o $(SRC)/utils.o 
$(SRC)/utils.o : 

include $(JAGSDK)/tools/build/jagdefs.mk

OBJS =	e2pget.o \
	e2pput.o \
	eeprom.o

include $(JAGSDK)/jaguar/skunk/skunk.mk

PROGS = e2pget.cof e2pput.cof e2pchk

e2pget.cof: e2pget.o eeprom.o skunk.o
	$(LINK) $(LINKFLAGS) $^ -o $@

e2pput.cof: e2pput.o eeprom.o skunk.o
	$(LINK) $(LINKFLAGS) $^ -o $@

e2pchk: e2pchk.c
	gcc e2pchk.c -o e2pchk

include $(JAGSDK)/tools/build/jagrules.mk

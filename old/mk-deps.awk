prev {
    print "$(PACKETS_DIR)" $0 ".edges: $(PACKETS_DIR)" prev ".qbml";
    print "$(PACKETS_DIR)" $0 ".x.edges: $(PACKETS_DIR)" prev ".x.qbml";
}
{
    prev=$0
}

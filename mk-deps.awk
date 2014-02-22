prev {
    print "$(DIR)/" $0 ".edges: $(DIR)/" prev ".qbml";
    print "$(DIR)/" $0 ".x.edges: $(DIR)/" prev ".x.qbml";
}
{
    prev=$0
}

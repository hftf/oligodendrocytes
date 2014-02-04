awk 'line {print "$(DIR)/" $0 ".edges: $(DIR)/" line ".qbml";}{line=$0'} order.txt

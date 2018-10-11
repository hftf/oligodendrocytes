require 'pragmatic_segmenter'

ARGF.each do |line|
	puts PragmaticSegmenter::Segmenter.new(text: line).segment
end

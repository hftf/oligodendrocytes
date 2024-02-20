#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import re
import io
import lemminflect

# START_OF_QUESTION_OR_PART = r'^\s*(?:\d+\.)?\s*'
QUESTION_regex = r'<p class="'
ANSWER_regex = r'<p class="answer">.*?</p>'
TOSSUPS_regex = r'Tossups'
# note: will not catch e.g. "A major" because "A" is a stopword
STOPWORDS = re.compile(r'(?i)^(a|the|an|in|on|to|for|de|of|and|is|was|were|are|or|but|by|not|i|from|that|this|with)$')
# TODO does not catch inflected forms because I'm using \b
# e.g. echinodermata echinoderms

def get_inflected_forms_regex(word):
	# remove suffixes like ’s:
	word = re.sub(r'(’s?|[,.;:!?])$', '', word)
	# lemmatize the word:
	for upos in ['NOUN', 'VERB', 'ADV', 'ADJ']:
		lemma = lemminflect.getLemma(word, upos)
		inflections = lemminflect.getAllInflections(lemma[0])
		print (lemma, inflections)
		for values in inflections.values():
			for v in values:
				yield re.escape(v)

def check_revealed_answer(contents):
	# find start and end positions of all matches for ANSWER_regex
	split = split_into_text_and_answers(contents)

	current_question_text = ''
	current_required_words = set()
	for span in split:
		span_begins_new_question = re.search(QUESTION_regex, span['text'])
		if span_begins_new_question:
			current_question_text = span['text'][span_begins_new_question.start():]
			current_required_words = set(span['required_words'])
		else:
			current_question_text += span['text']
			current_required_words = set(span['required_words'])

		required_words_regex = re.compile(required_words_as_regex(sorted(current_required_words)))
		match = re.search(required_words_regex, current_question_text)
		if match:
			highlighted_text = re.sub(required_words_regex, '\033[102m\g<0>\033[0m', current_question_text)
			highlighted_answer = re.sub(
				f'(until|after|before|read|mention(ed)?) ?',
				'\033[103m\g<0>\033[0m',
				re.sub(required_words_regex, '\033[107m\g<0>\033[0m', span['answer']))

			sys.stderr.write(highlighted_text)
			sys.stderr.write(highlighted_answer)
			sys.stderr.write('\n\033[7m—————————————————————————\033[0m\n')
	
def find_required_words(answer):
	for match in re.finditer(r'<u>(.*?)</u>', answer):
		removed_tags = re.sub(r'<.*?>', '', match.group(1))
		for required_word in removed_tags.split():
			if not STOPWORDS.match(required_word):
				yield required_word

def required_words_as_regex(required_set):
	for required_word in required_set:
		inflections = sorted(list(set(get_inflected_forms_regex(required_word))))
		print(required_word, inflections)

	required_boundaries = map(lambda required_word: f'\b{required_word}\b', required_set)
	return '|'.join(required_boundaries)

def split_into_text_and_answers(contents):
	split = []
	pos = contents.find(TOSSUPS_regex)
	for match in re.finditer(ANSWER_regex, contents):
		answer = match.group()
		required_words = find_required_words(answer)

		split.append({
			'text': contents[pos : match.start()],
			'answer': answer,
			'required_words': required_words,
		})

		pos = match.end()
	return split


# fake = False
# try:
filename_in = sys.argv[1]
# except IndexError as error:
	# fake = True

# if not fake:
if 1:
	# try:
		with io.open(filename_in, 'r', encoding='utf-8') as file_in:
			contents = file_in.read()
			sys.stderr.write('\n\n\033[105m' + filename_in + '\033[0m\n\n')

			check_revealed_answer(contents)
	# except IOError as error:
		# fake = True

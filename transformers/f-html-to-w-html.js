#!/usr/bin/env node

'use strict';

const fs     = require('fs');
const Fibrio = require('fibrio');

const url   = process.argv[2];


function globalRegexWithFilter(regex, filterFn) {
	if (!regex.global) {
		throw new Error('Regex must be global');
	}
	function exec(text) {
		var result = regex.exec(text);
		if (result && !filterFn(result[0])) {
			return exec(text);
		}
		return result;
	}
	return {
		global: true,
		exec: exec
	};
}
function findExclude(regexFind, regexExclude) {
	return globalRegexWithFilter(
		regexFind,
		function(x) { return !regexExclude.test(x); }
	);
}


fs.readFile(
	url,
	'utf-8',

	(err, html) => {
		let fib = Fibrio(html);

		// using unnamed group to keep ^ and $ outside of | scope
		// TODO keep “” outside word? barely matters, but more aesthetic
		const exclude = /^(?:\(\*\)|[\/,\.?!'‘’"“”…–—-]+)$/;

		// TODO fix final punctuation kerning (foo</m>.)

		var j = 0;
		function replace(portion, match) {
			var tn = portion.text;
			var v = match.index;

			// Don't wrap portion if it is a power mark (*) or only punctuation
			if (exclude.test(portion.text))
				return tn;

			return '<m data-v="' + v + '">' + tn + '</m>';
		}


		const find = /[^  \n]+/g;
		const findExcluded = findExclude(find, exclude);

		fib
		.qsa('.tu')
		// todo .s1
		.removeBdry('rt, rtc, rp')
		// Don't count words that are part of a pronunciation guide
		.addAvoid('span.s1, rt, rtc, rp')
		.replace(findExcluded, replace);

		process.stdout.write(fib.render());
	}
);

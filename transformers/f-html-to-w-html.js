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

function decodeEntities(result) {
	if (typeof result === 'string') {
		result = result.replace(/&#x([0-9a-f]{1,6});/ig, function (entity, code) {
			code = parseInt(code, 16);

			// don't unescape ascii characters, assuming that all ascii characters
			// are encoded for a good reason
			if (code < 0x80)
				return entity;

			return String.fromCodePoint(code);
	    })
	}

	return result;
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

			return '<m v="' + v + '">' + tn + '</m>';
		}


		const find = /[^  \n]+/g;
		const findExcluded = findExclude(find, exclude);

		fib
		.qsa('.tu')
		// todo .s1
		.removeBdry('rt, rtc, rp')
		// Don't count words that are part of a pronunciation guide
		.addAvoid('span.s1, .bracket-instruction, rt, rtc, rp')
		.replace(findExcluded, replace);

		process.stdout.write(decodeEntities(fib.render()));
	}
);

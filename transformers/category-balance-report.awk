BEGIN {
	FS = "\t";
	DELIM = "│"
	PROCINFO["sorted_in"] = "@ind_str_asc"
	split("T B", question_types, " ");
}
BEGINFILE {
	match(FILENAME, /(tossup|bonus).answers$/, f);
	question_type=toupper(substr(f[1],1,1));
}
{
	packet = $1;
	number = $2;
	category = $4;
	category_number = slugToMainCategoryId(category);

	packets[packet][question_type][number] = category_number;
	categories[category_number][question_type][number] = categories[category_number][question_type][number] packet;
	# print category, (category_number in category_names), join(category_names[category_number], 1, 3);
	# print category != category_names[category_number][1];
	if (!(category_number in category_names) || category != category_names[category_number][1]) {
		category_names[category_number][length(category_names[category_number]) + 1] = category;
	}
	last_packet_last_number = number;
}
END {
	# header
	printf "Packet    ";
	for (i=1; i<=20; i++) {
		if (i == 11) printf DELIM;
		printf "%-3s", i;
	}
	printf "\t1:Lit  2:His  3:Sci  4:Art 5:RM 6:P 7:S 8:Oth\t"
	for (i=1; i<=8; i++) {
		printf "▀" DELIM "▄ "
	}
	print "";

	# body
	for (packet in packets) {
		delete by_cat;
		delete by_half;

		for (qq in question_types) {
			q = question_type = question_types[qq];
			printf "%-4s %-4s ", packet, question_type;

			for (number=1; number<=20; number++) {
				category_number = packets[packet][question_type][number];
				integer  = int(category_number);
				fraction = 10 * (category_number - integer);
				superscript = fractionToSuperscript(fraction);

				if (number == 11) printf DELIM;
				printf "\033[10%s%-3s\033[0m", color(integer), integer superscript;
				if (!fraction)
					superscript = "₀";
				by_cat[question_type][integer][number >= 11] = by_cat[question_type][integer][number >= 11] superscript;
				by_half[question_type][integer][number >= 11] ++
			}
			printf "\t";

			for (c=1; c<=8; c++) {
				printf "\033[10%s%s%s%s\033[0m  ", \
					color(c), by_cat[q][c][0], DELIM, by_cat[q][c][1];
			}
			printf "\t";

			for (c=1; c<=8; c++) {
				diff = by_half["T"][c][0] + by_half["B"][c][0] - by_half["T"][c][1] - by_half["B"][c][1];
			    if (abs(diff) > 1) {
					printf "\033[2;3m";
				}
				printf "\033[10%s%s\033[0m ", color(c), (0+by_half[q][c][0]) DELIM (0+by_half[q][c][1])
			}
			print "";
		}
		print "";
	}

	printf "Category  ";
	for (i=1; i<=20; i++) {
		if (i == 11) printf DELIM;
		printf "%-6s", i;
	}
	print "";
	for (category_number in categories) {
		integer  = int(category_number);
		fraction = 10 * (category_number - integer);
		superscript = fractionToSuperscript(fraction);

		for (qq in question_types) {
			q = question_type = question_types[qq];

			printf "\033[10%s%-4s\033[0m %-4s ", color(integer), integer superscript, question_type;
			if (qq == 2) printf "\033[4m";

			for (number=1; number<=20; number++) {
				if (number == 11) printf DELIM;
				packets_in_number = categories[category_number][question_type][number];
				printf "\033[48;5;%sm%-6s", 224 - 36*((number - 1) % 5), packets_in_number;

				category_totals[integer] += length(packets_in_number);
				category_groups[integer][number] += length(packets_in_number);
			}
			printf "\033[0m \033[10%s ", color(integer);
			ss = "";
			if (qq == 2) ss = ss "  ";
			ss = ss category_names[category_number][qq];
			if (qq == 1 && category_names[category_number][2]) ss = ss ",";
			if (qq == 2 && category_names[category_number][2] != category_names[category_number][3]) ss = ss ", " category_names[category_number][3];
			printf "%-30s \033[0m\n", ss;
		}
	}
	print "";

	printf "Totals    ";
	for (i=1; i<=20; i++) {
		if (i == 11) printf DELIM;
		printf "%-7s", i;
	}
	num_categories = length(category_groups);
	num_packets = length(packets) - (last_packet_last_number < 20);
	num_questions_per_packet = 20;
	print "";

	for (integer in category_groups) {
		printf "\033[10%s%-4s\033[0m %-4s ", color(integer), integer, "";
		for (number=1; number<=20; number++) {
			if (number == 11) printf DELIM;
			packets_in_number = category_groups[integer][number];
			expected = category_totals[integer] / num_questions_per_packet;
			diff = packets_in_number - expected;
			diff_rounded = sprintf("%d", packets_in_number - expected);

			# clr = 230 + (diff_rounded > 0) - 36 * min(abs(diff_rounded), 5);
			if (diff_rounded == 0)
				clr = 231;
			else if (diff_rounded > 0)
				clr = 231 - min(abs(diff_rounded), 5);
			else if (diff_rounded < 0)
				clr = 231 - 6 * min(abs(diff_rounded), 5);
			if (abs(diff_rounded) > 5)
				clr -= 6 * (diff_rounded < 0 ? 6 : 1) * (abs(diff_rounded) - 5);
			printf "%-2s\033[48;5;%sm%+1.1f\033[0m ", packets_in_number, clr, diff;
		}
		print "";
	}
}

function slugToMainCategoryId(slug) {
	# Winter Closed
	# if (slug == "Other Academic")
	# 	return 5.2;

	switch(slug) {
		case "Literature":
			return 1;
		case "American Literature":
			return 1.1;
		case "British Literature":
			return 1.2;
		case "European Literature":
			return 1.3;
		case "World Literature":
		case "World/Other Literature":
		case "Other Literature":
		case "Misc Literature":
		case "Misc. Literature":
		case "Miscellaneous Lit":
			return 1.4;
		case "Long Fiction":
			return 1.1;
		case "Short Fiction":
		case "Drama":
			return 1.2;
		case "Poetry":
		case "Non-epic Poetry":
			return 1.3;

		case "History":
			return 2;
		case "American History":
		case "US History":
			return 2.1;
		case "European History":
			return 2.2;
		case "British/Commonwealth History":
		case "Commonwealth/Misc History":
		case "World History":
			return 2.3;
		case "Other History":
		case "Misc History":
		case "Ancient History":
		case "Archaeology":
		case "Historiography":
			return 2.4;

		case "Science":
			return 3;
		case "Biology":
			return 3.1;
		case "Chemistry":
			return 3.2;
		case "Physics":
			return 3.3;
		case "Math":
		case "Astronomy":
		case "Computer Science":
		case "Earth Science":
		case "Engineering":
		case "Other Science":
			return 3.4;

		case "Art":
		case "Arts":
		case "Fine Arts":
			return 4;
		case "Painting":
		case "Sculpture":
		case "Painting/Sculpture":
		case "Painting and Sculpture":
			return 4.1;
		case "Music":
		case "Classical Music":
		case "Classical Music/Opera":
		case "Classical Music and Opera":
			return 4.2;
		case "Opera":
		case "Other Art":
		case "Other Arts":
		case "Other Fine Arts":
		case "Architecture":
		case "Photography":
		case "Film":
		case "Performance":
		case "Performing":
		case "Design":
		case "Fashion":
		case "Dance":
		case "Ballet":
		case "Ballet/Dance":
		case "Jazz":
		case "Theater":
		case "World Music":
		case "Visual Fine Arts":
		case "Auditory Fine Arts":
			return 4.3;

		case "Religion":
			return 5.1;
		case "Mythology":
			return 5.2;

		case "Philosophy":
			return 6;

		case "Social Science":
		case "Economics":
		case "Psychology":
		case "Linguistics":
		case "Political Science":
		case "Sociology":
		case "Anthropology":
		case "Other Social Science":
			return 7;

		case "Other Academic":
		case "Current Events":
		case "General Knowledge":
		case "Modern World":
		case "Geography":
		case "Pop Culture":
		case "Trash":
			return 8;

		default:
			return "?";
	}
}
function fractionToSuperscript(fraction) {
	switch(fraction) {
		case "1": return "₁";
		case "2": return "₂";
		case "3": return "₃";
		case "4": return "₄";
		default:  return "";
	}
}
function color(integer) {
	r = integer;
	if (integer == 1 || integer == 4 || integer == 5)
		r = r ";97";
	return r "m";
}
function abs(v) {
	return v < 0 ? -v : v;
}
function min(a, b) {
	if (a < b) return a;
	return b;
}

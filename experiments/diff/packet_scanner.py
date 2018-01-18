# -*- coding: utf-8 -*-

from itertools import islice

# TODO rename
META = {
    'filename_template': '/Users/ophir/Documents/quizbowl/oligodendrocytes/bundled-packets/terrapin%s-packets/html/%02d.f.html',
    'tossup': {
        'line_startswith_template':  '<p class="p1 tu">%d. ',
        'get_next_n_lines': 0, # ANSWER + <Tag>
    },
    'bonus': {
        'line_startswith_template':  '<p class="p1">%d. ',
        'get_next_n_lines': 7, # (Part, ANSWER) × 3 + <Tag>
    },
}


def get_question_html(bundle_str, packet_number, question_type, question_number):
    # TODO Hardcoded
    packet_filename = META['filename_template'] % (bundle_str, packet_number)
    return scan_packet(packet_filename, question_type, question_number)

def scan_packet(packet_filename, question_type, question_number):
    with open(packet_filename, 'r') as packet_file:
        for line in packet_file:
            if line.startswith(META[question_type]['line_startswith_template'] % question_number):
                return line + '\n'.join(islice(packet_file, META[question_type]['get_next_n_lines']))
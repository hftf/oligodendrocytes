#!/usr/bin/perl

# http://mashimonator.weblike.jp/storage/library/20090118_001/demo/ruby2/index.html
# http://mashimonator.weblike.jp/library/2009/01/javascript-rubyjs.html

use strict;
use warnings;

use Path::Tiny qw(path);

my $filename_in = $ARGV[0];
(my $filename_out = $filename_in) =~ s/\.f\./\.r\./g;

my $file_in = path($filename_in);
my $file_out = path($filename_out);

my $contents = $file_in->slurp_utf8;

my $regex = qr{(?(DEFINE)
(?<EXTRA_TAGS>        (?><\/?b>)                )
(?<P_S_TAG>           (?><span\ class=\"s\d\">) )
(?<P_E_TAG>           (?><\/span>)              )
(?<P_S_BRACKET>       [\(\[]                    )
(?<P_E_BRACKET>       [\)\]]                    )
(?<S_QUOTE>           (?:\"|“)?                 )
(?<E_QUOTE>           (?:\"|”)?                 )
(?<LETTER>            [^\]\)\h\v]               )
(?<SPACE>             \h+                       )
(?<WORD>              (?:(?&LETTER)+)           )
)

(?<a>
  (?! (?&SPACE) )
  (?:
    (?: | (?&SPACE) )
    (?&WORD)

    (?=
      (?:    (?&SPACE) (?&WORD) )*

      (?<m>
        # (?&EXTRA_TAGS)?
        (?<ss>(?&SPACE))
        (?&P_S_TAG)
        (?&EXTRA_TAGS)?
        (?<sb>(?&P_S_BRACKET)(?&S_QUOTE))
      )

      (?<b>  \k<b>?+ 
        (?&WORD)
        (?: (?&SPACE) | (?=

          (?<e>
            (?<eb>(?&E_QUOTE)(?&P_E_BRACKET))
            (?&EXTRA_TAGS)?
            (?|
              (?&P_E_TAG)
              (?<es>(?&SPACE)?)
            |
              (?<es>(?&SPACE)?)
              (?&P_E_TAG)
            )
            (?&EXTRA_TAGS)?
          )
        ) )
      )
    )
  )+
)
\k<m>
\k<b>
\k<e>}x;
#my $replacement = ;

my $data2 = 'test aaa     <span class="s1"><b>[bbb]</b></span>      test
test aaa</b> <span class="s1"><b>[bbb]</b></span>   <b>test
test aaa</i> <span class="s1"><b>[bbb]</b></span>   <i>test

test aaa aaa <span class="s1"><b>[bbb bbb]</b></span>  test

<p>
<b>One morning, when <i>Gregor Samsa</i></b>  <span class="s1"><b>[SAM-sa]</b></span> <b>woke from troubled dreams,
<b>One morning, when <i>Gregor Samsa</i></b> <span class="s1"><b>[GREG-or SAM-sa]</b></span> <b>woke from troubled dreams,
</p>
';

$contents =~ s($regex)(<ruby><rb>$+{a}</rb><rp>$+{ss}$+{sb}</rp><rt>$+{b}</rt><rp>$+{eb}</rp></ruby>$+{es})g;
$contents =~ s(</b></rb>)(</rb>)g;
print $contents;

$file_out->spew_utf8( $contents );

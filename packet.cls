% packet.cls
%  Typesets quizbowl packets
%
% 2013-03-22
% Ophir Lifshitz
% quizbowl@ophir.li

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{packet}[2013/03/22 Typesets quizbowl packets]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions \relax
\LoadClass{article}

% LAYOUT
\RequirePackage{hyperref}
\RequirePackage{xcolor}

%\RequirePackage{showframe}
%\renewcommand\ShowFrameLinethickness{0.3pt}
%\renewcommand\ShowFrameColor{\color{gray!60}}

% PRONUNCIATION GUIDES
\newcommand{\prongray}[1]{{\color{gray!75}{#1}}}

%% transform uppercase to small caps
%% https://tex.stackexchange.com/questions/39831/uppercase-smallcaps-with-latex-not-xelatex
\makeatletter
\newif\ifsc@active
\newif\ifnf@active
\def\upsc#1{{\sc@activefalse\nf@activetrue\@upsc#1\@nil}}
\def\@upsc#1{\ifx#1\@nil\else\@@upsc{#1}\expandafter\@upsc\fi}
\def\@@upsc#1{%
  \ifnum\uccode`#1=`#1\relax
     \ifsc@active\else\sc@activetrue\nf@activefalse\scshape\fi
     \expandafter\@firstoftwo
   \else
     \ifsc@active\sc@activefalse\fi
     \ifnf@active\else\nf@activetrue\normalfont\fi
     \expandafter\@secondoftwo
   \fi
     {\lowercase{#1}}%
     {#1}}
\makeatother

%% margin note
\newcommand{\marginfont}{\footnotesize}
\newcommand{\pronsymbol}{\prongray{°}}
\newcommand{\pronnote}[1]{\marginpar{\marginfont{#1}}\pronsymbol}
\newcommand{\pronmargin}[2]{\pronnote{#2}#1}
\newcommand{\pronmargingeom}{left=0.75in,right=1.5in,marginparsep=0.2in,marginparwidth=0.8in}

%% parentheses
\newcommand{\prontheses}[2]{#1 \prongray{[#2]}}
\newcommand{\pronthesesgeom}{hmargin=0.75in}

%% ruby
\RequirePackage[latin]{ruby}
\renewcommand{\rubysize}{0.75}
\renewcommand{\rubysep}{-0.75ex}
\newcommand{\pronruby}[2]{\ruby{#1}{\prongray{\normalfont{#2}}}}
\newcommand{\pronrubygeom}{hmargin=0.75in}

%% set pronunciation guide style
\let\pronstyle\prontheses
\newcommand{\pron}[2]{\pronstyle{#1}{\upsc{#2}}}
\let\geom\pronthesesgeom

\RequirePackage[\geom,vmargin=0.75in]{geometry}

% TYPOGRAPHY
\RequirePackage[normalem]{ulem}
\RequirePackage{newunicodechar}
\newunicodechar{ }{~}
\newunicodechar{ɶ}{\textsc{œ}}

\RequirePackage[log-declarations=false]{xparse}
\RequirePackage{realscripts}
\RequirePackage{fontspec}
\defaultfontfeatures{Mapping=tex-text}
\newcommand{\myfont}{Lyon Text}
\setmainfont[BoldFont={* Semibold},Numbers={Lining},Ligatures={Common}]{\myfont}
\newcommand{\mymonofont}{TheSansMono}
\setmonofont{\mymonofont}

\newcommand{\powersym}{(*)}% *⁕⁎⋆

\iffontchar\font`☞
\newcommand{\manicule}{☞}
\else
% \RequirePackage{bbding}
% \newcommand{\manicule}{\HandRight}
\newcommand{\manicule}{{\fontsize{14pt}{14pt}\fontspec{Brill}☞}}
\fi

% SEMANTICS
\newenvironment{tossups}{\subsection*{Tossups}\setcounter{question}0}{}
\newenvironment{bonuses}{\subsection*{Bonuses}\setcounter{question}0}{}

\newcounter{question}
\def\claim#1{\par\noindent\hspace{-10mm}\makebox[10mm][r]{#1\enskip}\ignorespaces}
\def\endclaim{\par\medskip}
\newenvironment{lb}{\claim}{\endclaim}
\newenvironment{question}{\begin{lb}{\refstepcounter{question}\arabic{question}.\hyperdef{tossup}{\arabic{question}}{}}}{\end{lb}}

\newcommand{\power}[1]{{\textbf{#1}}}
\newcommand{\req}[1]{{\textbf{\uline{#1}}}}
\newcommand{\answer}[1]{{\textsc{answer}: #1}}
\newcommand{\partvalue}[1]{{[#1]}}
\newcommand{\w}[2]{\tooltip{#1}{#2}\kernright{#1}}

% TOOLTIP
% Source: http://tex.stackexchange.com/questions/31078/kerning-between-bold-and-non-bold-text
% TODO: kernleft (this will restore the kerning between “ and A, T, or similar letters the most)
\newcommand\kernright[1]{\renewcommand{\marginpar}[1]{}\def\hltext{#1}\futurelet\hlnext\hldokern}
\def\hldokern{\sbox0{\mbox\hltext\mbox\hlnext}\sbox2{\hltext\hlnext}\kern\dimexpr\wd2-\wd0\relax}
\newcommand\tooltip[2]{%
\special{pdf:bann
  <<
  /Type /Annot
  /Subtype /Widget
  /FT /Btn
  /Ff 65536
  /H /N
  /TU (#2)
  >>
}%
#1%
\special{pdf:eann}%
}

% STRINGS
\newcommand{\tournamentname}{}
\newcommand{\tournamentyear}{}
\newcommand{\subtitle}{}
\newcommand{\packetname}{}
\newcommand{\authors}{}

\newcommand{\packet}{Packet}

\newif\iffirstpacket\firstpacketfalse
\newif\ifnolastpacket\nolastpacketfalse
\newcommand{\lastpacketname}{}
\newcommand{\lastpacketone}{}
\newcommand{\lastpackettwenty}{}

% LEADING, WIDOWS
\linespread{1.3}
\widowpenalties 1 10000
\raggedbottom

% HEADER
\renewcommand{\maketitle}{\noindent
\tournamentname{} \tournamentyear{}: \subtitle{}\\
\textbf{%{\packet{}} {\packetnumber{}} --- {
\packetname}\\
\authors{}

\medskip
\begin{lb}{\manicule}
Please verify that the last packet was \textit{\lastpacketname}%
\iffirstpacket\else
\ifnolastpacket\else, which began with a tossup on \lastpacketone{} and ended with one on \lastpackettwenty{}%
\fi\fi.
\end{lb}
}

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
\newcommand{\marginfont}{\footnotesize}
\newcommand{\pronsymbol}{°}
\newcommand{\pronnote}[1]{\marginpar{\marginfont{#1}}\pronsymbol}
\newcommand{\pronmargin}[2]{\pronnote{#2}#1}
\newcommand{\pronmargingeom}{left=0.75in,right=1.5in,marginparsep=0.2in,marginparwidth=0.8in}

\newcommand{\prongray}[1]{{\color{gray!60}{#1}}}
\newcommand{\prontheses}[2]{#1 \prongray{[#2]}}
\newcommand{\pronthesesgeom}{hmargin=0.75in}

\let\pron\prontheses
\let\geom\pronthesesgeom

\RequirePackage[\geom,vmargin=0.75in]{geometry}

% TYPOGRAPHY
\RequirePackage[normalem]{ulem}
\RequirePackage{newunicodechar}
\newunicodechar{ }{~}

\RequirePackage[log-declarations=false]{xparse}
\RequirePackage{realscripts}
\RequirePackage{fontspec}
\defaultfontfeatures{Mapping=tex-text}
\newcommand{\myfont}{Lyon Text}
\setmainfont[BoldFont={* Semibold},Numbers={Lining},Ligatures={Common}]{\myfont}

\newcommand{\powersym}{(*)}% *⁕⁎⋆

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
\linespread{1.15}
\widowpenalties 1 10000
\raggedbottom

% HEADER
\renewcommand{\maketitle}{\noindent
\tournamentname{} \tournamentyear{}: \subtitle{}\\
\textbf{%{\packet{}} {\packetnumber{}} --- {
\packetname}\\
\authors{}

\medskip
\begin{lb}{☞}
Please verify that the last packet was \textit{\lastpacketname}%
\iffirstpacket\else
\ifnolastpacket\else, which began with a tossup on \lastpacketone{} and ended with one on \lastpackettwenty{}%
\fi\fi.
\end{lb}
}
